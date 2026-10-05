import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/core/usecases/usecase.dart';
import '../repository/member_manager_repo.dart';

class DeleteMember implements UseCase<String, DeleteMemberParams> {
  final MemberManagerRepo repo;

  const DeleteMember(this.repo);

  @override
  Future<Either<String, Failure>> call(DeleteMemberParams params) async {
    return await repo.deleteMember(
      id: params.id,
      force: params.force,
    );
  }
}

class DeleteMemberParams {
  final String id;
  final bool force;

  const DeleteMemberParams({
    required this.id,
    this.force = false,
  });
}
