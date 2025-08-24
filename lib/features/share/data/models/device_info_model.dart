class DeviceInfo {
  final String id;
  final String name;
  final String ipAddress;
  final int port;
  final String platform;
  final DateTime lastSeen;

  DeviceInfo({
    required this.id,
    required this.name,
    required this.ipAddress,
    required this.port,
    required this.platform,
    required this.lastSeen,
  });

  factory DeviceInfo.fromJson(Map<String, dynamic> json) {
    return DeviceInfo(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown Device',
      ipAddress: json['ipAddress'] ?? '',
      port: json['port'] ?? 8888,
      platform: json['platform'] ?? 'unknown',
      lastSeen: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ipAddress': ipAddress,
      'port': port,
      'platform': platform,
    };
  }
}
