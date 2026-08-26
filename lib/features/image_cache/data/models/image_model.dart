import 'package:club_fitness/features/image_cache/domain/entity/image_entity.dart';

class ImageModel extends ImageEntity {
  const ImageModel({
    required super.url,
    super.id,
    required super.filePath,
    required super.timeStamp,
  });

  factory ImageModel.fromJson(Map<String, dynamic> json) => ImageModel(
    timeStamp: json['time_stamp'],
    filePath: json['file_path'],
    url: json['url'],
    id: json['id'],
  );

  factory ImageModel.fromEntity(ImageEntity entity) => ImageModel(
    timeStamp: entity.timeStamp,
    filePath: entity.filePath,
    url: entity.url,
    id: entity.id,
  );

  Map<String, dynamic> toJson() => {
    'time_stamp': timeStamp,
    'file_path': filePath,
    'url': url,
    'id': id,
  };

  ImageModel copyWith({
    String? url,
    num? id,
    String? filePath,
    int? timeStamp,
  }) => ImageModel(
    timeStamp: timeStamp ?? this.timeStamp,
    filePath: filePath ?? this.filePath,
    url: url ?? this.url,
    id: id ?? this.id,
  );
}
