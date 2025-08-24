part of 'share_cubit.dart';

class ShareState extends Equatable {
  final List<DeviceInfo> discoveredDevices;
  final DeviceInfo? myDevice;
  final List<FileInfo> selectedFiles;
  final TransferStatus currentStatus;
  final String statusMessage;
  final double transferProgress;
  final bool isReceiving;
  final TransferSession? activeSession;
  final int selectedTabIndex;

  const ShareState({
    this.discoveredDevices = const [],
    this.myDevice,
    this.selectedFiles = const [],
    this.currentStatus = TransferStatus.idle,
    this.statusMessage = 'Ready to share files',
    this.transferProgress = 0.0,
    this.isReceiving = false,
    this.activeSession,
    this.selectedTabIndex = 0,
  });

  ShareState copyWith({
    List<DeviceInfo>? discoveredDevices,
    DeviceInfo? myDevice,
    List<FileInfo>? selectedFiles,
    TransferStatus? currentStatus,
    String? statusMessage,
    double? transferProgress,
    bool? isReceiving,
    TransferSession? activeSession,
    int? selectedTabIndex,
  }) {
    return ShareState(
      discoveredDevices: discoveredDevices ?? this.discoveredDevices,
      myDevice: myDevice ?? this.myDevice,
      selectedFiles: selectedFiles ?? this.selectedFiles,
      currentStatus: currentStatus ?? this.currentStatus,
      statusMessage: statusMessage ?? this.statusMessage,
      transferProgress: transferProgress ?? this.transferProgress,
      isReceiving: isReceiving ?? this.isReceiving,
      activeSession: activeSession ?? this.activeSession,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
    );
  }

  @override
  List<Object?> get props => [
    discoveredDevices,
    myDevice,
    selectedFiles,
    currentStatus,
    statusMessage,
    transferProgress,
    isReceiving,
    activeSession,
    selectedTabIndex,
  ];
}
