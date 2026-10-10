import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';

import '../entities/member_manager_entities.dart';

abstract interface class MemberManagerRepo {
  Future<Either<MemberPaginationEntity, Failure>> getMemberList({
    String search = '',
    String status = '',
    String? plan,
    String? trainer,
    bool checkedInToday = false,
    bool overdueOnly = false,
    String sortBy = '',
    String page = '',
    String limit = '',
  });
  Future<Either<MemberListEntity, Failure>> createMember({
    required String name,
    required String phone,
    required String email,
    required String plan,
    required String trainer,
    required String dob,
    required String startDate,
    required String userRole,
    required String? profileImagePath,
    required String? offerId,
    required String? offerCode,
  });
  Future<Either<MemberListEntity, Failure>> updateMember({
    required String id,
    required String name,
    required String phone,
    required String email,
    required String plan,
    required String trainer,
    required String dob,
    required String startDate,
    required String? profileImagePath,
    required bool removeProfileImage,
  });
  Future<Either<List<TrainerMiniEntity>, Failure>> getTrainers();
  Future<Either<List<MembershipPlanMiniEntity>, Failure>> getPlans(
    bool includeInactive,
  );
  Future<Either<MembershipPlanMiniEntity, Failure>> createMembershipPlan(
    MembershipPlanMiniEntity entity,
  );
  Future<Either<MembershipPlanMiniEntity, Failure>> updateMembershipPlan(
    MembershipPlanMiniEntity entity,
  );
  Future<Either<bool, Failure>> deleteMembershipPlan(String id);
  Future<Either<MemberDetailEntity, Failure>> getMemberDetails(String id);
  Future<Either<String, Failure>> reactivateMember(String id);
  Future<Either<String, Failure>> deleteMember({
    required String id,
    bool force = false,
  });
  Future<Either<String, Failure>> suspendMember(String id);
  Future<Either<RenewMemberEntity, Failure>> renewMembership({
    required String id,
    required String planId,
    required num paidAmount,
    required String paymentMethod,
    required String notes,
    String? startOverride,
    String? receiptPath,
    required bool waiveRemaining,
    required String? offerId,
    required String? offerCode,
  });

  Future<Either<String, Failure>> revertLastRenewal(String id);
  Future<Either<String, Failure>> sendReminder(String id);
}
