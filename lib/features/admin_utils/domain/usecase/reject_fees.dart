import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/core/usecases/usecase.dart';
import '../entities/admin_utils_entities.dart';
import '../repository/admin_utils_repo.dart';

class RejectFees implements UseCase<FeesEntity, RejectFeesParams> {
  final AdminUtilsRepo repo;

  const RejectFees(this.repo);

  @override
  Future<Either<FeesEntity, Failure>> call(RejectFeesParams params) async {
    return await repo.rejectFees(params.id, reason: params.reason);
  }
}

class RejectFeesParams {
  final String id;
  final String? reason;

  RejectFeesParams({required this.id, this.reason});
}