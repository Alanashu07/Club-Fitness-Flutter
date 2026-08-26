import 'package:club_fitness/core/entities/user_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';

import '../entities/auth_entities.dart';

abstract interface class AuthRepo {
  Future<Either<LoginUserEntity, Failure>> login(String email, String password);
  Future<Either<UserEntity, Failure>> register({
    required String name,
    required String phone,
    required String email,
    required String password,
  });
  Future<Either<UserEntity, Failure>> getMyProfile();
  Future<Either<String, Failure>> logout();
  Future<Either<String, Failure>> logoutAll();
  Future<Either<UserEntity, Failure>> signInWithGoogle();

  Future<Either<void, Failure>> signInWithPhoneRequestOtp({
    required String phoneNumber,
    required void Function() onCodeSent,
    required void Function(UserEntity user) onAutoVerified,
  });
  Future<Either<UserEntity, Failure>> signInWithPhoneVerifyOtp(String otp);

  Future<Either<String, Failure>> signInWithEmailRequestOtp(String email);
  Future<Either<UserEntity, Failure>> signInWithEmailVerifyOtp({
    required String email,
    required String otp,
  });
}
