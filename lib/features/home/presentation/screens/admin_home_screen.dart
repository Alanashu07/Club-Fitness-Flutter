import 'package:club_fitness/config/navigation/routes_class.dart';
import 'package:club_fitness/config/theme/theme.dart';
import 'package:club_fitness/core/utils/utils.dart';
import 'package:club_fitness/di.dart';
import 'package:club_fitness/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:club_fitness/features/image_cache/presentation/widgets/custom_cached_image.dart';
import 'package:club_fitness/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as math;

import '../../domain/entities/home_entities.dart';
import '../bloc/home_bloc/home_bloc.dart';

// ─── Display helper models ────────────────────────────────────────────────────
class _StatItem {
  final String label;
  final String value;
  final String sub;
  final IconData icon;
  final Color accent;
  const _StatItem(this.label, this.value, this.sub, this.icon, this.accent);
}

class _RecentMemberVM {
  final String name;
  final String plan;
  final String joinedAgo;
  final String initials;
  final Color avatarColor;
  const _RecentMemberVM(
    this.name,
    this.plan,
    this.joinedAgo,
    this.initials,
    this.avatarColor,
  );
}

class _PendingPaymentVM {
  final String name;
  final String amount;
  final String daysAgo;
  final String initials;
  const _PendingPaymentVM(this.name, this.amount, this.daysAgo, this.initials);
}

// ─── Formatting helpers ───────────────────────────────────────────────────────
const _avatarPalette = [
  Color(0xFFC41E2D),
  Color(0xFF7B1FA2),
  Color(0xFF1565C0),
  Color(0xFF2E7D32),
  Color(0xFFFFA000),
  Color(0xFF29B6F6),
];

String _initialsOf(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((p) => p.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) {
    return parts.first
        .substring(0, math.min(2, parts.first.length))
        .toUpperCase();
  }
  return (parts.first[0] + parts.last[0]).toUpperCase();
}

Color _colorForIndex(int i) => _avatarPalette[i % _avatarPalette.length];

String _formatInr(num value) {
  final isNeg = value < 0;
  final intVal = value.abs().round();
  final str = intVal.toString();
  String result;
  if (str.length <= 3) {
    result = str;
  } else {
    final last3 = str.substring(str.length - 3);
    var remaining = str.substring(0, str.length - 3);
    final buffer = StringBuffer();
    while (remaining.length > 2) {
      buffer.write(',${remaining.substring(remaining.length - 2)}');
      remaining = remaining.substring(0, remaining.length - 2);
    }
    result =
        '$remaining${buffer.toString().split('').reversed.join().isEmpty ? '' : ''}';
    // rebuild properly (simpler approach below)
    final groups = <String>[];
    var rest = str.substring(0, str.length - 3);
    while (rest.length > 2) {
      groups.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) groups.insert(0, rest);
    result = '${groups.join(',')},$last3';
  }
  return '${isNeg ? '-' : ''}₹ $result';
}

String _compactInr(num value) {
  final abs = value.abs();
  if (abs >= 100000) return '₹${(value / 100000).toStringAsFixed(1)}L';
  if (abs >= 1000) return '₹${(value / 1000).toStringAsFixed(0)}K';
  return '₹${value.toStringAsFixed(0)}';
}

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc(sl())..add(const GetHomeEvent("admin")),
      child: Scaffold(
        body: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            switch (state) {
              case HomeInitial():
              case HomeLoading():
                return const Center(
                  child: CircularProgressIndicator.adaptive(),
                );
              case HomeSuccess():
                return AdminHomeView(data: state.home.adminHome!);
              case HomeFailure():
                return FailureTextWidget(
                  state.failure,
                  onRetry: () =>
                      context.read<HomeBloc>().add(const GetHomeEvent("admin")),
                );
            }
          },
        ),
      ),
    );
  }
}

// ─── Main Screen ──────────────────────────────────────────────────────────────
class AdminHomeView extends StatefulWidget {
  final AdminHomeEntity data;
  const AdminHomeView({super.key, required this.data});

  @override
  State<AdminHomeView> createState() => _AdminHomeViewState();
}

class _AdminHomeViewState extends State<AdminHomeView>
    with SingleTickerProviderStateMixin {
  int _navIndex = 0;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  AdminHomeEntity get _data => widget.data;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  List<_StatItem> get _stats {
    final o = _data.overview;
    return [
      _StatItem(
        'Total Members',
        '${o.totalMembers}',
        '+${o.newMembersThisMonth} this month',
        Icons.people_alt_rounded,
        AppTheme.primary,
      ),
      _StatItem(
        'Active Today',
        '${o.todayCheckIns}',
        '${o.activeTodayPercent}% of members',
        Icons.bolt_rounded,
        const Color(0xFF4CAF50),
      ),
      _StatItem(
        'Pending Fees',
        '${o.pendingFeesCount}',
        '${_formatInr(o.outstandingAmount)} due',
        Icons.receipt_long_rounded,
        const Color(0xFFFFA000),
      ),
      _StatItem(
        'Orders Today',
        '${o.ordersToday}',
        '${o.ordersReadyToday} ready for pickup',
        Icons.shopping_bag_rounded,
        const Color(0xFF29B6F6),
      ),
    ];
  }

  List<_RecentMemberVM> get _recentMembers {
    final list = _data.recentMembers;
    return List.generate(list.length, (i) {
      final m = list[i];
      return _RecentMemberVM(
        m.name,
        m.plan,
        m.joinedAgo,
        _initialsOf(m.name),
        _colorForIndex(i),
      );
    });
  }

  List<_PendingPaymentVM> get _pendingPayments {
    return _data.pendingPayments
        .map(
          (p) => _PendingPaymentVM(
            p.name,
            _formatInr(p.amountDue),
            p.submittedAgo,
            _initialsOf(p.name),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildSliverAppBar(),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 24),
                  _buildQuickActions(),
                  const SizedBox(height: 28),
                  _buildSectionLabel('Overview', 'Today'),
                  const SizedBox(height: 16),
                  _buildStatsGrid(),
                  const SizedBox(height: 28),
                  _buildSectionLabel('Revenue', 'This Year'),
                  const SizedBox(height: 16),
                  _buildRevenueSummaryRow(),
                  const SizedBox(height: 14),
                  if (_data.revenue.monthly.isNotEmpty)
                    _buildMonthlyRevenueChart(),
                  const SizedBox(height: 14),
                  _buildRevenueBottomRow(),
                  const SizedBox(height: 28),
                  _buildSectionLabel(
                    'Pending Approvals',
                    '${_pendingPayments.length} payments',
                  ),
                  const SizedBox(height: 16),
                  _buildPendingPayments(),
                  const SizedBox(height: 28),
                  _buildSectionLabel('Recent Members', 'View all →'),
                  const SizedBox(height: 16),
                  _buildRecentMembers(),
                  const SizedBox(height: 28),
                  _buildSectionLabel('Quick Announcements', ''),
                  const SizedBox(height: 16),
                  _buildAnnouncementComposer(),
                  const SizedBox(height: 28),
                  if (_data.lowStockProducts.isNotEmpty) _buildLowStockBanner(),
                ]),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // ── Sliver App Bar ──────────────────────────────────────────────────────────
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 130,
      floating: true,
      pinned: false,
      backgroundColor: AppTheme.background,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A0005), AppTheme.background],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(right: 8, top: 2),
                            decoration: const BoxDecoration(
                              color: Color(0xFF4CAF50),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const Text(
                            'ADMIN PANEL',
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 3,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Club Fitness',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                Stack(
                  children: [
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return Container(
                          width: 46,
                          height: 46,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.primary,
                              width: 2,
                            ),
                            color: AppTheme.surface,
                          ),
                          child: ClipOval(
                            child: CustomCachedImage(
                              state.user.profileImageUrl,
                              errorBuilder: (errorTitle, error, url) => Center(
                                child: Text(
                                  state.user.initials,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.background,
                            width: 2,
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            '',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ).onTap(() => context.push(Routes.adminProfile)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Quick Actions ───────────────────────────────────────────────────────────
  Widget _buildQuickActions() {
    final actions = [
      (
        Icons.person_add_rounded,
        'Add\nMember',
        AppTheme.primary,
        Routes.addMember,
      ),
      (
        Icons.fitness_center_rounded,
        'Assign\nWorkout',
        const Color(0xFF7B1FA2),
        Routes.assignWorkout,
      ),
      (
        Icons.campaign_rounded,
        'Announce',
        const Color(0xFF1565C0),
        Routes.announcementCreate,
      ),
      (
        Icons.bar_chart_rounded,
        'Reports',
        const Color(0xFF2E7D32),
        Routes.adminReports,
      ),
    ];
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: actions
            .map(
              (a) => Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (a.$4.isEmpty) return;
                    context.push(a.$4);
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: a == actions.last ? 0 : 10),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: (a.$3).withAOpacity(0.18),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: (a.$3).withAOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(a.$1, color: a.$3, size: 20),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          a.$2,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  // ── Section Label ───────────────────────────────────────────────────────────
  Widget _buildSectionLabel(String title, String sub) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
        if (sub.isNotEmpty)
          Text(
            sub,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
      ],
    );
  }

  // ── Stats Grid ──────────────────────────────────────────────────────────────
  Widget _buildStatsGrid() {
    final stats = _stats;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stats.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemBuilder: (_, i) => _StatCard(item: stats[i]),
    );
  }

  // ── Pending Payments ────────────────────────────────────────────────────────
  Widget _buildPendingPayments() {
    final payments = _pendingPayments;
    if (payments.isEmpty) {
      return const Text(
        'No pending approvals',
        style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
      );
    }
    return Column(
      children: payments.map((p) => _PendingPaymentTile(payment: p)).toList(),
    );
  }

  // ── Recent Members ──────────────────────────────────────────────────────────
  Widget _buildRecentMembers() {
    final members = _recentMembers;
    if (members.isEmpty) {
      return const Text(
        'No recent members',
        style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
      );
    }
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: members.length,
        itemBuilder: (_, i) => _MemberCard(member: members[i]),
      ),
    );
  }

  // ── Announcement Composer ───────────────────────────────────────────────────
  Widget _buildAnnouncementComposer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.primary.withAOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withAOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.campaign_rounded,
                  color: AppTheme.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Send Quick Announcement',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            height: 52,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const TextField(
              style: TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Type your message here…',
                hintStyle: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const _ChannelChip(Icons.notifications_rounded, 'Push', true),
              const SizedBox(width: 8),
              const _ChannelChip(Icons.chat_rounded, 'WhatsApp', true),
              const SizedBox(width: 8),
              const _ChannelChip(Icons.sms_rounded, 'SMS', false),
              const Spacer(),
              SizedBox(
                height: 36,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Send',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Low Stock Banner ────────────────────────────────────────────────────────
  Widget _buildLowStockBanner() {
    final products = _data.lowStockProducts;
    final summaryText = products
        .take(3)
        .map((p) => '${p.name} (${p.stockCount} left)')
        .join(', ');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1100),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFA000).withAOpacity(0.4),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFFA000).withAOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFFFA000),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Low Stock Alert',
                  style: TextStyle(
                    color: Color(0xFFFFA000),
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  summaryText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppTheme.textSecondary,
            size: 20,
          ),
        ],
      ),
    );
  }

  // ── Revenue Summary Row ─────────────────────────────────────────────────────
  Widget _buildRevenueSummaryRow() {
    final r = _data.revenue;
    final summaries = [
      (
        'This Month',
        _formatInr(r.thisMonth),
        '${r.thisMonthChangePct}%',
        r.thisMonthChangePct >= 0,
        false,
      ),
      (
        'Last Month',
        _formatInr(r.lastMonth),
        '${r.lastMonthChangePct}%',
        r.lastMonthChangePct >= 0,
        false,
      ),
      (
        'Overdue',
        _formatInr(r.overdueAmount),
        '${r.overdueMemberCount} members',
        false,
        true,
      ),
    ];
    return Row(
      children: summaries.asMap().entries.map((e) {
        final i = e.key;
        final s = e.value;
        final isLast = i == summaries.length - 1;
        final isOverdue = s.$5;
        final isPositive = s.$4;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: isLast ? 0 : 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: (isOverdue ? const Color(0xFFFFA000) : AppTheme.primary)
                    .withAOpacity(0.15),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.$1,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  s.$2,
                  style: TextStyle(
                    color: isOverdue ? const Color(0xFFFFA000) : Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (!isOverdue)
                      Icon(
                        isPositive
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                        color: isPositive
                            ? const Color(0xFF4CAF50)
                            : AppTheme.error,
                        size: 10,
                      ),
                    if (!isOverdue) const SizedBox(width: 2),
                    Text(
                      s.$3,
                      style: TextStyle(
                        color: isOverdue
                            ? const Color(0xFFFFA000).withAOpacity(0.7)
                            : (isPositive
                                  ? const Color(0xFF4CAF50)
                                  : AppTheme.error),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Monthly Revenue Bar Chart ───────────────────────────────────────────────
  Widget _buildMonthlyRevenueChart() {
    final monthly = _data.revenue.monthly;
    final values = monthly.map((m) => m.total.toDouble()).toList();
    final labels = monthly.map((m) => m.label).toList();
    final total = values.fold<double>(0, (a, b) => a + b);
    final rangeLabel = monthly.isNotEmpty
        ? '${monthly.first.label} – ${monthly.last.label}'
        : '';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withAOpacity(0.05), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Monthly Revenue',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    rangeLabel,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withAOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.primary.withAOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  '${_compactInr(total)} total',
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: CustomPaint(
              size: const Size(double.infinity, 160),
              painter: _BarChartPainter(
                values: values,
                labels: labels,
                barColor: AppTheme.primary,
                highlightIndex: values.length - 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Revenue Bottom Row: Sparkline + Donut ───────────────────────────────────
  Widget _buildRevenueBottomRow() {
    final last7 = _data.revenue.last7Days.map((v) => v.toDouble()).toList();
    final byPlan = _data.revenue.byPlan;
    final donutSegments = List.generate(
      byPlan.length,
      (i) => _DonutSegment(
        byPlan[i].label,
        byPlan[i].fraction.toDouble(),
        _colorForIndex(i),
      ),
    );
    final donutTotal = byPlan.fold<num>(0, (a, b) => a + b.amount);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 7-day sparkline
        Expanded(
          flex: 5,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withAOpacity(0.05),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Last 7 Days',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Daily collections',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 10),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 72,
                  child: last7.isEmpty
                      ? const SizedBox.shrink()
                      : CustomPaint(
                          size: const Size(double.infinity, 72),
                          painter: _SparklinePainter(
                            values: last7,
                            lineColor: const Color(0xFF29B6F6),
                          ),
                        ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                      .map(
                        (d) => Text(
                          d,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Membership plan donut
        Expanded(
          flex: 4,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withAOpacity(0.05),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'By Plan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Revenue split',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 10),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 90,
                  child: donutSegments.isEmpty
                      ? const SizedBox.shrink()
                      : CustomPaint(
                          size: const Size(double.infinity, 90),
                          painter: _DonutChartPainter(
                            segments: donutSegments,
                            centerLabel: _compactInr(donutTotal),
                          ),
                        ),
                ),
                const SizedBox(height: 12),
                _DonutLegend(segments: donutSegments),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Bottom Nav ──────────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    final items = [
      (Icons.dashboard_rounded, Icons.dashboard_outlined, 'Home', ''),
      (
        Icons.people_alt_rounded,
        Icons.people_alt_outlined,
        'Members',
        Routes.addMember,
      ),
      (
        Icons.receipt_long_rounded,
        Icons.receipt_long_outlined,
        'Fees',
        Routes.manageFees,
      ),
      (
        Icons.shopping_bag_rounded,
        Icons.shopping_bag_outlined,
        'Shop',
        Routes.shopAdminHome,
      ),
      (
        Icons.bar_chart_rounded,
        Icons.bar_chart_outlined,
        'Reports',
        Routes.adminReports,
      ),
    ];
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
        border: const Border(
          top: BorderSide(color: Colors.white10, width: 0.5),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((e) {
              final i = e.key;
              final item = e.value;
              final selected = _navIndex == i;
              return GestureDetector(
                onTap: () {
                  if (item.$4.isNotEmpty) {
                    context.push(item.$4);
                  } else {
                    setState(() => _navIndex = i);
                  }
                },
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppTheme.primary.withAOpacity(0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        selected ? item.$1 : item.$2,
                        color: selected ? AppTheme.primary : Colors.grey,
                        size: 22,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.$3,
                        style: TextStyle(
                          color: selected ? AppTheme.primary : Colors.grey,
                          fontSize: 10,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // ── FAB ─────────────────────────────────────────────────────────────────────
  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () => context.push(Routes.addMember),
      backgroundColor: AppTheme.primary,
      elevation: 4,
      icon: const Icon(Icons.add_rounded, color: Colors.white),
      label: const Text(
        'New Member',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final _StatItem item;
  const _StatCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: item.accent.withAOpacity(0.15), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: item.accent.withAOpacity(0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item.icon, color: item.accent, size: 18),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: item.accent.withAOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_upward_rounded,
                      color: item.accent,
                      size: 10,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      item.sub.split(' ').first,
                      style: TextStyle(
                        color: item.accent,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.label,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.sub,
                style: TextStyle(
                  color: item.accent.withAOpacity(0.8),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PendingPaymentTile extends StatelessWidget {
  final _PendingPaymentVM payment;
  const _PendingPaymentTile({required this.payment});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withAOpacity(0.05), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primary.withAOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                payment.initials,
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Submitted ${payment.daysAgo}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            payment.amount,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(width: 12),
          Row(
            children: [
              _ActionBtn(
                icon: Icons.close_rounded,
                color: AppTheme.error,
                onTap: () {},
              ),
              const SizedBox(width: 8),
              _ActionBtn(
                icon: Icons.check_rounded,
                color: const Color(0xFF4CAF50),
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color.withAOpacity(0.14),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(icon, color: color, size: 17),
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  final _RecentMemberVM member;
  const _MemberCard({required this.member});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: member.avatarColor.withAOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: member.avatarColor.withAOpacity(0.2),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Center(
                  child: Text(
                    member.initials,
                    style: TextStyle(
                      color: member.avatarColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                member.joinedAgo,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            member.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            member.plan,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _ChannelChip extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool initialActive;
  const _ChannelChip(this.icon, this.label, this.initialActive);
  @override
  State<_ChannelChip> createState() => _ChannelChipState();
}

class _ChannelChipState extends State<_ChannelChip> {
  late bool _active;
  @override
  void initState() {
    super.initState();
    _active = widget.initialActive;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _active = !_active),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: _active
              ? AppTheme.primary.withAOpacity(0.15)
              : AppTheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _active
                ? AppTheme.primary.withAOpacity(0.5)
                : Colors.white10,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.icon,
              color: _active ? AppTheme.primary : Colors.grey,
              size: 13,
            ),
            const SizedBox(width: 4),
            Text(
              widget.label,
              style: TextStyle(
                color: _active ? AppTheme.primary : Colors.grey,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Donut segment model ──────────────────────────────────────────────────────
class _DonutSegment {
  final String label;
  final double fraction; // 0.0 – 1.0
  final Color color;
  const _DonutSegment(this.label, this.fraction, this.color);
}

// ─── Donut Legend ─────────────────────────────────────────────────────────────
class _DonutLegend extends StatelessWidget {
  final List<_DonutSegment> segments;
  const _DonutLegend({required this.segments});

  @override
  Widget build(BuildContext context) {
    if (segments.isEmpty) return const SizedBox.shrink();
    return Column(
      children: segments
          .map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: s.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      s.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    '${(s.fraction * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

// ─── Bar Chart Painter ────────────────────────────────────────────────────────
class _BarChartPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final Color barColor;
  final int highlightIndex;

  const _BarChartPainter({
    required this.values,
    required this.labels,
    required this.barColor,
    this.highlightIndex = -1,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final double maxVal = values
        .reduce((a, b) => a > b ? a : b)
        .clamp(1, double.infinity);
    final int count = values.length;
    final double labelHeight = 20.0;
    final double chartHeight = size.height - labelHeight - 8;
    final double barAreaWidth = size.width / count;
    final double barWidth = barAreaWidth * 0.52;

    final gridPaint = Paint()
      ..color = Colors.white.withAOpacity(0.06)
      ..strokeWidth = 0.8;

    for (int i = 1; i <= 4; i++) {
      final y = chartHeight - (chartHeight * i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    for (int i = 0; i < count; i++) {
      final double barH = (values[i] / maxVal) * chartHeight;
      final double left = i * barAreaWidth + (barAreaWidth - barWidth) / 2;
      final double top = chartHeight - barH;
      final bool highlight = i == highlightIndex;

      if (highlight) {
        final glowPaint = Paint()
          ..color = barColor.withAOpacity(0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(left - 3, top - 3, barWidth + 6, barH + 6),
            const Radius.circular(8),
          ),
          glowPaint,
        );
      }

      final barPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: highlight
              ? [barColor, barColor.withAOpacity(0.6)]
              : [barColor.withAOpacity(0.55), barColor.withAOpacity(0.25)],
        ).createShader(Rect.fromLTWH(left, top, barWidth, barH));

      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(left, top, barWidth, barH),
          topLeft: const Radius.circular(6),
          topRight: const Radius.circular(6),
        ),
        barPaint,
      );

      if (highlight) {
        final valStr = _compactInr(values[i]);
        final tp = TextPainter(
          text: TextSpan(
            text: valStr,
            style: TextStyle(
              color: barColor,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(
          canvas,
          Offset(left + barWidth / 2 - tp.width / 2, top - tp.height - 4),
        );
      }

      final labelPainter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(
            color: highlight ? Colors.white : AppTheme.textSecondary,
            fontSize: 10,
            fontWeight: highlight ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      labelPainter.paint(
        canvas,
        Offset(
          i * barAreaWidth + barAreaWidth / 2 - labelPainter.width / 2,
          chartHeight + 8,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}

// ─── Sparkline Painter ────────────────────────────────────────────────────────
class _SparklinePainter extends CustomPainter {
  final List<double> values;
  final Color lineColor;

  const _SparklinePainter({required this.values, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final double maxVal = values.reduce((a, b) => a > b ? a : b);
    final double minVal = values.reduce((a, b) => a < b ? a : b);
    final double range = (maxVal - minVal).clamp(1.0, double.infinity);
    final int count = values.length;

    Offset point(int i) {
      final x = count > 1 ? i * (size.width / (count - 1)) : 0.0;
      final y = size.height - ((values[i] - minVal) / range) * size.height;
      return Offset(x, y);
    }

    final path = Path();
    path.moveTo(point(0).dx, point(0).dy);
    for (int i = 0; i < count - 1; i++) {
      final p0 = point(i);
      final p1 = point(i + 1);
      final ctrl1 = Offset((p0.dx + p1.dx) / 2, p0.dy);
      final ctrl2 = Offset((p0.dx + p1.dx) / 2, p1.dy);
      path.cubicTo(ctrl1.dx, ctrl1.dy, ctrl2.dx, ctrl2.dy, p1.dx, p1.dy);
    }

    final fillPath = Path()..addPath(path, Offset.zero);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [lineColor.withAOpacity(0.22), lineColor.withAOpacity(0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, linePaint);

    final lastPoint = point(count - 1);
    canvas.drawCircle(
      lastPoint,
      4,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      lastPoint,
      4,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}

// ─── Donut Chart Painter ──────────────────────────────────────────────────────
class _DonutChartPainter extends CustomPainter {
  final List<_DonutSegment> segments;
  final String centerLabel;
  const _DonutChartPainter({required this.segments, required this.centerLabel});

  @override
  void paint(Canvas canvas, Size size) {
    if (segments.isEmpty) return;
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double radius = (size.height / 2) - 4;
    final double strokeWidth = 14.0;
    double startAngle = -math.pi / 2;

    for (final seg in segments) {
      final sweepAngle = seg.fraction * 2 * math.pi;

      final paint = Paint()
        ..color = seg.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: radius),
        startAngle + 0.04,
        sweepAngle - 0.08,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }

    final tp = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$centerLabel\n',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              height: 1.3,
            ),
          ),
          const TextSpan(
            text: 'total',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}
