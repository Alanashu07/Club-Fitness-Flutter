import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';

import '../entities/member_manager_entities.dart';

abstract interface class MemberManagerRepo {
  Future<Either<MemberPaginationEntity, Failure>> getMemberList({
    String search,
    String status,
    String? plan,
    String? trainer,
    bool checkedInToday,
    bool overdueOnly,
    String sortBy,
    String page,
    String limit,
  });
  Future<Either<MemberListEntity, Failure>> createMember({
    required String name,
    required String phone,
    required String email,
    required String plan,
    required String trainer,
    required String dob,
  });

  Future<Either<List<TrainerMiniEntity>, Failure>> getTrainers();
  Future<Either<List<MembershipPlanMiniEntity>, Failure>> getPlans(bool includeInactive);
}
