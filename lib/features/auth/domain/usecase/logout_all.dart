import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/core/usecases/usecase.dart';
import '../repository/auth_repo.dart';

class LogoutAll implements UseCase<String, void> {
  final AuthRepo repo;

  const LogoutAll(this.repo);

  @override
  Future<Either<String, Failure>> call(void params) async {
    return await repo.logoutAll();
  }
}
