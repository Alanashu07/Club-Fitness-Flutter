import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/core/usecases/usecase.dart';
import '../repository/auth_repo.dart';

class SignInWithEmailRequestOtp implements UseCase<String, String> {
  final AuthRepo repo;

  const SignInWithEmailRequestOtp(this.repo);

  @override
  Future<Either<String, Failure>> call(String params) async {
    return await repo.signInWithEmailRequestOtp(params);
  }
}
