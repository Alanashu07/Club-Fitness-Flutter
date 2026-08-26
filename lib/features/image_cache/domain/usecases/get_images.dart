import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/core/usecases/usecase.dart';
import '../repository/cache_image_repository.dart';
import '../entity/image_entity.dart';

class GetImages implements UseCase<List<ImageEntity>, void> {
  final CacheImageRepository repo;

  const GetImages(this.repo);

  @override
  Future<Either<List<ImageEntity>, Failure>> call(void params) async {
    return await repo.getImages();
  }
}
