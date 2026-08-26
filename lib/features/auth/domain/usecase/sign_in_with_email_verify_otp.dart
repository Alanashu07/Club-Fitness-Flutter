import 'package:club_fitness/core/entities/user_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/core/usecases/usecase.dart';
import '../repository/auth_repo.dart';

class SignInWithEmailVerifyOtp implements UseCase<UserEntity, SignInWithEmailVerifyOtpParams> {
  final AuthRepo repo;

  const SignInWithEmailVerifyOtp(this.repo);

  @override
  Future<Either<UserEntity, Failure>> call(SignInWithEmailVerifyOtpParams params) async {
    return await repo.signInWithEmailVerifyOtp(
      email: params.email,
      otp: params.otp,
    );
  }
}

class SignInWithEmailVerifyOtpParams {
  final String email;
  final String otp;

  const SignInWithEmailVerifyOtpParams({
    required this.email,
    required this.otp,
  });
}
