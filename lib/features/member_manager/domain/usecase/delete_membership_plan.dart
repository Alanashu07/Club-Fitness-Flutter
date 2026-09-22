import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/core/usecases/usecase.dart';
import '../repository/member_manager_repo.dart';

class DeleteMembershipPlan implements UseCase<bool, String> {
  final MemberManagerRepo repo;

  const DeleteMembershipPlan(this.repo);

  @override
  Future<Either<bool, Failure>> call(String params) async {
    return await repo.deleteMembershipPlan(params);
  }
}
