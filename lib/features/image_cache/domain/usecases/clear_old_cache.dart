import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/core/usecases/usecase.dart';
import '../repository/cache_image_repository.dart';

class ClearOldCache implements UseCase<int, void> {
  final CacheImageRepository repo;

  const ClearOldCache(this.repo);

  @override
  Future<Either<int, Failure>> call(void params) async {
    return await repo.clearOldCache();
  }
}
