import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/core/usecases/usecase.dart';
import '../repository/member_manager_repo.dart';

class RevertLastRenewal implements UseCase<String, String> {
  final MemberManagerRepo repo;

  const RevertLastRenewal(this.repo);

  @override
  Future<Either<String, Failure>> call(String params) async {
    return await repo.revertLastRenewal(params);
  }
}
