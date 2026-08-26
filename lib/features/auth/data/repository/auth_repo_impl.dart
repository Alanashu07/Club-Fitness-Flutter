import 'dart:developer' as dev_log;
import 'package:club_fitness/core/entities/user_entity.dart';
import 'package:club_fitness/core/models/user_model.dart';
import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import '../data_source/auth_network_data_source.dart';
import '../../domain/repository/auth_repo.dart';
import '../models/auth_models.dart';

class AuthRepoImpl implements AuthRepo {
  final AuthNetworkDataSource dataSource;
  const AuthRepoImpl(this.dataSource);

  @override
  Future<Either<LoginUserModel, Failure>> login(
    String email,
    String password,
  ) async {
    try {
      final result = await dataSource.login(email, password);
      return Left(result);
    } catch (e, s) {
      dev_log.log(
        e.toString(),
        name: 'login in AuthRepoImpl',
        stackTrace: s,
        error: e,
      );
      return Right(Failure.fromException(e));
    }
  }

  @override
  Future<Either<UserModel, Failure>> register({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    try {
      final result = await dataSource.register(
        password: password,
        email: email,
        name: name,
        phone: phone,
      );
      return Left(result);
    } catch (e, s) {
      dev_log.log(
        e.toString(),
        name: 'register in AuthRepoImpl',
        stackTrace: s,
        error: e,
      );
      return Right(Failure.fromException(e));
    }
  }

  @override
  Future<Either<UserModel, Failure>> getMyProfile() async {
    try {
      final result = await dataSource.getMyProfile();
      return Left(result);
    } catch (e, s) {
      dev_log.log(
        e.toString(),
        name: 'getMyProfile in AuthRepoImpl',
        stackTrace: s,
        error: e,
      );
      return Right(Failure.fromException(e));
    }
  }

  @override
  Future<Either<String, Failure>> logout() async {
    try {
      final result = await dataSource.logout();
      return Left(result);
    } catch (e, s) {
      dev_log.log(
        e.toString(),
        name: 'logout in AuthRepoImpl',
        stackTrace: s,
        error: e,
      );
      return Right(Failure.fromException(e));
    }
  }

  @override
  Future<Either<String, Failure>> logoutAll() async {
    try {
      final result = await dataSource.logoutAll();
      return Left(result);
    } catch (e, s) {
      dev_log.log(
        e.toString(),
        name: 'logoutAll in AuthRepoImpl',
        stackTrace: s,
        error: e,
      );
      return Right(Failure.fromException(e));
    }
  }

  @override
  Future<Either<UserModel, Failure>> signInWithGoogle() async {
    try {
      final result = await dataSource.signInWithGoogle();
      return Left(result);
    } catch (e, s) {
      dev_log.log(
        e.toString(),
        name: 'signInWithGoogle in AuthRepoImpl',
        stackTrace: s,
        error: e,
      );
      return Right(Failure.fromException(e));
    }
  }

  @override
  Future<Either<void, Failure>> signInWithPhoneRequestOtp({
    required String phoneNumber,
    required void Function() onCodeSent,
    required void Function(UserEntity user) onAutoVerified,
  }) async {
    try {
      Failure? failure;
      final result = await dataSource.signInWithPhoneRequestOtp(
        phoneNumber: phoneNumber,
        onCodeSent: onCodeSent,
        onAutoVerified: onAutoVerified,
        onError: (message) => failure = Failure(
          code: -999,
          title: "Error logging in with phone: $phoneNumber",
          message: message,
        ),
      );
      if (failure != null) {
        return Right(failure!);
      }
      return Left(result);
    } catch (e, s) {
      dev_log.log(
        e.toString(),
        name: 'signInWithPhoneRequestOtp in AuthRepoImpl',
        stackTrace: s,
        error: e,
      );
      return Right(Failure.fromException(e));
    }
  }

  @override
  Future<Either<UserModel, Failure>> signInWithPhoneVerifyOtp(
    String otp,
  ) async {
    try {
      final result = await dataSource.signInWithPhoneVerifyOtp(otp);
      return Left(result);
    } catch (e, s) {
      dev_log.log(
        e.toString(),
        name: 'signInWithPhoneVerifyOtp in AuthRepoImpl',
        stackTrace: s,
        error: e,
      );
      return Right(Failure.fromException(e));
    }
  }

  @override
  Future<Either<String, Failure>> signInWithEmailRequestOtp(String email) async {
    try {
      final result = await dataSource.signInWithEmailRequestOtp(email);
      return Left(result);
    } catch (e, s) {
      dev_log.log(
        e.toString(),
        name: 'signInWithEmailRequestOtp in AuthRepoImpl',
        stackTrace: s,
        error: e,
      );
      return Right(Failure.fromException(e));
    }
  }

  @override
  Future<Either<UserModel, Failure>> signInWithEmailVerifyOtp({required String email, required String otp}) async {
    try {
      final result = await dataSource.signInWithEmailVerifyOtp(email: email, otp: otp);
      return Left(result);
    } catch (e, s) {
      dev_log.log(
        e.toString(),
        name: 'signInWithEmailVerifyOtp in AuthRepoImpl',
        stackTrace: s,
        error: e,
      );
      return Right(Failure.fromException(e));
    }
  }
}
