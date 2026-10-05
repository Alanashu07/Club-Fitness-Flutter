import 'package:club_fitness/core/utils/utils.dart';

import '../../domain/entities/renew_member_entity.dart';

class FeeRecordModel extends FeeRecordEntity {
  const FeeRecordModel({
    super.id,
    super.memberId,
    super.planId,
    super.amount,
    super.paidAmount,
    super.status,
    super.dueDate,
    super.submittedDate,
    super.approvedDate,
    super.paidDate,
    super.paymentMethod,
    super.receiptImageUrl,
    super.notes,
    super.approvedById,
    super.createdAt,
    super.updatedAt,
    super.periodStart,
    super.periodEnd,
    super.appliedAt,
  });

  factory FeeRecordModel.fromJson(Map<String, dynamic> json) {
    return FeeRecordModel(
      id: json['id'] as String? ?? '',
      memberId: json['memberId'] as String? ?? '',
      planId: json['planId'] as String? ?? '',
      amount: json['amount'] as String? ?? '',
      paidAmount: json['paidAmount']?.toString().toNum ?? 0,
      status: json['status'] as String? ?? '',
      dueDate: json['dueDate'] as String? ?? '',
      submittedDate: json['submittedDate']?.toString() ?? '',
      approvedDate: json['approvedDate']?.toString() ?? '',
      paidDate: json['paidDate']?.toString() ?? '',
      paymentMethod: json['paymentMethod']?.toString() ?? '',
      receiptImageUrl: json['receiptImageUrl']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      approvedById: json['approvedById'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
      periodStart: json['periodStart'] as String? ?? '',
      periodEnd: json['periodEnd'] as String? ?? '',
      appliedAt: json['appliedAt'] as String? ?? '',
    );
  }

  factory FeeRecordModel.fromEntity(FeeRecordEntity entity) {
    return FeeRecordModel(
      id: entity.id,
      memberId: entity.memberId,
      planId: entity.planId,
      amount: entity.amount,
      paidAmount: entity.paidAmount,
      status: entity.status,
      dueDate: entity.dueDate,
      submittedDate: entity.submittedDate,
      approvedDate: entity.approvedDate,
      paidDate: entity.paidDate,
      paymentMethod: entity.paymentMethod,
      receiptImageUrl: entity.receiptImageUrl,
      notes: entity.notes,
      approvedById: entity.approvedById,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      periodStart: entity.periodStart,
      periodEnd: entity.periodEnd,
      appliedAt: entity.appliedAt,
    );
  }

  FeeRecordModel copyWith({
    String? id,
    String? memberId,
    String? planId,
    String? amount,
    num? paidAmount,
    String? status,
    String? dueDate,
    String? submittedDate,
    String? approvedDate,
    String? paidDate,
    String? paymentMethod,
    String? receiptImageUrl,
    String? notes,
    String? approvedById,
    String? createdAt,
    String? updatedAt,
    String? periodStart,
    String? periodEnd,
    String? appliedAt,
  }) => FeeRecordModel(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      planId: planId ?? this.planId,
      amount: amount ?? this.amount,
      paidAmount: paidAmount ?? this.paidAmount,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      submittedDate: submittedDate ?? this.submittedDate,
      approvedDate: approvedDate ?? this.approvedDate,
      paidDate: paidDate ?? this.paidDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      receiptImageUrl: receiptImageUrl ?? this.receiptImageUrl,
      notes: notes ?? this.notes,
      approvedById: approvedById ?? this.approvedById,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      appliedAt: appliedAt ?? this.appliedAt,
  );

  Map<String, dynamic> toJson() => {
        'id': id,
        'memberId': memberId,
        'planId': planId,
        'amount': amount,
        'paidAmount': paidAmount,
        'status': status,
        'dueDate': dueDate,
        'submittedDate': submittedDate,
        'approvedDate': approvedDate,
        'paidDate': paidDate,
        'paymentMethod': paymentMethod,
        'receiptImageUrl': receiptImageUrl,
        'notes': notes,
        'approvedById': approvedById,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'periodStart': periodStart,
        'periodEnd': periodEnd,
        'appliedAt': appliedAt,
      }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'FeeRecordModel('
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
    return identical(this, other) || (other is FeeRecordModel && other.id == id);
  }

  @override
  int get hashCode => id.hashCode;

  // Helper function to remove empty values
  bool _removeEmpty(dynamic value) {
    if (value == null) return true;
    if (value is num) return value == 0;
    if (value is String) return value.isEmpty;
    if (value is List) return value.isEmpty;
    if (value is bool) return !value;
    if (value is Map) {return (value..removeWhere((key, value) => _removeEmpty(value),)).isEmpty;}
    return false;
  }
}

class MemberMiniModel extends MemberMiniEntity {
  const MemberMiniModel({
    super.id,
    super.status,
    super.membershipPlanId,
    super.membershipStart,
    super.membershipEnd,
  });

  factory MemberMiniModel.fromJson(Map<String, dynamic> json) {
    return MemberMiniModel(
      id: json['id'] as String? ?? '',
      status: json['status'] as String? ?? '',
      membershipPlanId: json['membershipPlanId'] as String? ?? '',
      membershipStart: json['membershipStart'] as String? ?? '',
      membershipEnd: json['membershipEnd'] as String? ?? '',
    );
  }

  factory MemberMiniModel.fromEntity(MemberMiniEntity entity) {
    return MemberMiniModel(
      id: entity.id,
      status: entity.status,
      membershipPlanId: entity.membershipPlanId,
      membershipStart: entity.membershipStart,
      membershipEnd: entity.membershipEnd,
    );
  }

  MemberMiniModel copyWith({
    String? id,
    String? status,
    String? membershipPlanId,
    String? membershipStart,
    String? membershipEnd,
  }) => MemberMiniModel(
      id: id ?? this.id,
      status: status ?? this.status,
      membershipPlanId: membershipPlanId ?? this.membershipPlanId,
      membershipStart: membershipStart ?? this.membershipStart,
      membershipEnd: membershipEnd ?? this.membershipEnd,
  );

  Map<String, dynamic> toJson() => {
        'id': id,
        'status': status,
        'membershipPlanId': membershipPlanId,
        'membershipStart': membershipStart,
        'membershipEnd': membershipEnd,
      }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'MemberMiniModel('
      'id: $id, '
      'status: $status, '
      'membershipPlanId: $membershipPlanId, '
      'membershipStart: $membershipStart, '
      'membershipEnd: $membershipEnd, '
    ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other is MemberMiniModel && other.id == id);
  }

  @override
  int get hashCode => id.hashCode;

  // Helper function to remove empty values
  bool _removeEmpty(dynamic value) {
    if (value == null) return true;
    if (value is num) return value == 0;
    if (value is String) return value.isEmpty;
    if (value is List) return value.isEmpty;
    if (value is bool) return !value;
    if (value is Map) {return (value..removeWhere((key, value) => _removeEmpty(value),)).isEmpty;}
    return false;
  }
}

class RenewMemberModel extends RenewMemberEntity {
  const RenewMemberModel({
    super.feeRecord,
    super.member,
    super.applied,
    super.message,
  });

  factory RenewMemberModel.fromJson(Map<String, dynamic> json) {
    return RenewMemberModel(
      feeRecord: json['feeRecord'] != null ? FeeRecordModel.fromJson(json['feeRecord']) : const FeeRecordModel(),
      member: json['member'] != null ? MemberMiniModel.fromJson(json['member']) : const MemberMiniModel(),
      applied: json['applied'] as bool? ?? false,
      message: json['message'] as String? ?? '',
    );
  }

  factory RenewMemberModel.fromEntity(RenewMemberEntity entity) {
    return RenewMemberModel(
      feeRecord: entity.feeRecord,
      member: entity.member,
      applied: entity.applied,
      message: entity.message,
    );
  }

  RenewMemberModel copyWith({
    FeeRecordModel? feeRecord,
    MemberMiniModel? member,
    bool? applied,
    String? message,
  }) => RenewMemberModel(
      feeRecord: feeRecord ?? this.feeRecord,
      member: member ?? this.member,
      applied: applied ?? this.applied,
      message: message ?? this.message,
  );

  Map<String, dynamic> toJson() => {
        'feeRecord': FeeRecordModel.fromEntity(feeRecord).toJson(),
        'member': MemberMiniModel.fromEntity(member).toJson(),
        'applied': applied,
        'message': message,
      }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'RenewMemberModel('
      'feeRecord: $feeRecord, '
      'member: $member, '
      'applied: $applied, '
      'message: $message, '
    ')';
  }

  // Helper function to remove empty values
  bool _removeEmpty(dynamic value) {
    if (value == null) return true;
    if (value is num) return value == 0;
    if (value is String) return value.isEmpty;
    if (value is List) return value.isEmpty;
    if (value is bool) return !value;
    if (value is Map) {return (value..removeWhere((key, value) => _removeEmpty(value),)).isEmpty;}
    return false;
  }
}

