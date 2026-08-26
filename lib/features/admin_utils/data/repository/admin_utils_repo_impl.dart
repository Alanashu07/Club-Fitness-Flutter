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
        page: page,
        search: search,
        status: status,
        memberId: memberId,
        planId: planId,
        sortBy: sortBy,
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
  Future<Either<FeeSummaryModel, Failure>> getFeeSummary() async {
    try {
      final result = await dataSource.getFeeSummary();
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
  Future<Either<ReportDetailsModel, Failure>> getSalesReport(String range) async {
    try {
      final result = await dataSource.getSalesReport(range);
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
}
