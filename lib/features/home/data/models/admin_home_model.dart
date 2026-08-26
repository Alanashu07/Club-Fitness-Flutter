import '../../domain/entities/admin_home_entity.dart';

class OverviewModel extends OverviewEntity {
  const OverviewModel({
    super.totalMembers,
    super.newMembersThisMonth,
    super.activeMembers,
    super.todayCheckIns,
    super.activeTodayPercent,
    super.pendingFeesCount,
    super.outstandingAmount,
    super.ordersToday,
    super.ordersReadyToday,
  });

  factory OverviewModel.fromJson(Map<String, dynamic> json) {
    return OverviewModel(
      totalMembers: json['totalMembers'] as num? ?? 0,
      newMembersThisMonth: json['newMembersThisMonth'] as num? ?? 0,
      activeMembers: json['activeMembers'] as num? ?? 0,
      todayCheckIns: json['todayCheckIns'] as num? ?? 0,
      activeTodayPercent: json['activeTodayPercent'] as num? ?? 0,
      pendingFeesCount: json['pendingFeesCount'] as num? ?? 0,
      outstandingAmount: json['outstandingAmount'] as num? ?? 0,
      ordersToday: json['ordersToday'] as num? ?? 0,
      ordersReadyToday: json['ordersReadyToday'] as num? ?? 0,
    );
  }

  factory OverviewModel.fromEntity(OverviewEntity entity) {
    return OverviewModel(
      totalMembers: entity.totalMembers,
      newMembersThisMonth: entity.newMembersThisMonth,
      activeMembers: entity.activeMembers,
      todayCheckIns: entity.todayCheckIns,
      activeTodayPercent: entity.activeTodayPercent,
      pendingFeesCount: entity.pendingFeesCount,
      outstandingAmount: entity.outstandingAmount,
      ordersToday: entity.ordersToday,
      ordersReadyToday: entity.ordersReadyToday,
    );
  }

  OverviewModel copyWith({
    num? totalMembers,
    num? newMembersThisMonth,
    num? activeMembers,
    num? todayCheckIns,
    num? activeTodayPercent,
    num? pendingFeesCount,
    num? outstandingAmount,
    num? ordersToday,
    num? ordersReadyToday,
  }) => OverviewModel(
      totalMembers: totalMembers ?? this.totalMembers,
      newMembersThisMonth: newMembersThisMonth ?? this.newMembersThisMonth,
      activeMembers: activeMembers ?? this.activeMembers,
      todayCheckIns: todayCheckIns ?? this.todayCheckIns,
      activeTodayPercent: activeTodayPercent ?? this.activeTodayPercent,
      pendingFeesCount: pendingFeesCount ?? this.pendingFeesCount,
      outstandingAmount: outstandingAmount ?? this.outstandingAmount,
      ordersToday: ordersToday ?? this.ordersToday,
      ordersReadyToday: ordersReadyToday ?? this.ordersReadyToday,
  );

  Map<String, dynamic> toJson() => {
        'totalMembers': totalMembers,
        'newMembersThisMonth': newMembersThisMonth,
        'activeMembers': activeMembers,
        'todayCheckIns': todayCheckIns,
        'activeTodayPercent': activeTodayPercent,
        'pendingFeesCount': pendingFeesCount,
        'outstandingAmount': outstandingAmount,
        'ordersToday': ordersToday,
        'ordersReadyToday': ordersReadyToday,
      }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'OverviewModel('
      'totalMembers: $totalMembers, '
      'newMembersThisMonth: $newMembersThisMonth, '
      'activeMembers: $activeMembers, '
      'todayCheckIns: $todayCheckIns, '
      'activeTodayPercent: $activeTodayPercent, '
      'pendingFeesCount: $pendingFeesCount, '
      'outstandingAmount: $outstandingAmount, '
      'ordersToday: $ordersToday, '
      'ordersReadyToday: $ordersReadyToday, '
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

class MonthlModel extends MonthlEntity {
  const MonthlModel({
    super.label,
    super.total,
  });

  factory MonthlModel.fromJson(Map<String, dynamic> json) {
    return MonthlModel(
      label: json['label'] as String? ?? '',
      total: json['total'] as num? ?? 0,
    );
  }

  factory MonthlModel.fromEntity(MonthlEntity entity) {
    return MonthlModel(
      label: entity.label,
      total: entity.total,
    );
  }

  MonthlModel copyWith({
    String? label,
    num? total,
  }) => MonthlModel(
      label: label ?? this.label,
      total: total ?? this.total,
  );

  Map<String, dynamic> toJson() => {
        'label': label,
        'total': total,
      }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'MonthlModel('
      'label: $label, '
      'total: $total, '
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

class ByPlaModel extends ByPlaEntity {
  const ByPlaModel({
    super.label,
    super.amount,
    super.fraction,
  });

  factory ByPlaModel.fromJson(Map<String, dynamic> json) {
    return ByPlaModel(
      label: json['label'] as String? ?? '',
      amount: json['amount'] as num? ?? 0,
      fraction: json['fraction'] as num? ?? 0,
    );
  }

  factory ByPlaModel.fromEntity(ByPlaEntity entity) {
    return ByPlaModel(
      label: entity.label,
      amount: entity.amount,
      fraction: entity.fraction,
    );
  }

  ByPlaModel copyWith({
    String? label,
    num? amount,
    num? fraction,
  }) => ByPlaModel(
      label: label ?? this.label,
      amount: amount ?? this.amount,
      fraction: fraction ?? this.fraction,
  );

  Map<String, dynamic> toJson() => {
        'label': label,
        'amount': amount,
        'fraction': fraction,
      }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'ByPlaModel('
      'label: $label, '
      'amount: $amount, '
      'fraction: $fraction, '
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

class RevenueModel extends RevenueEntity {
  const RevenueModel({
    super.thisMonth,
    super.thisMonthChangePct,
    super.lastMonth,
    super.lastMonthChangePct,
    super.overdueAmount,
    super.overdueMemberCount,
    super.monthly,
    super.last7Days,
    super.byPlan,
  });

  factory RevenueModel.fromJson(Map<String, dynamic> json) {
    return RevenueModel(
      thisMonth: json['thisMonth'] as num? ?? 0,
      thisMonthChangePct: json['thisMonthChangePct'] as num? ?? 0,
      lastMonth: json['lastMonth'] as num? ?? 0,
      lastMonthChangePct: json['lastMonthChangePct'] as num? ?? 0,
      overdueAmount: json['overdueAmount'] as num? ?? 0,
      overdueMemberCount: json['overdueMemberCount'] as num? ?? 0,
      monthly: (json['monthly'] as List?)?.map((e) => MonthlModel.fromJson(e)).toList() ?? const [],
      last7Days: (json['last7Days'] as List?)?.cast<num>() ?? const [],
      byPlan: (json['byPlan'] as List?)?.map((e) => ByPlaModel.fromJson(e)).toList() ?? const [],
    );
  }

  factory RevenueModel.fromEntity(RevenueEntity entity) {
    return RevenueModel(
      thisMonth: entity.thisMonth,
      thisMonthChangePct: entity.thisMonthChangePct,
      lastMonth: entity.lastMonth,
      lastMonthChangePct: entity.lastMonthChangePct,
      overdueAmount: entity.overdueAmount,
      overdueMemberCount: entity.overdueMemberCount,
      monthly: entity.monthly,
      last7Days: entity.last7Days,
      byPlan: entity.byPlan,
    );
  }

  RevenueModel copyWith({
    num? thisMonth,
    num? thisMonthChangePct,
    num? lastMonth,
    num? lastMonthChangePct,
    num? overdueAmount,
    num? overdueMemberCount,
    List<MonthlModel>? monthly,
    List<num>? last7Days,
    List<ByPlaModel>? byPlan,
  }) => RevenueModel(
      thisMonth: thisMonth ?? this.thisMonth,
      thisMonthChangePct: thisMonthChangePct ?? this.thisMonthChangePct,
      lastMonth: lastMonth ?? this.lastMonth,
      lastMonthChangePct: lastMonthChangePct ?? this.lastMonthChangePct,
      overdueAmount: overdueAmount ?? this.overdueAmount,
      overdueMemberCount: overdueMemberCount ?? this.overdueMemberCount,
      monthly: monthly ?? this.monthly,
      last7Days: last7Days ?? this.last7Days,
      byPlan: byPlan ?? this.byPlan,
  );

  Map<String, dynamic> toJson() => {
        'thisMonth': thisMonth,
        'thisMonthChangePct': thisMonthChangePct,
        'lastMonth': lastMonth,
        'lastMonthChangePct': lastMonthChangePct,
        'overdueAmount': overdueAmount,
        'overdueMemberCount': overdueMemberCount,
        'monthly': monthly.map((e) => MonthlModel.fromEntity(e).toJson()).toList(),
        'last7Days': last7Days,
        'byPlan': byPlan.map((e) => ByPlaModel.fromEntity(e).toJson()).toList(),
      }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'RevenueModel('
      'thisMonth: $thisMonth, '
      'thisMonthChangePct: $thisMonthChangePct, '
      'lastMonth: $lastMonth, '
      'lastMonthChangePct: $lastMonthChangePct, '
      'overdueAmount: $overdueAmount, '
      'overdueMemberCount: $overdueMemberCount, '
      'monthly: $monthly, '
      'last7Days: $last7Days, '
      'byPlan: $byPlan, '
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

class PendingPaymentModel extends PendingPaymentEntity {
  const PendingPaymentModel({
    super.id,
    super.memberId,
    super.name,
    super.amountDue,
    super.submittedAgo,
  });

  factory PendingPaymentModel.fromJson(Map<String, dynamic> json) {
    return PendingPaymentModel(
      id: json['id'] as String? ?? '',
      memberId: json['memberId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      amountDue: json['amountDue'] as num? ?? 0,
      submittedAgo: json['submittedAgo'] as String? ?? '',
    );
  }

  factory PendingPaymentModel.fromEntity(PendingPaymentEntity entity) {
    return PendingPaymentModel(
      id: entity.id,
      memberId: entity.memberId,
      name: entity.name,
      amountDue: entity.amountDue,
      submittedAgo: entity.submittedAgo,
    );
  }

  PendingPaymentModel copyWith({
    String? id,
    String? memberId,
    String? name,
    num? amountDue,
    String? submittedAgo,
  }) => PendingPaymentModel(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      name: name ?? this.name,
      amountDue: amountDue ?? this.amountDue,
      submittedAgo: submittedAgo ?? this.submittedAgo,
  );

  Map<String, dynamic> toJson() => {
        'id': id,
        'memberId': memberId,
        'name': name,
        'amountDue': amountDue,
        'submittedAgo': submittedAgo,
      }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'PendingPaymentModel('
      'id: $id, '
      'memberId: $memberId, '
      'name: $name, '
      'amountDue: $amountDue, '
      'submittedAgo: $submittedAgo, '
    ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other is PendingPaymentModel && other.id == id);
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

class RecentMemberModel extends RecentMemberEntity {
  const RecentMemberModel({
    super.id,
    super.name,
    super.plan,
    super.joinedAgo,
  });

  factory RecentMemberModel.fromJson(Map<String, dynamic> json) {
    return RecentMemberModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      plan: json['plan'] as String? ?? '',
      joinedAgo: json['joinedAgo'] as String? ?? '',
    );
  }

  factory RecentMemberModel.fromEntity(RecentMemberEntity entity) {
    return RecentMemberModel(
      id: entity.id,
      name: entity.name,
      plan: entity.plan,
      joinedAgo: entity.joinedAgo,
    );
  }

  RecentMemberModel copyWith({
    String? id,
    String? name,
    String? plan,
    String? joinedAgo,
  }) => RecentMemberModel(
      id: id ?? this.id,
      name: name ?? this.name,
      plan: plan ?? this.plan,
      joinedAgo: joinedAgo ?? this.joinedAgo,
  );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'plan': plan,
        'joinedAgo': joinedAgo,
      }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'RecentMemberModel('
      'id: $id, '
      'name: $name, '
      'plan: $plan, '
      'joinedAgo: $joinedAgo, '
    ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other is RecentMemberModel && other.id == id);
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

class LowStockProductModel extends LowStockProductEntity {
  const LowStockProductModel({
    super.id,
    super.name,
    super.stockCount,
    super.imageUrl,
  });

  factory LowStockProductModel.fromJson(Map<String, dynamic> json) {
    return LowStockProductModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      stockCount: json['stockCount'] as num? ?? 0,
      imageUrl: json['imageUrl'] as String? ?? '',
    );
  }

  factory LowStockProductModel.fromEntity(LowStockProductEntity entity) {
    return LowStockProductModel(
      id: entity.id,
      name: entity.name,
      stockCount: entity.stockCount,
      imageUrl: entity.imageUrl,
    );
  }

  LowStockProductModel copyWith({
    String? id,
    String? name,
    num? stockCount,
    String? imageUrl,
  }) => LowStockProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      stockCount: stockCount ?? this.stockCount,
      imageUrl: imageUrl ?? this.imageUrl,
  );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'stockCount': stockCount,
        'imageUrl': imageUrl,
      }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'LowStockProductModel('
      'id: $id, '
      'name: $name, '
      'stockCount: $stockCount, '
      'imageUrl: $imageUrl, '
    ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other is LowStockProductModel && other.id == id);
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

class AdminHomeModel extends AdminHomeEntity {
  const AdminHomeModel({
    super.overview,
    super.revenue,
    super.pendingPayments,
    super.recentMembers,
    super.lowStockProducts,
  });

  factory AdminHomeModel.fromJson(Map<String, dynamic> json) {
    return AdminHomeModel(
      overview: json['overview'] != null ? OverviewModel.fromJson(json['overview']) : const OverviewModel(),
      revenue: json['revenue'] != null ? RevenueModel.fromJson(json['revenue']) : const RevenueModel(),
      pendingPayments: (json['pendingPayments'] as List?)?.map((e) => PendingPaymentModel.fromJson(e)).toList() ?? const [],
      recentMembers: (json['recentMembers'] as List?)?.map((e) => RecentMemberModel.fromJson(e)).toList() ?? const [],
      lowStockProducts: (json['lowStockProducts'] as List?)?.map((e) => LowStockProductModel.fromJson(e)).toList() ?? const [],
    );
  }

  factory AdminHomeModel.fromEntity(AdminHomeEntity entity) {
    return AdminHomeModel(
      overview: entity.overview,
      revenue: entity.revenue,
      pendingPayments: entity.pendingPayments,
      recentMembers: entity.recentMembers,
      lowStockProducts: entity.lowStockProducts,
    );
  }

  AdminHomeModel copyWith({
    OverviewModel? overview,
    RevenueModel? revenue,
    List<PendingPaymentModel>? pendingPayments,
    List<RecentMemberModel>? recentMembers,
    List<LowStockProductModel>? lowStockProducts,
  }) => AdminHomeModel(
      overview: overview ?? this.overview,
      revenue: revenue ?? this.revenue,
      pendingPayments: pendingPayments ?? this.pendingPayments,
      recentMembers: recentMembers ?? this.recentMembers,
      lowStockProducts: lowStockProducts ?? this.lowStockProducts,
  );

  Map<String, dynamic> toJson() => {
        'overview': OverviewModel.fromEntity(overview).toJson(),
        'revenue': RevenueModel.fromEntity(revenue).toJson(),
        'pendingPayments': pendingPayments.map((e) => PendingPaymentModel.fromEntity(e).toJson()).toList(),
        'recentMembers': recentMembers.map((e) => RecentMemberModel.fromEntity(e).toJson()).toList(),
        'lowStockProducts': lowStockProducts.map((e) => LowStockProductModel.fromEntity(e).toJson()).toList(),
      }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'AdminHomeModel('
      'overview: $overview, '
      'revenue: $revenue, '
      'pendingPayments: $pendingPayments, '
      'recentMembers: $recentMembers, '
      'lowStockProducts: $lowStockProducts, '
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

