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
  Future<Either<FeeSummaryEntity, Failure>> getFeeSummary({String? memberId});
  Future<Either<ReportDetailsEntity, Failure>> getSalesReport(String range, {
    String? startDate,
    String? endDate,
  });
  Future<Either<FeeDetailEntity, Failure>> getFeeById(String id);
  Future<Either<FeesEntity, Failure>> createFee({
    required String memberId,
    required String dueDate,
    String? planId,
    double? amount,
    String? status,
    double? paidAmount,
    String? paymentMethod,
    String? notes,
  });
  Future<Either<FeesEntity, Failure>> updateFee(String id, {
    double? amount,
    String? dueDate,
    String? planId,
    String? notes,
  });
  Future<Either<FeesEntity, Failure>> approveFees(String id);
  Future<Either<FeesEntity, Failure>> rejectFees(String id, {String? reason});
  Future<Either<FeesEntity, Failure>> markFeePaid(String id, {
    required double amountReceived,
    required String method,
    String? notes,
  });
  Future<Either<FeesEntity, Failure>> waiveFee(String id, {String? reason});
  Future<Either<FeesEntity, Failure>> attachReceipt(String id, {
    String? receiptFilePath,
    String? receiptUrl,
  });
  Future<Either<String, Failure>> deleteFee(String id);
  Future<Either<List<int>, Failure>> exportFeesPdf({
    String? search,
    String? status,
    String? memberId,
    String? planId,
    String? sortBy,
  });
    Future<Either<String, Failure>> exportSalesReportPdf(
    String range, {
    String? startDate,
    String? endDate,
    num? txLimit,
  });

  Future<Either<String, Failure>> exportSalesReportExcel(
    String range, {
    String? startDate,
    String? endDate,
    num? txLimit,
  });
}
