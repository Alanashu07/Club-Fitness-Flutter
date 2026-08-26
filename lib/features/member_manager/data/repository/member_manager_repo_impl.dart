import 'dart:developer' as dev_log;
import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import '../data_source/member_manager_network_data_source.dart';
import '../../domain/repository/member_manager_repo.dart';
import '../models/member_manager_models.dart';

class MemberManagerRepoImpl implements MemberManagerRepo {
  final MemberManagerNetworkDataSource dataSource;
  const MemberManagerRepoImpl(this.dataSource);

  @override
  Future<Either<MemberPaginationModel, Failure>> getMemberList({
    String search = '',
    String status = '',
    String? plan,
    String? trainer,
    bool checkedInToday = false,
    bool overdueOnly = false,
    String sortBy = '',
    String page = '',
    String limit = '',
  }) async {
    try {
      final result = await dataSource.getMemberList(
        search: search,
        status: status,
        plan: plan,
        trainer: trainer,
        checkedInToday: checkedInToday,
        overdueOnly: overdueOnly,
        sortBy: sortBy,
        page: page,
        limit: limit,
      );
      return Left(result);
    } catch (e, s) {
      dev_log.log(
        e.toString(),
        name: 'getMemberList in MemberManagerRepoImpl',
        stackTrace: s,
        error: e,
      );
      return Right(Failure.fromException(e));
    }
  }

  @override
  Future<Either<MemberListModel, Failure>> createMember({
    required String name,
    required String phone,
    required String email,
    required String plan,
    required String trainer,
    required String dob,
  }) async {
    try {
      final result = await dataSource.createMember(
        name: name,
        phone: phone,
        email: email,
        plan: plan,
        trainer: trainer,
        dob: dob,
      );
      return Left(result);
    } catch (e, s) {
      dev_log.log(
        e.toString(),
        name: 'createMember in MemberManagerRepoImpl',
        stackTrace: s,
        error: e,
      );
      return Right(Failure.fromException(e));
    }
  }

  @override
  Future<Either<List<MembershipPlanMiniModel>, Failure>> getPlans(bool includeInactive) async {
    try {
      final result = await dataSource.getPlans(includeInactive);
      return Left(result);
    } catch (e, s) {
      dev_log.log(
        e.toString(),
        name: 'getPlans in MemberManagerRepoImpl',
        stackTrace: s,
        error: e,
      );
      return Right(Failure.fromException(e));
    }
  }

  @override
  Future<Either<List<TrainerMiniModel>, Failure>> getTrainers() async {
    try {
      final result = await dataSource.getTrainers();
      return Left(result);
    } catch (e, s) {
      dev_log.log(
        e.toString(),
        name: 'getTrainers in MemberManagerRepoImpl',
        stackTrace: s,
        error: e,
      );
      return Right(Failure.fromException(e));
    }
  }
}
