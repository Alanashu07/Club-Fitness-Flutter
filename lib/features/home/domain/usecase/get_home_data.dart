import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/core/usecases/usecase.dart';
import '../entities/home_entities.dart';
import '../repository/home_repo.dart';

class GetHomeData implements UseCase<HomeEntity, String> {
  final HomeRepo repo;

  const GetHomeData(this.repo);

  @override
  Future<Either<HomeEntity, Failure>> call(String params) async {
    return await repo.getHomeData(params);
  }
}
