import 'package:club_fitness/config/navigation/routes_class.dart';
import 'package:club_fitness/config/theme/theme.dart';
import 'package:club_fitness/core/utils/utils.dart';
import 'package:club_fitness/di.dart';
import 'package:club_fitness/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/admin_utils_entities.dart';
import '../bloc/report_bloc/report_bloc.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';

enum ReportExportFormat { pdf, excel }

class ReportsProvider extends StatelessWidget {
  const ReportsProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReportBloc(sl(), sl(), sl()),
      child: const ReportsScreen(),
    );
  }
}

// ─── Main Screen ──────────────────────────────────────────────────────────────
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  int _rangeIndex = 2; // 0: 1D, 1: 7D, 2: 30D, 3: 6M, 4: 1Y, -1: custom
  final List<String> _ranges = const ['1D', '7D', '30D', '6M', '1Y'];

  final Map<String, String> rangeLabels = {
    '1D': 'Today',
    '7D': 'Last 7 days',
    '30D': 'Last 30 days',
    '6M': 'Last 6 months',
    '1Y': 'Last year',
  };

  DateTimeRange? _customRange;
  ReportExportFormat? _exporting;

  bool get _isCustom => _rangeIndex < 0 && _customRange != null;
  String get _rangeParam => _isCustom ? 'CUSTOM' : _ranges[_rangeIndex];
  String? get _startDate => _isCustom ? _apiDate(_customRange!.start) : null;
  String? get _endDate => _isCustom ? _apiDate(_customRange!.end) : null;

  String _apiDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  String _fmtDay(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

  void _loadReport() => context.read<ReportBloc>().add(
    GetSalesReportEvent(_rangeParam, startDate: _startDate, endDate: _endDate),
  );

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _pickCustomRange() async {
    final now = DateTime.now();
    final result = await showModalBottomSheet<DateTimeRange>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CustomRangeSheet(
        initial: _customRange,
        firstDate: DateTime(2000),
        lastDate: DateTime(now.year, now.month, now.day),
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      _customRange = result;
      _rangeIndex = -1;
    });
    _loadReport();
  }

  Future<void> _startExport(ReportExportFormat format) async {
    final limit = await showDialog<int>(
      context: context,
      builder: (_) => const _TxLimitDialog(),
    );
    if (limit == null || !mounted) return; // cancelled
    bool isPdf = format == ReportExportFormat.pdf;

    final bloc = context.read<ReportBloc>();
    bloc.add(
      isPdf
          ? ExportSalesReportPdfEvent(
              _rangeParam,
              startDate: _startDate,
              endDate: _endDate,
              txLimit: limit,
            )
          : ExportSalesReportExcelEvent(
              _rangeParam,
              startDate: _startDate,
              endDate: _endDate,
              txLimit: limit,
            ),
    );
  }

  Future<void> _onExported(String path, bool isPdf) async {
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
              Text(
                '${isPdf ? 'PDF' : 'Excel'} report ready',
                style: const TextStyle(
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
    if (!mounted || action == null) return;

    String dateLabel;
    if (_isCustom) {
      dateLabel =
          'from ${_fmtDay(_customRange!.start)} to ${_fmtDay(_customRange!.end)}';
    } else {
      dateLabel = "for ${rangeLabels[_ranges[_rangeIndex]]}";
    }

    if (action == 'share') {
      await SharePlus.instance.share(
        ShareParams(
          text: 'Check out our sales report $dateLabel',
          files: [XFile(path)],
        ),
      );
    } else {
      final result = await OpenFilex.open(path);
      if (result.type != ResultType.done && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No app found to open this file. ${result.message}'),
          ),
        );
      }
    }
  }

  static const _txPreviewLimit = 20; // must match the API's default txLimit

  void _openFeeRecords() {
    context.pushNamed(RoutesName.manageFees);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [_ReportActionMenu(onExport: _startExport)],
      ),
      body: SafeArea(
        child: BlocConsumer<ReportBloc, ReportState>(
          listener: (context, state) {
            if (state is ReportExportSuccess) {
              _onExported(state.path, state.isPdf);
            } else if (state is ReportExportFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Could not export the ${state.isPdf ? 'PDF' : 'Excel'} report. Please try again.',
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is ReportFailure) {
              return FailureTextWidget(state.failure, onRetry: _loadReport);
            }
            return ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              children: [
                _buildRangeSelector(),
                const SizedBox(height: 20),
                if (state is ReportLoaded) ...[
                  _buildKpiGrid(state.report.kpis),
                  const SizedBox(height: 28),
                  _buildSectionLabel(
                    'Revenue Trend',
                    state.report.revenueTrendDuration,
                  ),
                  const SizedBox(height: 16),
                  _buildRevenueChartCard(state.report.revenueTrend),
                  const SizedBox(height: 28),
                  _buildSectionLabel('Revenue Split', 'By membership plan'),
                  const SizedBox(height: 16),
                  _buildPlanSplitRow(state.report.planSplit),
                  const SizedBox(height: 28),
                  _buildSectionLabel(
                    'Plan Performance',
                    state.report.planSplit.length.pluralizeWithCount('plan'),
                  ),
                  const SizedBox(height: 16),
                  _buildPlanTable(state.report.planSplit),
                  const SizedBox(height: 28),
                  _buildSectionLabel(
                    'Transaction Log',
                    state.report.transactions.length >= _txPreviewLimit
                        ? 'Latest ${state.report.transactions.length}'
                        : state.report.transactions.length.pluralizeWithCount(
                            'record',
                          ),
                  ),
                  const SizedBox(height: 16),
                  _buildTransactionTable(state.report.transactions),
                  const SizedBox(height: 16),
                  _buildExportRow(state),
                ] else ...[
                  const Center(child: CircularProgressIndicator()),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  // ── Range Selector ──────────────────────────────────────────────────────────
  Widget _buildRangeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.cardBorder, width: 1),
          ),
          child: Row(
            children: [
              ..._ranges.asMap().entries.map(
                (e) => _rangeChip(
                  selected: _rangeIndex == e.key,
                  onTap: () {
                    setState(() => _rangeIndex = e.key);
                    _loadReport();
                  },
                  child: Text(
                    e.value,
                    style: TextStyle(
                      color: _rangeIndex == e.key
                          ? Colors.white
                          : AppTheme.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              _rangeChip(
                selected: _isCustom,
                onTap: _pickCustomRange,
                child: Icon(
                  Icons.date_range_rounded,
                  size: 16,
                  color: _isCustom ? Colors.white : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (_isCustom)
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 4),
            child: Text(
              '${_fmtDay(_customRange!.start)} – ${_fmtDay(_customRange!.end)}',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _rangeChip({
    required bool selected,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppTheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: child,
        ),
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

  String? _vsPrevious(num? v, {bool percent = false}) {
    if (v == null) return null; // no previous data -> hide the line
    return '${v >= 0 ? '+' : ''}$v${percent ? '%' : ''} vs previous period';
  }

  // ── KPI Grid ─────────────────────────────────────────────────────────────────
  Widget _buildKpiGrid(KpisEntity kpis) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.05,
      ),
      children: [
        _KpiCard(
          color: AppTheme.primary,
          icon: Icons.wallet,
          value: kpis.totalRevenue.value.toString(),
          label: "Total Revenue",
          positive: kpis.totalRevenue.positive,
          sub:
              _vsPrevious(kpis.totalRevenue.changePercent, percent: true) ?? '',
        ),
        _KpiCard(
          color: AppTheme.primary,
          icon: Icons.card_membership_rounded,
          value: kpis.membershipsSold.value.toString(),
          label: "Memberships Sold",
          positive: kpis.membershipsSold.positive,
          sub: _vsPrevious(kpis.membershipsSold.delta) ?? '',
        ),
        _KpiCard(
          color: AppTheme.primary,
          icon: Icons.shopping_bag_rounded,
          value: kpis.shopSales.value.toString(),
          label: "Shop Sales",
          positive: kpis.shopSales.positive,
          sub: _vsPrevious(kpis.shopSales.changePercent, percent: true) ?? '',
        ),
        _KpiCard(
          color: AppTheme.primary,
          icon: Icons.receipt_long_rounded,
          value: kpis.outstandingDues.value.toString(),
          label: "Outstanding Dues",
          positive: kpis.outstandingDues.positive,
          sub: "${kpis.outstandingDues.memberCount} members",
        ),
      ],
    );
  }

  // ── Revenue Chart Card ──────────────────────────────────────────────────────
  Widget _buildRevenueChartCard(RevenueTrendEntity trend) {
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
                    'Total Collections',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '₹ ${trend.total.formatIndianComma} over ${trend.months.length.pluralizeWithCount('month')}',
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
                  color: const Color(0xFF4CAF50).withAOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF4CAF50).withAOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.arrow_upward_rounded,
                      color: Color(0xFF4CAF50),
                      size: 12,
                    ),
                    SizedBox(width: 2),
                    Text(
                      '8.4%',
                      style: TextStyle(
                        color: Color(0xFF4CAF50),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const SizedBox(
            height: 180,
            child: CustomPaint(
              size: Size(double.infinity, 180),
              painter: _BarChartPainter(
                values: [98000, 114900, 105000, 122000, 110000, 124500],
                labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
                barColor: AppTheme.primary,
                highlightIndex: 5,
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Divider(height: 24),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ChartLegendDot(color: AppTheme.primary, label: 'Memberships'),
              _ChartLegendDot(color: Color(0xFF29B6F6), label: 'Shop Sales'),
              _ChartLegendDot(color: Color(0xFFFFA000), label: 'Other'),
            ],
          ),
        ],
      ),
    );
  }

  // ── Plan Split Row (donut + summary) ────────────────────────────────────────
  Widget _buildPlanSplitRow(List<PlanSpliEntity> planRows) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              children: [
                SizedBox(
                  height: 120,
                  child: CustomPaint(
                    size: const Size(double.infinity, 120),
                    painter: _DonutChartPainter(
                      segments: planRows
                          .map(
                            (p) =>
                                _DonutSegment(p.plan, p.share, p.color.fromHex),
                          )
                          .toList(),
                      centerValue: '₹6.8L',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
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
              children: planRows
                  .map(
                    (p) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: p.color.fromHex,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              p.plan,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            '${(p.share * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  // ── Plan Table ───────────────────────────────────────────────────────────────
  Widget _buildPlanTable(List<PlanSpliEntity> planRows) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withAOpacity(0.05), width: 1),
      ),
      child: Column(
        children: [
          _planTableHeader(),
          ...planRows.asMap().entries.map((e) {
            final isLast = e.key == planRows.length - 1;
            return _planTableRow(e.value, isLast);
          }),
        ],
      ),
    );
  }

  Widget _planTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.divider, width: 1)),
      ),
      child: const Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              'PLAN',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'MEMBERS',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'REVENUE',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _planTableRow(PlanSpliEntity row, bool isLast) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : const BorderSide(color: AppTheme.divider, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: row.color.fromHex,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    row.plan,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${row.members}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              "₹ ${row.revenue.formatIndianComma}",
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Transaction Table ────────────────────────────────────────────────────────
  Widget _buildTransactionTable(List<TransactionEntity> transactions) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withAOpacity(0.05), width: 1),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Text(
                    'MEMBER',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'AMOUNT',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'STATUS',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...transactions.asMap().entries.map((e) {
            final isLast = e.key == transactions.length - 1;
            return _transactionRow(e.value, isLast);
          }),
          if (transactions.length >= _txPreviewLimit)
            InkWell(
              onTap: _openFeeRecords,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(18),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppTheme.divider, width: 1),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'See all fee records',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: AppTheme.primary,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _transactionRow(TransactionEntity row, bool isLast) {
    Color statusColor;
    switch (row.status.toLowerCase()) {
      case 'paid':
        statusColor = const Color(0xFF4CAF50);
        break;
      case 'overdue':
        statusColor = AppTheme.error;
        break;
      default:
        statusColor = const Color(0xFFFFA000);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : const BorderSide(color: AppTheme.divider, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.member,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${row.plan} · ${row.mode.or('N/A')} · ${_formatTransactionDate(row.date)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              "₹ ${row.amount.formatIndianComma}",
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withAOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: statusColor.withAOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  row.status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTransactionDate(String date) {
    final dateTime = date.toDateTime;
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return "${months[dateTime.month - 1]} ${dateTime.day}";
  }

  // ── Export Row ───────────────────────────────────────────────────────────────
  Widget _buildExportRow(ReportLoaded state) {
    final exporting = state is ReportExportLoading ? state : null;

    Widget icon(bool isPdf, IconData data) => exporting?.isPdf == isPdf
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Icon(data, size: 18);

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: exporting == null
                ? () => _startExport(ReportExportFormat.pdf)
                : null,
            icon: icon(true, Icons.picture_as_pdf_rounded),
            label: const Text('Export PDF'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: exporting == null
                ? () => _startExport(ReportExportFormat.excel)
                : null,
            icon: icon(false, Icons.table_chart_rounded),
            label: const Text('Export Excel'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── KPI Card ───────────────────────────────────────────────────────────────────
class _KpiCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String value, label, sub;
  final bool positive;

  const _KpiCard({
    required this.color,
    required this.icon,
    required this.value,
    required this.label,
    required this.sub,
    required this.positive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withAOpacity(0.15), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withAOpacity(0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (sub.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      positive
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      color: positive
                          ? const Color(0xFF4CAF50)
                          : AppTheme.error,
                      size: 11,
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        sub,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: positive
                              ? const Color(0xFF4CAF50)
                              : AppTheme.error,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Chart legend dot ─────────────────────────────────────────────────────────
class _ChartLegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _ChartLegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ─── Donut segment model ──────────────────────────────────────────────────────
class _DonutSegment {
  final String label;
  final num fraction;
  final Color color;
  const _DonutSegment(this.label, this.fraction, this.color);
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
    final double maxVal = values.reduce((a, b) => a > b ? a : b);
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
        final valStr = '₹${(values[i] / 1000).toStringAsFixed(0)}K';
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
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─── Donut Chart Painter ──────────────────────────────────────────────────────
class _DonutChartPainter extends CustomPainter {
  final List<_DonutSegment> segments;
  final String centerValue;
  const _DonutChartPainter({required this.segments, this.centerValue = ''});

  @override
  void paint(Canvas canvas, Size size) {
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

    if (centerValue.isNotEmpty) {
      final tp = TextPainter(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$centerValue\n',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w900,
                height: 1.3,
              ),
            ),
            const TextSpan(
              text: 'total',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 10,
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
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _CustomRangeSheet extends StatefulWidget {
  final DateTimeRange? initial;
  final DateTime firstDate;
  final DateTime lastDate;
  const _CustomRangeSheet({
    required this.initial,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  State<_CustomRangeSheet> createState() => _CustomRangeSheetState();
}

class _CustomRangeSheetState extends State<_CustomRangeSheet> {
  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  late DateTime _start;
  late DateTime _end;

  @override
  void initState() {
    super.initState();
    final today = widget.lastDate;
    _start = widget.initial?.start ?? today.subtract(const Duration(days: 6));
    _end = widget.initial?.end ?? today;
  }

  String _fmt(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';
  int get _days => _end.difference(_start).inDays + 1;

  Future<void> _pick({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _start : _end,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      helpText: isStart ? 'SELECT START DATE' : 'SELECT END DATE',
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _start = picked;
        if (_end.isBefore(_start)) _end = _start;
      } else {
        _end = picked;
        if (_start.isAfter(_end)) _start = _end;
      }
    });
  }

  void _preset(DateTime start, DateTime end) => setState(() {
    _start = start;
    _end = end.isAfter(widget.lastDate) ? widget.lastDate : end;
  });

  @override
  Widget build(BuildContext context) {
    final t = widget.lastDate; // today
    final presets = <String, VoidCallback>{
      'Yesterday': () => _preset(
        t.subtract(const Duration(days: 1)),
        t.subtract(const Duration(days: 1)),
      ),
      'This month': () => _preset(DateTime(t.year, t.month, 1), t),
      'Last month': () => _preset(
        DateTime(t.year, t.month - 1, 1),
        DateTime(t.year, t.month, 0),
      ),
      'This year': () => _preset(DateTime(t.year, 1, 1), t),
      'Last year': () =>
          _preset(DateTime(t.year - 1, 1, 1), DateTime(t.year - 1, 12, 31)),
    };

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Custom range',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _dateTile('FROM', _start, () => _pick(isStart: true)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _dateTile('TO', _end, () => _pick(isStart: false)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: presets.entries
                  .map(
                    (e) => ActionChip(
                      label: Text(e.key, style: const TextStyle(fontSize: 12)),
                      onPressed: e.value,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
            Text(
              '$_days ${_days == 1 ? 'day' : 'days'} selected',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(
                  context,
                  DateTimeRange(start: _start, end: _end),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Apply'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateTile(String label, DateTime date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _fmt(date),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 14,
                  color: AppTheme.textSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportActionMenu extends StatelessWidget {
  final void Function(ReportExportFormat format) onExport;
  const _ReportActionMenu({required this.onExport});

  List<(String, IconData, void Function()?)> get actions => [
    (
      'Export PDF',
      Icons.picture_as_pdf_rounded,
      () => onExport(ReportExportFormat.pdf),
    ),
    (
      'Export Excel',
      Icons.insert_drive_file_rounded,
      () => onExport(ReportExportFormat.excel),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final color = Colors.white;
    return PopupMenuButton<int>(
      tooltip: 'Report Actions',
      offset: const Offset(0, 48),
      elevation: 12,
      color: AppTheme.card,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black.withAOpacity(0.5),
      constraints: const BoxConstraints(minWidth: 210),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withAOpacity(0.08), width: 1),
      ),
      icon: const Icon(Icons.more_vert_rounded, color: Colors.white, size: 20),
      onSelected: (i) => actions[i].$3?.call(),
      itemBuilder: (_) {
        final items = <PopupMenuEntry<int>>[];
        for (int i = 0; i < actions.length; i++) {
          final (label, icon, onTap) = actions[i];

          items.add(
            PopupMenuItem<int>(
              value: i,
              enabled: onTap != null,
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Opacity(
                opacity: onTap == null ? 0.45 : 1,
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color.withAOpacity(0.14),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Icon(icon, color: color, size: 17),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return items;
      },
    );
  }
}

class _TxLimitDialog extends StatefulWidget {
  const _TxLimitDialog();
  @override
  State<_TxLimitDialog> createState() => _TxLimitDialogState();
}

class _TxLimitDialogState extends State<_TxLimitDialog> {
  static const _presets = [100, 250, 500, 1000];
  static const _max = 1000; // backend clamps txLimit to 1000
  final _controller = TextEditingController(text: '500');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int? get _value {
    final n = int.tryParse(_controller.text.trim());
    return (n != null && n >= 1 && n <= _max) ? n : null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.card,
      title: const Text(
        'Transactions to include',
        style: TextStyle(color: Colors.white, fontSize: 17),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _presets
                .map(
                  (n) => ChoiceChip(
                    label: Text('$n'),
                    selected: _controller.text == '$n',
                    onSelected: (_) => setState(() => _controller.text = '$n'),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(color: Colors.white),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'Number of records (1–$_max)',
              errorText: _value == null
                  ? 'Enter a number from 1 to $_max'
                  : null,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _value == null
              ? null
              : () => Navigator.pop(context, _value),
          child: const Text('Export'),
        ),
      ],
    );
  }
}
