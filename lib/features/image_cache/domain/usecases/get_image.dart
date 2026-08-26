import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/core/usecases/usecase.dart';
import '../entity/image_entity.dart';
import '../repository/cache_image_repository.dart';

class GetImage implements UseCase<ImageEntity, String?> {
  final CacheImageRepository repo;

  const GetImage(this.repo);

  @override
  Future<Either<ImageEntity, Failure>> call(String? params) async {
    return await repo.getImage(params);
  }
}
