import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/core/usecases/usecase.dart';
import '../repository/admin_utils_repo.dart';
import '../entities/admin_utils_entities.dart';

class WaiveFee implements UseCase<FeesEntity, WaiveFeeParams> {
  final AdminUtilsRepo repo;

  const WaiveFee(this.repo);

  @override
  Future<Either<FeesEntity, Failure>> call(WaiveFeeParams params) async {
    return await repo.waiveFee(
      params.id,
      reason: params.reason,
    );
  }
}

class WaiveFeeParams {
  final String id;
  final String? reason;

  const WaiveFeeParams({
    required this.id,
    required this.reason,
  });
}
