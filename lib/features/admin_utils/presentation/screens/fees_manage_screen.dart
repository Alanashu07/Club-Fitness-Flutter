import 'dart:async';
import 'dart:io';
import 'package:club_fitness/config/network/api.dart';
import 'package:club_fitness/features/image_cache/image_cache.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:club_fitness/config/navigation/routes_class.dart';
import 'package:club_fitness/config/theme/theme.dart';
import 'package:club_fitness/core/utils/utils.dart';
import 'package:club_fitness/di.dart';
import 'package:club_fitness/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

import '../../admin_utils.dart';

// ─── Constants ────────────────────────────────────────────────────────────────

const _kGreen = Color(0xFF4CAF50);
const _kBlue = Color(0xFF29B6F6);
const _kAmber = Color(0xFFFFA000);

/// Tabs map 1:1 to the `status` query param of GET /api/admin/fees.
const _kTabs = ['All', 'Pending', 'Overdue', 'Paid', 'Partial', 'Waived'];

/// UI label -> `sortBy` query param (dueDate|amount|name|overdueDays).
const _kSortOptions = {
  'Due Date': 'dueDate',
  'Amount': 'amount',
  'Name': 'name',
  'Overdue Days': 'overdueDays',
};

String _fmtDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
String _money(num v) => '₹${v.toStringAsFixed(0)}';

// ─── Provider ─────────────────────────────────────────────────────────────────

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

// ─── Screen ───────────────────────────────────────────────────────────────────

String _successMessage(FeeActionsSuccess s) => switch (s.action) {
  FeeActions.approve => 'Payment approved',
  FeeActions.reject => 'Payment rejected',
  FeeActions.create => 'Fee record created',
  FeeActions.update => 'Fee record updated',
  FeeActions.markPaid => 'Payment recorded',
  FeeActions.waive => 'Fee waived',
  FeeActions.remind => 'Reminder sent via selected channels',
  FeeActions.receipt => 'Receipt attached',
  FeeActions.delete => s.message ?? 'Fee record deleted',
  FeeActions.export => 'Report ready',
};

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

  String _status = 'All';
  String _sortBy = 'Due Date';
  final _searchCtrl = TextEditingController();
  Timer? _debounceTimer;

  String get _search => _searchCtrl.text.trim();
  String get _statusParam => _status == 'All' ? '' : _status;
  String get _sortParam => _kSortOptions[_sortBy] ?? 'dueDate';

  FeesListingBloc get _listingBloc => context.read<FeesListingBloc>();
  FeeActionsBloc get _actionsBloc => context.read<FeeActionsBloc>();

  /// Re-fetch page 1 of the listing with the current filters (shows loader).
  void _refreshListing() {
    _listingBloc.add(
      GetFeesListingEvent(
        search: _search,
        sortBy: _sortParam,
        status: _statusParam,
      ),
    );
  }

  /// Re-fetch summary + listing silently (used after any mutation).
  void _refreshAll() {
    _listingBloc.add(
      const GetFeesSummaryEvent(continueLoading: false, silent: true),
    );
    _listingBloc.add(
      GetFeesListingEvent(
        silent: true,
        search: _search,
        sortBy: _sortParam,
        status: _statusParam,
      ),
    );
  }

  void _searchWithDebounce() {
    setState(() {}); // updates clear icon / border
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), _refreshListing);
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
    _tabCtrl = TabController(length: _kTabs.length, vsync: this);
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _fadeCtrl.dispose();
    _searchCtrl.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: BlocListener<FeeActionsBloc, FeeActionsState>(
          listenWhen: (_, s) =>
              s is FeeActionsSuccess || s is FeeActionsFailure,
          listener: (context, state) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            if (state is FeeActionsSuccess) {
              if (state.action == FeeActions.export) {
                _openPdf(state.pdfBytes);
                return;
              }
              _showSnack(_successMessage(state));
              if (state.action != FeeActions.remind) _refreshAll();
            } else if (state is FeeActionsFailure) {
              _showSnack(state.failure.message, isError: true);
            }
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              BlocBuilder<FeesListingBloc, FeesListingState>(
                builder: (context, state) {
                  if (state is FeesListingInitial || state is SummaryLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is SummaryLoadFailure) {
                    return FailureTextWidget(
                      state.failure,
                      onRetry: () =>
                          _listingBloc.add(const GetFeesSummaryEvent()),
                    );
                  }

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
                        delegate: _TabBarDelegate(_buildTabBar(counts)),
                      ),
                    ],
                    body: Column(
                      children: [
                        _buildSortRow(state),
                        Expanded(child: _buildListBody(state)),
                      ],
                    ),
                  );
                },
              ),
              BlocBuilder<FeeActionsBloc, FeeActionsState>(
                buildWhen: (p, c) =>
                    p is FeeActionsLoading || c is FeeActionsLoading,
                builder: (_, s) =>
                    s is FeeActionsLoading && s.action != FeeActions.export
                    ? const _BlockingLoader()
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
      // floatingActionButton: _buildFAB(),
    );
  }

  Future<void> _openPdf(List<int>? bytes) async {
    if (bytes == null || bytes.isEmpty) {
      _showSnack('The report was empty', isError: true);
      return;
    }
    final dir = await getApplicationDocumentsDirectory();
    final file = File(
      '${dir.path}/fee-report-${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(bytes);
    if (!mounted) return;
    _onExported(context, file.path);
  }

  TabBar _buildTabBar(dynamic counts) {
    num countFor(String tab) {
      switch (tab.toLowerCase()) {
        case 'all':
          return counts.total;
        case 'pending':
          return counts.pending;
        case 'overdue':
          return counts.overdue;
        case 'paid':
          return counts.paid;
        case 'partial':
          return counts.partial;
        case 'waived':
          return counts.waived;
        default:
          return 0;
      }
    }

    return TabBar(
      controller: _tabCtrl,
      isScrollable: true,
      onTap: (i) {
        setState(() => _status = _kTabs[i]);
        _refreshListing();
      },
      tabAlignment: TabAlignment.start,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      labelPadding: const EdgeInsets.symmetric(horizontal: 6),
      indicator: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: Colors.transparent,
      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
      unselectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      labelColor: Colors.white,
      unselectedLabelColor: AppTheme.textSecondary,
      tabs: _kTabs.map((t) {
        return Tab(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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
                    '${countFor(t)}',
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildListBody(FeesListingState state) {
    if (state is FeesListingLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is FeesListingFailure) {
      return FailureTextWidget(state.failure, onRetry: _refreshListing);
    }
    if (state is FeesListingLoaded) {
      if (state.fees.isEmpty) return _buildEmptyState();
      final isLoadingMore = state is FeesLoadingMore;
      final itemCount = state.fees.length + (isLoadingMore ? 1 : 0);
      return RefreshIndicator(
        color: AppTheme.primary,
        onRefresh: () async => _refreshAll(),
        child: NotificationListener<ScrollNotification>(
          onNotification: (n) {
            if (n.depth == 0 &&
                n is ScrollUpdateNotification &&
                n.metrics.extentAfter < 300 &&
                !isLoadingMore) {
              _listingBloc.add(const GetMoreFeesListingEvent());
            }
            return false;
          },
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
            itemCount: itemCount,
            itemBuilder: (_, i) {
              if (i >= state.fees.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              }
              final fee = state.fees[i];
              return _FeeCard(
                record: fee,
                onApprove: () => _approvePayment(fee),
                onReject: () => _rejectPayment(fee),
                onRemind: () => context.showToast(
                  'This feature is coming soon',
                  type: ToastificationType.info,
                ),
                onMarkPaid: () => _showMarkPaidSheet(fee, null),
                onTap: () => _openDetail(fee),
                onLongPress: () => _showManageSheet(fee),
              );
            },
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  // ── App Bar ─────────────────────────────────────────────────────────────────

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
          tooltip: 'Export PDF',
          icon: const Icon(
            Icons.ios_share_rounded,
            color: AppTheme.textSecondary,
            size: 22,
          ),
          onPressed: _exportPdf,
        ),
        // IconButton(
        //   icon: Container(
        //     width: 34,
        //     height: 34,
        //     decoration: BoxDecoration(
        //       color: AppTheme.primary,
        //       borderRadius: BorderRadius.circular(10),
        //     ),
        //     child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
        //   ),
        //   onPressed: _showAddFeeSheet,
        // ),
        const SizedBox(width: 8),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(0.5),
        child: Divider(height: 0.5, color: Colors.white12),
      ),
    );
  }

  // ── Revenue Card ────────────────────────────────────────────────────────────

  Widget _buildRevenueCard(FeeSummaryEntity summary) {
    // Server computes collected / (collected + outstanding).
    final progress = summary.collectedProgress.toDouble().clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A0008), Color(0xFF1A1A1A)],
        ),
        border: Border.all(color: AppTheme.primary.withAOpacity(0.35)),
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
                    'ALL TIME',
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
                  color: _kGreen.withAOpacity(0.14),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _kGreen.withAOpacity(0.35)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.trending_up_rounded,
                      color: _kGreen,
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}% collected',
                      style: const TextStyle(
                        color: _kGreen,
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
                child: _RevenueFigure(
                  label: 'Collected',
                  value: _money(summary.totalCollected),
                  color: _kGreen,
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
                  child: _RevenueFigure(
                    label: 'Outstanding',
                    value: _money(summary.totalOutstanding),
                    color: _kAmber,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
                widthFactor: progress,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_kGreen, Color(0xFF81C784)],
                    ),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: _kGreen.withAOpacity(0.4),
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
                '${summary.counts.overdue} invoices',
                AppTheme.error,
              ),
              _MiniStat(
                'Partial',
                '${_money(summary.totalPartialPaid)} received',
                _kAmber,
              ),
              _MiniStat(
                'Waived',
                '${summary.counts.waived} invoices',
                AppTheme.textSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Summary Row ─────────────────────────────────────────────────────────────

  Widget _buildSummaryRow(FeeSummaryEntity summary) {
    final c = summary.counts;
    final items = [
      (c.pending, 'Pending', Icons.hourglass_empty_rounded, _kBlue),
      (c.overdue, 'Overdue', Icons.warning_amber_rounded, AppTheme.error),
      (c.paid, 'Paid', Icons.check_circle_rounded, _kGreen),
      (c.total, 'Total Records', Icons.receipt_long_rounded, AppTheme.primary),
    ];

    return Row(
      children: items.asMap().entries.map((e) {
        final isLast = e.key == items.length - 1;
        final s = e.value;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: isLast ? 0 : 10),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: s.$4.withAOpacity(0.18)),
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

  // ── Search ──────────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    final hasQuery = _searchCtrl.text.isNotEmpty;
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasQuery
              ? AppTheme.primary.withAOpacity(0.5)
              : Colors.white.withAOpacity(0.06),
        ),
      ),
      child: TextField(
        controller: _searchCtrl,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        onChanged: (_) => _searchWithDebounce(),
        decoration: InputDecoration(
          hintText: 'Search by name, phone or invoice ID…',
          hintStyle: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppTheme.textSecondary,
            size: 20,
          ),
          suffixIcon: hasQuery
              ? GestureDetector(
                  onTap: () {
                    _searchCtrl.clear();
                    _debounceTimer?.cancel();
                    setState(() {});
                    _refreshListing();
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

  // ── Sort Row ────────────────────────────────────────────────────────────────

  String _recordsLabel(FeesListingState state) {
    if (state is! FeesListingLoaded) return '';
    if (_search.isNotEmpty) return 'Showing ${state.fees.length} results';
    final c = state.summary.counts;
    final n = switch (_status) {
      'Pending' => c.pending,
      'Overdue' => c.overdue,
      'Paid' => c.paid,
      'Partial' => c.partial,
      'Waived' => c.waived,
      _ => c.total,
    };
    return '$n ${_status == 'All' ? '' : '${_status.toLowerCase()} '}records';
  }

  Widget _buildSortRow(FeesListingState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Row(
        children: [
          Text(
            _recordsLabel(state),
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
                border: Border.all(color: Colors.white.withAOpacity(0.08)),
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

  // ── Empty State / FAB ───────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    final filtered = _search.isNotEmpty || _status != 'All';
    final title = filtered ? 'No matching fee records' : 'No fee records yet';
    final subtitle = filtered
        ? 'No ${_status == 'All' ? '' : '${_status.toLowerCase()} '}invoices'
              '${_search.isNotEmpty ? ' for "$_search"' : ''}'
        : 'Create a member to get started';

    return RefreshIndicator(
      onRefresh: () async => _refreshAll(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 80),
          Icon(
            Icons.receipt_long_rounded,
            color: AppTheme.textSecondary.withAOpacity(0.3),
            size: 54,
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              subtitle,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          if (filtered)
            Center(
              child: TextButton(
                onPressed: () {
                  _searchCtrl.clear();
                  setState(() => _status = 'All');
                  _tabCtrl.animateTo(0);
                  _refreshListing();
                },
                child: const Text('Clear filters'),
              ),
            ),
        ],
      ),
    );
  }

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

  // ── Actions (each maps to one endpoint) ─────────────────────────────────────

  /// PATCH /fees/:id/approve
  void _approvePayment(FeesEntity f) {
    showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: _kGreen, size: 26),
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
          'Mark ${_money(f.amount)} from ${f.memberName} as received?',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _kGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(dCtx);
              _actionsBloc.add(ApproveFeesEvent(f.id));
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

  /// PATCH /fees/:id/reject  (body: reason?)
  Future<void> _rejectPayment(FeesEntity f) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => _ReasonDialog(
        title: 'Reject Payment',
        subtitle: f.memberName,
        hint: 'Reason (optional)…',
        confirmLabel: 'Reject',
        color: AppTheme.error,
        icon: Icons.close_rounded,
      ),
    );
    if (reason == null || !mounted) return;
    _actionsBloc.add(RejectFeesEvent(f.id, reason: reason));
  }

  /// PATCH /fees/:id/waive  (body: reason?)
  Future<void> _waiveFee(FeesEntity f) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => _ReasonDialog(
        title: 'Waive Fee',
        subtitle:
            '${f.memberName} · ${_money(f.balance)} outstanding will be waived',
        hint: 'Reason (optional)…',
        confirmLabel: 'Waive',
        color: _kAmber,
        icon: Icons.do_not_disturb_rounded,
      ),
    );
    if (reason == null || !mounted) return;
    _actionsBloc.add(WaiveFeeEvent(f.id, reason: reason));
  }

  /// PATCH /fees/:id/mark-paid  (body: amountReceived, method, notes?)
  void _showMarkPaidSheet(FeesEntity? f, FeeEntity? d) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MarkPaidSheet(
        record: f,
        detail: d,
        onSubmit: (amount, method, notes) => _actionsBloc.add(
          MarkFeePaidEvent(
            f?.id ?? d?.id ?? '',
            amountReceived: amount,
            method: method.name, // cash | upi | bankTransfer | other
            notes: notes,
          ),
        ),
      ),
    );
  }

  /// POST /fees
  void _showAddFeeSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddFeeSheet(
        onSubmit: (data) => _actionsBloc.add(
          CreateFeeEvent(
            memberId: data.memberId,
            planId: data.planId,
            amount: data.amount,
            dueDate: data.dueDate.toIso8601String(),
            status: data.status,
            paidAmount: data.paidAmount,
            paymentMethod: data.paymentMethod,
            notes: data.notes,
          ),
        ),
      ),
    );
  }

  /// PATCH /fees/:id  (any subset of amount, dueDate, planId, notes)
  void _showEditSheet(FeesEntity? f, FeeEntity? d) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditFeeSheet(
        record: f,
        detail: d,
        onSubmit: (data) => _actionsBloc.add(
          UpdateFeeEvent(
            f?.id ?? d?.id ?? '',
            amount: data.amount,
            dueDate: data.dueDate?.toIso8601String(),
            planId: data.planId,
            notes: data.notes,
          ),
        ),
      ),
    );
  }

  /// DELETE /fees/:id
  void _confirmDelete(FeesEntity f) {
    showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete fee record?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
        content: Text(
          '${f.id} for ${f.memberName} will be permanently removed.',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(dCtx);
              _actionsBloc.add(DeleteFeeEvent(f.id));
            },
            child: const Text(
              'Delete',
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

  /// GET /fees/export/pdf — same filters as the listing, never paginated.
  void _exportPdf() {
    _showSnack('Exporting report…');
    _actionsBloc.add(
      ExportFeesPdfEvent(
        search: _search,
        sortBy: _sortParam,
        status: _statusParam,
      ),
    );
  }

  Future<void> _openDetail(FeesEntity f) async {
    await context.pushNamed(
      RoutesName.feeDetails,
      extra: {'fee': f},
      pathParameters: {'id': f.id},
    );
    if (mounted) _refreshAll();
  }

  /// Long-press menu: edit / waive / delete.
  void _showManageSheet(FeesEntity f) {
    final settled =
        f.statusEnum == FeeStatus.paid || f.statusEnum == FeeStatus.waived;
    Widget tile(IconData icon, String label, Color color, VoidCallback onTap) =>
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
            onTap();
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );

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
            Text(
              '${f.memberName} · ${f.id}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            tile(
              Icons.edit_rounded,
              'Edit record',
              _kAmber,
              () => _showEditSheet(f, null),
            ),
            if (!settled)
              tile(
                Icons.do_not_disturb_rounded,
                'Waive fee',
                AppTheme.textSecondary,
                () => _waiveFee(f),
              ),
            tile(
              Icons.delete_rounded,
              'Delete',
              AppTheme.error,
              () => _confirmDelete(f),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => Padding(
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
            ..._kSortOptions.keys.map(
              (s) => GestureDetector(
                onTap: () {
                  Navigator.pop(sheetCtx);
                  if (_sortBy == s) return;
                  setState(() => _sortBy = s);
                  _refreshListing();
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

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: isError ? AppTheme.error : AppTheme.surface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }
}

// ─── Fee Card ─────────────────────────────────────────────────────────────────

class _FeeCard extends StatelessWidget {
  final FeesEntity record;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onRemind;
  final VoidCallback onMarkPaid;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _FeeCard({
    required this.record,
    required this.onApprove,
    required this.onReject,
    required this.onRemind,
    required this.onMarkPaid,
    required this.onTap,
    required this.onLongPress,
  });

  Color get _statusColor => switch (record.statusEnum) {
    FeeStatus.paid => _kGreen,
    FeeStatus.pending => _kBlue,
    FeeStatus.overdue => AppTheme.error,
    FeeStatus.partial => _kAmber,
    FeeStatus.waived => AppTheme.textSecondary,
  };

  String get _statusLabel => switch (record.statusEnum) {
    FeeStatus.paid => 'Paid',
    FeeStatus.pending => 'Pending',
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

  @override
  Widget build(BuildContext context) {
    final isPending = record.statusEnum == FeeStatus.pending;
    final isOverdue = record.statusEnum == FeeStatus.overdue;
    final isPartial = record.statusEnum == FeeStatus.partial;
    final hasReceipt = record.receiptUrl.isNotEmpty;
    // A pending invoice with a receipt is a member-submitted claim to review;
    // without one it is just an unpaid invoice (remind / mark paid).
    final isReview = isPending && hasReceipt;
    final showPaidProgress = isPartial && record.paidAmount != 0;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isOverdue
                ? AppTheme.error.withAOpacity(0.25)
                : isPending
                ? _kBlue.withAOpacity(0.2)
                : Colors.white.withAOpacity(0.05),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                            // _StatusBadge(
                            //   label: _statusLabel,
                            //   color: _statusColor,
                            //   icon: _statusIcon,
                            // ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _StatusBadge(
                                  label: isReview ? 'In Review' : _statusLabel,
                                  color: _statusColor,
                                  icon: _statusIcon,
                                ),
                                GestureDetector(
                                  onTap: onLongPress,
                                  behavior: HitTestBehavior.opaque,
                                  child: const Padding(
                                    padding: EdgeInsets.only(left: 6),
                                    child: Icon(
                                      Icons.more_vert_rounded,
                                      size: 18,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              _money(record.amount),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                            if (showPaidProgress) ...[
                              const SizedBox(width: 6),
                              Text(
                                '(${_money(record.paidAmount)} paid)',
                                style: const TextStyle(
                                  color: _kAmber,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                            const Spacer(),
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
                            Flexible(
                              child: Text(
                                isOverdue
                                    ? '${record.overdueDays} days overdue · Due ${_fmtDate(record.dueDate.toDateTime)}'
                                    : 'Due ${_fmtDate(record.dueDate.toDateTime)}',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: isOverdue
                                      ? AppTheme.error
                                      : AppTheme.textSecondary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (record.statusEnum == FeeStatus.paid &&
                                record.paidDate.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.check_rounded,
                                size: 11,
                                color: _kGreen,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                'Paid ${_fmtDate(record.paidDate.toDateTime)}',
                                style: const TextStyle(
                                  color: _kGreen,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (hasReceipt) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: _kBlue.withAOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: _kBlue.withAOpacity(0.3),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.attach_file_rounded,
                                  size: 10,
                                  color: _kBlue,
                                ),
                                SizedBox(width: 3),
                                Text(
                                  'Receipt uploaded',
                                  style: TextStyle(
                                    color: _kBlue,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        if (record.notes.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.sticky_note_2_outlined,
                                size: 11,
                                color:
                                    record.notes.startsWith('Payment rejected')
                                    ? AppTheme.error
                                    : AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  record.notes,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color:
                                        record.notes.startsWith(
                                          'Payment rejected',
                                        )
                                        ? AppTheme.error
                                        : AppTheme.textSecondary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
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

            // Partial progress bar (uses server-computed balance)
            if (showPaidProgress)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_money(record.paidAmount)} of ${_money(record.amount)}',
                          style: const TextStyle(
                            color: _kAmber,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Balance: ${_money(record.balance)}',
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
                        value: (record.paidAmount / record.amount).clamp(
                          0.0,
                          1.0,
                        ),
                        minHeight: 5,
                        backgroundColor: Colors.white.withAOpacity(0.07),
                        valueColor: const AlwaysStoppedAnimation(_kAmber),
                      ),
                    ),
                  ],
                ),
              ),

            // Action bar
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
                  if (isReview) ...[
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
                      color: _kGreen,
                      onTap: onApprove,
                    ),
                  ] else if (isPending || isOverdue || isPartial) ...[
                    _ActionBtn(
                      icon: Icons.notifications_outlined,
                      label: 'Remind',
                      color: _kBlue,
                      onTap: onRemind,
                    ),
                    _VDivider(),
                    _ActionBtn(
                      icon: Icons.payments_outlined,
                      label: 'Mark Paid',
                      color: _kGreen,
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

// ─── Reason dialog (reject / waive) ───────────────────────────────────────────

class _ReasonDialog extends StatefulWidget {
  final String title;
  final String subtitle;
  final String hint;
  final String confirmLabel;
  final Color color;
  final IconData icon;
  const _ReasonDialog({
    required this.title,
    required this.subtitle,
    required this.hint,
    required this.confirmLabel,
    required this.color,
    required this.icon,
  });

  @override
  State<_ReasonDialog> createState() => _ReasonDialogState();
}

class _ReasonDialogState extends State<_ReasonDialog> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(widget.icon, color: widget.color, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              widget.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.subtitle,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 14),
          _SheetField(
            controller: _ctrl,
            hint: widget.hint,
            icon: Icons.note_rounded,
            maxLines: 2,
          ),
        ],
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
            backgroundColor: widget.color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () => Navigator.pop(context, _ctrl.text.trim()),
          child: Text(
            widget.confirmLabel,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Mark Paid Sheet ──────────────────────────────────────────────────────────

class _MarkPaidSheet extends StatefulWidget {
  final FeesEntity? record;
  final FeeEntity? detail;
  final void Function(double amount, PaymentMethod method, String? notes)
  onSubmit;
  const _MarkPaidSheet({
    required this.record,
    required this.onSubmit,
    required this.detail,
  }) : assert(
         record != null || detail != null,
         'Either record or detail must not be null.',
       );
  @override
  State<_MarkPaidSheet> createState() => _MarkPaidSheetState();
}

class _MarkPaidSheetState extends State<_MarkPaidSheet> {
  PaymentMethod _method = PaymentMethod.cash;
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  String? _error;

  double get _balance =>
      (widget.record?.balance ?? widget.detail!.balance).toDouble();

  @override
  void initState() {
    super.initState();
    // The API ADDS amountReceived to what's already paid, so default to the balance.
    _amountCtrl.text = _balance.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Enter an amount greater than zero.');
      return;
    }
    if (amount > _balance) {
      setState(() => _error = 'Only ${_money(_balance)} is outstanding.');
      return;
    }
    final note = _noteCtrl.text.trim();
    Navigator.pop(context);
    widget.onSubmit(amount, _method, note.isEmpty ? null : note);
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
            const _SheetHandle(),
            _SheetHeader(
              icon: Icons.payments_rounded,
              color: _kGreen,
              title: 'Mark as Paid',
              subtitle:
                  '${widget.record?.memberName ?? widget.detail!.memberName} · Balance ${_money(_balance)}',
            ),
            const SizedBox(height: 24),
            const _SheetLabel('Amount Received'),
            const SizedBox(height: 8),
            _AmountField(controller: _amountCtrl),
            const SizedBox(height: 20),
            const _SheetLabel('Payment Method'),
            const SizedBox(height: 10),
            _MethodPicker(
              selected: _method,
              onChanged: (m) => setState(() => _method = m),
            ),
            const SizedBox(height: 16),
            const _SheetLabel('Notes (optional)'),
            const SizedBox(height: 8),
            _SheetField(
              controller: _noteCtrl,
              hint: 'Add any notes…',
              icon: Icons.note_rounded,
              maxLines: 2,
            ),
            if (_error != null) _ErrorText(_error!),
            const SizedBox(height: 24),
            _PrimaryButton(
              label: 'Confirm Payment',
              color: _kGreen,
              onPressed: _submit,
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
  final void Function(List<String> channels) onSubmit;
  const _ReminderSheet({required this.record, required this.onSubmit});
  @override
  State<_ReminderSheet> createState() => _ReminderSheetState();
}

class _ReminderSheetState extends State<_ReminderSheet> {
  bool _push = true, _whatsapp = false, _sms = false;

  List<String> get _channels => [
    if (_push) 'push',
    if (_whatsapp) 'whatsapp',
    if (_sms) 'sms',
  ];

  @override
  Widget build(BuildContext context) {
    final r = widget.record;
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
          const _SheetHandle(),
          _SheetHeader(
            icon: Icons.notifications_rounded,
            color: _kBlue,
            title: 'Send Fee Reminder',
            subtitle: r.memberName,
          ),
          const SizedBox(height: 20),
          // Mirrors the message the server sends (uses balance, not amount).
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withAOpacity(0.06)),
            ),
            child: Text(
              'Hi ${r.memberName.split(' ').first}, your ${r.plan} fee of ${_money(r.balance)} is ${r.overdueDays > 0 ? '${r.overdueDays} days overdue' : 'due soon'}. Please pay at the earliest. — Club Fitness',
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
            _kBlue,
            _push,
            (v) => setState(() => _push = v),
          ),
          const SizedBox(height: 8),
          _ChannelToggle(
            Icons.chat_rounded,
            'WhatsApp',
            _kGreen,
            _whatsapp,
            (v) => setState(() => _whatsapp = v),
          ),
          const SizedBox(height: 8),
          _ChannelToggle(
            Icons.sms_rounded,
            'SMS',
            _kAmber,
            _sms,
            (v) => setState(() => _sms = v),
          ),
          const SizedBox(height: 24),
          _PrimaryButton(
            label: 'Send Reminder',
            color: _kBlue,
            // API requires a non-empty channel list
            onPressed: _channels.isEmpty
                ? null
                : () {
                    Navigator.pop(context);
                    widget.onSubmit(_channels);
                  },
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

// ─── Add Fee Sheet (POST /fees) ───────────────────────────────────────────────

class NewFeeData {
  final String memberId;
  final String? planId;
  final double? amount;
  final DateTime dueDate;
  final String status; // PENDING | PAID | PARTIAL | WAIVED
  final double? paidAmount;
  final String? paymentMethod; // cash | upi | bankTransfer | other
  final String? notes;
  const NewFeeData({
    required this.memberId,
    required this.planId,
    required this.amount,
    required this.dueDate,
    required this.status,
    required this.paidAmount,
    required this.paymentMethod,
    required this.notes,
  });
}

class _AddFeeSheet extends StatefulWidget {
  final void Function(NewFeeData data) onSubmit;
  const _AddFeeSheet({required this.onSubmit});
  @override
  State<_AddFeeSheet> createState() => _AddFeeSheetState();
}

class _AddFeeSheetState extends State<_AddFeeSheet> {
  final _dateCtrl = TextEditingController();
  final _memberCtrl = TextEditingController();
  final _planCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _paidCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime? _dueDate;
  FeeStatus _status = FeeStatus.pending;
  PaymentMethod _method = PaymentMethod.cash;
  String? _error;

  bool get _takesPayment =>
      _status == FeeStatus.paid || _status == FeeStatus.partial;

  @override
  void dispose() {
    _dateCtrl.dispose();
    _memberCtrl.dispose();
    _planCtrl.dispose();
    _amountCtrl.dispose();
    _paidCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 5),
    );
    if (d != null) {
      setState(() => _dueDate = d);
      _dateCtrl.text = _fmtDate(d);
    }
  }

  void _submit() {
    final memberId = _memberCtrl.text.trim();
    final planId = _planCtrl.text.trim();
    final amount = double.tryParse(_amountCtrl.text.trim());
    final paid = double.tryParse(_paidCtrl.text.trim());

    String? err;
    if (memberId.isEmpty) {
      err = 'Member ID is required.';
    } else if (amount == null && planId.isEmpty) {
      err = 'Enter an amount or a plan ID (amount defaults to the plan price).';
    } else if (amount != null && amount <= 0) {
      err = 'Amount must be greater than zero.';
    } else if (_dueDate == null) {
      err = 'Pick a due date.';
    } else if (_status == FeeStatus.partial &&
        (paid == null || paid <= 0 || (amount != null && paid >= amount))) {
      err =
          'A partial invoice needs a paid amount above 0 and below the amount.';
    } else if (paid != null && amount != null && paid > amount) {
      err = 'Paid amount cannot exceed the invoice amount.';
    }
    if (err != null) {
      setState(() => _error = err);
      return;
    }

    final notes = _notesCtrl.text.trim();
    Navigator.pop(context);
    widget.onSubmit(
      NewFeeData(
        memberId: memberId,
        planId: planId.isEmpty ? null : planId,
        amount: amount,
        dueDate: _dueDate!,
        status: _status.name.toUpperCase(),
        paidAmount: _takesPayment ? paid : null,
        paymentMethod: _takesPayment ? _method.name : null,
        notes: notes.isEmpty ? null : notes,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
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
            const _SheetHandle(),
            const _SheetHeader(
              icon: Icons.receipt_long_rounded,
              color: AppTheme.primary,
              title: 'Record New Fee',
              subtitle: 'Standalone invoice',
            ),
            const SizedBox(height: 24),
            const _SheetLabel('Member ID'),
            const SizedBox(height: 8),
            _SheetField(
              controller: _memberCtrl,
              hint: 'Member ID…',
              icon: Icons.person_search_rounded,
            ),
            const SizedBox(height: 16),
            const _SheetLabel('Plan ID (optional)'),
            const SizedBox(height: 8),
            _SheetField(
              controller: _planCtrl,
              hint: 'Membership plan ID…',
              icon: Icons.inventory_2_rounded,
            ),
            const SizedBox(height: 16),
            const _SheetLabel('Amount (optional if plan is set)'),
            const SizedBox(height: 8),
            _AmountField(controller: _amountCtrl),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SheetLabel('Due Date'),
                      const SizedBox(height: 8),
                      _SheetField(
                        hint: 'Select date',
                        icon: Icons.calendar_today_rounded,
                        readOnly: true,
                        onTap: _pickDate,
                        controller: _dateCtrl,
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
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        height: 50,
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
                              const [
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
            if (_takesPayment) ...[
              const SizedBox(height: 16),
              _SheetLabel(
                _status == FeeStatus.partial
                    ? 'Amount Paid'
                    : 'Amount Paid (defaults to full amount)',
              ),
              const SizedBox(height: 8),
              _AmountField(controller: _paidCtrl),
              const SizedBox(height: 16),
              const _SheetLabel('Payment Method'),
              const SizedBox(height: 10),
              _MethodPicker(
                selected: _method,
                onChanged: (m) => setState(() => _method = m),
              ),
            ],
            const SizedBox(height: 16),
            const _SheetLabel('Notes (optional)'),
            const SizedBox(height: 8),
            _SheetField(
              controller: _notesCtrl,
              hint: 'Any additional notes…',
              icon: Icons.note_rounded,
              maxLines: 2,
            ),
            if (_error != null) _ErrorText(_error!),
            const SizedBox(height: 28),
            _PrimaryButton(
              label: 'Save Fee Record',
              color: AppTheme.primary,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Edit Fee Sheet (PATCH /fees/:id) ─────────────────────────────────────────

class FeeEditData {
  final double? amount;
  final DateTime? dueDate;
  final String? planId;
  final String? notes;
  const FeeEditData({this.amount, this.dueDate, this.planId, this.notes});
}

class _EditFeeSheet extends StatefulWidget {
  final FeesEntity? record;
  final FeeEntity? detail;
  final void Function(FeeEditData data) onSubmit;
  const _EditFeeSheet({
    required this.record,
    required this.onSubmit,
    required this.detail,
  });
  @override
  State<_EditFeeSheet> createState() => _EditFeeSheetState();
}

class _EditFeeSheetState extends State<_EditFeeSheet> {
  late final TextEditingController _dateCtrl;
  late final TextEditingController _amountCtrl;
  late final TextEditingController _planCtrl;
  late final TextEditingController _notesCtrl;
  late DateTime _dueDate;
  String? _error;

  @override
  void initState() {
    super.initState();
    final r = widget.record;
    final d = widget.detail;
    _amountCtrl = TextEditingController(
      text: (r?.amount ?? d?.amount)?.toStringAsFixed(0),
    );
    _planCtrl = TextEditingController();
    _notesCtrl = TextEditingController(text: r?.notes ?? d?.notes);
    _dueDate = (r?.dueDate ?? d?.dueDate ?? '').toDateTime;
    _dateCtrl = TextEditingController(text: _fmtDate(_dueDate));
  }

  @override
  void dispose() {
    _dateCtrl.dispose();
    _amountCtrl.dispose();
    _planCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(_dueDate.year - 2),
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (d != null) {
      setState(() => _dueDate = d);
      _dateCtrl.text = _fmtDate(d);
    }
  }

  void _submit() {
    final r = widget.record;
    final d = widget.detail;
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Amount must be greater than zero.');
      return;
    }
    // API rejects lowering the amount below what was already received.
    final paid = (r?.paidAmount ?? d?.paidAmount ?? 0).toDouble();
    if (amount < paid) {
      setState(
        () => _error =
            '${_money(paid)} has already been received on this invoice.',
      );
      return;
    }

    // Send only what changed (PATCH accepts any subset).
    final notes = _notesCtrl.text.trim();
    final plan = _planCtrl.text.trim();
    Navigator.pop(context);
    widget.onSubmit(
      FeeEditData(
        amount: amount != (r?.amount ?? d?.amount)?.toDouble() ? amount : null,
        dueDate:
            _fmtDate(_dueDate) !=
                _fmtDate((r?.dueDate ?? d?.dueDate ?? '').toDateTime)
            ? _dueDate
            : null,
        planId: plan.isEmpty ? null : plan,
        notes: notes != (r?.notes ?? d?.notes) ? notes : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
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
            const _SheetHandle(),
            _SheetHeader(
              icon: Icons.edit_rounded,
              color: _kAmber,
              title: 'Edit Fee Record',
              subtitle:
                  '${widget.record?.memberName ?? widget.detail?.memberName} · ${widget.record?.id ?? widget.detail?.id}',
            ),
            const SizedBox(height: 24),
            const _SheetLabel('Amount'),
            const SizedBox(height: 8),
            _AmountField(controller: _amountCtrl),
            const SizedBox(height: 16),
            const _SheetLabel('Due Date'),
            const SizedBox(height: 8),
            _SheetField(
              hint: 'Select date',
              icon: Icons.calendar_today_rounded,
              readOnly: true,
              onTap: _pickDate,
              controller: _dateCtrl,
            ),
            const SizedBox(height: 16),
            const _SheetLabel('Change plan (plan ID, optional)'),
            const SizedBox(height: 8),
            _SheetField(
              controller: _planCtrl,
              hint:
                  'Leave empty to keep ${widget.record?.plan ?? widget.detail?.plan}',
              icon: Icons.inventory_2_rounded,
            ),
            const SizedBox(height: 16),
            const _SheetLabel('Notes'),
            const SizedBox(height: 8),
            _SheetField(
              controller: _notesCtrl,
              hint: 'Notes…',
              icon: Icons.note_rounded,
              maxLines: 2,
            ),
            if (_error != null) _ErrorText(_error!),
            const SizedBox(height: 24),
            _PrimaryButton(
              label: 'Save Changes',
              color: _kAmber,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shared small widgets ─────────────────────────────────────────────────────

class _RevenueFigure extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _RevenueFigure({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
      ),
      const SizedBox(height: 3),
      Text(
        value,
        style: TextStyle(
          color: color,
          fontSize: 24,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
      ),
    ],
  );
}

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
      border: Border.all(color: color.withAOpacity(0.35)),
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

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();
  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(2),
      ),
    ),
  );
}

class _SheetHeader extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  const _SheetHeader({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withAOpacity(0.14),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              subtitle,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    ],
  );
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
  final TextEditingController? controller;
  final String hint;
  final IconData icon;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  const _SheetField({
    required this.hint,
    required this.icon,
    this.controller,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.white.withAOpacity(0.06)),
    ),
    child: TextField(
      controller: controller,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
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

class _AmountField extends StatelessWidget {
  final TextEditingController controller;
  const _AmountField({required this.controller});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: _kGreen.withAOpacity(0.3)),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(color: Colors.white.withAOpacity(0.07)),
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
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
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
  );
}

class _MethodPicker extends StatelessWidget {
  final PaymentMethod selected;
  final ValueChanged<PaymentMethod> onChanged;
  const _MethodPicker({required this.selected, required this.onChanged});

  static const _info = {
    PaymentMethod.cash: ('Cash', Icons.payments_rounded),
    PaymentMethod.upi: ('UPI', Icons.phone_android_rounded),
    PaymentMethod.bankTransfer: ('Bank', Icons.account_balance_rounded),
    PaymentMethod.other: ('Other', Icons.more_horiz_rounded),
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      children: PaymentMethod.values.map((m) {
        final info = _info[m]!;
        final sel = selected == m;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(m),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              margin: EdgeInsets.only(right: m != PaymentMethod.other ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: sel ? _kGreen.withAOpacity(0.12) : AppTheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: sel
                      ? _kGreen.withAOpacity(0.5)
                      : Colors.white.withAOpacity(0.07),
                  width: sel ? 1.5 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    info.$2,
                    color: sel ? _kGreen : AppTheme.textSecondary,
                    size: 18,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    info.$1,
                    style: TextStyle(
                      color: sel ? Colors.white : AppTheme.textSecondary,
                      fontSize: 10,
                      fontWeight: sel ? FontWeight.w800 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ErrorText extends StatelessWidget {
  final String text;
  const _ErrorText(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: Text(
      text,
      style: const TextStyle(
        color: AppTheme.error,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onPressed;
  const _PrimaryButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: color,
      disabledBackgroundColor: color.withAOpacity(0.3),
      minimumSize: const Size(double.infinity, 52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    child: Text(
      label,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w800,
        fontSize: 15,
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

  // Tab counts change when the summary refreshes.
  @override
  bool shouldRebuild(_TabBarDelegate old) => true;
}

class _BlockingLoader extends StatelessWidget {
  const _BlockingLoader();
  @override
  Widget build(BuildContext context) => const AbsorbPointer(
    child: ColoredBox(
      color: Colors.black54,
      child: Center(child: CircularProgressIndicator()),
    ),
  );
}

extension _FeeStatusUi on FeesEntity {
  bool get isReview => statusEnum == FeeStatus.pending && receiptUrl.isNotEmpty;
  bool get isSettled =>
      statusEnum == FeeStatus.paid || statusEnum == FeeStatus.waived;
}

extension _FeeDetailEntityUi on FeeDetailEntity {
  bool get isReview =>
      statusEnum == FeeStatus.pending && fee.receiptUrl.isNotEmpty;
  bool get isSettled =>
      statusEnum == FeeStatus.paid || statusEnum == FeeStatus.waived;

  Color get statusColor => switch (statusEnum) {
    FeeStatus.paid => _kGreen,
    FeeStatus.pending => _kBlue,
    FeeStatus.overdue => AppTheme.error,
    FeeStatus.partial => _kAmber,
    FeeStatus.waived => AppTheme.textSecondary,
  };

  String get statusLabel => switch (statusEnum) {
    FeeStatus.paid => 'Paid',
    FeeStatus.pending => isReview ? 'In Review' : 'Pending',
    FeeStatus.overdue => 'Overdue',
    FeeStatus.partial => 'Partial',
    FeeStatus.waived => 'Waived',
  };

  IconData get statusIcon => switch (statusEnum) {
    FeeStatus.paid => Icons.check_circle_rounded,
    FeeStatus.pending => Icons.hourglass_empty_rounded,
    FeeStatus.overdue => Icons.warning_amber_rounded,
    FeeStatus.partial => Icons.pie_chart_rounded,
    FeeStatus.waived => Icons.do_not_disturb_rounded,
  };
}

class FeeDetailProvider extends StatelessWidget {
  final String id;
  final FeesEntity? initial;
  const FeeDetailProvider({super.key, required this.id, this.initial});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FeeDetailBloc(sl())..add(GetFeeDetailEvent(id)),
      child: FeeDetailScreen(id: id),
    );
  }
}

class FeeDetailScreen extends StatefulWidget {
  final String id;
  const FeeDetailScreen({super.key, required this.id});
  @override
  State<FeeDetailScreen> createState() => _FeeDetailScreenState();
}

class _FeeDetailScreenState extends State<FeeDetailScreen> {
  FeeActionsBloc get _actions => context.read<FeeActionsBloc>();
  void _reload() =>
      context.read<FeeDetailBloc>().add(GetFeeDetailEvent(widget.id));

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: isError ? AppTheme.error : AppTheme.surface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  void _initMarkPaidSheet(FeeEntity fee) {
    final router = context.router;
    final query = router.state.uri.queryParameters;
    if (query.isEmpty) return;
    bool openPaidSheet = query['open-mark-paid-sheet'] == 'true';
    if (!openPaidSheet) return;
    WidgetsBinding.instance.addPostFrameCallback((_) => _markPaid(null, fee));
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: BlocListener<FeeActionsBloc, FeeActionsState>(
        listenWhen: (_, s) => s is FeeActionsSuccess || s is FeeActionsFailure,
        listener: (context, state) {
          if (state is FeeActionsFailure) {
            _snack(state.failure.message, isError: true);
            return;
          }
          if (state is! FeeActionsSuccess) return;

          _snack(_successMessage(state));
          if (state.action == FeeActions.delete) {
            Navigator.of(context).pop(true); // list refreshes on return
          } else if (state.fee != null) {
            _reload();
          } else if (state.action != FeeActions.remind) {
            _reload();
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            BlocConsumer<FeeDetailBloc, FeeDetailState>(
              listener: (context, state) {
                if (state is FeeDetailSuccessState) {
                  _initMarkPaidSheet(state.detail.fee);
                }
              },
              builder: (context, state) => switch (state) {
                FeeDetailLoadingState() => _shell(
                  const Center(child: CircularProgressIndicator()),
                ),
                FeeDetailFailureState(:final failure) => _shell(
                  FailureTextWidget(failure, onRetry: _reload),
                ),
                FeeDetailSuccessState() => _buildLoaded(state.detail),

                FeeDetailInitial() => const SizedBox(),
              },
            ),
            BlocBuilder<FeeActionsBloc, FeeActionsState>(
              buildWhen: (p, c) =>
                  p is FeeActionsLoading || c is FeeActionsLoading,
              builder: (_, s) => s is FeeActionsLoading
                  ? const _BlockingLoader()
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  /// Plain scaffold body with a back button, for loading / failure states.
  Widget _shell(Widget child) => SafeArea(
    child: Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
        Expanded(child: child),
      ],
    ),
  );

  Widget _buildLoaded(FeeDetailEntity fee) {
    final r = fee;
    final c = r.statusColor;
    final showPaymentBreakdown = r.fee.paidAmount > 0 && !r.isSettled;

    return RefreshIndicator(
      color: AppTheme.primary,
      onRefresh: () async {},
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
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
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            actions: [
              IconButton(
                tooltip: 'Copy invoice ID',
                icon: const Icon(
                  Icons.copy_rounded,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: r.fee.id));
                  _snack('Invoice ID copied');
                },
              ),
            ],
            // bottom: state.refreshing
            //     ? const PreferredSize(
            //         preferredSize: Size.fromHeight(2),
            //         child: LinearProgressIndicator(minHeight: 2),
            //       )
            //     : null,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [c.withAOpacity(0.2), AppTheme.background],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(24, 80, 24, 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: r.memberColor.withAOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: r.memberColor.withAOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          r.memberInitials,
                          style: TextStyle(
                            color: r.memberColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.fee.memberName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  r.fee.id,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withAOpacity(0.35),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              _StatusBadge(
                                label: r.statusLabel,
                                color: c,
                                icon: r.statusIcon,
                              ),
                            ],
                          ),
                        ],
                      ),
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
                // if (state.refreshError != null) ...[
                //   _InlineBanner(
                //     icon: Icons.cloud_off_rounded,
                //     color: _kAmber,
                //     text: "Couldn't refresh, showing last known data.",
                //     actionLabel: 'Retry',
                //     onAction: _reload,
                //   ),
                //   const SizedBox(height: 12),
                // ],
                if (r.statusEnum == FeeStatus.overdue) ...[
                  _InlineBanner(
                    icon: Icons.timer_off_rounded,
                    color: AppTheme.error,
                    text:
                        '${r.fee.overdueDays} days overdue · ${_money(r.fee.balance)} outstanding',
                  ),
                  const SizedBox(height: 12),
                ],
                if (r.isReview) ...[
                  const _InlineBanner(
                    icon: Icons.fact_check_rounded,
                    color: _kBlue,
                    text: 'The member submitted a receipt. Approve or reject.',
                  ),
                  const SizedBox(height: 12),
                ],
                if (r.fee.notes.startsWith('Payment rejected')) ...[
                  _InlineBanner(
                    icon: Icons.report_gmailerrorred_rounded,
                    color: AppTheme.error,
                    text: r.fee.notes,
                  ),
                  const SizedBox(height: 12),
                ],

                // Amount card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.card,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: c.withAOpacity(0.25)),
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
                                _money(r.fee.amount),
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
                              color: c.withAOpacity(0.14),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(r.statusIcon, color: c, size: 28),
                          ),
                        ],
                      ),
                      if (showPaymentBreakdown) ...[
                        const SizedBox(height: 14),
                        const Divider(color: Colors.white12),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _AmountRow(
                              'Paid',
                              _money(r.fee.paidAmount),
                              _kGreen,
                            ),
                            _AmountRow(
                              'Balance',
                              _money(r.fee.balance),
                              _kAmber,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (r.fee.paidAmount / r.fee.amount).clamp(
                              0.0,
                              1.0,
                            ),
                            minHeight: 6,
                            backgroundColor: Colors.white.withAOpacity(0.07),
                            valueColor: const AlwaysStoppedAnimation(_kGreen),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                const _SectionTitle('Payment Details'),
                const SizedBox(height: 12),
                _InfoCard(
                  rows: [
                    _InfoRowData(Icons.inventory_2_rounded, 'Plan', r.fee.plan),
                    _InfoRowData(
                      Icons.calendar_today_rounded,
                      'Due Date',
                      _fmtDate(r.fee.dueDate.toDateTime),
                    ),
                    if (r.fee.discountAmount > 0)
                      _InfoRowData(
                        Icons.local_offer_rounded,
                        'Discount',
                        '- ${_money(r.fee.discountAmount)}',
                      ),
                    if (r.fee.paidDate.isNotEmpty)
                      _InfoRowData(
                        Icons.check_circle_outline_rounded,
                        'Last Payment',
                        _fmtDate(r.fee.paidDate.toDateTime),
                      ),
                    if (r.fee.paidAmount > 0)
                      _InfoRowData(
                        Icons.payment_rounded,
                        'Method',
                        _methodLabel(r.paymentMethodEnum),
                      ),
                    if (r.fee.submittedDateTime != null)
                      _InfoRowData(
                        Icons.upload_rounded,
                        'Receipt Submitted',
                        _fmtDate(r.fee.submittedDateTime!),
                      ),
                    if (r.approvedBy.name.isNotEmpty)
                      _InfoRowData(
                        Icons.verified_user_rounded,
                        'Handled By',
                        r.approvedBy.name,
                      ),
                    if (r.fee.approvedDate.isNotEmpty)
                      _InfoRowData(
                        Icons.event_available_rounded,
                        'Handled On',
                        _fmtDate(r.fee.approvedDate.toDateTime),
                      ),
                    if (r.fee.createdAt.isNotEmpty)
                      _InfoRowData(
                        Icons.add_circle_outline_rounded,
                        'Invoice Created',
                        _fmtDate(r.fee.createdAt.toDateTime),
                      ),
                    if (r.fee.notes.isNotEmpty &&
                        !r.fee.notes.startsWith('Payment rejected'))
                      _InfoRowData(Icons.note_rounded, 'Notes', r.fee.notes),
                  ],
                ),
                const SizedBox(height: 20),

                const _SectionTitle('Member'),
                const SizedBox(height: 12),
                _InfoCard(
                  rows: [
                    _InfoRowData(
                      Icons.person_rounded,
                      'Name',
                      r.fee.memberName,
                    ),
                    if (r.fee.memberPhone.isNotEmpty)
                      _InfoRowData(
                        Icons.phone_rounded,
                        'Phone',
                        r.fee.memberPhone,
                      ),
                    if (r.fee.memberEmail.isNotEmpty)
                      _InfoRowData(
                        Icons.email_rounded,
                        'Email',
                        r.fee.memberEmail,
                      ),
                  ],
                ),
                const SizedBox(height: 20),

                if (r.membership.planId.isNotEmpty) ...[
                  const _SectionTitle('Membership'),
                  const SizedBox(height: 12),
                  _MembershipCard(info: r.membership),
                  const SizedBox(height: 20),
                ],

                if (r.relatedFees.isNotEmpty) ...[
                  _SectionTitle(
                    'Linked Invoices (${r.relatedFees.length}) · same renewal',
                  ),
                  const SizedBox(height: 12),
                  ...r.relatedFees.map(
                    (f) =>
                        _LinkedFeeTile(fee: f, onTap: () => _openLinked(f.id)),
                  ),
                  const SizedBox(height: 20),
                ],

                const _SectionTitle('Payment Receipt'),
                const SizedBox(height: 12),
                _ReceiptCard(
                  url: r.fee.receiptUrl,
                  onOpen: () => _openReceipt(r.fee.receiptUrl),
                  onAttach: () => _attachReceipt(null, r.fee),
                ),
                const SizedBox(height: 20),

                const _SectionTitle('Actions'),
                const SizedBox(height: 12),
                _buildActions(null, r),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openLinked(String id) async {
    await context.pushNamed(RoutesName.feeDetails, pathParameters: {'id': id});
    if (mounted) _reload();
  }

  String _methodLabel(PaymentMethod? m) => switch (m) {
    PaymentMethod.cash => 'Cash',
    PaymentMethod.upi => 'UPI',
    PaymentMethod.bankTransfer => 'Bank Transfer',
    PaymentMethod.other => 'Other',
    null => '-',
  };

  // ── Actions grid (only what the API allows for the current status) ──────────

  Widget _buildActions(FeesEntity? r, FeeDetailEntity? d) {
    final actions = <_Act>[
      if (r?.isReview ?? d?.isReview ?? false) ...[
        _Act(
          'Approve',
          Icons.check_rounded,
          _kGreen,
          () => _approve(r, d?.fee),
        ),
        _Act(
          'Reject',
          Icons.close_rounded,
          AppTheme.error,
          () => _reject(r, d?.fee),
        ),
      ],
      if (!(r?.isSettled ?? d?.isSettled ?? false)) ...[
        _Act(
          'Mark Paid',
          Icons.payments_rounded,
          _kGreen,
          () => _markPaid(r, d?.fee),
        ),
        _Act(
          'Send Reminder',
          Icons.notifications_rounded,
          _kBlue,
          () => context.showToast(
            'This feature is coming soon',
            type: ToastificationType.info,
          ),
        ),
        _Act(
          'Waive Fee',
          Icons.do_not_disturb_rounded,
          AppTheme.textSecondary,
          () => _waive(r, d?.fee),
        ),
      ],
      _Act(
        (r?.receiptUrl ?? d?.fee.receiptUrl ?? '').isEmpty
            ? 'Attach Receipt'
            : 'Replace Receipt',
        Icons.attach_file_rounded,
        _kBlue,
        () => _attachReceipt(r, d?.fee),
      ),
      _Act('Edit Record', Icons.edit_rounded, _kAmber, () => _edit(r, d?.fee)),
      _Act(
        'Delete',
        Icons.delete_rounded,
        AppTheme.error,
        () => _delete(r, d?.fee),
      ),
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
              onTap: a.onTap,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: a.color.withAOpacity(0.2)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(a.icon, color: a.color, size: 22),
                    const SizedBox(height: 6),
                    Text(
                      a.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: a.color,
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

  // ── Action handlers ─────────────────────────────────────────────────────────

  Future<bool> _confirm({
    required String title,
    required String message,
    required String confirmLabel,
    required Color color,
  }) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dCtx) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(dCtx, true),
            child: Text(
              confirmLabel,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
    return ok == true && mounted;
  }

  Future<void> _approve(FeesEntity? r, FeeEntity? d) async {
    final ok = await _confirm(
      title: 'Approve payment?',
      message:
          'Mark ${_money(r?.amount ?? d?.amount ?? 0)} from ${r?.memberName ?? d?.memberName ?? 'Unknown'} as received?',
      confirmLabel: 'Approve',
      color: _kGreen,
    );
    if (ok) _actions.add(ApproveFeesEvent(r?.id ?? d?.id ?? ''));
  }

  Future<void> _reject(FeesEntity? r, FeeEntity? d) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => _ReasonDialog(
        title: 'Reject Payment',
        subtitle: r?.memberName ?? d?.memberName ?? '',
        hint: 'Reason (optional)…',
        confirmLabel: 'Reject',
        color: AppTheme.error,
        icon: Icons.close_rounded,
      ),
    );
    if (reason == null || !mounted) return;
    _actions.add(RejectFeesEvent(r?.id ?? d?.id ?? '', reason: reason));
  }

  Future<void> _waive(FeesEntity? r, FeeEntity? d) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => _ReasonDialog(
        title: 'Waive Fee',
        subtitle:
            '${r?.memberName ?? d?.memberName ?? ''} · ${_money(r?.balance ?? d?.balance ?? 0)} outstanding will be waived',
        hint: 'Reason (optional)…',
        confirmLabel: 'Waive',
        color: _kAmber,
        icon: Icons.do_not_disturb_rounded,
      ),
    );
    if (reason == null || !mounted) return;
    _actions.add(WaiveFeeEvent(r?.id ?? d?.id ?? '', reason: reason));
  }

  void _markPaid(FeesEntity? r, FeeEntity? d) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MarkPaidSheet(
        record: r,
        detail: d,
        onSubmit: (amount, method, notes) => _actions.add(
          MarkFeePaidEvent(
            r?.id ?? d?.id ?? '',
            amountReceived: amount,
            method: method.name,
            notes: notes,
          ),
        ),
      ),
    );
  }

  // void _remind(FeesEntity r) {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (_) => _ReminderSheet(
  //       record: r,
  //       onSubmit: (channels) =>
  //           _actions.add(SendFeeReminderEvent(r.id, channels: channels)),
  //     ),
  //   );
  // }

  void _edit(FeesEntity? r, FeeEntity? d) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditFeeSheet(
        record: r,
        detail: d,
        onSubmit: (data) => _actions.add(
          UpdateFeeEvent(
            r?.id ?? d?.id ?? '',
            amount: data.amount,
            dueDate: data.dueDate?.toIso8601String(),
            planId: data.planId,
            notes: data.notes,
          ),
        ),
      ),
    );
  }

  Future<void> _delete(FeesEntity? r, FeeEntity? d) async {
    final ok = await _confirm(
      title: 'Delete fee record?',
      message:
          '${r?.amount ?? d?.amount} payment record for ${r?.memberName ?? d?.memberName} (${r?.statusEnum.label ?? d?.statusEnum.label}) will be permanently removed.',
      confirmLabel: 'Delete',
      color: AppTheme.error,
    );
    if (ok) _actions.add(DeleteFeeEvent(r?.id ?? d?.id ?? ''));
  }

  Future<void> _attachReceipt(FeesEntity? r, FeeEntity? d) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppTheme.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: _kBlue),
              title: const Text(
                'Choose from gallery',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () => Navigator.pop(sCtx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded, color: _kBlue),
              title: const Text(
                'Take a photo',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () => Navigator.pop(sCtx, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;

    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        imageQuality: 80,
      );
      if (picked == null || !mounted) return;
      _actions.add(
        AttachReceiptEvent(r?.id ?? d?.id ?? '', receiptFilePath: picked.path),
      );
    } catch (_) {
      if (mounted) _snack("Couldn't open the image picker", isError: true);
    }
  }

  void _openReceipt(String url) {
    context.pushNamed(
      RoutesName.imageViewer,
      extra: {'image': url, 'title': 'Payment Receipt'},
    );
    // showDialog(
    //   context: context,
    //   builder: (_) => Dialog.fullscreen(
    //     backgroundColor: Colors.black,
    //     child: Stack(
    //       children: [
    //         Positioned.fill(
    //           child: InteractiveViewer(
    //             minScale: 1,
    //             maxScale: 5,
    //             child: Center(
    //               child: _ReceiptImage(url: url, fit: BoxFit.contain),
    //             ),
    //           ),
    //         ),
    //         SafeArea(
    //           child: Align(
    //             alignment: Alignment.topRight,
    //             child: IconButton(
    //               icon: const Icon(Icons.close_rounded, color: Colors.white),
    //               onPressed: () => Navigator.pop(context),
    //             ),
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }
}

// ─── Detail-only widgets ──────────────────────────────────────────────────────

class _Act {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _Act(this.label, this.icon, this.color, this.onTap);
}

class _InlineBanner extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;
  const _InlineBanner({
    required this.icon,
    required this.color,
    required this.text,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: color.withAOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withAOpacity(0.3)),
    ),
    child: Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (actionLabel != null)
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    ),
  );
}

class _ReceiptImage extends StatelessWidget {
  final String url;
  final BoxFit fit;
  const _ReceiptImage({required this.url, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) => CustomCachedImage(
    url,
    fit: fit,
    placeholder: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    errorBuilder: (_, __, ___) => const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.broken_image_rounded,
            color: AppTheme.textSecondary,
            size: 32,
          ),
          SizedBox(height: 6),
          Text(
            "Couldn't load receipt",
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
        ],
      ),
    ),
  );
}

class _ReceiptCard extends StatelessWidget {
  final String url;
  final VoidCallback onOpen;
  final VoidCallback onAttach;
  const _ReceiptCard({
    required this.url,
    required this.onOpen,
    required this.onAttach,
  });

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return GestureDetector(
        onTap: onAttach,
        child: Container(
          height: 110,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _kBlue.withAOpacity(0.25)),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.upload_file_rounded, color: _kBlue, size: 30),
              SizedBox(height: 8),
              Text(
                'No receipt attached',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Tap to upload one',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onOpen,
      child: Container(
        height: 200,
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _kBlue.withAOpacity(0.3)),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _ReceiptImage(url: url),
            Positioned(
              right: 10,
              bottom: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.zoom_out_map_rounded, color: _kBlue, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'View full image',
                      style: TextStyle(
                        color: _kBlue,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
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
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppTheme.card,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white.withAOpacity(0.05)),
    ),
    child: Column(
      children: rows.asMap().entries.map((e) {
        final row = e.value;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: e.key < rows.length - 1
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

({String label, Color color, IconData icon}) _statusStyle(
  String s,
) => switch (s) {
  'paid' => (label: 'Paid', color: _kGreen, icon: Icons.check_circle_rounded),
  'overdue' => (
    label: 'Overdue',
    color: AppTheme.error,
    icon: Icons.warning_amber_rounded,
  ),
  'partial' => (
    label: 'Partial',
    color: _kAmber,
    icon: Icons.pie_chart_rounded,
  ),
  'waived' => (
    label: 'Waived',
    color: AppTheme.textSecondary,
    icon: Icons.do_not_disturb_rounded,
  ),
  _ => (label: 'Pending', color: _kBlue, icon: Icons.hourglass_empty_rounded),
};

class _MembershipCard extends StatelessWidget {
  final MembershipEntity info;
  const _MembershipCard({required this.info});

  @override
  Widget build(BuildContext context) {
    final p = info;
    final badgeColor = p.isCurrentPeriod ? _kGreen : AppTheme.textSecondary;
    final badgeText = p.periodStart.isEmpty
        ? 'Standalone invoice'
        : p.isCurrentPeriod
        ? 'Current period'
        : 'Past / upcoming period';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withAOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withAOpacity(0.14),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.card_membership_rounded,
                  color: AppTheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.plan.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Plan price ${_money(p.plan.price)}',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withAOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: badgeColor.withAOpacity(0.35)),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    color: badgeColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          if (p.periodStart.isNotEmpty && p.periodEnd.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Divider(color: Colors.white12, height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                _AmountRow(
                  'Period Start',
                  _fmtDate(p.periodStart.toDateTime),
                  Colors.white,
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppTheme.textSecondary,
                  size: 16,
                ),
                const Spacer(),
                _AmountRow(
                  'Period End',
                  _fmtDate(p.periodEnd.toDateTime),
                  Colors.white,
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              if (p.isRenewal) const _Chip('Renewal', _kBlue),
              _Chip(
                p.applied ? 'Applied to membership' : 'Not applied yet',
                p.applied ? _kGreen : _kAmber,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final Color color;
  const _Chip(this.text, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withAOpacity(0.12),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: color.withAOpacity(0.3)),
    ),
    child: Text(
      text,
      style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700),
    ),
  );
}

class _LinkedFeeTile extends StatelessWidget {
  final RelatedFeeEntity fee;
  final VoidCallback onTap;
  const _LinkedFeeTile({required this.fee, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final s = _statusStyle(fee.status);
    final showBalance = fee.balance > 0 && fee.status != 'waived';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: s.color.withAOpacity(0.25)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: s.color.withAOpacity(0.14),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(s.icon, color: s.color, size: 19),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fee.plan,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    [
                      if (fee.dueDate.isNotEmpty)
                        'Due ${_fmtDate(fee.dueDate.toDateTime)}',
                      if (fee.paidDate.isNotEmpty)
                        'Paid ${_fmtDate(fee.paidDate.toDateTime)}',
                    ].join(' · '),
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _money(fee.amount),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (showBalance)
                  Text(
                    'Bal ${_money(fee.balance)}',
                    style: const TextStyle(color: _kAmber, fontSize: 10),
                  ),
                const SizedBox(height: 4),
                _StatusBadge(label: s.label, color: s.color, icon: s.icon),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _onExported(BuildContext context, String path) async {
  final action = await showModalBottomSheet<String>(
    context: context,
    backgroundColor: AppTheme.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PDF Report is ready',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'What would you like to do with it?',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context, 'open'),
                    icon: const Icon(Icons.open_in_new_rounded, size: 18),
                    label: const Text('Open'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context, 'share'),
                    icon: const Icon(Icons.ios_share_rounded, size: 18),
                    label: const Text('Share'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  if (!context.mounted || action == null) return;

  if (action == 'share') {
    await SharePlus.instance.share(
      ShareParams(text: 'Check out our Fee record', files: [XFile(path)]),
    );
  } else {
    final result = await OpenFilex.open(path);
    if (result.type != ResultType.done && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No app found to open this file. ${result.message}'),
        ),
      );
    }
  }
}
