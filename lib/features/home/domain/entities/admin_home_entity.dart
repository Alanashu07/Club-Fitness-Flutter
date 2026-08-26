class OverviewEntity {
  final num totalMembers;
  final num newMembersThisMonth;
  final num activeMembers;
  final num todayCheckIns;
  final num activeTodayPercent;
  final num pendingFeesCount;
  final num outstandingAmount;
  final num ordersToday;
  final num ordersReadyToday;

  const OverviewEntity({
    this.totalMembers = 0,
    this.newMembersThisMonth = 0,
    this.activeMembers = 0,
    this.todayCheckIns = 0,
    this.activeTodayPercent = 0,
    this.pendingFeesCount = 0,
    this.outstandingAmount = 0,
    this.ordersToday = 0,
    this.ordersReadyToday = 0,
  });

  @override
  String toString() {
    return 'OverviewEntity('
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
}

class MonthlEntity {
  final String label;
  final num total;

  const MonthlEntity({
    this.label = '',
    this.total = 0,
  });

  @override
  String toString() {
    return 'MonthlEntity('
      'label: $label, '
      'total: $total, '
    ')';
  }
}

class ByPlaEntity {
  final String label;
  final num amount;
  final num fraction;

  const ByPlaEntity({
    this.label = '',
    this.amount = 0,
    this.fraction = 0,
  });

  @override
  String toString() {
    return 'ByPlaEntity('
      'label: $label, '
      'amount: $amount, '
      'fraction: $fraction, '
    ')';
  }
}

class RevenueEntity {
  final num thisMonth;
  final num thisMonthChangePct;
  final num lastMonth;
  final num lastMonthChangePct;
  final num overdueAmount;
  final num overdueMemberCount;
  final List<MonthlEntity> monthly;
  final List<num> last7Days;
  final List<ByPlaEntity> byPlan;

  const RevenueEntity({
    this.thisMonth = 0,
    this.thisMonthChangePct = 0,
    this.lastMonth = 0,
    this.lastMonthChangePct = 0,
    this.overdueAmount = 0,
    this.overdueMemberCount = 0,
    this.monthly = const [],
    this.last7Days = const [],
    this.byPlan = const [],
  });

  @override
  String toString() {
    return 'RevenueEntity('
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
}

class PendingPaymentEntity {
  final String id;
  final String memberId;
  final String name;
  final num amountDue;
  final String submittedAgo;

  const PendingPaymentEntity({
    this.id = '',
    this.memberId = '',
    this.name = '',
    this.amountDue = 0,
    this.submittedAgo = '',
  });

  @override
  String toString() {
    return 'PendingPaymentEntity('
      'id: $id, '
      'memberId: $memberId, '
      'name: $name, '
      'amountDue: $amountDue, '
      'submittedAgo: $submittedAgo, '
    ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other is PendingPaymentEntity && other.id == id);
  }

  @override
  int get hashCode => id.hashCode;
}

class RecentMemberEntity {
  final String id;
  final String name;
  final String plan;
  final String joinedAgo;

  const RecentMemberEntity({
    this.id = '',
    this.name = '',
    this.plan = '',
    this.joinedAgo = '',
  });

  @override
  String toString() {
    return 'RecentMemberEntity('
      'id: $id, '
      'name: $name, '
      'plan: $plan, '
      'joinedAgo: $joinedAgo, '
    ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other is RecentMemberEntity && other.id == id);
  }

  @override
  int get hashCode => id.hashCode;
}

class LowStockProductEntity {
  final String id;
  final String name;
  final num stockCount;
  final String imageUrl;

  const LowStockProductEntity({
    this.id = '',
    this.name = '',
    this.stockCount = 0,
    this.imageUrl = '',
  });

  @override
  String toString() {
    return 'LowStockProductEntity('
      'id: $id, '
      'name: $name, '
      'stockCount: $stockCount, '
      'imageUrl: $imageUrl, '
    ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other is LowStockProductEntity && other.id == id);
  }

  @override
  int get hashCode => id.hashCode;
}

class AdminHomeEntity {
  final OverviewEntity overview;
  final RevenueEntity revenue;
  final List<PendingPaymentEntity> pendingPayments;
  final List<RecentMemberEntity> recentMembers;
  final List<LowStockProductEntity> lowStockProducts;

  const AdminHomeEntity({
    this.overview = const OverviewEntity(),
    this.revenue = const RevenueEntity(),
    this.pendingPayments = const [],
    this.recentMembers = const [],
    this.lowStockProducts = const [],
  });

  @override
  String toString() {
    return 'AdminHomeEntity('
      'overview: $overview, '
      'revenue: $revenue, '
      'pendingPayments: $pendingPayments, '
      'recentMembers: $recentMembers, '
      'lowStockProducts: $lowStockProducts, '
    ')';
  }
}

