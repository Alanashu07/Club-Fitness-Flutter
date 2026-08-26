import 'package:club_fitness/config/theme/theme.dart';
import 'package:club_fitness/core/utils/utils.dart';
import 'package:club_fitness/di.dart';
import 'package:club_fitness/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/admin_utils_entities.dart';
import '../bloc/report_bloc/report_bloc.dart';

// // ─── Dummy data ───────────────────────────────────────────────────────────────
class _KpiItem {
  final String label;
  final String value;
  final String sub;
  final IconData icon;
  final Color accent;
  final bool positive;
  const _KpiItem(
    this.label,
    this.value,
    this.sub,
    this.icon,
    this.accent,
    this.positive,
  );
}

class _RevenueRow {
  final String date;
  final String member;
  final String plan;
  final String mode;
  final String amount;
  final String status;
  const _RevenueRow(
    this.date,
    this.member,
    this.plan,
    this.mode,
    this.amount,
    this.status,
  );
}

class _PlanRow {
  final String plan;
  final int members;
  final String revenue;
  final double share;
  final Color color;
  const _PlanRow(this.plan, this.members, this.revenue, this.share, this.color);
}

const _kpis = [
  _KpiItem(
    'Total Revenue',
    '₹ 6,84,200',
    '+8.4% vs last month',
    Icons.account_balance_wallet_rounded,
    AppTheme.primary,
    true,
  ),
  _KpiItem(
    'Memberships Sold',
    '57',
    '+5 vs last month',
    Icons.card_membership_rounded,
    Color(0xFF7B1FA2),
    true,
  ),
  _KpiItem(
    'Shop Sales',
    '₹ 42,300',
    '-2.1% vs last month',
    Icons.shopping_bag_rounded,
    Color(0xFF29B6F6),
    false,
  ),
  _KpiItem(
    'Outstanding Dues',
    '₹ 54,000',
    '18 members',
    Icons.receipt_long_rounded,
    Color(0xFFFFA000),
    false,
  ),
];

const _planRows = [
  _PlanRow('Annual Plan', 64, '₹ 2,87,400', 0.42, Color(0xFFC41E2D)),
  _PlanRow('Premium Monthly', 41, '₹ 2,12,000', 0.31, Color(0xFF7B1FA2)),
  _PlanRow('Basic Monthly', 38, '₹ 1,23,200', 0.18, Color(0xFF1565C0)),
  _PlanRow('Quarterly', 12, '₹ 61,600', 0.09, Color(0xFF2E7D32)),
];

const _revenueRows = [
  _RevenueRow(
    'Jun 7',
    'Arjun Menon',
    'Premium Monthly',
    'UPI',
    '₹ 2,500',
    'Paid',
  ),
  _RevenueRow('Jun 7', 'Priya Nair', 'Annual Plan', 'Card', '₹ 18,000', 'Paid'),
  _RevenueRow('Jun 6', 'Rahul Das', 'Basic Monthly', 'Cash', '₹ 1,800', 'Paid'),
  _RevenueRow('Jun 6', 'Sneha Pillai', 'Quarterly', 'UPI', '₹ 5,400', 'Paid'),
  _RevenueRow(
    'Jun 5',
    'Kiran Kumar',
    'Premium Monthly',
    'UPI',
    '₹ 2,500',
    'Overdue',
  ),
  _RevenueRow(
    'Jun 5',
    'Deepa Suresh',
    'Basic Monthly',
    'Cash',
    '₹ 1,800',
    'Overdue',
  ),
  _RevenueRow(
    'Jun 4',
    'Amal Jose',
    'Annual Plan',
    'Card',
    '₹ 18,000',
    'Pending',
  ),
];

class ReportsProvider extends StatelessWidget {
  const ReportsProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReportBloc(sl()),
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
  int _rangeIndex = 1; // 0: 7D, 1: 30D, 2: 6M, 3: 1Y
  final List<String> _ranges = const ['7D', '30D', '6M', '1Y'];

  @override
  void initState() {
    super.initState();
    context.read<ReportBloc>().add(GetSalesReportEvent(_ranges[_rangeIndex]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Reports'),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.ios_share_rounded, color: Colors.white),
        //     onPressed: () {},
        //   ),
        // ],
      ),
      body: SafeArea(
        child: BlocBuilder<ReportBloc, ReportState>(
          builder: (context, state) {
            if (state is ReportFailure) {
              return FailureTextWidget(
                state.failure,
                onRetry: () => context.read<ReportBloc>().add(
                  GetSalesReportEvent(_ranges[_rangeIndex]),
                ),
              );
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
                    state.report.transactions.length.pluralizeWithCount(
                      'record',
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTransactionTable(state.report.transactions),
                  const SizedBox(height: 16),
                  // _buildExportRow(),
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
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.cardBorder, width: 1),
      ),
      child: Row(
        children: _ranges.asMap().entries.map((e) {
          final selected = _rangeIndex == e.key;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _rangeIndex = e.key);
                context.read<ReportBloc>().add(GetSalesReportEvent(e.value));
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? AppTheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  e.value,
                  style: TextStyle(
                    color: selected ? Colors.white : AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
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
              "${kpis.totalRevenue.positive ? '+' : ''}${kpis.totalRevenue.changePercent}% vs last month",
        ),
        _KpiCard(
          color: AppTheme.primary,
          icon: Icons.card_membership_rounded,
          value: kpis.membershipsSold.value.toString(),
          label: "Memberships Sold",
          positive: kpis.membershipsSold.positive,
          sub:
              "${kpis.membershipsSold.positive ? '+' : ''}${kpis.membershipsSold.delta} vs last month",
        ),
        _KpiCard(
          color: AppTheme.primary,
          icon: Icons.shopping_bag_rounded,
          value: kpis.shopSales.value.toString(),
          label: "Shop Sales",
          positive: kpis.shopSales.positive,
          sub:
              "${kpis.shopSales.positive ? '+' : ''}${kpis.shopSales.changePercent}% vs last month",
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
  Widget _buildExportRow() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
            label: const Text('Export PDF'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.table_chart_rounded, size: 18),
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
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    positive
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                    color: positive ? const Color(0xFF4CAF50) : AppTheme.error,
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
