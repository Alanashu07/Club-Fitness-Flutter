import 'dart:developer' as dev_log;
import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import '../data_source/admin_utils_network_data_source.dart';
import '../../domain/repository/admin_utils_repo.dart';
import '../models/admin_utils_models.dart';

class AdminUtilsRepoImpl implements AdminUtilsRepo {
  final AdminUtilsNetworkDataSource dataSource;
  const AdminUtilsRepoImpl(this.dataSource);

  @override
  Future<Either<FeeResponseModel, Failure>> getFees({
    required String search,
    required String status,
    required String? memberId,
    required String? planId,
    required String sortBy,
    required String page,
    required String limit,
  }) async {
    try {
      final result = await dataSource.getFees(
        limit: limit,
        memberId: memberId,
        page: page,
        planId: planId,
        search: search,
        sortBy: sortBy,
        status: status,
      );
      return Left(result);
    } catch (e, s) {
      dev_log.log(
        e.toString(),
        name: 'getFees in AdminUtilsRepoImpl',
        stackTrace: s,
        error: e,
      );
      return Right(Failure.fromException(e));
    }
  }

  @override
  Future<Either<FeeSummaryModel, Failure>> getFeeSummary({
    String? memberId,
  }) async {
    try {
      final result = await dataSource.getFeeSummary(memberId: memberId);
      return Left(result);
    } catch (e, s) {
      dev_log.log(
        e.toString(),
        name: 'getFeeSummary in AdminUtilsRepoImpl',
        stackTrace: s,
        error: e,
      );
      return Right(Failure.fromException(e));
    }
  }

  @override
  Future<Either<ReportDetailsModel, Failure>> getSalesReport(
    String range, {
    String? startDate,
    String? endDate,
  }) async {
    try {
      final result = await dataSource.getSalesReport(
        range,
        startDate: startDate,
        endDate: endDate,
      );
      return Left(result);
    } catch (e, s) {
      dev_log.log(
        e.toString(),
        name: 'getSalesReport in AdminUtilsRepoImpl',
        stackTrace: s,
        error: e,
      );
      return Right(Failure.fromException(e));
    }
  }

  @override
  Future<Either<FeeDetailModel, Failure>> getFeeById(String id) async {
    try {
      final result = await dataSource.getFeeById(id);
      return Left(result);
    } catch (e, s) {
      dev_log.log(
        e.toString(),
        name: 'getFeeById in AdminUtilsRepoImpl',
        stackTrace: s,
        error: e,
      );
      return Right(Failure.fromException(e));
    }
  }

  @override
  Future<Either<FeesModel, Failure>> createFee({
    required String memberId,
    required String dueDate,
    String? planId,
    double? amount,
    String? status,
    double? paidAmount,
    String? paymentMethod,
    String? notes,
  }) async {
    try {
      final result = await dataSource.createFee(
        notes: notes,
        paymentMethod: paymentMethod,
        paidAmount: paidAmount,
        planId: planId,
        status: status,
        amount: amount,
        dueDate: dueDate,
        memberId: memberId,
      );
      return Left(result);
    } catch (e, s) {
      dev_log.log(
        e.toString(),
        name: 'createFee in AdminUtilsRepoImpl',
        stackTrace: s,
        error: e,
      );
      return Right(Failure.fromException(e));
    }
  }

  @override
  Future<Either<FeesModel, Failure>> updateFee(
    String id, {
    double? amount,
    String? dueDate,
    String? planId,
    String? notes,
  }) async {
    try {
      final result = await dataSource.updateFee(
        id,
        notes: notes,
        planId: planId,
        dueDate: dueDate,
        amount: amount,
      );
      return Left(result);
    } catch (e, s) {
      dev_log.log(
        e.toString(),
        name: 'updateFee in AdminUtilsRepoImpl',
        stackTrace: s,
        error: e,
      );
      return Right(Failure.fromException(e));
    }
  }

  @override
  Future<Either<FeesModel, Failure>> approveFees(String id) async {
    try {
      final result = await dataSource.approveFees(id);
      return Left(result);
    } catch (e, s) {
      dev_log.log(
        e.toString(),
        name: 'approveFees in AdminUtilsRepoImpl',
        stackTrace: s,
        error: e,
      );
      return Right(Failure.fromException(e));
    }
  }

  @override
  Future<Either<FeesModel, Failure>> rejectFees(
    String id, {
    String? reason,
  }) async {
    try {
      final result = await dataSource.rejectFees(id, reason: reason);
      return Left(result);
    } catch (e, s) {
      dev_log.log(
        e.toString(),
        name: 'rejectFees in AdminUtilsRepoImpl',
        stackTrace: s,
        error: e,
      );
      return Right(Failure.fromException(e));
    }
  }

  @override
  Future<Either<FeesModel, Failure>> markFeePaid(
    String id, {
    required double amountReceived,
    required String method,
    String? notes,
  }) async {
    try {
      final result = await dataSource.markFeePaid(
        id,
        notes: notes,
        amountReceived: amountReceived,
        method: method,
      );
      return Left(result);
    } catch (e, s) {
      dev_log.log(
        e.toString(),
        name: 'markFeePaid in AdminUtilsRepoImpl',
        stackTrace: s,
        error: e,
      );
      return Right(Failure.fromException(e));
    }
  }

  @override
  Future<Either<FeesModel, Failure>> waiveFee(
    String id, {
    String? reason,
  }) async {
    try {
      final result = await dataSource.waiveFee(id, reason: reason);
      return Left(result);
    } catch (e, s) {
      dev_log.log(
        e.toString(),
        name: 'waiveFee in AdminUtilsRepoImpl',
        stackTrace: s,
        error: e,
      );
      return Right(Failure.fromException(e));
    }
  }

  @override
  Future<Either<FeesModel, Failure>> attachReceipt(
    String id, {
    String? receiptFilePath,
    String? receiptUrl,
  }) async {
    try {
      final result = await dataSource.attachReceipt(
        id,
        receiptUrl: receiptUrl,
        receiptFilePath: receiptFilePath,
      );
      return Left(result);
    } catch (e, s) {
      dev_log.log(
        e.toString(),
        name: 'attachReceipt in AdminUtilsRepoImpl',
        stackTrace: s,
        error: e,
      );
      return Right(Failure.fromException(e));
    }
  }

  @override
  Future<Either<String, Failure>> deleteFee(String id) async {
    try {
      final result = await dataSource.deleteFee(id);
      return Left(result);
    } catch (e, s) {
      dev_log.log(
        e.toString(),
        name: 'deleteFee in AdminUtilsRepoImpl',
        stackTrace: s,
        error: e,
      );
      return Right(Failure.fromException(e));
    }
  }

  @override
  Future<Either<List<int>, Failure>> exportFeesPdf({
    String? search,
    String? status,
    String? memberId,
    String? planId,
    String? sortBy,
  }) async {
    try {
      final result = await dataSource.exportFeesPdf(
        sortBy: sortBy,
        search: search,
        status: status,
        memberId: memberId,
        planId: planId,
      );
      return Left(result);
    } catch (e, s) {
      dev_log.log(
        e.toString(),
        name: 'exportFeesPdf in AdminUtilsRepoImpl',
        stackTrace: s,
        error: e,
      );
      return Right(Failure.fromException(e));
    }
  }

  @override
  Future<Either<String, Failure>> exportSalesReportExcel(
    String range, {
    String? startDate,
    String? endDate,
    num? txLimit,
  }) async {
    try {
      final result = await dataSource.exportSalesReportExcel(
        range,
        startDate: startDate,
        endDate: endDate,
        txLimit: txLimit,
      );
      return Left(result);
    } catch (e, s) {
      dev_log.log(
        e.toString(),
        name: 'exportSalesReportExcel in AdminUtilsRepoImpl',
        stackTrace: s,
        error: e,
      );
      return Right(Failure.fromException(e));
    }
  }

  @override
  Future<Either<String, Failure>> exportSalesReportPdf(
    String range, {
    String? startDate,
    String? endDate,
    num? txLimit,
  }) async {
    try {
      final result = await dataSource.exportSalesReportPdf(
        range,
        startDate: startDate,
        endDate: endDate,
        txLimit: txLimit,
      );
      return Left(result);
    } catch (e, s) {
      dev_log.log(
        e.toString(),
        name: 'exportSalesReportPdf in AdminUtilsRepoImpl',
        stackTrace: s,
        error: e,
      );
      return Right(Failure.fromException(e));
    }
  }
}
