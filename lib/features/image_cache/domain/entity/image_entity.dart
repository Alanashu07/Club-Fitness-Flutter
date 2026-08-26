import 'package:equatable/equatable.dart';

class ImageEntity extends Equatable {
  final String url;
  final num? id;
  final String filePath;
  final num timeStamp;

  const ImageEntity({
    required this.url,
    this.id,
    required this.filePath,
    required this.timeStamp,
  });
  @override
  List<Object?> get props => [url, id, filePath, timeStamp];
}
