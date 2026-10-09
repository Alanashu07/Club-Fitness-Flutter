import 'package:club_fitness/config/theme/theme.dart';
import 'package:club_fitness/core/utils/utils.dart';
import 'package:flutter/material.dart';

import 'admin_utils_entities.dart';

class FeeEntity {
  final String id;
  final String memberId;
  final String memberName;
  final String memberPhone;
  final String memberEmail;
  final String plan;
  final String planId;
  final num amount;
  final num discountAmount;
  final num paidAmount;
  final num balance;
  final String status;
  final String dueDate;
  final String paidDate;
  final String paymentMethod;
  final String receiptUrl;
  final String notes;
  final num overdueDays;
  final bool isRenewal;
  final String periodStart;
  final String periodEnd;
  final bool applied;
  final String renewalGroupId;
  final String approvedById;
  final String approvedDate;
  final String createdAt;
  final String updatedAt;
  final String submittedDate;

  DateTime? get submittedDateTime => DateTime.tryParse(submittedDate);

  const FeeEntity({
    this.id = '',
    this.memberId = '',
    this.memberName = '',
    this.memberPhone = '',
    this.memberEmail = '',
    this.plan = '',
    this.planId = '',
    this.amount = 0,
    this.discountAmount = 0,
    this.paidAmount = 0,
    this.balance = 0,
    this.status = '',
    this.dueDate = '',
    this.paidDate = '',
    this.paymentMethod = '',
    this.receiptUrl = '',
    this.notes = '',
    this.overdueDays = 0,
    this.isRenewal = false,
    this.periodStart = '',
    this.periodEnd = '',
    this.applied = false,
    this.renewalGroupId = '',
    this.approvedById = '',
    this.approvedDate = '',
    this.createdAt = '',
    this.updatedAt = '',
    this.submittedDate = '',
  });

  @override
  String toString() {
    return 'FeeEntity('
        'id: $id, '
        'memberId: $memberId, '
        'memberName: $memberName, '
        'memberPhone: $memberPhone, '
        'memberEmail: $memberEmail, '
        'plan: $plan, '
        'planId: $planId, '
        'amount: $amount, '
        'discountAmount: $discountAmount, '
        'paidAmount: $paidAmount, '
        'balance: $balance, '
        'status: $status, '
        'dueDate: $dueDate, '
        'paidDate: $paidDate, '
        'paymentMethod: $paymentMethod, '
        'receiptUrl: $receiptUrl, '
        'notes: $notes, '
        'overdueDays: $overdueDays, '
        'isRenewal: $isRenewal, '
        'periodStart: $periodStart, '
        'periodEnd: $periodEnd, '
        'applied: $applied, '
        'renewalGroupId: $renewalGroupId, '
        'approvedById: $approvedById, '
        'approvedDate: $approvedDate, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt, '
        'submittedDate: $submittedDate, '
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other is FeeEntity && other.id == id);
  }

  @override
  int get hashCode => id.hashCode;
}

class PlanEntity {
  final String id;
  final String name;
  final num durationDays;
  final num price;
  final String description;
  final List<String> features;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  const PlanEntity({
    this.id = '',
    this.name = '',
    this.durationDays = 0,
    this.price = 0,
    this.description = '',
    this.features = const [],
    this.isActive = false,
    this.createdAt = '',
    this.updatedAt = '',
  });

  @override
  String toString() {
    return 'PlanEntity('
        'id: $id, '
        'name: $name, '
        'durationDays: $durationDays, '
        'price: $price, '
        'description: $description, '
        'features: $features, '
        'isActive: $isActive, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt, '
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other is PlanEntity && other.id == id);
  }

  @override
  int get hashCode => id.hashCode;
}

class MembershipEntity {
  final String planId;
  final PlanEntity plan;
  final bool isRenewal;
  final String periodStart;
  final String periodEnd;
  final bool applied;
  final String appliedAt;
  final bool isCurrentPeriod;
  final String renewalGroupId;

  const MembershipEntity({
    this.planId = '',
    this.plan = const PlanEntity(),
    this.isRenewal = false,
    this.periodStart = '',
    this.periodEnd = '',
    this.applied = false,
    this.appliedAt = '',
    this.isCurrentPeriod = false,
    this.renewalGroupId = '',
  });

  @override
  String toString() {
    return 'MembershipEntity('
        'planId: $planId, '
        'plan: $plan, '
        'isRenewal: $isRenewal, '
        'periodStart: $periodStart, '
        'periodEnd: $periodEnd, '
        'applied: $applied, '
        'appliedAt: $appliedAt, '
        'isCurrentPeriod: $isCurrentPeriod, '
        'renewalGroupId: $renewalGroupId, '
        ')';
  }
}

class RelatedFeeEntity {
  final String id;
  final String memberId;
  final String memberName;
  final String memberPhone;
  final String memberEmail;
  final String plan;
  final String planId;
  final num amount;
  final num discountAmount;
  final num paidAmount;
  final num balance;
  final String status;
  final String dueDate;
  final String paidDate;
  final String paymentMethod;
  final String receiptUrl;
  final String notes;
  final num overdueDays;
  final bool isRenewal;
  final String periodStart;
  final String periodEnd;
  final bool applied;
  final String renewalGroupId;
  final String approvedById;
  final String approvedDate;
  final String createdAt;
  final String updatedAt;

  const RelatedFeeEntity({
    this.id = '',
    this.memberId = '',
    this.memberName = '',
    this.memberPhone = '',
    this.memberEmail = '',
    this.plan = '',
    this.planId = '',
    this.amount = 0,
    this.discountAmount = 0,
    this.paidAmount = 0,
    this.balance = 0,
    this.status = '',
    this.dueDate = '',
    this.paidDate = '',
    this.paymentMethod = '',
    this.receiptUrl = '',
    this.notes = '',
    this.overdueDays = 0,
    this.isRenewal = false,
    this.periodStart = '',
    this.periodEnd = '',
    this.applied = false,
    this.renewalGroupId = '',
    this.approvedById = '',
    this.approvedDate = '',
    this.createdAt = '',
    this.updatedAt = '',
  });

  @override
  String toString() {
    return 'RelatedFeeEntity('
        'id: $id, '
        'memberId: $memberId, '
        'memberName: $memberName, '
        'memberPhone: $memberPhone, '
        'memberEmail: $memberEmail, '
        'plan: $plan, '
        'planId: $planId, '
        'amount: $amount, '
        'discountAmount: $discountAmount, '
        'paidAmount: $paidAmount, '
        'balance: $balance, '
        'status: $status, '
        'dueDate: $dueDate, '
        'paidDate: $paidDate, '
        'paymentMethod: $paymentMethod, '
        'receiptUrl: $receiptUrl, '
        'notes: $notes, '
        'overdueDays: $overdueDays, '
        'isRenewal: $isRenewal, '
        'periodStart: $periodStart, '
        'periodEnd: $periodEnd, '
        'applied: $applied, '
        'renewalGroupId: $renewalGroupId, '
        'approvedById: $approvedById, '
        'approvedDate: $approvedDate, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt, '
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is RelatedFeeEntity && other.id == id);
  }

  @override
  int get hashCode => id.hashCode;
}

class ReminderEntity {
  final String id;
  final String channel;
  final String sentAt;
  final bool automatic;

  const ReminderEntity({
    this.id = '',
    this.channel = '',
    this.sentAt = '',
    this.automatic = false,
  });

  @override
  String toString() {
    return 'ReminderEntity('
        'id: $id, '
        'channel: $channel, '
        'sentAt: $sentAt, '
        'automatic: $automatic, '
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ReminderEntity && other.id == id);
  }

  @override
  int get hashCode => id.hashCode;
}

class ApprovedByEntity {
  final String id;
  final String name;
  final String role;

  const ApprovedByEntity({this.id = '', this.name = '', this.role = ''});

  @override
  String toString() {
    return 'ApprovedByEntity('
        'id: $id, '
        'name: $name, '
        'role: $role, '
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ApprovedByEntity && other.id == id);
  }

  @override
  int get hashCode => id.hashCode;
}

class MemberHistoryEntity {
  final String id;
  final String memberId;
  final String memberName;
  final String memberPhone;
  final String memberEmail;
  final String plan;
  final String planId;
  final num amount;
  final num discountAmount;
  final num paidAmount;
  final num balance;
  final String status;
  final String dueDate;
  final String paidDate;
  final String paymentMethod;
  final String receiptUrl;
  final String notes;
  final num overdueDays;
  final bool isRenewal;
  final String periodStart;
  final String periodEnd;
  final bool applied;
  final String renewalGroupId;
  final String approvedById;
  final String approvedDate;
  final String createdAt;
  final String updatedAt;

  const MemberHistoryEntity({
    this.id = '',
    this.memberId = '',
    this.memberName = '',
    this.memberPhone = '',
    this.memberEmail = '',
    this.plan = '',
    this.planId = '',
    this.amount = 0,
    this.discountAmount = 0,
    this.paidAmount = 0,
    this.balance = 0,
    this.status = '',
    this.dueDate = '',
    this.paidDate = '',
    this.paymentMethod = '',
    this.receiptUrl = '',
    this.notes = '',
    this.overdueDays = 0,
    this.isRenewal = false,
    this.periodStart = '',
    this.periodEnd = '',
    this.applied = false,
    this.renewalGroupId = '',
    this.approvedById = '',
    this.approvedDate = '',
    this.createdAt = '',
    this.updatedAt = '',
  });

  @override
  String toString() {
    return 'MemberHistoryEntity('
        'id: $id, '
        'memberId: $memberId, '
        'memberName: $memberName, '
        'memberPhone: $memberPhone, '
        'memberEmail: $memberEmail, '
        'plan: $plan, '
        'planId: $planId, '
        'amount: $amount, '
        'discountAmount: $discountAmount, '
        'paidAmount: $paidAmount, '
        'balance: $balance, '
        'status: $status, '
        'dueDate: $dueDate, '
        'paidDate: $paidDate, '
        'paymentMethod: $paymentMethod, '
        'receiptUrl: $receiptUrl, '
        'notes: $notes, '
        'overdueDays: $overdueDays, '
        'isRenewal: $isRenewal, '
        'periodStart: $periodStart, '
        'periodEnd: $periodEnd, '
        'applied: $applied, '
        'renewalGroupId: $renewalGroupId, '
        'approvedById: $approvedById, '
        'approvedDate: $approvedDate, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt, '
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is MemberHistoryEntity && other.id == id);
  }

  @override
  int get hashCode => id.hashCode;
}

class FeeDetailEntity {
  final FeeEntity fee;
  final MembershipEntity membership;
  final List<RelatedFeeEntity> relatedFees;
  final List<ReminderEntity> reminders;
  final ApprovedByEntity approvedBy;
  final dynamic offer;
  final List<MemberHistoryEntity> memberHistory;

  const FeeDetailEntity({
    this.fee = const FeeEntity(),
    this.membership = const MembershipEntity(),
    this.relatedFees = const [],
    this.reminders = const [],
    this.approvedBy = const ApprovedByEntity(),
    this.offer = '',
    this.memberHistory = const [],
  });

  @override
  String toString() {
    return 'FeeDetailEntity('
        'fee: $fee, '
        'membership: $membership, '
        'relatedFees: $relatedFees, '
        'reminders: $reminders, '
        'approvedBy: $approvedBy, '
        'offer: $offer, '
        'memberHistory: $memberHistory, '
        ')';
  }
}

extension FeeDetailExtension on FeeDetailEntity {
  Color get memberColor {
    final colors = AppTheme.palette;
    return colors[Randomizer.clampInt(fee.memberId.hashCode, colors.length)];
  }

  String get memberInitials => fee.memberName.twoLetters.toUpperCase();

  FeeStatus get statusEnum => FeeStatus.fromKey(fee.status.toUpperCase());

  PaymentMethod get paymentMethodEnum {
    switch (fee.paymentMethod.toLowerCase()) {
      case 'cash':
        return PaymentMethod.cash;
      case 'bank transfer':
      case 'bank_transfer':
      case 'banktransfer':
        return PaymentMethod.bankTransfer;
      case 'upi':
        return PaymentMethod.upi;
      default:
        return PaymentMethod.other;
    }
  }
}

extension FeeExtension on FeeEntity {
  FeeStatus get statusEnum => FeeStatus.fromKey(status.toUpperCase());
}