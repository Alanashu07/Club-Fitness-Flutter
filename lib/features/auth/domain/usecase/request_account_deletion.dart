import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/core/usecases/usecase.dart';
import '../entities/auth_entities.dart';
import '../repository/auth_repo.dart';

class RequestAccountDeletion
    implements UseCase<AccountDeletionResponse, DeletionMode> {
  final AuthRepo repo;

  const RequestAccountDeletion(this.repo);

  @override
  Future<Either<AccountDeletionResponse, Failure>> call(
    DeletionMode params,
  ) async {
    return await repo.requestAccountDeletion(params);
  }
}
