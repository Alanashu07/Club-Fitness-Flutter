import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/core/usecases/usecase.dart';
import '../entities/admin_utils_entities.dart';
import '../repository/admin_utils_repo.dart';

class GetSalesReport implements UseCase<ReportDetailsEntity, GetSalesReportParams> {
  final AdminUtilsRepo repo;

  const GetSalesReport(this.repo);

  @override
  Future<Either<ReportDetailsEntity, Failure>> call(GetSalesReportParams params) async {
    return await repo.getSalesReport(params.range, startDate: params.startDate, endDate: params.endDate);
  }
}

class GetSalesReportParams {
  final String range;
  final String? startDate;
  final String? endDate;

  GetSalesReportParams(this.range, {this.startDate, this.endDate});
}
