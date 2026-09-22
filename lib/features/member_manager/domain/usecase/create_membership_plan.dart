import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/core/usecases/usecase.dart';
import '../entities/member_manager_entities.dart';
import '../repository/member_manager_repo.dart';

class CreateMembershipPlan implements UseCase<MembershipPlanMiniEntity, MembershipPlanMiniEntity> {
  final MemberManagerRepo repo;

  const CreateMembershipPlan(this.repo);

  @override
  Future<Either<MembershipPlanMiniEntity, Failure>> call(MembershipPlanMiniEntity params) async {
    return await repo.createMembershipPlan(params);
  }
}
