import 'package:club_fitness/core/entities/user_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/core/usecases/usecase.dart';
import '../repository/auth_repo.dart';

class Register implements UseCase<UserEntity, RegisterParams> {
  final AuthRepo repo;

  const Register(this.repo);

  @override
  Future<Either<UserEntity, Failure>> call(RegisterParams params) async {
    return await repo.register(
      name: params.name,
      phone: params.phone,
      email: params.email,
      password: params.password,
    );
  }
}

class RegisterParams {
  final String name;
  final String phone;
  final String email;
  final String password;

  const RegisterParams({
    required this.name,
    required this.phone,
    required this.email,
    required this.password,
  });
}
