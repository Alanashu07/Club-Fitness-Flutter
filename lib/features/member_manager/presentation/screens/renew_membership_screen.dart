import 'package:club_fitness/config/theme/theme.dart';
import 'package:club_fitness/core/constants/constants.dart';
import 'package:flutter/material.dart';

// ─── Models ───────────────────────────────────────────────────────────────────

class _PlanOption {
  final String name;
  final String price;
  final String period;
  final String savings;
  final bool popular;
  const _PlanOption(
    this.name,
    this.price,
    this.period, {
    this.savings = '',
    this.popular = false,
  });
}

class _PaymentMethod {
  final String name;
  final IconData icon;
  final Color accent;
  const _PaymentMethod(this.name, this.icon, this.accent);
}

// ─── Dummy data ───────────────────────────────────────────────────────────────

const _plans = [
  _PlanOption('Monthly', '₹ 2,500', '/month'),
  _PlanOption(
    'Quarterly',
    '₹ 6,750',
    '/3 months',
    savings: 'Save ₹750',
    popular: true,
  ),
  _PlanOption('Annual', '₹ 24,000', '/year', savings: 'Save ₹6,000'),
];

const _paymentMethods = [
  _PaymentMethod('UPI', Icons.qr_code_rounded, Color(0xFF4CAF50)),
  _PaymentMethod(
    'Credit / Debit Card',
    Icons.credit_card_rounded,
    Color(0xFF29B6F6),
  ),
  _PaymentMethod(
    'Net Banking',
    Icons.account_balance_rounded,
    Color(0xFF7B1FA2),
  ),
  _PaymentMethod(
    'Pay at Front Desk',
    Icons.storefront_rounded,
    AppTheme.primary,
  ),
];

// ─── Main Screen ──────────────────────────────────────────────────────────────

class RenewMembershipScreen extends StatefulWidget {
  const RenewMembershipScreen({super.key});
  @override
  State<RenewMembershipScreen> createState() => _RenewMembershipScreenState();
}

class _RenewMembershipScreenState extends State<RenewMembershipScreen> {
  int _selectedPlan = 1; // Quarterly selected by default
  int _selectedPayment = 0;

  String get _planTotal {
    final p = _plans[_selectedPlan];
    return p.price;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Renew Membership')),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 140),
              children: [
                _buildCurrentPlanCard(),
                const SizedBox(height: 28),
                _buildSectionLabel('Choose a Plan'),
                const SizedBox(height: 14),
                ..._plans.asMap().entries.map(
                  (e) => _PlanCard(
                    plan: e.value,
                    selected: _selectedPlan == e.key,
                    onTap: () => setState(() => _selectedPlan = e.key),
                  ),
                ),
                const SizedBox(height: 28),
                _buildSectionLabel('Payment Method'),
                const SizedBox(height: 14),
                ..._paymentMethods.asMap().entries.map(
                  (e) => _PaymentMethodTile(
                    method: e.value,
                    selected: _selectedPayment == e.key,
                    onTap: () => setState(() => _selectedPayment = e.key),
                  ),
                ),
                const SizedBox(height: 28),
                _buildSectionLabel('Order Summary'),
                const SizedBox(height: 14),
                _buildOrderSummary(),
                const SizedBox(height: 16),
                _buildPromoRow(),
              ],
            ),
            Positioned(bottom: 0, right: 0, left: 0, child: _buildBottomBar()),
          ],
        ),
      ),
    );
  }

  // ── Section Label ───────────────────────────────────────────────────────────
  Widget _buildSectionLabel(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 17,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.2,
      ),
    );
  }

  // ── Current Plan Card ───────────────────────────────────────────────────────
  Widget _buildCurrentPlanCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A0008), Color(0xFF1A1A1A)],
        ),
        border: Border.all(color: AppTheme.primary.withAOpacity(0.4), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppTheme.primary.withAOpacity(0.15),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.card_membership_rounded,
              color: AppTheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Premium Monthly',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Expires in 18 days · Jun 25, 2025',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFFFA000).withAOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFFFA000).withAOpacity(0.4),
                width: 1,
              ),
            ),
            child: const Text(
              'EXPIRING SOON',
              style: TextStyle(
                color: Color(0xFFFFA000),
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Order Summary ───────────────────────────────────────────────────────────
  Widget _buildOrderSummary() {
    final plan = _plans[_selectedPlan];
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withAOpacity(0.05), width: 1),
      ),
      child: Column(
        children: [
          _summaryRow('${plan.name} Plan', plan.price),
          const SizedBox(height: 10),
          _summaryRow('GST (18%)', '₹ ${_gstAmount(plan.price)}'),
          if (plan.savings.isNotEmpty) ...[
            const SizedBox(height: 10),
            _summaryRow(plan.savings, '', valueColor: const Color(0xFF4CAF50)),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: AppTheme.divider),
          ),
          _summaryRow(
            'Total Payable',
            '₹ ${_totalWithGst(plan.price)}',
            bold: true,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    bool bold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: bold ? Colors.white : AppTheme.textSecondary,
            fontSize: bold ? 15 : 13,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? (bold ? AppTheme.primary : Colors.white),
            fontSize: bold ? 18 : 13,
            fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
      ],
    );
  }

  String _gstAmount(String price) {
    final num = double.tryParse(price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
    final gst = num * 0.18;
    return gst
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  }

  String _totalWithGst(String price) {
    final num = double.tryParse(price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
    final total = num * 1.18;
    return total
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  }

  // ── Promo Row ────────────────────────────────────────────────────────────────
  Widget _buildPromoRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFFFD600).withAOpacity(0.25),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.local_offer_rounded,
            color: Color(0xFFFFD600),
            size: 18,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Have a promo code?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: const Text(
              'Apply',
              style: TextStyle(
                color: Color(0xFFFFD600),
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom Bar ───────────────────────────────────────────────────────────────
  Widget _buildBottomBar() {
    final plan = _plans[_selectedPlan];
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),

      width: context.width,
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
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
              ),
              const SizedBox(height: 2),
              Text(
                '₹ ${_totalWithGst(plan.price)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: 180,
            child: ElevatedButton(
              onPressed: () {},
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock_rounded, size: 16, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Pay & Renew'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Plan Card ──────────────────────────────────────────────────────────────────
class _PlanCard extends StatelessWidget {
  final _PlanOption plan;
  final bool selected;
  final VoidCallback onTap;
  const _PlanCard({
    required this.plan,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary.withAOpacity(0.1) : AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? AppTheme.primary
                : Colors.white.withAOpacity(0.06),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppTheme.primary : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? AppTheme.primary
                      : Colors.white.withAOpacity(0.25),
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 13,
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        plan.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (plan.popular) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withAOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'MOST POPULAR',
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (plan.savings.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      plan.savings,
                      style: const TextStyle(
                        color: Color(0xFF4CAF50),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  plan.price,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  plan.period,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Payment Method Tile ──────────────────────────────────────────────────────
class _PaymentMethodTile extends StatelessWidget {
  final _PaymentMethod method;
  final bool selected;
  final VoidCallback onTap;
  const _PaymentMethodTile({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? method.accent.withAOpacity(0.08) : AppTheme.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? method.accent.withAOpacity(0.5)
                : Colors.white.withAOpacity(0.05),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: method.accent.withAOpacity(0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(method.icon, color: method.accent, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                method.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? method.accent : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? method.accent
                      : Colors.white.withAOpacity(0.25),
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 12,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
