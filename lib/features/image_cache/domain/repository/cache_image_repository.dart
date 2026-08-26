import 'package:dartz/dartz.dart';

import '../../../../core/exceptions/failure.dart';
import '../entity/image_entity.dart';

abstract interface class CacheImageRepository {
  Future<Either<ImageEntity, Failure>> getImage(String? url);

  Future<Either<List<ImageEntity>, Failure>> getImages();

  Future<Either<ImageEntity, Failure>> saveImage(String url);

  Future<Either<int, Failure>> updateImage(ImageEntity imageModel);

  Future<Either<int, Failure>> deleteImage(String? url);

  Future<Either<int, Failure>> deleteAllImages();

  Future<Either<int, Failure>> clearAllCache();

  Future<Either<int, Failure>> clearOldCache();
}
