import 'package:club_fitness/core/entities/user_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/core/usecases/usecase.dart';
import '../repository/auth_repo.dart';

class GetMyProfile implements UseCase<UserEntity, void> {
  final AuthRepo repo;

  const GetMyProfile(this.repo);

  @override
  Future<Either<UserEntity, Failure>> call(void params) async {
    return await repo.getMyProfile();
  }
}
