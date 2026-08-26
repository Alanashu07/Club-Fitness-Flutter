class WindowEntity {
  final String start;
  final String end;

  const WindowEntity({this.start = '', this.end = ''});

  @override
  String toString() {
    return 'WindowEntity('
        'start: $start, '
        'end: $end, '
        ')';
  }
}

class TotalRevenueEntity {
  final num value;
  final num changePercent;
  final bool positive;

  const TotalRevenueEntity({
    this.value = 0,
    this.changePercent = 0,
    this.positive = false,
  });

  @override
  String toString() {
    return 'TotalRevenueEntity('
        'value: $value, '
        'changePercent: $changePercent, '
        'positive: $positive, '
        ')';
  }
}

class MembershipsSoldEntity {
  final num value;
  final num delta;
  final bool positive;

  const MembershipsSoldEntity({
    this.value = 0,
    this.delta = 0,
    this.positive = false,
  });

  @override
  String toString() {
    return 'MembershipsSoldEntity('
        'value: $value, '
        'delta: $delta, '
        'positive: $positive, '
        ')';
  }
}

class ShopSalesEntity {
  final num value;
  final num changePercent;
  final bool positive;

  const ShopSalesEntity({
    this.value = 0,
    this.changePercent = 0,
    this.positive = false,
  });

  @override
  String toString() {
    return 'ShopSalesEntity('
        'value: $value, '
        'changePercent: $changePercent, '
        'positive: $positive, '
        ')';
  }
}

class OutstandingDuesEntity {
  final num value;
  final num memberCount;
  final bool positive;

  const OutstandingDuesEntity({
    this.value = 0,
    this.memberCount = 0,
    this.positive = false,
  });

  @override
  String toString() {
    return 'OutstandingDuesEntity('
        'value: $value, '
        'memberCount: $memberCount, '
        'positive: $positive, '
        ')';
  }
}

class KpisEntity {
  final TotalRevenueEntity totalRevenue;
  final MembershipsSoldEntity membershipsSold;
  final ShopSalesEntity shopSales;
  final OutstandingDuesEntity outstandingDues;

  const KpisEntity({
    this.totalRevenue = const TotalRevenueEntity(),
    this.membershipsSold = const MembershipsSoldEntity(),
    this.shopSales = const ShopSalesEntity(),
    this.outstandingDues = const OutstandingDuesEntity(),
  });

  @override
  String toString() {
    return 'KpisEntity('
        'totalRevenue: $totalRevenue, '
        'membershipsSold: $membershipsSold, '
        'shopSales: $shopSales, '
        'outstandingDues: $outstandingDues, '
        ')';
  }
}

class MonthEntity {
  final String label;
  final num membership;
  final num shop;
  final num total;

  const MonthEntity({
    this.label = '',
    this.membership = 0,
    this.shop = 0,
    this.total = 0,
  });

  @override
  String toString() {
    return 'MonthEntity('
        'label: $label, '
        'membership: $membership, '
        'shop: $shop, '
        'total: $total, '
        ')';
  }
}

class RevenueTrendEntity {
  final num total;
  final num changePercent;
  final List<MonthEntity> months;

  const RevenueTrendEntity({
    this.total = 0,
    this.changePercent = 0,
    this.months = const [],
  });

  @override
  String toString() {
    return 'RevenueTrendEntity('
        'total: $total, '
        'changePercent: $changePercent, '
        'months: $months, '
        ')';
  }
}

class PlanSpliEntity {
  final String plan;
  final num members;
  final num revenue;
  final num share;
  final String color;

  const PlanSpliEntity({
    this.plan = '',
    this.members = 0,
    this.revenue = 0,
    this.share = 0,
    this.color = '',
  });

  @override
  String toString() {
    return 'PlanSpliEntity('
        'plan: $plan, '
        'members: $members, '
        'revenue: $revenue, '
        'share: $share, '
        'color: $color, '
        ')';
  }
}

class TransactionEntity {
  final String date;
  final String member;
  final String plan;
  final String mode;
  final num amount;
  final String status;

  const TransactionEntity({
    this.date = '',
    this.member = '',
    this.plan = '',
    this.mode = '',
    this.amount = 0,
    this.status = '',
  });

  @override
  String toString() {
    return 'TransactionEntity('
        'date: $date, '
        'member: $member, '
        'plan: $plan, '
        'mode: $mode, '
        'amount: $amount, '
        'status: $status, '
        ')';
  }
}

class ReportDetailsEntity {
  final String range;
  final String rangeLabel;
  final WindowEntity window;
  final KpisEntity kpis;
  final RevenueTrendEntity revenueTrend;
  final List<PlanSpliEntity> planSplit;
  final List<TransactionEntity> transactions;

  const ReportDetailsEntity({
    this.range = '',
    this.rangeLabel = '',
    this.window = const WindowEntity(),
    this.kpis = const KpisEntity(),
    this.revenueTrend = const RevenueTrendEntity(),
    this.planSplit = const [],
    this.transactions = const [],
  });

  String get revenueTrendDuration {
    int year = DateTime.now().year;
    if (revenueTrend.months.isEmpty) {
      return '$year';
    }

    if (revenueTrend.months.length == 1) {
      return "${revenueTrend.months.first.label} $year";
    }

    return '${revenueTrend.months.first.label} - ${revenueTrend.months.last.label} $year';
  }

  @override
  String toString() {
    return 'ReportDetailsEntity('
        'range: $range, '
        'rangeLabel: $rangeLabel, '
        'window: $window, '
        'kpis: $kpis, '
        'revenueTrend: $revenueTrend, '
        'planSplit: $planSplit, '
        'transactions: $transactions, '
        ')';
  }
}
