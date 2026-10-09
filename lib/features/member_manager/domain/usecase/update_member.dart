import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/core/usecases/usecase.dart';
import '../entities/member_manager_entities.dart';
import '../repository/member_manager_repo.dart';

class UpdateMember implements UseCase<MemberListEntity, UpdateMemberParams> {
  final MemberManagerRepo repo;

  const UpdateMember(this.repo);

  @override
  Future<Either<MemberListEntity, Failure>> call(UpdateMemberParams params) async {
    return await repo.updateMember(
      id: params.id,
      name: params.name,
      phone: params.phone,
      email: params.email,
      plan: params.plan,
      trainer: params.trainer,
      dob: params.dob,
      startDate: params.startDate,
      profileImagePath: params.profileImagePath,
      removeProfileImage: params.removeProfileImage,
    );
  }
}

class UpdateMemberParams {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String plan;
  final String trainer;
  final String dob;
  final String startDate;
  final String? profileImagePath;
  final bool removeProfileImage;

  const UpdateMemberParams({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.plan,
    required this.trainer,
    required this.dob,
    required this.startDate,
    required this.profileImagePath,
    required this.removeProfileImage,
  });
}
