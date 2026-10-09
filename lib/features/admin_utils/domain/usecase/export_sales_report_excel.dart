import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/core/usecases/usecase.dart';
import '../repository/admin_utils_repo.dart';

class ExportSalesReportExcel
    implements UseCase<String, ExportSalesReportExcelParams> {
  final AdminUtilsRepo repo;

  const ExportSalesReportExcel(this.repo);

  @override
  Future<Either<String, Failure>> call(
    ExportSalesReportExcelParams params,
  ) async {
    return await repo.exportSalesReportExcel(
      params.range,
      startDate: params.startDate,
      endDate: params.endDate,
      txLimit: params.txLimit,
    );
  }
}

class ExportSalesReportExcelParams {
  final String range;
  final String? startDate;
  final String? endDate;
  final num? txLimit;

  const ExportSalesReportExcelParams(
    this.range, {
    required this.startDate,
    required this.endDate,
    required this.txLimit,
  });
}
