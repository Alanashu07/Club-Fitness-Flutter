class ImageSaveResult {
  final String url;
  final String filePath;
  final int timestamp;
  final bool success;
  final String? error;

  ImageSaveResult({
    required this.url,
    required this.filePath,
    required this.timestamp,
    this.success = true,
    this.error,
  });
}
