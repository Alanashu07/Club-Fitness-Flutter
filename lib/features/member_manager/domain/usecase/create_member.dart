import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/core/usecases/usecase.dart';
import '../entities/member_manager_entities.dart';
import '../repository/member_manager_repo.dart';

class CreateMember implements UseCase<MemberListEntity, CreateMemberParams> {
  final MemberManagerRepo repo;

  const CreateMember(this.repo);

  @override
  Future<Either<MemberListEntity, Failure>> call(
    CreateMemberParams params,
  ) async {
    return await repo.createMember(
      name: params.name,
      phone: params.phone,
      email: params.email,
      plan: params.plan,
      trainer: params.trainer,
      dob: params.dob,
      startDate: params.startDate,
      userRole: params.userRole,
    );
  }
}

class CreateMemberParams {
  final String name;
  final String phone;
  final String email;
  final String plan;
  final String trainer;
  final String dob;
  final String startDate;
  final String userRole;

  CreateMemberParams({
    required this.name,
    required this.phone,
    required this.email,
    required this.plan,
    required this.trainer,
    required this.dob,
    required this.startDate,
    required this.userRole,
  });
}
