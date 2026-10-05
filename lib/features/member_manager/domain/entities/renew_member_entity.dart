class FeeRecordEntity {
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
  final String periodStart;
  final String periodEnd;
  final String appliedAt;

  const FeeRecordEntity({
    this.id = '',
    this.memberId = '',
    this.planId = '',
    this.amount = '',
    this.paidAmount = 0,
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
    this.periodStart = '',
    this.periodEnd = '',
    this.appliedAt = '',
  });

  @override
  String toString() {
    return 'FeeRecordEntity('
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
      'periodStart: $periodStart, '
      'periodEnd: $periodEnd, '
      'appliedAt: $appliedAt, '
    ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other is FeeRecordEntity && other.id == id);
  }

  @override
  int get hashCode => id.hashCode;
}

class MemberMiniEntity {
  final String id;
  final String status;
  final String membershipPlanId;
  final String membershipStart;
  final String membershipEnd;

  const MemberMiniEntity({
    this.id = '',
    this.status = '',
    this.membershipPlanId = '',
    this.membershipStart = '',
    this.membershipEnd = '',
  });

  @override
  String toString() {
    return 'MemberMiniEntity('
      'id: $id, '
      'status: $status, '
      'membershipPlanId: $membershipPlanId, '
      'membershipStart: $membershipStart, '
      'membershipEnd: $membershipEnd, '
    ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other is MemberMiniEntity && other.id == id);
  }

  @override
  int get hashCode => id.hashCode;
}

class RenewMemberEntity {
  final FeeRecordEntity feeRecord;
  final MemberMiniEntity member;
  final bool applied;
  final String message;

  const RenewMemberEntity({
    this.feeRecord = const FeeRecordEntity(),
    this.member = const MemberMiniEntity(),
    this.applied = false,
    this.message = '',
  });

  @override
  String toString() {
    return 'RenewMemberEntity('
      'feeRecord: $feeRecord, '
      'member: $member, '
      'applied: $applied, '
      'message: $message, '
    ')';
  }
}

