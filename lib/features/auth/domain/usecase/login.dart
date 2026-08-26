import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/core/usecases/usecase.dart';
import '../entities/auth_entities.dart';
import '../repository/auth_repo.dart';

class Login implements UseCase<LoginUserEntity, (String, String)> {
  final AuthRepo repo;

  const Login(this.repo);

  @override
  Future<Either<LoginUserEntity, Failure>> call((String, String) params) async {
    return await repo.login(params.$1, params.$2);
  }
}
