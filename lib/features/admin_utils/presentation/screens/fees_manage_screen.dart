import 'dart:async';

import 'package:club_fitness/config/navigation/routes_class.dart';
import 'package:club_fitness/config/theme/theme.dart';
import 'package:club_fitness/core/utils/utils.dart';
import 'package:club_fitness/di.dart';
import 'package:club_fitness/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../admin_utils.dart';

// ─── Screen ───────────────────────────────────────────────────────────────────

class FeesManagementProvider extends StatelessWidget {
  const FeesManagementProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          FeesListingBloc(sl(), sl())..add(const GetFeesSummaryEvent()),
      child: const FeesManagementScreen(),
    );
  }
}

class FeesManagementScreen extends StatefulWidget {
  const FeesManagementScreen({super.key});
  @override
  State<FeesManagementScreen> createState() => _FeesManagementScreenState();
}

class _FeesManagementScreenState extends State<FeesManagementScreen>
    with TickerProviderStateMixin {
  late final TabController _tabCtrl;
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  String _searchQuery = '';
  String _sortBy = 'Due Date';
  final _searchCtrl = TextEditingController();

  static const _tabs = ['All', 'Pending', 'Overdue', 'Paid', 'Partial'];

  void _refreshListing([String status = '']) {
    context.read<FeesListingBloc>().add(
      GetFeesListingEvent(
        search: _searchQuery,
        sortBy: _sortBy.toPascalCase(),
        status: status.toLowerCase() == 'all' ? '' : status,
      ),
    );
  }

  Timer? _debounceTimer;

  void _searchWithDebounce() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _refreshListing();
    });
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    _tabCtrl = TabController(length: _tabs.length, vsync: this);

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();

    _searchCtrl.addListener(
      () => setState(() => _searchQuery = _searchCtrl.text.toLowerCase()),
    );
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _fadeCtrl.dispose();
    _searchCtrl.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: BlocBuilder<FeesListingBloc, FeesListingState>(
          builder: (context, state) {
            if (state is FeesListingInitial || state is SummaryLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is SummaryLoadFailure) {
              return FailureTextWidget(
                state.failure,
                onRetry: () => context.read<FeesListingBloc>().add(
                  const GetFeesSummaryEvent(),
                ),
              );
            }

            // From here on, state is always a FeesSummaryLoaded, so the
            // header/summary card can be built unconditionally and only
            // the list body swaps on FeesListingLoading/Loaded/Failure.
            final summary = (state as FeesSummaryLoaded).summary;
            final counts = summary.counts;
            return NestedScrollView(
              headerSliverBuilder: (_, __) => [
                _buildAppBar(),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      children: [
                        _buildRevenueCard(summary),
                        const SizedBox(height: 16),
                        _buildSummaryRow(summary),
                        const SizedBox(height: 16),
                        _buildSearchBar(),
                        const SizedBox(height: 14),
                      ],
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _TabBarDelegate(
                    TabBar(
                      controller: _tabCtrl,
                      isScrollable: true,
                      onTap: (value) => _refreshListing(_tabs[value]),
                      tabAlignment: TabAlignment.start,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                      indicator: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: AppTheme.textSecondary,
                      tabs: _tabs.map((t) {
                        num count;
                        switch (t.toLowerCase()) {
                          case 'all':
                            count = counts.total;
                            break;
                          case 'pending':
                            count = counts.pending;
                            break;
                          case 'overdue':
                            count = counts.overdue;
                            break;
                          case 'paid':
                            count = counts.paid;
                            break;
                          case 'partial':
                            count = counts.partial;
                            break;
                          default:
                            count = 0;
                            break;
                        }
                        return Tab(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(t),
                                const SizedBox(width: 5),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withAOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '$count',
                                    style: const TextStyle(fontSize: 10),
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
              ],
              body: Column(
                children: [
                  _buildSortRow(summary.counts.total),
                  Expanded(child: _buildListBody(state)),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildListBody(FeesListingState state) {
    if (state is FeesListingLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is FeesListingFailure) {
      return FailureTextWidget(state.failure, onRetry: () => _refreshListing());
    }
    if (state is FeesListingLoaded) {
      if (state.fees.isEmpty) return _buildEmptyState();
      return ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
        itemCount: state.fees.length,
        itemBuilder: (_, i) => _FeeCard(
          record: state.fees[i],
          onApprove: () => _approvePayment(state.fees[i]),
          onReject: () => _rejectPayment(state.fees[i]),
          onRemind: () => _sendReminder(state.fees[i]),
          onMarkPaid: () => _showMarkPaidSheet(state.fees[i]),
          onTap: () => _openDetail(state.fees[i]),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  // ── App Bar ──────────────────────────────────────────────────────────────────

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppTheme.background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
          size: 20,
        ),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: const Text(
        'Fee Management',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.ios_share_rounded,
            color: AppTheme.textSecondary,
            size: 22,
          ),
          onPressed: () => _showSnack('Exporting report…'),
        ),
        IconButton(
          icon: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
          ),
          onPressed: _showAddFeeSheet,
        ),
        const SizedBox(width: 8),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(0.5),
        child: Divider(height: 0.5, color: Colors.white12),
      ),
    );
  }

  // ── Revenue Card ─────────────────────────────────────────────────────────────

  Widget _buildRevenueCard(FeeSummaryEntity summary) {
    final total = summary.totalCollected + summary.totalOutstanding;
    final progress = total > 0 ? summary.totalCollected / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A0008), Color(0xFF1A1A1A)],
        ),
        border: Border.all(
          color: AppTheme.primary.withAOpacity(0.35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withAOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
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
                  Text(
                    'JUNE 2025',
                    style: TextStyle(
                      color: AppTheme.primary.withAOpacity(0.7),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Fee Overview',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
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
                  color: const Color(0xFF4CAF50).withAOpacity(0.14),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF4CAF50).withAOpacity(0.35),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.trending_up_rounded,
                      color: Color(0xFF4CAF50),
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}% collected',
                      style: const TextStyle(
                        color: Color(0xFF4CAF50),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Collected',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '₹${summary.totalCollected.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Color(0xFF4CAF50),
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 36,
                color: Colors.white.withAOpacity(0.1),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Outstanding',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '₹${summary.totalOutstanding.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Color(0xFFFFA000),
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withAOpacity(0.07),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                    ),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4CAF50).withAOpacity(0.4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _MiniStat(
                'Overdue',
                '${summary.counts.overdue} members',
                AppTheme.error,
              ),
              _MiniStat(
                'Partial',
                '₹${summary.counts.partial} paid',
                const Color(0xFFFFA000),
              ),
              _MiniStat(
                'Waived',
                '${summary.counts.waived} members',
                AppTheme.textSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Summary Row ──────────────────────────────────────────────────────────────

  Widget _buildSummaryRow(FeeSummaryEntity summary) {
    final counts = summary.counts;
    final items = [
      (
        counts.pending,
        'Pending Review',
        Icons.hourglass_empty_rounded,
        const Color(0xFF29B6F6),
      ),
      (counts.overdue, 'Overdue', Icons.warning_amber_rounded, AppTheme.error),
      (
        counts.paid,
        'Paid This Month',
        Icons.check_circle_rounded,
        const Color(0xFF4CAF50),
      ),
      (
        counts.total,
        'Total Records',
        Icons.receipt_long_rounded,
        AppTheme.primary,
      ),
    ];

    return Row(
      children: items.asMap().entries.map((e) {
        final i = e.key;
        final s = e.value;
        final isLast = i == items.length - 1;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: isLast ? 0 : 10),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: (s.$4).withAOpacity(0.18), width: 1),
            ),
            child: Column(
              children: [
                Icon(s.$3, color: s.$4, size: 17),
                const SizedBox(height: 5),
                Text(
                  '${s.$1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  s.$2,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Search ────────────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _searchQuery.isNotEmpty
              ? AppTheme.primary.withAOpacity(0.5)
              : Colors.white.withAOpacity(0.06),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _searchCtrl,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        onChanged: (value) => _searchWithDebounce(),
        decoration: InputDecoration(
          hintText: 'Search by name, ID or invoice…',
          hintStyle: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppTheme.textSecondary,
            size: 20,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchCtrl.clear();
                    setState(() => _searchQuery = '');
                  },
                  child: const Icon(
                    Icons.close_rounded,
                    color: AppTheme.textSecondary,
                    size: 18,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  // ── Sort Row ──────────────────────────────────────────────────────────────────

  Widget _buildSortRow(num total) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Row(
        children: [
          Text(
            '$total records',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          const Text(
            'Sort: ',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
          GestureDetector(
            onTap: _showSortSheet,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white.withAOpacity(0.08),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _sortBy,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.unfold_more_rounded,
                    color: AppTheme.textSecondary,
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty State ───────────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_rounded,
            color: AppTheme.textSecondary.withAOpacity(0.3),
            size: 54,
          ),
          const SizedBox(height: 16),
          const Text(
            'No fee records found',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try adjusting your search or filter',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ── FAB ───────────────────────────────────────────────────────────────────────

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: _showAddFeeSheet,
      backgroundColor: AppTheme.primary,
      elevation: 4,
      icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
      label: const Text(
        'Record Fee',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 13,
        ),
      ),
    );
  }

  // ── Actions ───────────────────────────────────────────────────────────────────

  void _approvePayment(FeesEntity f) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF4CAF50),
              size: 26,
            ),
            SizedBox(width: 10),
            Text(
              'Approve Payment',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        content: Text(
          'Mark ₹${f.amount.toStringAsFixed(0)} from ${f.memberName} as received?',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              _showSnack('Payment approved for ${f.memberName}');
            },
            child: const Text(
              'Approve',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _rejectPayment(FeesEntity f) {
    _showSnack('Payment rejected for ${f.memberName}');
  }

  void _sendReminder(FeesEntity f) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReminderSheet(record: f),
    );
  }

  void _showMarkPaidSheet(FeesEntity f) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MarkPaidSheet(record: f),
    );
  }

  void _openDetail(FeesEntity f) {
    context.pushNamed(
      RoutesName.feeDetails,
      extra: {'fee': f},
      pathParameters: {'id': f.id},
    );
    // Navigator.of(
    //   context,
    // ).push(MaterialPageRoute(builder: (_) => FeeDetailScreen(record: f)));
  }

  void _showAddFeeSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddFeeSheet(),
    );
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sort by',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            ...['Due Date', 'Amount', 'Name', 'Overdue Days'].map(
              (s) => GestureDetector(
                onTap: () {
                  setState(() => _sortBy = s);
                  Navigator.pop(context);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    color: _sortBy == s
                        ? AppTheme.primary.withAOpacity(0.12)
                        : AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _sortBy == s
                          ? AppTheme.primary.withAOpacity(0.4)
                          : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        s,
                        style: TextStyle(
                          color: _sortBy == s ? AppTheme.primary : Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      if (_sortBy == s)
                        const Icon(
                          Icons.check_rounded,
                          color: AppTheme.primary,
                          size: 18,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnack(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg),
      backgroundColor: AppTheme.surface,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

// ─── Fee Card ─────────────────────────────────────────────────────────────────

class _FeeCard extends StatelessWidget {
  final FeesEntity record;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onRemind;
  final VoidCallback onMarkPaid;
  final VoidCallback onTap;

  const _FeeCard({
    required this.record,
    required this.onApprove,
    required this.onReject,
    required this.onRemind,
    required this.onMarkPaid,
    required this.onTap,
  });

  Color get _statusColor => switch (record.statusEnum) {
    FeeStatus.paid => const Color(0xFF4CAF50),
    FeeStatus.pending => const Color(0xFF29B6F6),
    FeeStatus.overdue => AppTheme.error,
    FeeStatus.partial => const Color(0xFFFFA000),
    FeeStatus.waived => AppTheme.textSecondary,
  };

  String get _statusLabel => switch (record.statusEnum) {
    FeeStatus.paid => 'Paid',
    FeeStatus.pending => 'Pending Review',
    FeeStatus.overdue => 'Overdue',
    FeeStatus.partial => 'Partial',
    FeeStatus.waived => 'Waived',
  };

  IconData get _statusIcon => switch (record.statusEnum) {
    FeeStatus.paid => Icons.check_circle_rounded,
    FeeStatus.pending => Icons.hourglass_empty_rounded,
    FeeStatus.overdue => Icons.warning_amber_rounded,
    FeeStatus.partial => Icons.pie_chart_rounded,
    FeeStatus.waived => Icons.do_not_disturb_rounded,
  };

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final isPending = record.statusEnum == FeeStatus.pending;
    final isOverdue = record.statusEnum == FeeStatus.overdue;
    final isPartial = record.statusEnum == FeeStatus.partial;
    final hasReceipt = record.receiptUrl.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isOverdue
                ? AppTheme.error.withAOpacity(0.25)
                : isPending
                ? const Color(0xFF29B6F6).withAOpacity(0.2)
                : Colors.white.withAOpacity(0.05),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            // ── Main info ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: record.memberColor.withAOpacity(0.2),
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(
                        color: record.memberColor.withAOpacity(0.4),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        record.memberInitials,
                        style: TextStyle(
                          color: record.memberColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    record.memberName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    record.plan,
                                    style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Status badge
                            _StatusBadge(
                              label: _statusLabel,
                              color: _statusColor,
                              icon: _statusIcon,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            // Amount
                            Text(
                              '₹${record.amount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                            if (isPartial && record.paidAmount != 0) ...[
                              const SizedBox(width: 6),
                              Text(
                                '(₹${record.paidAmount.toStringAsFixed(0)} paid)',
                                style: const TextStyle(
                                  color: Color(0xFFFFA000),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                            const Spacer(),
                            // Invoice ID
                            Text(
                              record.id,
                              style: TextStyle(
                                color: Colors.white.withAOpacity(0.25),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Dates row
                        Row(
                          children: [
                            Icon(
                              isOverdue
                                  ? Icons.timer_off_rounded
                                  : Icons.calendar_today_rounded,
                              size: 11,
                              color: isOverdue
                                  ? AppTheme.error
                                  : AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isOverdue
                                  ? '${record.overdueDays} days overdue · Due ${_formatDate(record.dueDate.toDateTime)}'
                                  : 'Due ${_formatDate(record.dueDate.toDateTime)}',
                              style: TextStyle(
                                color: isOverdue
                                    ? AppTheme.error
                                    : AppTheme.textSecondary,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (record.statusEnum == FeeStatus.paid &&
                                record.paidDate.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.check_rounded,
                                size: 11,
                                color: Color(0xFF4CAF50),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                'Paid ${_formatDate(record.paidDate.toDateTime)}',
                                style: const TextStyle(
                                  color: Color(0xFF4CAF50),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                        // Receipt badge
                        if (hasReceipt) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF29B6F6,
                                  ).withAOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: const Color(
                                      0xFF29B6F6,
                                    ).withAOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.attach_file_rounded,
                                      size: 10,
                                      color: Color(0xFF29B6F6),
                                    ),
                                    SizedBox(width: 3),
                                    Text(
                                      'Receipt uploaded',
                                      style: TextStyle(
                                        color: Color(0xFF29B6F6),
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Partial progress bar ───────────────────────────────────────
            if (isPartial && record.paidAmount != 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₹${record.paidAmount.toStringAsFixed(0)} of ₹${record.amount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Color(0xFFFFA000),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Balance: ₹${(record.amount - record.paidAmount).toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: record.paidAmount / record.amount,
                        minHeight: 5,
                        backgroundColor: Colors.white.withAOpacity(0.07),
                        valueColor: const AlwaysStoppedAnimation(
                          Color(0xFFFFA000),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // ── Action bar ─────────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surface.withAOpacity(0.5),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(18),
                ),
                border: const Border(
                  top: BorderSide(color: Colors.white10, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  if (isPending) ...[
                    _ActionBtn(
                      icon: Icons.close_rounded,
                      label: 'Reject',
                      color: AppTheme.error,
                      onTap: onReject,
                    ),
                    _VDivider(),
                    _ActionBtn(
                      icon: Icons.check_rounded,
                      label: 'Approve',
                      color: const Color(0xFF4CAF50),
                      onTap: onApprove,
                    ),
                  ] else if (isOverdue || isPartial) ...[
                    _ActionBtn(
                      icon: Icons.notifications_outlined,
                      label: 'Remind',
                      color: const Color(0xFF29B6F6),
                      onTap: onRemind,
                    ),
                    _VDivider(),
                    _ActionBtn(
                      icon: Icons.payments_outlined,
                      label: 'Mark Paid',
                      color: const Color(0xFF4CAF50),
                      onTap: onMarkPaid,
                    ),
                    _VDivider(),
                    _ActionBtn(
                      icon: Icons.open_in_new_rounded,
                      label: 'Details',
                      color: AppTheme.textSecondary,
                      onTap: onTap,
                    ),
                  ] else ...[
                    _ActionBtn(
                      icon: Icons.receipt_rounded,
                      label: 'Invoice',
                      color: AppTheme.textSecondary,
                      onTap: onTap,
                    ),
                    _VDivider(),
                    _ActionBtn(
                      icon: Icons.open_in_new_rounded,
                      label: 'Details',
                      color: AppTheme.textSecondary,
                      onTap: onTap,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Fee Detail Screen ────────────────────────────────────────────────────────

class FeeDetailScreen extends StatelessWidget {
  final FeesEntity record;
  const FeeDetailScreen({super.key, required this.record});

  Color get _statusColor => switch (record.statusEnum) {
    FeeStatus.paid => const Color(0xFF4CAF50),
    FeeStatus.pending => const Color(0xFF29B6F6),
    FeeStatus.overdue => AppTheme.error,
    FeeStatus.partial => const Color(0xFFFFA000),
    FeeStatus.waived => AppTheme.textSecondary,
  };

  String get _statusLabel => switch (record.statusEnum) {
    FeeStatus.paid => 'Paid',
    FeeStatus.pending => 'Pending Review',
    FeeStatus.overdue => 'Overdue',
    FeeStatus.partial => 'Partial',
    FeeStatus.waived => 'Waived',
  };

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

  String get _methodLabel => switch (record.paymentMethodEnum) {
    PaymentMethod.cash => 'Cash',
    PaymentMethod.upi => 'UPI',
    PaymentMethod.bankTransfer => 'Bank Transfer',
    PaymentMethod.other => 'Other',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: AppTheme.background,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.share_rounded,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _statusColor.withAOpacity(0.2),
                      AppTheme.background,
                    ],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(24, 80, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: record.memberColor.withAOpacity(0.2),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: record.memberColor.withAOpacity(0.5),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              record.memberInitials,
                              style: TextStyle(
                                color: record.memberColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                record.memberName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  Text(
                                    record.id,
                                    style: TextStyle(
                                      color: Colors.white.withAOpacity(0.35),
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  _StatusBadge(
                                    label: _statusLabel,
                                    color: _statusColor,
                                    icon: Icons.circle,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Amount card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.card,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: _statusColor.withAOpacity(0.25),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Invoice Amount',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '₹${record.amount.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -1,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: _statusColor.withAOpacity(0.14),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              _statusIcon,
                              color: _statusColor,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                      if (record.statusEnum == FeeStatus.partial &&
                          record.paidAmount != 0) ...[
                        const SizedBox(height: 14),
                        const Divider(color: Colors.white12),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _AmountRow(
                              'Paid',
                              '₹${record.paidAmount.toStringAsFixed(0)}',
                              const Color(0xFF4CAF50),
                            ),
                            _AmountRow(
                              'Balance',
                              '₹${(record.amount - record.paidAmount).toStringAsFixed(0)}',
                              const Color(0xFFFFA000),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Payment details
                const _SectionTitle('Payment Details'),
                const SizedBox(height: 12),
                _InfoCard(
                  rows: [
                    _InfoRowData(
                      Icons.inventory_2_rounded,
                      'Plan',
                      record.plan,
                    ),
                    _InfoRowData(
                      Icons.calendar_today_rounded,
                      'Due Date',
                      _formatDate(record.dueDate.toDateTime),
                    ),
                    if (record.paidDate.isNotEmpty)
                      _InfoRowData(
                        Icons.check_circle_outline_rounded,
                        'Paid On',
                        _formatDate(record.paidDate.toDateTime),
                      ),
                    _InfoRowData(Icons.payment_rounded, 'Method', _methodLabel),
                    if (record.notes.isNotEmpty)
                      _InfoRowData(Icons.note_rounded, 'Notes', record.notes),
                  ],
                ),

                if (record.receiptUrl.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const _SectionTitle('Payment Receipt'),
                  const SizedBox(height: 12),
                  Container(
                    height: 140,
                    decoration: BoxDecoration(
                      color: AppTheme.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF29B6F6).withAOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.image_rounded,
                          color: Color(0xFF29B6F6),
                          size: 36,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Receipt Image',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          record.receiptUrl,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF29B6F6).withAOpacity(0.14),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'View Full Image',
                            style: TextStyle(
                              color: Color(0xFF29B6F6),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),
                const _SectionTitle('Actions'),
                const SizedBox(height: 12),
                _ActionsGrid(record: record),
                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  IconData get _statusIcon => switch (record.statusEnum) {
    FeeStatus.paid => Icons.check_circle_rounded,
    FeeStatus.pending => Icons.hourglass_empty_rounded,
    FeeStatus.overdue => Icons.warning_amber_rounded,
    FeeStatus.partial => Icons.pie_chart_rounded,
    FeeStatus.waived => Icons.do_not_disturb_rounded,
  };
}

class _AmountRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _AmountRow(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
      ),
      Text(
        value,
        style: TextStyle(
          color: color,
          fontSize: 18,
          fontWeight: FontWeight.w900,
        ),
      ),
    ],
  );
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.w800,
    ),
  );
}

class _InfoRowData {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRowData(this.icon, this.label, this.value);
}

class _InfoCard extends StatelessWidget {
  final List<_InfoRowData> rows;
  const _InfoCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAOpacity(0.05), width: 1),
      ),
      child: Column(
        children: rows.asMap().entries.map((e) {
          final i = e.key;
          final row = e.value;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: i < rows.length - 1
                  ? const Border(
                      bottom: BorderSide(color: Colors.white10, width: 0.5),
                    )
                  : null,
            ),
            child: Row(
              children: [
                Icon(row.icon, color: AppTheme.textSecondary, size: 16),
                const SizedBox(width: 10),
                Text(
                  '${row.label}: ',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
                Expanded(
                  child: Text(
                    row.value,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ActionsGrid extends StatelessWidget {
  final FeesEntity record;
  const _ActionsGrid({required this.record});

  @override
  Widget build(BuildContext context) {
    final actions = [
      if (record.statusEnum == FeeStatus.pending) ...[
        ('Approve', Icons.check_rounded, const Color(0xFF4CAF50)),
        ('Reject', Icons.close_rounded, AppTheme.error),
      ],
      if (record.statusEnum == FeeStatus.overdue ||
          record.statusEnum == FeeStatus.partial) ...[
        ('Mark Paid', Icons.payments_rounded, const Color(0xFF4CAF50)),
        ('Send Reminder', Icons.notifications_rounded, const Color(0xFF29B6F6)),
        ('Waive Fee', Icons.do_not_disturb_rounded, AppTheme.textSecondary),
      ],
      ('View Receipt', Icons.attach_file_rounded, const Color(0xFF29B6F6)),
      ('Edit Record', Icons.edit_rounded, const Color(0xFFFFA000)),
      ('Delete', Icons.delete_rounded, AppTheme.error),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.4,
      children: actions
          .map(
            (a) => GestureDetector(
              onTap: () {},
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: (a.$3).withAOpacity(0.2), width: 1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(a.$2, color: a.$3, size: 22),
                    const SizedBox(height: 6),
                    Text(
                      a.$1,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: a.$3,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

// ─── Mark Paid Sheet ──────────────────────────────────────────────────────────

class _MarkPaidSheet extends StatefulWidget {
  final FeesEntity record;
  const _MarkPaidSheet({required this.record});
  @override
  State<_MarkPaidSheet> createState() => _MarkPaidSheetState();
}

class _MarkPaidSheetState extends State<_MarkPaidSheet> {
  PaymentMethod _method = PaymentMethod.cash;
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _amountCtrl.text = widget.record.amount.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: ListView(
          controller: ctrl,
          padding: EdgeInsets.fromLTRB(
            24,
            16,
            24,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withAOpacity(0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.payments_rounded,
                    color: Color(0xFF4CAF50),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mark as Paid',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      widget.record.memberName,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            const _SheetLabel('Amount Received'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF4CAF50).withAOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(
                          color: Colors.white.withAOpacity(0.07),
                        ),
                      ),
                    ),
                    child: const Text(
                      '₹',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _amountCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const _SheetLabel('Payment Method'),
            const SizedBox(height: 10),
            Row(
              children: PaymentMethod.values.map((m) {
                final labels = {
                  PaymentMethod.cash: ('Cash', Icons.payments_rounded),
                  PaymentMethod.upi: ('UPI', Icons.phone_android_rounded),
                  PaymentMethod.bankTransfer: (
                    'Bank',
                    Icons.account_balance_rounded,
                  ),
                  PaymentMethod.other: ('Other', Icons.more_horiz_rounded),
                };
                final info = labels[m]!;
                final sel = _method == m;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _method = m),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      margin: EdgeInsets.only(
                        right: m != PaymentMethod.other ? 8 : 0,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: sel
                            ? const Color(0xFF4CAF50).withAOpacity(0.12)
                            : AppTheme.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: sel
                              ? const Color(0xFF4CAF50).withAOpacity(0.5)
                              : Colors.white.withAOpacity(0.07),
                          width: sel ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            info.$2,
                            color: sel
                                ? const Color(0xFF4CAF50)
                                : AppTheme.textSecondary,
                            size: 18,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            info.$1,
                            style: TextStyle(
                              color: sel
                                  ? Colors.white
                                  : AppTheme.textSecondary,
                              fontSize: 10,
                              fontWeight: sel
                                  ? FontWeight.w800
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const _SheetLabel('Notes (optional)'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _noteCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Add any notes…',
                  hintStyle: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(14),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Fee marked as paid for ${widget.record.memberName}',
                    ),
                    backgroundColor: AppTheme.surface,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Confirm Payment',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Reminder Sheet ───────────────────────────────────────────────────────────

class _ReminderSheet extends StatefulWidget {
  final FeesEntity record;
  const _ReminderSheet({required this.record});
  @override
  State<_ReminderSheet> createState() => _ReminderSheetState();
}

class _ReminderSheetState extends State<_ReminderSheet> {
  bool _push = true, _whatsapp = true, _sms = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF29B6F6).withAOpacity(0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.notifications_rounded,
                  color: Color(0xFF29B6F6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Send Fee Reminder',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    widget.record.memberName,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Preview message
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withAOpacity(0.06),
                width: 1,
              ),
            ),
            child: Text(
              'Hi ${widget.record.memberName.split(' ').first}, your ${widget.record.plan} fee of ₹${widget.record.amount.toStringAsFixed(0)} is ${widget.record.overdueDays > 0 ? '${widget.record.overdueDays} days overdue' : 'due soon'}. Please pay at the earliest. — Club Fitness',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Send via',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          _ChannelToggle(
            Icons.notifications_rounded,
            'Push Notification',
            const Color(0xFF29B6F6),
            _push,
            (v) => setState(() => _push = v),
          ),
          const SizedBox(height: 8),
          _ChannelToggle(
            Icons.chat_rounded,
            'WhatsApp',
            const Color(0xFF4CAF50),
            _whatsapp,
            (v) => setState(() => _whatsapp = v),
          ),
          const SizedBox(height: 8),
          _ChannelToggle(
            Icons.sms_rounded,
            'SMS',
            const Color(0xFFFFA000),
            _sms,
            (v) => setState(() => _sms = v),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Reminder sent to ${widget.record.memberName}'),
                  backgroundColor: AppTheme.surface,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF29B6F6),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Send Reminder',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChannelToggle extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ChannelToggle(
    this.icon,
    this.label,
    this.color,
    this.value,
    this.onChanged,
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: value ? color.withAOpacity(0.08) : AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value
                ? color.withAOpacity(0.4)
                : Colors.white.withAOpacity(0.06),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: value ? color : AppTheme.textSecondary, size: 18),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: value ? Colors.white : AppTheme.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: value ? color : Colors.transparent,
                border: Border.all(
                  color: value ? color : Colors.white.withAOpacity(0.2),
                  width: 2,
                ),
              ),
              child: value
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 13,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Add Fee Sheet ────────────────────────────────────────────────────────────

class _AddFeeSheet extends StatefulWidget {
  const _AddFeeSheet();
  @override
  State<_AddFeeSheet> createState() => _AddFeeSheetState();
}

class _AddFeeSheetState extends State<_AddFeeSheet> {
  String _selectedPlan = 'Basic Monthly';
  final PaymentMethod _method = PaymentMethod.cash;
  FeeStatus _status = FeeStatus.paid;
  final _plans = [
    ('Basic Monthly', '₹1,500'),
    ('Premium Monthly', '₹3,000'),
    ('Quarterly', '₹5,500'),
    ('Annual Plan', '₹18,000'),
  ];

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: ListView(
          controller: ctrl,
          padding: EdgeInsets.fromLTRB(
            24,
            16,
            24,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withAOpacity(0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.receipt_long_rounded,
                    color: AppTheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Record New Fee',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const _SheetLabel('Member'),
            const SizedBox(height: 8),
            const _SheetField(
              hint: 'Search member name or ID…',
              icon: Icons.person_search_rounded,
            ),
            const SizedBox(height: 16),
            const _SheetLabel('Membership Plan'),
            const SizedBox(height: 10),
            ..._plans.map(
              (p) => GestureDetector(
                onTap: () => setState(() => _selectedPlan = p.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: _selectedPlan == p.$1
                        ? AppTheme.primary.withAOpacity(0.1)
                        : AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedPlan == p.$1
                          ? AppTheme.primary.withAOpacity(0.5)
                          : Colors.white.withAOpacity(0.06),
                      width: _selectedPlan == p.$1 ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        p.$1,
                        style: TextStyle(
                          color: _selectedPlan == p.$1
                              ? Colors.white
                              : AppTheme.textSecondary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        p.$2,
                        style: TextStyle(
                          color: _selectedPlan == p.$1
                              ? AppTheme.primary
                              : AppTheme.textSecondary,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                      if (_selectedPlan == p.$1) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.check_rounded,
                          color: AppTheme.primary,
                          size: 16,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SheetLabel('Due Date'),
                      SizedBox(height: 8),
                      _SheetField(
                        hint: 'DD / MM / YYYY',
                        icon: Icons.calendar_today_rounded,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SheetLabel('Status'),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButton<FeeStatus>(
                          value: _status,
                          isExpanded: true,
                          dropdownColor: AppTheme.card,
                          underline: const SizedBox(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                          items:
                              [
                                    FeeStatus.pending,
                                    FeeStatus.paid,
                                    FeeStatus.partial,
                                    FeeStatus.waived,
                                  ]
                                  .map(
                                    (s) => DropdownMenuItem(
                                      value: s,
                                      child: Text(
                                        s.name[0].toUpperCase() +
                                            s.name.substring(1),
                                      ),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (v) => setState(() => _status = v!),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const _SheetLabel('Notes (optional)'),
            const SizedBox(height: 8),
            const _SheetField(
              hint: 'Any additional notes…',
              icon: Icons.note_rounded,
              maxLines: 2,
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Save Fee Record',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shared small widgets ─────────────────────────────────────────────────────

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MiniStat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 9),
      ),
      Text(
        value,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    ],
  );
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  const _StatusBadge({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withAOpacity(0.12),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withAOpacity(0.35), width: 1),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 10),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
      ],
    ),
  );
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            Icon(icon, color: color, size: 17),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _VDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 0.5, height: 36, color: Colors.white10);
}

class _SheetLabel extends StatelessWidget {
  final String text;
  const _SheetLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      color: AppTheme.textSecondary,
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.3,
    ),
  );
}

class _SheetField extends StatelessWidget {
  final String hint;
  final IconData icon;
  final int maxLines;
  const _SheetField({
    required this.hint,
    required this.icon,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.white.withAOpacity(0.06), width: 1),
    ),
    child: TextField(
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 18),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
    ),
  );
}

// ─── Tab bar persistent header delegate ───────────────────────────────────────

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  const _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => 42;
  @override
  double get maxExtent => 42;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => Container(color: AppTheme.background, child: tabBar);

  @override
  bool shouldRebuild(_TabBarDelegate old) => false;
}
