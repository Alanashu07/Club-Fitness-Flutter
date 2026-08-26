import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/core/usecases/usecase.dart';
import '../repository/cache_image_repository.dart';

class DeleteImage implements UseCase<int, String?> {
  final CacheImageRepository repo;

  const DeleteImage(this.repo);

  @override
  Future<Either<int, Failure>> call(String? params) async {
    return await repo.deleteImage(params);
  }
}
