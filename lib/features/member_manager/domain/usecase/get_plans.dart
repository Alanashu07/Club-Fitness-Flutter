import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/core/usecases/usecase.dart';
import '../entities/member_manager_entities.dart';
import '../repository/member_manager_repo.dart';

class GetPlans implements UseCase<List<MembershipPlanMiniEntity>, bool> {
  final MemberManagerRepo repo;

  const GetPlans(this.repo);

  @override
  Future<Either<List<MembershipPlanMiniEntity>, Failure>> call(bool params) async {
    return await repo.getPlans(params);
  }
}
