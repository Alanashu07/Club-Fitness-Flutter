import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/core/usecases/usecase.dart';
import '../entities/admin_utils_entities.dart';
import '../repository/admin_utils_repo.dart';

class MarkFeePaid implements UseCase<FeesEntity, MarkFeePaidParams> {
  final AdminUtilsRepo repo;

  const MarkFeePaid(this.repo);

  @override
  Future<Either<FeesEntity, Failure>> call(MarkFeePaidParams params) async {
    return await repo.markFeePaid(
      params.id,
      amountReceived: params.amountReceived,
      method: params.method,
      notes: params.notes,
    );
  }
}

class MarkFeePaidParams {
  final String id;
  final double amountReceived;
  final String method;
  final String? notes;

  const MarkFeePaidParams({
    required this.id,
    required this.amountReceived,
    required this.method,
    required this.notes,
  });
}
