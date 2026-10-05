import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';

import '../entities/admin_utils_entities.dart';

abstract interface class AdminUtilsRepo {
  Future<Either<FeeResponseEntity, Failure>> getFees({
    required String search,
    required String status,
    required String? memberId,
    required String? planId,
    required String sortBy,
    required String page,
    required String limit,
  });
  Future<Either<FeeSummaryEntity, Failure>> getFeeSummary();
  Future<Either<ReportDetailsEntity, Failure>> getSalesReport(String range);
  Future<Either<FeesEntity, Failure>> approveFees(String id);
  Future<Either<FeesEntity, Failure>> rejectFees(String id);
}
