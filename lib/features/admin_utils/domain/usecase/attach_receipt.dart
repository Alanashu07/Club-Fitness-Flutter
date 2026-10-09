import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/core/usecases/usecase.dart';
import '../entities/admin_utils_entities.dart';
import '../repository/admin_utils_repo.dart';

class AttachReceipt implements UseCase<FeesEntity, AttachReceiptParams> {
  final AdminUtilsRepo repo;

  const AttachReceipt(this.repo);

  @override
  Future<Either<FeesEntity, Failure>> call(AttachReceiptParams params) async {
    return await repo.attachReceipt(
      params.id,
      receiptFilePath: params.receiptFilePath,
      receiptUrl: params.receiptUrl,
    );
  }
}

class AttachReceiptParams {
  final String id;
  final String? receiptFilePath;
  final String? receiptUrl;

  const AttachReceiptParams({
    required this.id,
    required this.receiptFilePath,
    required this.receiptUrl,
  });
}
