class FileInfo {
  final String id;
  final String name;
  final String path;
  final int size;
  final String type;

  FileInfo({
    required this.id,
    required this.name,
    required this.path,
    required this.size,
    required this.type,
  });

  String get formattedSize {
    if (size < 1024) return '${size}B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)}KB';
    if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  bool get isImage =>
      ['jpg', 'jpeg', 'png', 'gif', 'bmp'].contains(type.toLowerCase());
  bool get isVideo =>
      ['mp4', 'avi', 'mov', 'wmv', 'flv'].contains(type.toLowerCase());
}
