import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/core/usecases/usecase.dart';
import '../entities/admin_utils_entities.dart';
import '../repository/admin_utils_repo.dart';

class GetSalesReport implements UseCase<ReportDetailsEntity, String> {
  final AdminUtilsRepo repo;

  const GetSalesReport(this.repo);

  @override
  Future<Either<ReportDetailsEntity, Failure>> call(String params) async {
    return await repo.getSalesReport(params);
  }
}
