import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/core/usecases/usecase.dart';
import '../entities/member_manager_entities.dart';
import '../repository/member_manager_repo.dart';

class GetMemberList implements UseCase<MemberPaginationEntity, GetMemberListParams> {
  final MemberManagerRepo repo;

  const GetMemberList(this.repo);

  @override
  Future<Either<MemberPaginationEntity, Failure>> call(GetMemberListParams params) async {
    return await repo.getMemberList(
      search: params.search,
      status: params.status,
      plan: params.plan,
      trainer: params.trainer,
      checkedInToday: params.checkedInToday,
      overdueOnly: params.overdueOnly,
      sortBy: params.sortBy,
      page: params.page,
      limit: params.limit,
    );
  }
}

class GetMemberListParams {
  final String search;
  final String status;
  final String? plan;
  final String? trainer;
  final bool checkedInToday;
  final bool overdueOnly;
  final String sortBy;
  final String page;
  final String limit;

  const GetMemberListParams({
    this.search = '',
    this.status = '',
    this.plan,
    this.trainer,
    this.checkedInToday = false,
    this.overdueOnly = false,
    this.sortBy = '',
    this.page = '',
    this.limit = '',
  });
}
