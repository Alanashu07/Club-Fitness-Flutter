import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/core/usecases/usecase.dart';
import '../entities/member_manager_entities.dart';
import '../repository/member_manager_repo.dart';

class RenewMembership implements UseCase<RenewMemberEntity, RenewMembershipParams> {
  final MemberManagerRepo repo;

  const RenewMembership(this.repo);

  @override
  Future<Either<RenewMemberEntity, Failure>> call(RenewMembershipParams params) async {
    return await repo.renewMembership(
      id: params.id,
      planId: params.planId,
      paidAmount: params.paidAmount,
      paymentMethod: params.paymentMethod,
      notes: params.notes,
      startOverride: params.startOverride,
      receiptPath: params.receiptPath,
      waiveRemaining: params.waiveRemaining,
      offerId: params.offerId,
      offerCode: params.offerCode,
    );
  }
}

class RenewMembershipParams {
  final String id;
  final String planId;
  final num paidAmount;
  final String paymentMethod;
  final String notes;
  final String? startOverride;
  final String? receiptPath;
  final bool waiveRemaining;
  final String? offerId;
  final String? offerCode;

  const RenewMembershipParams({
    required this.id,
    required this.planId,
    required this.paidAmount,
    required this.paymentMethod,
    required this.notes,
    required this.startOverride,
    required this.receiptPath,
    required this.waiveRemaining,
    required this.offerId,
    required this.offerCode,
  });
}
