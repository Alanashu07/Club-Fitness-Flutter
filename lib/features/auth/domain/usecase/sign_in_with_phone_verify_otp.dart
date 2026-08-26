import 'package:club_fitness/core/entities/user_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/core/usecases/usecase.dart';
import '../repository/auth_repo.dart';

class SignInWithPhoneVerifyOtp implements UseCase<UserEntity, String> {
  final AuthRepo repo;

  const SignInWithPhoneVerifyOtp(this.repo);

  @override
  Future<Either<UserEntity, Failure>> call(String params) async {
    return await repo.signInWithPhoneVerifyOtp(params);
  }
}
