import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/core/usecases/usecase.dart';
import '../repository/admin_utils_repo.dart';

class ExportSalesReportPdf implements UseCase<String, ExportSalesReportPdfParams> {
  final AdminUtilsRepo repo;

  const ExportSalesReportPdf(this.repo);

  @override
  Future<Either<String, Failure>> call(ExportSalesReportPdfParams params) async {
    return await repo.exportSalesReportPdf(
      params.range,
      startDate: params.startDate,
      endDate: params.endDate,
      txLimit: params.txLimit,
    );
  }
}

class ExportSalesReportPdfParams {
  final String range;
  final String? startDate;
  final String? endDate;
  final num? txLimit;

  const ExportSalesReportPdfParams(this.range,{
    required this.startDate,
    required this.endDate,
    required this.txLimit,
  });
}
