import 'package:club_fitness/features/admin_utils/domain/entities/fees_entity.dart';

import 'member_manager_entities.dart';

class FeeHistoryEntity {
  final String id;
  final String memberId;
  final String planId;
  final String amount;
  final num paidAmount;
  final String status;
  final String dueDate;
  final String submittedDate;
  final String approvedDate;
  final String paidDate;
  final String paymentMethod;
  final String receiptImageUrl;
  final String notes;
  final String approvedById;
  final String createdAt;
  final String updatedAt;
  final MembershipPlanMiniEntity plan;
  final num discountAmount;

  const FeeHistoryEntity({
    this.id = '',
    this.memberId = '',
    this.planId = '',
    this.amount = '',
    this.paidAmount = 0.0,
    this.status = '',
    this.dueDate = '',
    this.submittedDate = '',
    this.approvedDate = '',
    this.paidDate = '',
    this.paymentMethod = '',
    this.receiptImageUrl = '',
    this.notes = '',
    this.approvedById = '',
    this.createdAt = '',
    this.updatedAt = '',
    this.plan = const MembershipPlanMiniEntity(),
    this.discountAmount = 0.0,
  });

  @override
  String toString() {
    return 'FeeHistoryEntity('
        'id: $id, '
        'memberId: $memberId, '
        'planId: $planId, '
        'amount: $amount, '
        'paidAmount: $paidAmount, '
        'status: $status, '
        'dueDate: $dueDate, '
        'submittedDate: $submittedDate, '
        'approvedDate: $approvedDate, '
        'paidDate: $paidDate, '
        'paymentMethod: $paymentMethod, '
        'receiptImageUrl: $receiptImageUrl, '
        'notes: $notes, '
        'approvedById: $approvedById, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt, '
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is FeeHistoryEntity && other.id == id);
  }

  @override
  int get hashCode => id.hashCode;
}

extension FeeHistoryExtension on FeeHistoryEntity {
  FeeStatus get statusEnum => FeeStatus.fromKey(status.toUpperCase());
}
