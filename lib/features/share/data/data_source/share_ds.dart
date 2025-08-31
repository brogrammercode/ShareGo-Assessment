// ignore_for_file: deprecated_member_use, constant_identifier_names, unnecessary_nullable_for_final_variable_declarations, unnecessary_import

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:shareit/main.dart';
import 'package:uuid/uuid.dart';

import '../models/device_info_model.dart';
import '../models/file_info_model.dart';
import '../models/transfer_session_model.dart';

class ShareDataSource {
  static const int DISCOVERY_PORT = 8889;
  static const int TRANSFER_PORT = 8888;
  static const Duration DISCOVERY_INTERVAL = Duration(seconds: 3);
  static const Duration DISCOVERY_TIMEOUT = Duration(seconds: 30);

  RawDatagramSocket? _discoverySocket;
  ServerSocket? _transferServer;
  Timer? _discoveryTimer;
  Timer? _broadcastTimer;

  final ImagePicker _imagePicker = ImagePicker();
  // ignore: unused_field
  final Connectivity _connectivity = Connectivity();
  final NetworkInfo _networkInfo = NetworkInfo();
  final Uuid _uuid = const Uuid();

  late DeviceInfo _myDevice;

  final StreamController<List<DeviceInfo>> _devicesController =
      StreamController<List<DeviceInfo>>.broadcast();
  final StreamController<TransferStatus> _statusController =
      StreamController<TransferStatus>.broadcast();
  final StreamController<String> _messageController =
      StreamController<String>.broadcast();
  final StreamController<double> _progressController =
      StreamController<double>.broadcast();
  final StreamController<bool> _receivingController =
      StreamController<bool>.broadcast();

  Stream<List<DeviceInfo>> get devicesStream => _devicesController.stream;
  Stream<TransferStatus> get statusStream => _statusController.stream;
  Stream<String> get messageStream => _messageController.stream;
  Stream<double> get progressStream => _progressController.stream;
  Stream<bool> get receivingStream => _receivingController.stream;

  final List<DeviceInfo> _discoveredDevices = [];

  DeviceInfo get myDevice => _myDevice;

  Future<void> initialize() async {
    _statusController.add(TransferStatus.connecting);
    _messageController.add('Initializing...');

    try {
      await _requestPermissions();
      await _initializeDeviceInfo();
      await _startDiscoveryServer();
      await _startTransferServer();

      _statusController.add(TransferStatus.idle);
      _messageController.add('Ready to share files');
    } catch (e) {
      _statusController.add(TransferStatus.failed);
      _messageController.add('Initialization failed: $e');
      rethrow;
    }
  }

  Future<void> _requestPermissions() async {
    final permissions = [
      Permission.storage,
      Permission.manageExternalStorage,
      Permission.location,
      Permission.camera,
      Permission.photos,
    ];

    for (final permission in permissions) {
      final status = await permission.request();
      if (!status.isGranted) {
        dev.log('Permission ${permission.toString()} denied');
      }
    }
  }

  Future<void> _initializeDeviceInfo() async {
    final deviceName = Platform.localHostname.isNotEmpty
        ? Platform.localHostname
        : 'Flutter Device ${Random().nextInt(1000)}';

    String? wifiIP;
    try {
      wifiIP = await _networkInfo.getWifiIP();
    } catch (e) {
      dev.log('Could not get WiFi IP: $e');
    }

    _myDevice = DeviceInfo(
      id: _uuid.v4(),
      name: deviceName,
      ipAddress: wifiIP ?? '192.168.1.${100 + Random().nextInt(155)}',
      port: TRANSFER_PORT,
      platform: Platform.operatingSystem,
      lastSeen: DateTime.now(),
    );

    dev.log('My Device: ${_myDevice.name} (${_myDevice.ipAddress})');
  }

  Future<void> _startDiscoveryServer() async {
    try {
      _discoverySocket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        DISCOVERY_PORT,
        reuseAddress: true,
      );

      _discoverySocket!.broadcastEnabled = true;

      _discoverySocket!.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          final packet = _discoverySocket!.receive();
          if (packet != null) {
            _handleDiscoveryPacket(packet);
          }
        }
      });

      dev.log('Discovery server started on port $DISCOVERY_PORT');
    } catch (e) {
      dev.log('Failed to start discovery server: $e');
    }
  }

  void _handleDiscoveryPacket(Datagram packet) {
    try {
      final message = String.fromCharCodes(packet.data);
      final data = jsonDecode(message);

      if (data['type'] == 'DEVICE_BROADCAST' &&
          data['deviceId'] != _myDevice.id) {
        var device = DeviceInfo.fromJson(data);
        device = DeviceInfo(
          id: device.id,
          name: device.name,
          ipAddress: packet.address.address,
          port: device.port,
          platform: device.platform,
          lastSeen: DateTime.now(),
        );

        _addOrUpdateDevice(device);
      }
    } catch (e) {
      dev.log('Error parsing discovery packet: $e');
    }
  }

  void _addOrUpdateDevice(DeviceInfo device) {
    final existingIndex = _discoveredDevices.indexWhere(
      (d) => d.id == device.id,
    );
    if (existingIndex != -1) {
      _discoveredDevices[existingIndex] = device;
    } else {
      _discoveredDevices.add(device);
    }
    _devicesController.add(List.from(_discoveredDevices));
  }

  Future<void> startDeviceDiscovery() async {
    _statusController.add(TransferStatus.discovering);
    _messageController.add('Discovering nearby devices...');
    _discoveredDevices.clear();
    _devicesController.add(List.from(_discoveredDevices));

    _broadcastTimer = Timer.periodic(DISCOVERY_INTERVAL, (timer) {
      _broadcastPresence();
    });

    Timer(DISCOVERY_TIMEOUT, () {
      stopDeviceDiscovery();
    });
  }

  void _broadcastPresence() {
    if (_discoverySocket != null) {
      final message = jsonEncode({
        'type': 'DEVICE_BROADCAST',
        'deviceId': _myDevice.id,
        'name': _myDevice.name,
        'port': _myDevice.port,
        'platform': _myDevice.platform,
      });

      final bytes = utf8.encode(message);
      _discoverySocket!.send(
        bytes,
        InternetAddress("255.255.255.255"),
        DISCOVERY_PORT,
      );
    }
  }

  void stopDeviceDiscovery() {
    _broadcastTimer?.cancel();
    _statusController.add(TransferStatus.idle);
    _messageController.add('Found ${_discoveredDevices.length} devices');
  }

  void clearDiscoveredDevices() {
    _discoveredDevices.clear();
    _devicesController.add(List.from(_discoveredDevices));
  }

  Future<void> _startTransferServer() async {
    try {
      _transferServer = await ServerSocket.bind(
        InternetAddress.anyIPv4,
        TRANSFER_PORT,
      );

      _transferServer!.listen((Socket client) {
        _handleIncomingTransfer(client);
      });

      dev.log('Transfer server started on port $TRANSFER_PORT');
    } catch (e) {
      dev.log('Failed to start transfer server: $e');
    }
  }

  Future<bool> _showSimplePermissionDialog() async {
    final context = navigatorKey.currentContext;
    return await showDialog<bool>(
          context: context!,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.file_download, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(
                    'Incoming File Transfer',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: Text(
                'A device wants to send you files. Do you want to accept this transfer?',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
              ),
              actions: [
                TextButton.icon(
                  onPressed: () => Navigator.of(context).pop(false),
                  label: Text(
                    'Deny',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => Navigator.of(context).pop(true),
                  label: Text(
                    'Accept',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<void> _handleIncomingTransfer(Socket client) async {
    _receivingController.add(true);
    _statusController.add(TransferStatus.transferring);
    _messageController.add('Receiving files...');

    final bool userAccepted = await _showSimplePermissionDialog();

    if (!userAccepted) {
      _statusController.add(TransferStatus.cancelled);
      _messageController.add('Transfer request denied');
      client.close();
      _receivingController.add(false);
      return;
    }

    try {
      final buffer = <int>[];

      await for (final data in client) {
        buffer.addAll(data);

        while (buffer.length >= 4) {
          final messageLength = _bytesToInt32(buffer.sublist(0, 4));

          if (buffer.length >= 4 + messageLength) {
            final messageBytes = buffer.sublist(4, 4 + messageLength);
            final message = utf8.decode(messageBytes);

            buffer.removeRange(0, 4 + messageLength);

            await _processTransferMessage(message, client);
          } else {
            break;
          }
        }
      }
    } catch (e) {
      dev.log('Error in file transfer: $e');
      _statusController.add(TransferStatus.failed);
      _messageController.add('Transfer failed: $e');
    } finally {
      client.close();
      _receivingController.add(false);
    }
  }

  Future<void> _processTransferMessage(String message, Socket client) async {
    try {
      final data = jsonDecode(message);

      if (data['type'] == 'FILE_HEADER') {
        dev.log(
          'Receiving file: ${data['fileName']} (${data['fileSize']} bytes)',
        );

        final ack = jsonEncode({'type': 'ACK', 'status': 'ready'});
        final ackBytes = utf8.encode(ack);
        client.add(_int32ToBytes(ackBytes.length));
        client.add(ackBytes);
      } else if (data['type'] == 'FILE_DATA') {
        final fileName = data['fileName'];
        final fileBytes = base64Decode(data['data']);

        await _saveReceivedFile(fileName, fileBytes);

        final ack = jsonEncode({'type': 'ACK', 'status': 'completed'});
        final ackBytes = utf8.encode(ack);
        client.add(_int32ToBytes(ackBytes.length));
        client.add(ackBytes);

        _statusController.add(TransferStatus.completed);
        _messageController.add('Received $fileName successfully');
      }
    } catch (e) {
      dev.log('Error processing transfer message: $e');
    }
  }

  Future<void> _saveReceivedFile(String fileName, Uint8List fileBytes) async {
    try {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        dev.log("Storage permission not granted");
        return;
      }

      const platform = MethodChannel("com.example.shareit/downloads");
      final downloadsPath = await platform.invokeMethod<String>(
        "getDownloadsDirectory",
      );

      if (downloadsPath == null) {
        dev.log("Could not access Downloads directory");
        return;
      }

      File file = File("$downloadsPath/$fileName");
      int counter = 1;
      while (await file.exists()) {
        final name = fileName.split('.').first;
        final ext = fileName.contains('.')
            ? ".${fileName.split('.').last}"
            : "";
        file = File("$downloadsPath/${name}_$counter$ext");
        counter++;
      }

      await file.writeAsBytes(fileBytes, flush: true);

      dev.log("File saved to Downloads: ${file.path}");
    } catch (e) {
      dev.log("Error saving file: $e");
    }
  }

  Future<void> sendFilesToDevice(
    DeviceInfo device,
    List<FileInfo> files,
  ) async {
    if (files.isEmpty) return;

    _statusController.add(TransferStatus.connecting);
    _messageController.add('Connecting to ${device.name}...');

    try {
      final socket = await Socket.connect(device.ipAddress, device.port);

      _statusController.add(TransferStatus.transferring);
      _messageController.add('Sending files to ${device.name}...');

      for (int i = 0; i < files.length; i++) {
        final file = files[i];
        await _sendSingleFile(socket, file);

        _progressController.add((i + 1) / files.length);
      }

      socket.close();

      _statusController.add(TransferStatus.completed);
      _messageController.add('Successfully sent ${files.length} files');
      _progressController.add(1.0);
    } catch (e) {
      _statusController.add(TransferStatus.failed);
      _messageController.add('Failed to send files: $e');
    }
  }

  Future<void> _sendSingleFile(Socket socket, FileInfo fileInfo) async {
    try {
      final file = File(fileInfo.path);
      final fileBytes = await file.readAsBytes();

      final header = jsonEncode({
        'type': 'FILE_HEADER',
        'fileName': fileInfo.name,
        'fileSize': fileInfo.size,
        'fileType': fileInfo.type,
      });

      final headerBytes = utf8.encode(header);
      socket.add(_int32ToBytes(headerBytes.length));
      socket.add(headerBytes);

      await socket.flush();
      await Future.delayed(const Duration(milliseconds: 100));

      final fileData = jsonEncode({
        'type': 'FILE_DATA',
        'fileName': fileInfo.name,
        'data': base64Encode(fileBytes),
      });

      final fileDataBytes = utf8.encode(fileData);
      socket.add(_int32ToBytes(fileDataBytes.length));
      socket.add(fileDataBytes);

      await socket.flush();
    } catch (e) {
      dev.log('Error sending file ${fileInfo.name}: $e');
      rethrow;
    }
  }

  Future<List<FileInfo>> selectImages() async {
    try {
      final List<XFile>? images = await _imagePicker.pickMultiImage();
      final List<FileInfo> fileInfos = [];

      if (images != null) {
        for (final image in images) {
          final file = File(image.path);
          final stat = await file.stat();

          final fileInfo = FileInfo(
            id: _uuid.v4(),
            name: image.name,
            path: image.path,
            size: stat.size,
            type: image.path.split('.').last.toLowerCase(),
          );

          fileInfos.add(fileInfo);
        }
      }
      return fileInfos;
    } catch (e) {
      dev.log('Error selecting images: $e');
      return [];
    }
  }

  Future<List<FileInfo>> selectVideos() async {
    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
      );

      if (video != null) {
        final file = File(video.path);
        final stat = await file.stat();

        final fileInfo = FileInfo(
          id: _uuid.v4(),
          name: video.name,
          path: video.path,
          size: stat.size,
          type: video.path.split('.').last.toLowerCase(),
        );

        return [fileInfo];
      }
      return [];
    } catch (e) {
      dev.log('Error selecting video: $e');
      return [];
    }
  }

  Future<List<FileInfo>> selectFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );

      final List<FileInfo> fileInfos = [];

      if (result != null) {
        for (final platformFile in result.files) {
          if (platformFile.path != null) {
            final fileInfo = FileInfo(
              id: _uuid.v4(),
              name: platformFile.name,
              path: platformFile.path!,
              size: platformFile.size,
              type: platformFile.extension ?? 'unknown',
            );

            fileInfos.add(fileInfo);
          }
        }
      }
      return fileInfos;
    } catch (e) {
      dev.log('Error selecting files: $e');
      return [];
    }
  }

  List<int> _int32ToBytes(int value) {
    return [
      (value >> 24) & 0xFF,
      (value >> 16) & 0xFF,
      (value >> 8) & 0xFF,
      value & 0xFF,
    ];
  }

  int _bytesToInt32(List<int> bytes) {
    return (bytes[0] << 24) | (bytes[1] << 16) | (bytes[2] << 8) | bytes[3];
  }

  void dispose() {
    _discoverySocket?.close();
    _transferServer?.close();
    _discoveryTimer?.cancel();
    _broadcastTimer?.cancel();

    _devicesController.close();
    _statusController.close();
    _messageController.close();
    _progressController.close();
    _receivingController.close();
  }
}
