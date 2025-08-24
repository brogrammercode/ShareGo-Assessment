import 'device_info_model.dart';
import 'file_info_model.dart';

enum TransferStatus {
  idle,
  discovering,
  connecting,
  transferring,
  completed,
  failed,
  cancelled,
}

class TransferSession {
  final String id;
  final DeviceInfo targetDevice;
  final List<FileInfo> files;
  final TransferStatus status;
  final double progress;
  final String? errorMessage;

  TransferSession({
    required this.id,
    required this.targetDevice,
    required this.files,
    required this.status,
    this.progress = 0.0,
    this.errorMessage,
  });

  TransferSession copyWith({
    String? id,
    DeviceInfo? targetDevice,
    List<FileInfo>? files,
    TransferStatus? status,
    double? progress,
    String? errorMessage,
  }) {
    return TransferSession(
      id: id ?? this.id,
      targetDevice: targetDevice ?? this.targetDevice,
      files: files ?? this.files,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
