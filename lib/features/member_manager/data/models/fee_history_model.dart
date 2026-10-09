import 'package:club_fitness/core/utils/utils.dart';

import '../../domain/entities/fee_history_entity.dart';
import 'member_manager_models.dart';

class FeeHistoryModel extends FeeHistoryEntity {
  const FeeHistoryModel({
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
    super.plan,
    super.discountAmount
  });

  factory FeeHistoryModel.fromJson(Map<String, dynamic> json) {
    return FeeHistoryModel(
      id: json['id'] as String? ?? '',
      memberId: json['memberId'] as String? ?? '',
      planId: json['planId'] as String? ?? '',
      amount: json['amount'] as String? ?? '',
      paidAmount: json['paidAmount']?.toString().toNum ?? 0.0,
      status: json['status'] as String? ?? '',
      dueDate: json['dueDate'] as String? ?? '',
      submittedDate: json['submittedDate']?.toString() ?? '',
      approvedDate: json['approvedDate']?.toString() ?? '',
      paidDate: json['paidDate']?.toString() ?? '',
      paymentMethod: json['paymentMethod']?.toString() ?? '',
      receiptImageUrl: json['receiptImageUrl']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      approvedById: json['approvedById']?.toString() ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
      plan: MembershipPlanMiniModel.fromJson(json['plan'] ?? {}),
      discountAmount: json['discountAmount']?.toString().toNum ?? 0.0
    );
  }

  factory FeeHistoryModel.fromEntity(FeeHistoryEntity entity) {
    return FeeHistoryModel(
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
      plan: MembershipPlanMiniModel.fromEntity(entity.plan),
      discountAmount: entity.discountAmount
    );
  }

  FeeHistoryModel copyWith({
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
    MembershipPlanMiniModel? plan,
    num? discountAmount
  }) => FeeHistoryModel(
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
    plan: plan ?? this.plan,
    discountAmount: discountAmount ?? this.discountAmount
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
    'plan': MembershipPlanMiniModel.fromEntity(plan).toJson(),
    'discountAmount': discountAmount
  }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'FeeHistoryModel('
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
        (other is FeeHistoryModel && other.id == id);
  }

  @override
  int get hashCode => id.hashCode;

  // Helper function to remove empty or default values from JSON
  bool _removeEmpty(dynamic value) {
    if (value == null) return true;
    if (value is num) return value == 0;
    if (value is String) return value.isEmpty;
    if (value is List) return value.isEmpty;
    if (value is bool) return !value;
    if (value is Map) {
      return (value..removeWhere((key, value) => _removeEmpty(value))).isEmpty;
    }
    return false;
  }
}
