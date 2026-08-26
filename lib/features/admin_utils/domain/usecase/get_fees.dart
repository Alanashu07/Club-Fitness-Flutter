import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/core/usecases/usecase.dart';
import '../entities/admin_utils_entities.dart';
import '../repository/admin_utils_repo.dart';

class GetFees implements UseCase<FeeResponseEntity, GetFeesParams> {
  final AdminUtilsRepo repo;

  const GetFees(this.repo);

  @override
  Future<Either<FeeResponseEntity, Failure>> call(GetFeesParams params) async {
    return await repo.getFees(
      search: params.search,
      status: params.status,
      memberId: params.memberId,
      planId: params.planId,
      sortBy: params.sortBy,
      page: params.page,
      limit: params.limit,
    );
  }
}

class GetFeesParams {
  final String search;
  final String status;
  final String? memberId;
  final String? planId;
  final String sortBy;
  final String page;
  final String limit;

  const GetFeesParams({
    this.search = '',
    this.status = '',
    this.memberId,
    this.planId,
    this.sortBy = '',
    this.page = '',
    this.limit = '',
  });
}
