import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/device_info_model.dart';
import '../../data/models/file_info_model.dart';
import '../../data/models/transfer_session_model.dart';
import '../../domain/repo/share_repo.dart';

part 'share_state.dart';

class ShareCubit extends Cubit<ShareState> {
  final ShareRepository _repository;
  final Uuid _uuid = const Uuid();

  StreamSubscription<List<DeviceInfo>>? _devicesSubscription;
  StreamSubscription<TransferStatus>? _statusSubscription;
  StreamSubscription<String>? _messageSubscription;
  StreamSubscription<double>? _progressSubscription;
  StreamSubscription<bool>? _receivingSubscription;

  ShareCubit(this._repository) : super(const ShareState()) {
    _initializeSubscriptions();
  }

  void _initializeSubscriptions() {
    _devicesSubscription = _repository.devicesStream.listen((devices) {
      emit(state.copyWith(discoveredDevices: devices));
    });

    _statusSubscription = _repository.statusStream.listen((status) {
      emit(state.copyWith(currentStatus: status));
    });

    _messageSubscription = _repository.messageStream.listen((message) {
      emit(state.copyWith(statusMessage: message));
    });

    _progressSubscription = _repository.progressStream.listen((progress) {
      emit(state.copyWith(transferProgress: progress));
    });

    _receivingSubscription = _repository.receivingStream.listen((isReceiving) {
      emit(state.copyWith(isReceiving: isReceiving));
    });
  }

  // init
  Future<void> initialize() async {
    try {
      await _repository.initialize();
      emit(state.copyWith(myDevice: _repository.myDevice));
    } catch (e) {
      emit(
        state.copyWith(
          currentStatus: TransferStatus.failed,
          statusMessage: 'Initialization failed: $e',
        ),
      );
    }
  }

  // discovery
  Future<void> startDeviceDiscovery() async {
    await _repository.startDeviceDiscovery();
  }

  void stopDeviceDiscovery() {
    _repository.stopDeviceDiscovery();
  }

  void clearDiscoveredDevices() {
    _repository.clearDiscoveredDevices();
  }

  // file select
  Future<void> selectImages() async {
    final images = await _repository.selectImages();
    final updatedFiles = List<FileInfo>.from(state.selectedFiles)
      ..addAll(images);
    emit(state.copyWith(selectedFiles: updatedFiles));
  }

  Future<void> selectVideos() async {
    final videos = await _repository.selectVideos();
    final updatedFiles = List<FileInfo>.from(state.selectedFiles)
      ..addAll(videos);
    emit(state.copyWith(selectedFiles: updatedFiles));
  }

  Future<void> selectFiles() async {
    final files = await _repository.selectFiles();
    final updatedFiles = List<FileInfo>.from(state.selectedFiles)
      ..addAll(files);
    emit(state.copyWith(selectedFiles: updatedFiles));
  }

  void removeFile(String fileId) {
    final updatedFiles = state.selectedFiles
        .where((file) => file.id != fileId)
        .toList();
    emit(state.copyWith(selectedFiles: updatedFiles));
  }

  void clearAllFiles() {
    emit(state.copyWith(selectedFiles: []));
  }

  // transfer
  Future<void> sendFilesToDevice(DeviceInfo device) async {
    if (state.selectedFiles.isEmpty) return;

    final session = TransferSession(
      id: _uuid.v4(),
      targetDevice: device,
      files: state.selectedFiles,
      status: TransferStatus.connecting,
    );

    emit(state.copyWith(activeSession: session));

    await _repository.sendFilesToDevice(device, state.selectedFiles);
  }

  // tab
  void setSelectedTabIndex(int index) {
    emit(state.copyWith(selectedTabIndex: index));
  }

  // dispose
  @override
  Future<void> close() {
    _devicesSubscription?.cancel();
    _statusSubscription?.cancel();
    _messageSubscription?.cancel();
    _progressSubscription?.cancel();
    _receivingSubscription?.cancel();
    _repository.dispose();
    return super.close();
  }
}
