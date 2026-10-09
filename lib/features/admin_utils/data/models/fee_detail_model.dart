import '../../domain/entities/fee_detail_entity.dart';

class FeeModel extends FeeEntity {
  const FeeModel({
    super.id,
    super.memberId,
    super.memberName,
    super.memberPhone,
    super.memberEmail,
    super.plan,
    super.planId,
    super.amount,
    super.discountAmount,
    super.paidAmount,
    super.balance,
    super.status,
    super.dueDate,
    super.paidDate,
    super.paymentMethod,
    super.receiptUrl,
    super.notes,
    super.overdueDays,
    super.isRenewal,
    super.periodStart,
    super.periodEnd,
    super.applied,
    super.renewalGroupId,
    super.approvedById,
    super.approvedDate,
    super.createdAt,
    super.updatedAt,
    super.submittedDate,
  });

  factory FeeModel.fromJson(Map<String, dynamic> json) {
    return FeeModel(
      id: json['id'] as String? ?? '',
      memberId: json['memberId'] as String? ?? '',
      memberName: json['memberName'] as String? ?? '',
      memberPhone: json['memberPhone'] as String? ?? '',
      memberEmail: json['memberEmail'] as String? ?? '',
      plan: json['plan'] as String? ?? '',
      planId: json['planId'] as String? ?? '',
      amount: json['amount'] as num? ?? 0,
      discountAmount: json['discountAmount'] as num? ?? 0,
      paidAmount: json['paidAmount'] as num? ?? 0,
      balance: json['balance'] as num? ?? 0,
      status: json['status'] as String? ?? '',
      dueDate: json['dueDate'] as String? ?? '',
      paidDate: json['paidDate'] as String? ?? '',
      paymentMethod: json['paymentMethod'] as String? ?? '',
      receiptUrl: json['receiptUrl'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      overdueDays: json['overdueDays'] as num? ?? 0,
      isRenewal: json['isRenewal'] as bool? ?? false,
      periodStart: json['periodStart'] as String? ?? '',
      periodEnd: json['periodEnd'] as String? ?? '',
      applied: json['applied'] as bool? ?? false,
      renewalGroupId: json['renewalGroupId'] as String? ?? '',
      approvedById: json['approvedById'] as String? ?? '',
      approvedDate: json['approvedDate'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
      submittedDate: json['submittedDate'] as String? ?? '',
    );
  }

  factory FeeModel.fromEntity(FeeEntity entity) {
    return FeeModel(
      id: entity.id,
      memberId: entity.memberId,
      memberName: entity.memberName,
      memberPhone: entity.memberPhone,
      memberEmail: entity.memberEmail,
      plan: entity.plan,
      planId: entity.planId,
      amount: entity.amount,
      discountAmount: entity.discountAmount,
      paidAmount: entity.paidAmount,
      balance: entity.balance,
      status: entity.status,
      dueDate: entity.dueDate,
      paidDate: entity.paidDate,
      paymentMethod: entity.paymentMethod,
      receiptUrl: entity.receiptUrl,
      notes: entity.notes,
      overdueDays: entity.overdueDays,
      isRenewal: entity.isRenewal,
      periodStart: entity.periodStart,
      periodEnd: entity.periodEnd,
      applied: entity.applied,
      renewalGroupId: entity.renewalGroupId,
      approvedById: entity.approvedById,
      approvedDate: entity.approvedDate,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      submittedDate: entity.submittedDate,
    );
  }

  FeeModel copyWith({
    String? id,
    String? memberId,
    String? memberName,
    String? memberPhone,
    String? memberEmail,
    String? plan,
    String? planId,
    num? amount,
    num? discountAmount,
    num? paidAmount,
    num? balance,
    String? status,
    String? dueDate,
    String? paidDate,
    String? paymentMethod,
    String? receiptUrl,
    String? notes,
    num? overdueDays,
    bool? isRenewal,
    String? periodStart,
    String? periodEnd,
    bool? applied,
    String? renewalGroupId,
    String? approvedById,
    String? approvedDate,
    String? createdAt,
    String? updatedAt,
    String? submittedDate,
  }) => FeeModel(
    id: id ?? this.id,
    memberId: memberId ?? this.memberId,
    memberName: memberName ?? this.memberName,
    memberPhone: memberPhone ?? this.memberPhone,
    memberEmail: memberEmail ?? this.memberEmail,
    plan: plan ?? this.plan,
    planId: planId ?? this.planId,
    amount: amount ?? this.amount,
    discountAmount: discountAmount ?? this.discountAmount,
    paidAmount: paidAmount ?? this.paidAmount,
    balance: balance ?? this.balance,
    status: status ?? this.status,
    dueDate: dueDate ?? this.dueDate,
    paidDate: paidDate ?? this.paidDate,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    receiptUrl: receiptUrl ?? this.receiptUrl,
    notes: notes ?? this.notes,
    overdueDays: overdueDays ?? this.overdueDays,
    isRenewal: isRenewal ?? this.isRenewal,
    periodStart: periodStart ?? this.periodStart,
    periodEnd: periodEnd ?? this.periodEnd,
    applied: applied ?? this.applied,
    renewalGroupId: renewalGroupId ?? this.renewalGroupId,
    approvedById: approvedById ?? this.approvedById,
    approvedDate: approvedDate ?? this.approvedDate,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    submittedDate: submittedDate ?? this.submittedDate,
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
    'discountAmount': discountAmount,
    'paidAmount': paidAmount,
    'balance': balance,
    'status': status,
    'dueDate': dueDate,
    'paidDate': paidDate,
    'paymentMethod': paymentMethod,
    'receiptUrl': receiptUrl,
    'notes': notes,
    'overdueDays': overdueDays,
    'isRenewal': isRenewal,
    'periodStart': periodStart,
    'periodEnd': periodEnd,
    'applied': applied,
    'renewalGroupId': renewalGroupId,
    'approvedById': approvedById,
    'approvedDate': approvedDate,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'submittedDate': submittedDate,
  }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'FeeModel('
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
    return identical(this, other) || (other is FeeModel && other.id == id);
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
    if (value is Map) {
      return (value..removeWhere((key, value) => _removeEmpty(value))).isEmpty;
    }
    return false;
  }
}

class PlanModel extends PlanEntity {
  const PlanModel({
    super.id,
    super.name,
    super.durationDays,
    super.price,
    super.description,
    super.features,
    super.isActive,
    super.createdAt,
    super.updatedAt,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      durationDays: json['durationDays'] as num? ?? 0,
      price: json['price'] as num? ?? 0,
      description: json['description'] as String? ?? '',
      features:
          (json['features'] as List?)?.whereType<String>().toList() ?? const [],
      isActive: json['isActive'] as bool? ?? false,
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
    );
  }

  factory PlanModel.fromEntity(PlanEntity entity) {
    return PlanModel(
      id: entity.id,
      name: entity.name,
      durationDays: entity.durationDays,
      price: entity.price,
      description: entity.description,
      features: entity.features,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  PlanModel copyWith({
    String? id,
    String? name,
    num? durationDays,
    num? price,
    String? description,
    List<String>? features,
    bool? isActive,
    String? createdAt,
    String? updatedAt,
  }) => PlanModel(
    id: id ?? this.id,
    name: name ?? this.name,
    durationDays: durationDays ?? this.durationDays,
    price: price ?? this.price,
    description: description ?? this.description,
    features: features ?? this.features,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'durationDays': durationDays,
    'price': price,
    'description': description,
    'features': features,
    'isActive': isActive,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'PlanModel('
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
    return identical(this, other) || (other is PlanModel && other.id == id);
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
    if (value is Map) {
      return (value..removeWhere((key, value) => _removeEmpty(value))).isEmpty;
    }
    return false;
  }
}

class MembershipModel extends MembershipEntity {
  const MembershipModel({
    super.planId,
    super.plan,
    super.isRenewal,
    super.periodStart,
    super.periodEnd,
    super.applied,
    super.appliedAt,
    super.isCurrentPeriod,
    super.renewalGroupId,
  });

  factory MembershipModel.fromJson(Map<String, dynamic> json) {
    return MembershipModel(
      planId: json['planId'] as String? ?? '',
      plan: json['plan'] != null
          ? PlanModel.fromJson(json['plan'])
          : const PlanModel(),
      isRenewal: json['isRenewal'] as bool? ?? false,
      periodStart: json['periodStart'] as String? ?? '',
      periodEnd: json['periodEnd'] as String? ?? '',
      applied: json['applied'] as bool? ?? false,
      appliedAt: json['appliedAt'] as String? ?? '',
      isCurrentPeriod: json['isCurrentPeriod'] as bool? ?? false,
      renewalGroupId: json['renewalGroupId'] as String? ?? '',
    );
  }

  factory MembershipModel.fromEntity(MembershipEntity entity) {
    return MembershipModel(
      planId: entity.planId,
      plan: entity.plan,
      isRenewal: entity.isRenewal,
      periodStart: entity.periodStart,
      periodEnd: entity.periodEnd,
      applied: entity.applied,
      appliedAt: entity.appliedAt,
      isCurrentPeriod: entity.isCurrentPeriod,
      renewalGroupId: entity.renewalGroupId,
    );
  }

  MembershipModel copyWith({
    String? planId,
    PlanModel? plan,
    bool? isRenewal,
    String? periodStart,
    String? periodEnd,
    bool? applied,
    String? appliedAt,
    bool? isCurrentPeriod,
    String? renewalGroupId,
  }) => MembershipModel(
    planId: planId ?? this.planId,
    plan: plan ?? this.plan,
    isRenewal: isRenewal ?? this.isRenewal,
    periodStart: periodStart ?? this.periodStart,
    periodEnd: periodEnd ?? this.periodEnd,
    applied: applied ?? this.applied,
    appliedAt: appliedAt ?? this.appliedAt,
    isCurrentPeriod: isCurrentPeriod ?? this.isCurrentPeriod,
    renewalGroupId: renewalGroupId ?? this.renewalGroupId,
  );

  Map<String, dynamic> toJson() => {
    'planId': planId,
    'plan': PlanModel.fromEntity(plan).toJson(),
    'isRenewal': isRenewal,
    'periodStart': periodStart,
    'periodEnd': periodEnd,
    'applied': applied,
    'appliedAt': appliedAt,
    'isCurrentPeriod': isCurrentPeriod,
    'renewalGroupId': renewalGroupId,
  }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'MembershipModel('
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

  // Helper function to remove empty values
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

class RelatedFeeModel extends RelatedFeeEntity {
  const RelatedFeeModel({
    super.id,
    super.memberId,
    super.memberName,
    super.memberPhone,
    super.memberEmail,
    super.plan,
    super.planId,
    super.amount,
    super.discountAmount,
    super.paidAmount,
    super.balance,
    super.status,
    super.dueDate,
    super.paidDate,
    super.paymentMethod,
    super.receiptUrl,
    super.notes,
    super.overdueDays,
    super.isRenewal,
    super.periodStart,
    super.periodEnd,
    super.applied,
    super.renewalGroupId,
    super.approvedById,
    super.approvedDate,
    super.createdAt,
    super.updatedAt,
  });

  factory RelatedFeeModel.fromJson(Map<String, dynamic> json) {
    return RelatedFeeModel(
      id: json['id'] as String? ?? '',
      memberId: json['memberId'] as String? ?? '',
      memberName: json['memberName'] as String? ?? '',
      memberPhone: json['memberPhone'] as String? ?? '',
      memberEmail: json['memberEmail'] as String? ?? '',
      plan: json['plan'] as String? ?? '',
      planId: json['planId'] as String? ?? '',
      amount: json['amount'] as num? ?? 0,
      discountAmount: json['discountAmount'] as num? ?? 0,
      paidAmount: json['paidAmount'] as num? ?? 0,
      balance: json['balance'] as num? ?? 0,
      status: json['status'] as String? ?? '',
      dueDate: json['dueDate'] as String? ?? '',
      paidDate: json['paidDate'] as String? ?? '',
      paymentMethod: json['paymentMethod'] as String? ?? '',
      receiptUrl: json['receiptUrl'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      overdueDays: json['overdueDays'] as num? ?? 0,
      isRenewal: json['isRenewal'] as bool? ?? false,
      periodStart: json['periodStart'] as String? ?? '',
      periodEnd: json['periodEnd'] as String? ?? '',
      applied: json['applied'] as bool? ?? false,
      renewalGroupId: json['renewalGroupId'] as String? ?? '',
      approvedById: json['approvedById'] as String? ?? '',
      approvedDate: json['approvedDate'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
    );
  }

  factory RelatedFeeModel.fromEntity(RelatedFeeEntity entity) {
    return RelatedFeeModel(
      id: entity.id,
      memberId: entity.memberId,
      memberName: entity.memberName,
      memberPhone: entity.memberPhone,
      memberEmail: entity.memberEmail,
      plan: entity.plan,
      planId: entity.planId,
      amount: entity.amount,
      discountAmount: entity.discountAmount,
      paidAmount: entity.paidAmount,
      balance: entity.balance,
      status: entity.status,
      dueDate: entity.dueDate,
      paidDate: entity.paidDate,
      paymentMethod: entity.paymentMethod,
      receiptUrl: entity.receiptUrl,
      notes: entity.notes,
      overdueDays: entity.overdueDays,
      isRenewal: entity.isRenewal,
      periodStart: entity.periodStart,
      periodEnd: entity.periodEnd,
      applied: entity.applied,
      renewalGroupId: entity.renewalGroupId,
      approvedById: entity.approvedById,
      approvedDate: entity.approvedDate,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  RelatedFeeModel copyWith({
    String? id,
    String? memberId,
    String? memberName,
    String? memberPhone,
    String? memberEmail,
    String? plan,
    String? planId,
    num? amount,
    num? discountAmount,
    num? paidAmount,
    num? balance,
    String? status,
    String? dueDate,
    String? paidDate,
    String? paymentMethod,
    String? receiptUrl,
    String? notes,
    num? overdueDays,
    bool? isRenewal,
    String? periodStart,
    String? periodEnd,
    bool? applied,
    String? renewalGroupId,
    String? approvedById,
    String? approvedDate,
    String? createdAt,
    String? updatedAt,
  }) => RelatedFeeModel(
    id: id ?? this.id,
    memberId: memberId ?? this.memberId,
    memberName: memberName ?? this.memberName,
    memberPhone: memberPhone ?? this.memberPhone,
    memberEmail: memberEmail ?? this.memberEmail,
    plan: plan ?? this.plan,
    planId: planId ?? this.planId,
    amount: amount ?? this.amount,
    discountAmount: discountAmount ?? this.discountAmount,
    paidAmount: paidAmount ?? this.paidAmount,
    balance: balance ?? this.balance,
    status: status ?? this.status,
    dueDate: dueDate ?? this.dueDate,
    paidDate: paidDate ?? this.paidDate,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    receiptUrl: receiptUrl ?? this.receiptUrl,
    notes: notes ?? this.notes,
    overdueDays: overdueDays ?? this.overdueDays,
    isRenewal: isRenewal ?? this.isRenewal,
    periodStart: periodStart ?? this.periodStart,
    periodEnd: periodEnd ?? this.periodEnd,
    applied: applied ?? this.applied,
    renewalGroupId: renewalGroupId ?? this.renewalGroupId,
    approvedById: approvedById ?? this.approvedById,
    approvedDate: approvedDate ?? this.approvedDate,
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
    'discountAmount': discountAmount,
    'paidAmount': paidAmount,
    'balance': balance,
    'status': status,
    'dueDate': dueDate,
    'paidDate': paidDate,
    'paymentMethod': paymentMethod,
    'receiptUrl': receiptUrl,
    'notes': notes,
    'overdueDays': overdueDays,
    'isRenewal': isRenewal,
    'periodStart': periodStart,
    'periodEnd': periodEnd,
    'applied': applied,
    'renewalGroupId': renewalGroupId,
    'approvedById': approvedById,
    'approvedDate': approvedDate,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'RelatedFeeModel('
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
        (other is RelatedFeeModel && other.id == id);
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
    if (value is Map) {
      return (value..removeWhere((key, value) => _removeEmpty(value))).isEmpty;
    }
    return false;
  }
}

class ReminderModel extends ReminderEntity {
  const ReminderModel({super.id, super.channel, super.sentAt, super.automatic});

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['id'] as String? ?? '',
      channel: json['channel'] as String? ?? '',
      sentAt: json['sentAt'] as String? ?? '',
      automatic: json['automatic'] as bool? ?? false,
    );
  }

  factory ReminderModel.fromEntity(ReminderEntity entity) {
    return ReminderModel(
      id: entity.id,
      channel: entity.channel,
      sentAt: entity.sentAt,
      automatic: entity.automatic,
    );
  }

  ReminderModel copyWith({
    String? id,
    String? channel,
    String? sentAt,
    bool? automatic,
  }) => ReminderModel(
    id: id ?? this.id,
    channel: channel ?? this.channel,
    sentAt: sentAt ?? this.sentAt,
    automatic: automatic ?? this.automatic,
  );

  Map<String, dynamic> toJson() =>
      {'id': id, 'channel': channel, 'sentAt': sentAt, 'automatic': automatic}
        ..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'ReminderModel('
        'id: $id, '
        'channel: $channel, '
        'sentAt: $sentAt, '
        'automatic: $automatic, '
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other is ReminderModel && other.id == id);
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
    if (value is Map) {
      return (value..removeWhere((key, value) => _removeEmpty(value))).isEmpty;
    }
    return false;
  }
}

class ApprovedByModel extends ApprovedByEntity {
  const ApprovedByModel({super.id, super.name, super.role});

  factory ApprovedByModel.fromJson(Map<String, dynamic> json) {
    return ApprovedByModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? '',
    );
  }

  factory ApprovedByModel.fromEntity(ApprovedByEntity entity) {
    return ApprovedByModel(id: entity.id, name: entity.name, role: entity.role);
  }

  ApprovedByModel copyWith({String? id, String? name, String? role}) =>
      ApprovedByModel(
        id: id ?? this.id,
        name: name ?? this.name,
        role: role ?? this.role,
      );

  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name, 'role': role}
        ..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'ApprovedByModel('
        'id: $id, '
        'name: $name, '
        'role: $role, '
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ApprovedByModel && other.id == id);
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
    if (value is Map) {
      return (value..removeWhere((key, value) => _removeEmpty(value))).isEmpty;
    }
    return false;
  }
}

class MemberHistoryModel extends MemberHistoryEntity {
  const MemberHistoryModel({
    super.id,
    super.memberId,
    super.memberName,
    super.memberPhone,
    super.memberEmail,
    super.plan,
    super.planId,
    super.amount,
    super.discountAmount,
    super.paidAmount,
    super.balance,
    super.status,
    super.dueDate,
    super.paidDate,
    super.paymentMethod,
    super.receiptUrl,
    super.notes,
    super.overdueDays,
    super.isRenewal,
    super.periodStart,
    super.periodEnd,
    super.applied,
    super.renewalGroupId,
    super.approvedById,
    super.approvedDate,
    super.createdAt,
    super.updatedAt,
  });

  factory MemberHistoryModel.fromJson(Map<String, dynamic> json) {
    return MemberHistoryModel(
      id: json['id'] as String? ?? '',
      memberId: json['memberId'] as String? ?? '',
      memberName: json['memberName'] as String? ?? '',
      memberPhone: json['memberPhone'] as String? ?? '',
      memberEmail: json['memberEmail'] as String? ?? '',
      plan: json['plan'] as String? ?? '',
      planId: json['planId'] as String? ?? '',
      amount: json['amount'] as num? ?? 0,
      discountAmount: json['discountAmount'] as num? ?? 0,
      paidAmount: json['paidAmount'] as num? ?? 0,
      balance: json['balance'] as num? ?? 0,
      status: json['status'] as String? ?? '',
      dueDate: json['dueDate'] as String? ?? '',
      paidDate: json['paidDate'] as String? ?? '',
      paymentMethod: json['paymentMethod'] as String? ?? '',
      receiptUrl: json['receiptUrl'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      overdueDays: json['overdueDays'] as num? ?? 0,
      isRenewal: json['isRenewal'] as bool? ?? false,
      periodStart: json['periodStart'] as String? ?? '',
      periodEnd: json['periodEnd'] as String? ?? '',
      applied: json['applied'] as bool? ?? false,
      renewalGroupId: json['renewalGroupId'] as String? ?? '',
      approvedById: json['approvedById'] as String? ?? '',
      approvedDate: json['approvedDate'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
    );
  }

  factory MemberHistoryModel.fromEntity(MemberHistoryEntity entity) {
    return MemberHistoryModel(
      id: entity.id,
      memberId: entity.memberId,
      memberName: entity.memberName,
      memberPhone: entity.memberPhone,
      memberEmail: entity.memberEmail,
      plan: entity.plan,
      planId: entity.planId,
      amount: entity.amount,
      discountAmount: entity.discountAmount,
      paidAmount: entity.paidAmount,
      balance: entity.balance,
      status: entity.status,
      dueDate: entity.dueDate,
      paidDate: entity.paidDate,
      paymentMethod: entity.paymentMethod,
      receiptUrl: entity.receiptUrl,
      notes: entity.notes,
      overdueDays: entity.overdueDays,
      isRenewal: entity.isRenewal,
      periodStart: entity.periodStart,
      periodEnd: entity.periodEnd,
      applied: entity.applied,
      renewalGroupId: entity.renewalGroupId,
      approvedById: entity.approvedById,
      approvedDate: entity.approvedDate,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  MemberHistoryModel copyWith({
    String? id,
    String? memberId,
    String? memberName,
    String? memberPhone,
    String? memberEmail,
    String? plan,
    String? planId,
    num? amount,
    num? discountAmount,
    num? paidAmount,
    num? balance,
    String? status,
    String? dueDate,
    String? paidDate,
    String? paymentMethod,
    String? receiptUrl,
    String? notes,
    num? overdueDays,
    bool? isRenewal,
    String? periodStart,
    String? periodEnd,
    bool? applied,
    String? renewalGroupId,
    String? approvedById,
    String? approvedDate,
    String? createdAt,
    String? updatedAt,
  }) => MemberHistoryModel(
    id: id ?? this.id,
    memberId: memberId ?? this.memberId,
    memberName: memberName ?? this.memberName,
    memberPhone: memberPhone ?? this.memberPhone,
    memberEmail: memberEmail ?? this.memberEmail,
    plan: plan ?? this.plan,
    planId: planId ?? this.planId,
    amount: amount ?? this.amount,
    discountAmount: discountAmount ?? this.discountAmount,
    paidAmount: paidAmount ?? this.paidAmount,
    balance: balance ?? this.balance,
    status: status ?? this.status,
    dueDate: dueDate ?? this.dueDate,
    paidDate: paidDate ?? this.paidDate,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    receiptUrl: receiptUrl ?? this.receiptUrl,
    notes: notes ?? this.notes,
    overdueDays: overdueDays ?? this.overdueDays,
    isRenewal: isRenewal ?? this.isRenewal,
    periodStart: periodStart ?? this.periodStart,
    periodEnd: periodEnd ?? this.periodEnd,
    applied: applied ?? this.applied,
    renewalGroupId: renewalGroupId ?? this.renewalGroupId,
    approvedById: approvedById ?? this.approvedById,
    approvedDate: approvedDate ?? this.approvedDate,
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
    'discountAmount': discountAmount,
    'paidAmount': paidAmount,
    'balance': balance,
    'status': status,
    'dueDate': dueDate,
    'paidDate': paidDate,
    'paymentMethod': paymentMethod,
    'receiptUrl': receiptUrl,
    'notes': notes,
    'overdueDays': overdueDays,
    'isRenewal': isRenewal,
    'periodStart': periodStart,
    'periodEnd': periodEnd,
    'applied': applied,
    'renewalGroupId': renewalGroupId,
    'approvedById': approvedById,
    'approvedDate': approvedDate,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'MemberHistoryModel('
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
        (other is MemberHistoryModel && other.id == id);
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
    if (value is Map) {
      return (value..removeWhere((key, value) => _removeEmpty(value))).isEmpty;
    }
    return false;
  }
}

class FeeDetailModel extends FeeDetailEntity {
  const FeeDetailModel({
    super.fee,
    super.membership,
    super.relatedFees,
    super.reminders,
    super.approvedBy,
    super.offer,
    super.memberHistory,
  });

  factory FeeDetailModel.fromJson(Map<String, dynamic> json) {
    return FeeDetailModel(
      fee: json['fee'] != null
          ? FeeModel.fromJson(json['fee'])
          : const FeeModel(),
      membership: json['membership'] != null
          ? MembershipModel.fromJson(json['membership'])
          : const MembershipModel(),
      relatedFees:
          (json['relatedFees'] as List?)
              ?.map((e) => RelatedFeeModel.fromJson(e))
              .toList() ??
          const [],
      reminders:
          (json['reminders'] as List?)
              ?.map((e) => ReminderModel.fromJson(e))
              .toList() ??
          const [],
      approvedBy: json['approvedBy'] != null
          ? ApprovedByModel.fromJson(json['approvedBy'])
          : const ApprovedByModel(),
      offer: json['offer'] ?? '',
      memberHistory:
          (json['memberHistory'] as List?)
              ?.map((e) => MemberHistoryModel.fromJson(e))
              .toList() ??
          const [],
    );
  }

  factory FeeDetailModel.fromEntity(FeeDetailEntity entity) {
    return FeeDetailModel(
      fee: entity.fee,
      membership: entity.membership,
      relatedFees: entity.relatedFees,
      reminders: entity.reminders,
      approvedBy: entity.approvedBy,
      offer: entity.offer,
      memberHistory: entity.memberHistory,
    );
  }

  FeeDetailModel copyWith({
    FeeModel? fee,
    MembershipModel? membership,
    List<RelatedFeeModel>? relatedFees,
    List<ReminderModel>? reminders,
    ApprovedByModel? approvedBy,
    dynamic offer,
    List<MemberHistoryModel>? memberHistory,
  }) => FeeDetailModel(
    fee: fee ?? this.fee,
    membership: membership ?? this.membership,
    relatedFees: relatedFees ?? this.relatedFees,
    reminders: reminders ?? this.reminders,
    approvedBy: approvedBy ?? this.approvedBy,
    offer: offer ?? this.offer,
    memberHistory: memberHistory ?? this.memberHistory,
  );

  Map<String, dynamic> toJson() => {
    'fee': FeeModel.fromEntity(fee).toJson(),
    'membership': MembershipModel.fromEntity(membership).toJson(),
    'relatedFees': relatedFees
        .map((e) => RelatedFeeModel.fromEntity(e).toJson())
        .toList(),
    'reminders': reminders
        .map((e) => ReminderModel.fromEntity(e).toJson())
        .toList(),
    'approvedBy': ApprovedByModel.fromEntity(approvedBy).toJson(),
    'offer': offer,
    'memberHistory': memberHistory
        .map((e) => MemberHistoryModel.fromEntity(e).toJson())
        .toList(),
  }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'FeeDetailModel('
        'fee: $fee, '
        'membership: $membership, '
        'relatedFees: $relatedFees, '
        'reminders: $reminders, '
        'approvedBy: $approvedBy, '
        'offer: $offer, '
        'memberHistory: $memberHistory, '
        ')';
  }

  // Helper function to remove empty values
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
