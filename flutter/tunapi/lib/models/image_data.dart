class ImageData {
  final String url;
  final DateTime timestamp;
  final String className;

  ImageData(
      {required this.url, required this.timestamp, required this.className});

  factory ImageData.fromJson(Map<String, dynamic> json) {
    return ImageData(
        url: json['url'] as String,
        timestamp: DateTime.parse(json['timestamp']),
        className: json['class_name'] as String
        );
  }
}
