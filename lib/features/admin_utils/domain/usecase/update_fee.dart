import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/core/usecases/usecase.dart';
import '../repository/admin_utils_repo.dart';
import '../entities/admin_utils_entities.dart';

class UpdateFee implements UseCase<FeesEntity, UpdateFeeParams> {
  final AdminUtilsRepo repo;

  const UpdateFee(this.repo);

  @override
  Future<Either<FeesEntity, Failure>> call(UpdateFeeParams params) async {
    return await repo.updateFee(
      params.id,
      amount: params.amount,
      dueDate: params.dueDate,
      planId: params.planId,
      notes: params.notes,
    );
  }
}

class UpdateFeeParams {
  final String id;
  final double? amount;
  final String? dueDate;
  final String? planId;
  final String? notes;

  const UpdateFeeParams({
    required this.id,
    required this.amount,
    required this.dueDate,
    required this.planId,
    required this.notes,
  });
}
