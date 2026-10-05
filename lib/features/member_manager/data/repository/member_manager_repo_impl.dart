import 'dart:developer' as dev_log;
import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
// TODO: Import necessary models used in parameters or return types
import '../../domain/entities/member_manager_entities.dart';
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
        limit: limit,
        page: page,
        sortBy: sortBy,
        overdueOnly: overdueOnly,
        checkedInToday: checkedInToday,
        trainer: trainer,
        plan: plan,
        status: status,
        search: search,
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
    required String startDate,
    required String userRole,
  }) async {
    try {
      final result = await dataSource.createMember(
        userRole: userRole,
        startDate: startDate,
        dob: dob,
        trainer: trainer,
        plan: plan,
        email: email,
        phone: phone,
        name: name,
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
  Future<Either<MemberListModel, Failure>> updateMember({
    required String id,
    required String name,
    required String phone,
    required String email,
    required String plan,
    required String trainer,
    required String dob,
    required String startDate,
  }) async {
    try {
      final result = await dataSource.updateMember(
        startDate: startDate,
        dob: dob,
        trainer: trainer,
        plan: plan,
        email: email,
        phone: phone,
        name: name,
        id: id,
      );
      return Left(result);
    } catch (e, s) {
      dev_log.log(
        e.toString(),
        name: 'updateMember in MemberManagerRepoImpl',
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

  @override
  Future<Either<List<MembershipPlanMiniModel>, Failure>> getPlans(
    bool includeInactive,
  ) async {
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
  Future<Either<MembershipPlanMiniModel, Failure>> createMembershipPlan(
    MembershipPlanMiniEntity entity,
  ) async {
    try {
      final model = MembershipPlanMiniModel.fromEntity(entity);
      final result = await dataSource.createMembershipPlan(model);
      return Left(result);
    } catch (e, s) {
      dev_log.log(
        e.toString(),
        name: 'createMembershipPlan in MemberManagerRepoImpl',
        stackTrace: s,
        error: e,
      );
      return Right(Failure.fromException(e));
    }
  }

  @override
  Future<Either<MembershipPlanMiniModel, Failure>> updateMembershipPlan(
    MembershipPlanMiniEntity entity,
  ) async {
    try {
      final model = MembershipPlanMiniModel.fromEntity(entity);
      final result = await dataSource.updateMembershipPlan(model);
      return Left(result);
    } catch (e, s) {
      dev_log.log(
        e.toString(),
        name: 'updateMembershipPlan in MemberManagerRepoImpl',
        stackTrace: s,
        error: e,
      );
      return Right(Failure.fromException(e));
    }
  }

  @override
  Future<Either<bool, Failure>> deleteMembershipPlan(String id) async {
    try {
      final result = await dataSource.deleteMembershipPlan(id);
      return Left(result);
    } catch (e, s) {
      dev_log.log(
        e.toString(),
        name: 'deleteMembershipPlan in MemberManagerRepoImpl',
        stackTrace: s,
        error: e,
      );
      return Right(Failure.fromException(e));
    }
  }

  @override
  Future<Either<MemberDetailModel, Failure>> getMemberDetails(String id) async {
    try {
      final result = await dataSource.getMemberDetails(id);
      return Left(result);
    } catch (e, s) {
      dev_log.log(
        e.toString(),
        name: 'getMemberDetails in MemberManagerRepoImpl',
        stackTrace: s,
        error: e,
      );
      return Right(Failure.fromException(e));
    }
  }

  @override
  Future<Either<String, Failure>> reactivateMember(String id) async {
    try {
      final result = await dataSource.reactivateMember(id);
      return Left(result);
    } catch (e, s) {
      dev_log.log(
        e.toString(),
        name: 'reactivateMember in MemberManagerRepoImpl',
        stackTrace: s,
        error: e,
      );
      return Right(Failure.fromException(e));
    }
  }

  @override
  Future<Either<String, Failure>> deleteMember({
    required String id,
    bool force = false,
  }) async {
    try {
      final result = await dataSource.deleteMember(id: id, force: force);
      return Left(result);
    } catch (e, s) {
      dev_log.log(
        e.toString(),
        name: 'deleteMember in MemberManagerRepoImpl',
        stackTrace: s,
        error: e,
      );
      return Right(Failure.fromException(e));
    }
  }

  @override
  Future<Either<String, Failure>> suspendMember(String id) async {
    try {
      final result = await dataSource.suspendMember(id);
      return Left(result);
    } catch (e, s) {
      dev_log.log(
        e.toString(),
        name: 'suspendMember in MemberManagerRepoImpl',
        stackTrace: s,
        error: e,
      );
      return Right(Failure.fromException(e));
    }
  }

  @override
  Future<Either<RenewMemberModel, Failure>> renewMembership({
    required String id,
    required String planId,
    required num paidAmount,
    required String paymentMethod,
    required String notes,
    String? startOverride,
    String? receiptPath,
  }) async {
    try {
      final result = await dataSource.renewMembership(
        startOverride: startOverride,
        id: id,
        planId: planId,
        paidAmount: paidAmount,
        paymentMethod: paymentMethod,
        notes: notes,
        receiptPath: receiptPath,
      );
      return Left(result);
    } catch (e, s) {
      dev_log.log(
        e.toString(),
        name: 'renewMembership in MemberManagerRepoImpl',
        stackTrace: s,
        error: e,
      );
      return Right(Failure.fromException(e));
    }
  }
}
