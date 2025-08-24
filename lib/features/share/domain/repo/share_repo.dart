import '../../data/data_source/share_ds.dart';
import '../../data/models/device_info_model.dart';
import '../../data/models/file_info_model.dart';
import '../../data/models/transfer_session_model.dart';

abstract class ShareRepository {
  // init
  Future<void> initialize();

  // discovery
  Stream<List<DeviceInfo>> get devicesStream;
  Future<void> startDeviceDiscovery();
  void stopDeviceDiscovery();
  void clearDiscoveredDevices();
  DeviceInfo get myDevice;

  // transfer
  Stream<TransferStatus> get statusStream;
  Stream<String> get messageStream;
  Stream<double> get progressStream;
  Stream<bool> get receivingStream;
  Future<void> sendFilesToDevice(DeviceInfo device, List<FileInfo> files);

  // selection
  Future<List<FileInfo>> selectImages();
  Future<List<FileInfo>> selectVideos();
  Future<List<FileInfo>> selectFiles();

  // cleann
  void dispose();
}

class ShareRepositoryImpl implements ShareRepository {
  final ShareDataSource _dataSource;

  ShareRepositoryImpl(this._dataSource);

  @override
  Future<void> initialize() => _dataSource.initialize();

  @override
  Stream<List<DeviceInfo>> get devicesStream => _dataSource.devicesStream;

  @override
  Future<void> startDeviceDiscovery() => _dataSource.startDeviceDiscovery();

  @override
  void stopDeviceDiscovery() => _dataSource.stopDeviceDiscovery();

  @override
  void clearDiscoveredDevices() => _dataSource.clearDiscoveredDevices();

  @override
  DeviceInfo get myDevice => _dataSource.myDevice;

  @override
  Stream<TransferStatus> get statusStream => _dataSource.statusStream;

  @override
  Stream<String> get messageStream => _dataSource.messageStream;

  @override
  Stream<double> get progressStream => _dataSource.progressStream;

  @override
  Stream<bool> get receivingStream => _dataSource.receivingStream;

  @override
  Future<void> sendFilesToDevice(DeviceInfo device, List<FileInfo> files) =>
      _dataSource.sendFilesToDevice(device, files);

  @override
  Future<List<FileInfo>> selectImages() => _dataSource.selectImages();

  @override
  Future<List<FileInfo>> selectVideos() => _dataSource.selectVideos();

  @override
  Future<List<FileInfo>> selectFiles() => _dataSource.selectFiles();

  @override
  void dispose() => _dataSource.dispose();
}
