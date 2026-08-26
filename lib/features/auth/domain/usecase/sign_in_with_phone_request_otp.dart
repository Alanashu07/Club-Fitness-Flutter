import 'package:club_fitness/core/entities/user_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/core/usecases/usecase.dart';
import '../repository/auth_repo.dart';

class SignInWithPhoneRequestOtp
    implements UseCase<void, SignInWithPhoneRequestOtpParams> {
  final AuthRepo repo;

  const SignInWithPhoneRequestOtp(this.repo);

  @override
  Future<Either<void, Failure>> call(
    SignInWithPhoneRequestOtpParams params,
  ) async {
    return await repo.signInWithPhoneRequestOtp(
      phoneNumber: params.phoneNumber,
      onCodeSent: params.onCodeSent,
      onAutoVerified: params.onAutoVerified,
    );
  }
}

class SignInWithPhoneRequestOtpParams {
  final String phoneNumber;
  final void Function() onCodeSent;
  final void Function(UserEntity user) onAutoVerified;

  const SignInWithPhoneRequestOtpParams({
    required this.phoneNumber,
    required this.onCodeSent,
    required this.onAutoVerified,
  });
}
