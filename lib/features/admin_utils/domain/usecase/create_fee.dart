import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/core/usecases/usecase.dart';
import '../repository/admin_utils_repo.dart';
import '../entities/admin_utils_entities.dart';

class CreateFee implements UseCase<FeesEntity, CreateFeeParams> {
  final AdminUtilsRepo repo;

  const CreateFee(this.repo);

  @override
  Future<Either<FeesEntity, Failure>> call(CreateFeeParams params) async {
    return await repo.createFee(
      memberId: params.memberId,
      dueDate: params.dueDate,
      planId: params.planId,
      amount: params.amount,
      status: params.status,
      paidAmount: params.paidAmount,
      paymentMethod: params.paymentMethod,
      notes: params.notes,
    );
  }
}

class CreateFeeParams {
  final String memberId;
  final String dueDate;
  final String? planId;
  final double? amount;
  final String? status;
  final double? paidAmount;
  final String? paymentMethod;
  final String? notes;

  const CreateFeeParams({
    required this.memberId,
    required this.dueDate,
    required this.planId,
    required this.amount,
    required this.status,
    required this.paidAmount,
    required this.paymentMethod,
    required this.notes,
  });
}
