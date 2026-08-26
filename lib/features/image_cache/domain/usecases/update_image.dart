import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/core/usecases/usecase.dart';
import '../repository/cache_image_repository.dart';
import '../entity/image_entity.dart';

class UpdateImage implements UseCase<int, ImageEntity> {
  final CacheImageRepository repo;

  const UpdateImage(this.repo);

  @override
  Future<Either<int, Failure>> call(ImageEntity params) async {
    return await repo.updateImage(params);
  }
}
