import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/core/usecases/usecase.dart';
import '../entities/member_manager_entities.dart';
import '../repository/member_manager_repo.dart';

class GetMemberDetails implements UseCase<MemberDetailEntity, String> {
  final MemberManagerRepo repo;

  const GetMemberDetails(this.repo);

  @override
  Future<Either<MemberDetailEntity, Failure>> call(String params) async {
    return await repo.getMemberDetails(params);
  }
}
