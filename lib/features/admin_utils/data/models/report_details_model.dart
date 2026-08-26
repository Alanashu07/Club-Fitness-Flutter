import '../../domain/entities/report_details_entity.dart';

class WindowModel extends WindowEntity {
  const WindowModel({
    super.start,
    super.end,
  });

  factory WindowModel.fromJson(Map<String, dynamic> json) {
    return WindowModel(
      start: json['start'] as String? ?? '',
      end: json['end'] as String? ?? '',
    );
  }

  factory WindowModel.fromEntity(WindowEntity entity) {
    return WindowModel(
      start: entity.start,
      end: entity.end,
    );
  }

  WindowModel copyWith({
    String? start,
    String? end,
  }) => WindowModel(
      start: start ?? this.start,
      end: end ?? this.end,
  );

  Map<String, dynamic> toJson() => {
        'start': start,
        'end': end,
      }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'WindowModel('
      'start: $start, '
      'end: $end, '
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

class TotalRevenueModel extends TotalRevenueEntity {
  const TotalRevenueModel({
    super.value,
    super.changePercent,
    super.positive,
  });

  factory TotalRevenueModel.fromJson(Map<String, dynamic> json) {
    return TotalRevenueModel(
      value: json['value'] as num? ?? 0,
      changePercent: json['changePercent'] as num? ?? 0,
      positive: json['positive'] as bool? ?? false,
    );
  }

  factory TotalRevenueModel.fromEntity(TotalRevenueEntity entity) {
    return TotalRevenueModel(
      value: entity.value,
      changePercent: entity.changePercent,
      positive: entity.positive,
    );
  }

  TotalRevenueModel copyWith({
    num? value,
    num? changePercent,
    bool? positive,
  }) => TotalRevenueModel(
      value: value ?? this.value,
      changePercent: changePercent ?? this.changePercent,
      positive: positive ?? this.positive,
  );

  Map<String, dynamic> toJson() => {
        'value': value,
        'changePercent': changePercent,
        'positive': positive,
      }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'TotalRevenueModel('
      'value: $value, '
      'changePercent: $changePercent, '
      'positive: $positive, '
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

class MembershipsSoldModel extends MembershipsSoldEntity {
  const MembershipsSoldModel({
    super.value,
    super.delta,
    super.positive,
  });

  factory MembershipsSoldModel.fromJson(Map<String, dynamic> json) {
    return MembershipsSoldModel(
      value: json['value'] as num? ?? 0,
      delta: json['delta'] as num? ?? 0,
      positive: json['positive'] as bool? ?? false,
    );
  }

  factory MembershipsSoldModel.fromEntity(MembershipsSoldEntity entity) {
    return MembershipsSoldModel(
      value: entity.value,
      delta: entity.delta,
      positive: entity.positive,
    );
  }

  MembershipsSoldModel copyWith({
    num? value,
    num? delta,
    bool? positive,
  }) => MembershipsSoldModel(
      value: value ?? this.value,
      delta: delta ?? this.delta,
      positive: positive ?? this.positive,
  );

  Map<String, dynamic> toJson() => {
        'value': value,
        'delta': delta,
        'positive': positive,
      }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'MembershipsSoldModel('
      'value: $value, '
      'delta: $delta, '
      'positive: $positive, '
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

class ShopSalesModel extends ShopSalesEntity {
  const ShopSalesModel({
    super.value,
    super.changePercent,
    super.positive,
  });

  factory ShopSalesModel.fromJson(Map<String, dynamic> json) {
    return ShopSalesModel(
      value: json['value'] as num? ?? 0,
      changePercent: json['changePercent'] as num? ?? 0,
      positive: json['positive'] as bool? ?? false,
    );
  }

  factory ShopSalesModel.fromEntity(ShopSalesEntity entity) {
    return ShopSalesModel(
      value: entity.value,
      changePercent: entity.changePercent,
      positive: entity.positive,
    );
  }

  ShopSalesModel copyWith({
    num? value,
    num? changePercent,
    bool? positive,
  }) => ShopSalesModel(
      value: value ?? this.value,
      changePercent: changePercent ?? this.changePercent,
      positive: positive ?? this.positive,
  );

  Map<String, dynamic> toJson() => {
        'value': value,
        'changePercent': changePercent,
        'positive': positive,
      }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'ShopSalesModel('
      'value: $value, '
      'changePercent: $changePercent, '
      'positive: $positive, '
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

class OutstandingDuesModel extends OutstandingDuesEntity {
  const OutstandingDuesModel({
    super.value,
    super.memberCount,
    super.positive,
  });

  factory OutstandingDuesModel.fromJson(Map<String, dynamic> json) {
    return OutstandingDuesModel(
      value: json['value'] as num? ?? 0,
      memberCount: json['memberCount'] as num? ?? 0,
      positive: json['positive'] as bool? ?? false,
    );
  }

  factory OutstandingDuesModel.fromEntity(OutstandingDuesEntity entity) {
    return OutstandingDuesModel(
      value: entity.value,
      memberCount: entity.memberCount,
      positive: entity.positive,
    );
  }

  OutstandingDuesModel copyWith({
    num? value,
    num? memberCount,
    bool? positive,
  }) => OutstandingDuesModel(
      value: value ?? this.value,
      memberCount: memberCount ?? this.memberCount,
      positive: positive ?? this.positive,
  );

  Map<String, dynamic> toJson() => {
        'value': value,
        'memberCount': memberCount,
        'positive': positive,
      }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'OutstandingDuesModel('
      'value: $value, '
      'memberCount: $memberCount, '
      'positive: $positive, '
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

class KpisModel extends KpisEntity {
  const KpisModel({
    super.totalRevenue,
    super.membershipsSold,
    super.shopSales,
    super.outstandingDues,
  });

  factory KpisModel.fromJson(Map<String, dynamic> json) {
    return KpisModel(
      totalRevenue: json['totalRevenue'] != null ? TotalRevenueModel.fromJson(json['totalRevenue']) : const TotalRevenueModel(),
      membershipsSold: json['membershipsSold'] != null ? MembershipsSoldModel.fromJson(json['membershipsSold']) : const MembershipsSoldModel(),
      shopSales: json['shopSales'] != null ? ShopSalesModel.fromJson(json['shopSales']) : const ShopSalesModel(),
      outstandingDues: json['outstandingDues'] != null ? OutstandingDuesModel.fromJson(json['outstandingDues']) : const OutstandingDuesModel(),
    );
  }

  factory KpisModel.fromEntity(KpisEntity entity) {
    return KpisModel(
      totalRevenue: entity.totalRevenue,
      membershipsSold: entity.membershipsSold,
      shopSales: entity.shopSales,
      outstandingDues: entity.outstandingDues,
    );
  }

  KpisModel copyWith({
    TotalRevenueModel? totalRevenue,
    MembershipsSoldModel? membershipsSold,
    ShopSalesModel? shopSales,
    OutstandingDuesModel? outstandingDues,
  }) => KpisModel(
      totalRevenue: totalRevenue ?? this.totalRevenue,
      membershipsSold: membershipsSold ?? this.membershipsSold,
      shopSales: shopSales ?? this.shopSales,
      outstandingDues: outstandingDues ?? this.outstandingDues,
  );

  Map<String, dynamic> toJson() => {
        'totalRevenue': TotalRevenueModel.fromEntity(totalRevenue).toJson(),
        'membershipsSold': MembershipsSoldModel.fromEntity(membershipsSold).toJson(),
        'shopSales': ShopSalesModel.fromEntity(shopSales).toJson(),
        'outstandingDues': OutstandingDuesModel.fromEntity(outstandingDues).toJson(),
      }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'KpisModel('
      'totalRevenue: $totalRevenue, '
      'membershipsSold: $membershipsSold, '
      'shopSales: $shopSales, '
      'outstandingDues: $outstandingDues, '
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

class MonthModel extends MonthEntity {
  const MonthModel({
    super.label,
    super.membership,
    super.shop,
    super.total,
  });

  factory MonthModel.fromJson(Map<String, dynamic> json) {
    return MonthModel(
      label: json['label'] as String? ?? '',
      membership: json['membership'] as num? ?? 0,
      shop: json['shop'] as num? ?? 0,
      total: json['total'] as num? ?? 0,
    );
  }

  factory MonthModel.fromEntity(MonthEntity entity) {
    return MonthModel(
      label: entity.label,
      membership: entity.membership,
      shop: entity.shop,
      total: entity.total,
    );
  }

  MonthModel copyWith({
    String? label,
    num? membership,
    num? shop,
    num? total,
  }) => MonthModel(
      label: label ?? this.label,
      membership: membership ?? this.membership,
      shop: shop ?? this.shop,
      total: total ?? this.total,
  );

  Map<String, dynamic> toJson() => {
        'label': label,
        'membership': membership,
        'shop': shop,
        'total': total,
      }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'MonthModel('
      'label: $label, '
      'membership: $membership, '
      'shop: $shop, '
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

class RevenueTrendModel extends RevenueTrendEntity {
  const RevenueTrendModel({
    super.total,
    super.changePercent,
    super.months,
  });

  factory RevenueTrendModel.fromJson(Map<String, dynamic> json) {
    return RevenueTrendModel(
      total: json['total'] as num? ?? 0,
      changePercent: json['changePercent'] as num? ?? 0,
      months: (json['months'] as List?)?.map((e) => MonthModel.fromJson(e)).toList() ?? const [],
    );
  }

  factory RevenueTrendModel.fromEntity(RevenueTrendEntity entity) {
    return RevenueTrendModel(
      total: entity.total,
      changePercent: entity.changePercent,
      months: entity.months,
    );
  }

  RevenueTrendModel copyWith({
    num? total,
    num? changePercent,
    List<MonthModel>? months,
  }) => RevenueTrendModel(
      total: total ?? this.total,
      changePercent: changePercent ?? this.changePercent,
      months: months ?? this.months,
  );

  Map<String, dynamic> toJson() => {
        'total': total,
        'changePercent': changePercent,
        'months': months.map((e) => MonthModel.fromEntity(e).toJson()).toList(),
      }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'RevenueTrendModel('
      'total: $total, '
      'changePercent: $changePercent, '
      'months: $months, '
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

class PlanSpliModel extends PlanSpliEntity {
  const PlanSpliModel({
    super.plan,
    super.members,
    super.revenue,
    super.share,
    super.color,
  });

  factory PlanSpliModel.fromJson(Map<String, dynamic> json) {
    return PlanSpliModel(
      plan: json['plan'] as String? ?? '',
      members: json['members'] as num? ?? 0,
      revenue: json['revenue'] as num? ?? 0,
      share: json['share'] as num? ?? 0,
      color: json['color'] as String? ?? '',
    );
  }

  factory PlanSpliModel.fromEntity(PlanSpliEntity entity) {
    return PlanSpliModel(
      plan: entity.plan,
      members: entity.members,
      revenue: entity.revenue,
      share: entity.share,
      color: entity.color,
    );
  }

  PlanSpliModel copyWith({
    String? plan,
    num? members,
    num? revenue,
    num? share,
    String? color,
  }) => PlanSpliModel(
      plan: plan ?? this.plan,
      members: members ?? this.members,
      revenue: revenue ?? this.revenue,
      share: share ?? this.share,
      color: color ?? this.color,
  );

  Map<String, dynamic> toJson() => {
        'plan': plan,
        'members': members,
        'revenue': revenue,
        'share': share,
        'color': color,
      }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'PlanSpliModel('
      'plan: $plan, '
      'members: $members, '
      'revenue: $revenue, '
      'share: $share, '
      'color: $color, '
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

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    super.date,
    super.member,
    super.plan,
    super.mode,
    super.amount,
    super.status,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      date: json['date'] as String? ?? '',
      member: json['member'] as String? ?? '',
      plan: json['plan'] as String? ?? '',
      mode: json['mode'] as String? ?? '',
      amount: json['amount'] as num? ?? 0,
      status: json['status'] as String? ?? '',
    );
  }

  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      date: entity.date,
      member: entity.member,
      plan: entity.plan,
      mode: entity.mode,
      amount: entity.amount,
      status: entity.status,
    );
  }

  TransactionModel copyWith({
    String? date,
    String? member,
    String? plan,
    String? mode,
    num? amount,
    String? status,
  }) => TransactionModel(
      date: date ?? this.date,
      member: member ?? this.member,
      plan: plan ?? this.plan,
      mode: mode ?? this.mode,
      amount: amount ?? this.amount,
      status: status ?? this.status,
  );

  Map<String, dynamic> toJson() => {
        'date': date,
        'member': member,
        'plan': plan,
        'mode': mode,
        'amount': amount,
        'status': status,
      }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'TransactionModel('
      'date: $date, '
      'member: $member, '
      'plan: $plan, '
      'mode: $mode, '
      'amount: $amount, '
      'status: $status, '
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

class ReportDetailsModel extends ReportDetailsEntity {
  const ReportDetailsModel({
    super.range,
    super.rangeLabel,
    super.window,
    super.kpis,
    super.revenueTrend,
    super.planSplit,
    super.transactions,
  });

  factory ReportDetailsModel.fromJson(Map<String, dynamic> json) {
    return ReportDetailsModel(
      range: json['range'] as String? ?? '',
      rangeLabel: json['rangeLabel'] as String? ?? '',
      window: json['window'] != null ? WindowModel.fromJson(json['window']) : const WindowModel(),
      kpis: json['kpis'] != null ? KpisModel.fromJson(json['kpis']) : const KpisModel(),
      revenueTrend: json['revenueTrend'] != null ? RevenueTrendModel.fromJson(json['revenueTrend']) : const RevenueTrendModel(),
      planSplit: (json['planSplit'] as List?)?.map((e) => PlanSpliModel.fromJson(e)).toList() ?? const [],
      transactions: (json['transactions'] as List?)?.map((e) => TransactionModel.fromJson(e)).toList() ?? const [],
    );
  }

  factory ReportDetailsModel.fromEntity(ReportDetailsEntity entity) {
    return ReportDetailsModel(
      range: entity.range,
      rangeLabel: entity.rangeLabel,
      window: entity.window,
      kpis: entity.kpis,
      revenueTrend: entity.revenueTrend,
      planSplit: entity.planSplit,
      transactions: entity.transactions,
    );
  }

  ReportDetailsModel copyWith({
    String? range,
    String? rangeLabel,
    WindowModel? window,
    KpisModel? kpis,
    RevenueTrendModel? revenueTrend,
    List<PlanSpliModel>? planSplit,
    List<TransactionModel>? transactions,
  }) => ReportDetailsModel(
      range: range ?? this.range,
      rangeLabel: rangeLabel ?? this.rangeLabel,
      window: window ?? this.window,
      kpis: kpis ?? this.kpis,
      revenueTrend: revenueTrend ?? this.revenueTrend,
      planSplit: planSplit ?? this.planSplit,
      transactions: transactions ?? this.transactions,
  );

  Map<String, dynamic> toJson() => {
        'range': range,
        'rangeLabel': rangeLabel,
        'window': WindowModel.fromEntity(window).toJson(),
        'kpis': KpisModel.fromEntity(kpis).toJson(),
        'revenueTrend': RevenueTrendModel.fromEntity(revenueTrend).toJson(),
        'planSplit': planSplit.map((e) => PlanSpliModel.fromEntity(e).toJson()).toList(),
        'transactions': transactions.map((e) => TransactionModel.fromEntity(e).toJson()).toList(),
      }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'ReportDetailsModel('
      'range: $range, '
      'rangeLabel: $rangeLabel, '
      'window: $window, '
      'kpis: $kpis, '
      'revenueTrend: $revenueTrend, '
      'planSplit: $planSplit, '
      'transactions: $transactions, '
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

