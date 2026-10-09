import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/core/usecases/usecase.dart';
import '../repository/admin_utils_repo.dart';

class ExportFeesPdf implements UseCase<List<int>, ExportFeesPdfParams> {
  final AdminUtilsRepo repo;

  const ExportFeesPdf(this.repo);

  @override
  Future<Either<List<int>, Failure>> call(ExportFeesPdfParams params) async {
    return await repo.exportFeesPdf(
      search: params.search,
      status: params.status,
      memberId: params.memberId,
      planId: params.planId,
      sortBy: params.sortBy,
    );
  }
}

class ExportFeesPdfParams {
  final String? search;
  final String? status;
  final String? memberId;
  final String? planId;
  final String? sortBy;

  const ExportFeesPdfParams({
    required this.search,
    required this.status,
    required this.memberId,
    required this.planId,
    required this.sortBy,
  });
}
