import 'package:club_fitness/core/utils/utils.dart';

import '../../domain/entities/fees_entity.dart';

class FeesModel extends FeesEntity {
  const FeesModel({
    super.id,
    super.memberId,
    super.memberName,
    super.memberPhone,
    super.memberEmail,
    super.plan,
    super.planId,
    super.amount,
    super.paidAmount,
    super.status,
    super.dueDate,
    super.paidDate,
    super.paymentMethod,
    super.receiptUrl,
    super.notes,
    super.overdueDays,
    super.createdAt,
    super.updatedAt,
  });

  factory FeesModel.fromJson(Map<String, dynamic> json) {
    return FeesModel(
      id: json['id'] as String? ?? '',
      memberId: json['memberId'] as String? ?? '',
      memberName: json['memberName'] as String? ?? '',
      memberPhone: json['memberPhone'] as String? ?? '',
      memberEmail: json['memberEmail'] as String? ?? '',
      plan: json['plan'] as String? ?? '',
      planId: json['planId'] as String? ?? '',
      amount: json['amount'] as num? ?? 0,
      paidAmount: json['paidAmount']?.toString().toNum ?? 0,
      status: json['status'] as String? ?? '',
      dueDate: json['dueDate'] as String? ?? '',
      paidDate: json['paidDate'] as String? ?? '',
      paymentMethod: json['paymentMethod'] as String? ?? '',
      receiptUrl: json['receiptUrl'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      overdueDays: json['overdueDays'] as num? ?? 0,
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
    );
  }

  factory FeesModel.fromEntity(FeesEntity entity) {
    return FeesModel(
      id: entity.id,
      memberId: entity.memberId,
      memberName: entity.memberName,
      memberPhone: entity.memberPhone,
      memberEmail: entity.memberEmail,
      plan: entity.plan,
      planId: entity.planId,
      amount: entity.amount,
      paidAmount: entity.paidAmount,
      status: entity.status,
      dueDate: entity.dueDate,
      paidDate: entity.paidDate,
      paymentMethod: entity.paymentMethod,
      receiptUrl: entity.receiptUrl,
      notes: entity.notes,
      overdueDays: entity.overdueDays,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  FeesModel copyWith({
    String? id,
    String? memberId,
    String? memberName,
    String? memberPhone,
    String? memberEmail,
    String? plan,
    String? planId,
    num? amount,
    num? paidAmount,
    String? status,
    String? dueDate,
    String? paidDate,
    String? paymentMethod,
    String? receiptUrl,
    String? notes,
    num? overdueDays,
    String? createdAt,
    String? updatedAt,
  }) => FeesModel(
    id: id ?? this.id,
    memberId: memberId ?? this.memberId,
    memberName: memberName ?? this.memberName,
    memberPhone: memberPhone ?? this.memberPhone,
    memberEmail: memberEmail ?? this.memberEmail,
    plan: plan ?? this.plan,
    planId: planId ?? this.planId,
    amount: amount ?? this.amount,
    paidAmount: paidAmount ?? this.paidAmount,
    status: status ?? this.status,
    dueDate: dueDate ?? this.dueDate,
    paidDate: paidDate ?? this.paidDate,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    receiptUrl: receiptUrl ?? this.receiptUrl,
    notes: notes ?? this.notes,
    overdueDays: overdueDays ?? this.overdueDays,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'memberId': memberId,
    'memberName': memberName,
    'memberPhone': memberPhone,
    'memberEmail': memberEmail,
    'plan': plan,
    'planId': planId,
    'amount': amount,
    'paidAmount': paidAmount,
    'status': status,
    'dueDate': dueDate,
    'paidDate': paidDate,
    'paymentMethod': paymentMethod,
    'receiptUrl': receiptUrl,
    'notes': notes,
    'overdueDays': overdueDays,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'FeesModel('
        'id: $id, '
        'memberId: $memberId, '
        'memberName: $memberName, '
        'memberPhone: $memberPhone, '
        'memberEmail: $memberEmail, '
        'plan: $plan, '
        'planId: $planId, '
        'amount: $amount, '
        'paidAmount: $paidAmount, '
        'status: $status, '
        'dueDate: $dueDate, '
        'paidDate: $paidDate, '
        'paymentMethod: $paymentMethod, '
        'receiptUrl: $receiptUrl, '
        'notes: $notes, '
        'overdueDays: $overdueDays, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt, '
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other is FeesModel && other.id == id);
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
