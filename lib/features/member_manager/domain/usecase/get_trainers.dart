import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/core/usecases/usecase.dart';
import '../entities/member_manager_entities.dart';
import '../repository/member_manager_repo.dart';

class GetTrainers implements UseCase<List<TrainerMiniEntity>, void> {
  final MemberManagerRepo repo;

  const GetTrainers(this.repo);

  @override
  Future<Either<List<TrainerMiniEntity>, Failure>> call(void params) async {
    return await repo.getTrainers();
  }
}
