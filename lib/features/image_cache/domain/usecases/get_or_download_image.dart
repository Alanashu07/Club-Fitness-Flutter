

import 'package:dartz/dartz.dart';

import '../../../../core/exceptions/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entity/image_entity.dart';
import '../repository/cache_image_repository.dart';

class GetOrDownloadImage implements UseCase<ImageEntity, String?> {
  final CacheImageRepository repo;

  const GetOrDownloadImage(this.repo);
  @override
  Future<Either<ImageEntity, Failure>> call(String? params) async {
    return await repo.getImage(params);
  }
}
