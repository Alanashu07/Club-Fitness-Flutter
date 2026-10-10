import 'dart:async';

import 'package:club_fitness/config/theme/theme.dart';
import 'package:club_fitness/core/utils/utils.dart';
import 'package:club_fitness/features/member_manager/member_manager.dart';
import 'package:club_fitness/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';

class RenewMembershipSheet extends StatefulWidget {
  final MemberEntity member;
  const RenewMembershipSheet({super.key, required this.member});

  @override
  State<RenewMembershipSheet> createState() => _RenewMembershipSheetState();
}

class _RenewMembershipSheetState extends State<RenewMembershipSheet> {
  static const _methods = [
    (key: 'CASH', label: 'Cash'),
    (key: 'UPI', label: 'UPI'),
    (key: 'BANK_TRANSFER', label: 'Bank Transfer'),
    (key: 'OTHER', label: 'Other'),
  ];

  PlanOfferEntity? _offer;
  final _offerCodeCtrl = TextEditingController();
  RemainingAction _remaining = RemainingAction.pending;

  late String _planId = widget.member.membershipPlan.id;
  MembershipPlanMiniEntity? _plan;
  DateTime? _startDate; // null = automatically after the current membership
  String? _method = _methods.firstOrNull?.key;
  PlatformFile? _receipt;
  String? _error;

  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _plan = widget.member.membershipPlan;
    context.read<MembersConfigBloc>().add(
      const GetMembershipPlansEvent(false, true, 'RENEWAL'),
    );
    _amountCtrl.text = widget.member.membershipPlan.price.toString();
    final s = context.read<MembersConfigBloc>().state;
    if (s is! MembersConfigSuccess && s is! MembersConfigLoading) {
      context.read<MembersConfigBloc>().add(
        const GetMembershipPlansEvent(true),
      );
    }
  }

  @override
  void dispose() {
    _offerCodeCtrl.dispose();
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  // ── Dates ───────────────────────────────────────────────────────────────

  int get _planDays => _plan?.durationDays.toInt() ?? 0;

  /// The date used when the admin has not picked one: right after the current
  /// membership (or today if it already ended).
  DateTime get _autoStart {
    final end = widget.member.membershipEndDate;
    return end.isAfter(DateTime.now()) ? end : DateTime.now();
  }

  DateTime get _effectiveStart => _startDate ?? _autoStart;

  DateTime? get _effectiveEnd =>
      _plan == null ? null : _effectiveStart.add(Duration(days: _planDays));

  DateTime get _earliestStart {
    final end = widget.member.membershipEndDate;
    return end.isAfter(DateTime.now())
        ? end
        : DateTime.now().subtract(const Duration(days: 365));
  }

  Future<void> _pickStart() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _effectiveStart.isBefore(_earliestStart)
          ? _earliestStart
          : _effectiveStart,
      firstDate: _earliestStart,
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _pickReceipt() async {
    final res = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'pdf'],
    );
    final file = res?.files.single;
    if (file == null) return;
    if (file.size > 5 * 1024 * 1024) {
      setState(() => _error = 'Receipt must be 5MB or smaller');
      return;
    }
    setState(() {
      _receipt = file;
      _error = null;
    });
  }

  // ── Plan callbacks ──────────────────────────────────────────────────────

  void _onPlanPicked(MembershipPlanMiniEntity p) {
    setState(() {
      _planId = p.id;
      _plan = p;
      _offer = null;
      _offerCodeCtrl.clear();
      _error = null;
      _amountCtrl.text = p.price.toString();
    });
  }

  void _onPlanCleared() {
    setState(() {
      _planId = '';
      _plan = null;
      _offer = null;
      _offerCodeCtrl.clear();
      _amountCtrl.clear();
    });
  }

  // ── Money ───────────────────────────────────────────────────────────────

  double get _planPrice {
    if (_offer != null) return _offer!.finalAmount.toDouble();
    final price = _plan?.price ?? widget.member.membershipPlan.price;
    return double.tryParse(price.toString()) ?? 0;
  }

  double? get _balance {
    final paid = double.tryParse(_amountCtrl.text.trim());
    if (paid == null) return null;
    final diff = _planPrice - paid;
    return diff > 0 ? diff : null;
  }

  void _submit() {
    if (_planId.isEmpty) {
      return setState(() => _error = 'Select a plan');
    }
    double? paid;
    final raw = _amountCtrl.text.trim();
    if (raw.isNotEmpty) {
      paid = double.tryParse(raw);
      if (paid == null || paid < 0) {
        return setState(() => _error = 'Enter a valid amount');
      }
    }
    if ((paid ?? 0) > 0 && _method == null) {
      return setState(() => _error = 'Select a payment method');
    }
    final waive = _balance != null && _remaining == RemainingAction.waive;

    Navigator.pop(
      context,
      RenewResult(
        planId: _planId,
        paidPrice: paid ?? 0,
        startOverride: _startDate?.toIso8601String(),
        planName: _plan?.name ?? widget.member.membershipPlan.name,
        planPrice: _plan?.price ?? widget.member.membershipPlan.price,
        startDate: _effectiveStart.toIso8601String(),
        endDate: (_effectiveEnd ?? _effectiveStart).toIso8601String(),
        paidAmount: paid,
        paymentMethod: (paid ?? 0) > 0 ? _method : null,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        receiptPath: _receipt?.path,
        waiveRemaining: waive,
        offerId: _offer?.id,
        offerCode: _offer == null && _offerCodeCtrl.text.trim().isNotEmpty
            ? _offerCodeCtrl.text.trim()
            : null,
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final endLabel = widget.member.membershipEnd.isEmpty
        ? 'today'
        : formatShortDate(widget.member.membershipEnd.toDateTime);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          24,
          16,
          24,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SheetHandle(),
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withAOpacity(0.15),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(
                    Icons.more_time_rounded,
                    color: AppTheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Renew Membership',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── 1. Dates (first) ───────────────────────────────────────────
            MembershipDatesCard(
              start: _effectiveStart,
              end: _effectiveEnd,
              startIsAuto: _startDate == null,
              autoStartHint: 'After current plan ($endLabel)',
              onTapStart: _pickStart,
              onResetStart: () => setState(() => _startDate = null),
            ),
            const SizedBox(height: 6),
            const Text(
              'The current plan stays active until its end date. The renewal takes over automatically.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
            ),
            const SizedBox(height: 20),

            // ── 2. Plan (type-ahead) + Offer ───────────────────────────────
            BlocBuilder<MembersConfigBloc, MembersConfigState>(
              builder: (context, state) {
                if (state.membershipPlans.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Center(child: CircularProgressIndicator.adaptive()),
                  );
                }
                final planWithOffers = state.membershipPlans
                    .where((p) => p.id == _planId)
                    .firstOrNull;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TypeAheadSelectField<MembershipPlanMiniEntity>(
                      label: 'Plan',
                      hint: 'Type to search a plan…',
                      icon: Icons.workspace_premium_outlined,
                      items: state.membershipPlans,
                      selected: _plan,
                      labelOf: planLabel,
                      searchTextOf: planSearchText,
                      subtitleOf: planSubtitle,
                      onSelected: _onPlanPicked,
                      onCleared: _onPlanCleared,
                    ),
                    const SizedBox(height: 20),
                    OfferSelector(
                      offers:
                          planWithOffers?.offers ?? const <PlanOfferEntity>[],
                      selected: _offer,
                      codeController: _offerCodeCtrl,
                      onChanged: (o) => setState(() {
                        _offer = o;
                        _amountCtrl.text =
                            (o?.finalAmount ??
                                    planWithOffers?.price ??
                                    widget.member.membershipPlan.price)
                                .toString();
                        _error = null;
                      }),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),

            // ── 3. Payment ─────────────────────────────────────────────────
            const SheetLabel('Amount Paid'),
            const SizedBox(height: 8),
            Container(
              decoration: sheetFieldDecoration(),
              child: TextField(
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                style: const TextStyle(color: Colors.white, fontSize: 14),
                onChanged: (_) => setState(() => _error = null),
                decoration: const InputDecoration(
                  hintText: 'Leave empty to record as pending',
                  hintStyle: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                  prefixIcon: Icon(
                    Icons.currency_rupee_rounded,
                    color: AppTheme.textSecondary,
                    size: 18,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            if (_balance != null) ...[
              const SizedBox(height: 12),
              _buildRemainingOptions(_balance!),
            ],
            const SizedBox(height: 16),
            const SheetLabel('Payment Method'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _methods
                  .map(
                    (o) => SelectChip(
                      label: o.label,
                      selected: _method == o.key,
                      onTap: () => setState(() {
                        _method = _method == o.key ? null : o.key;
                        _error = null;
                      }),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),

            // ── Receipt ────────────────────────────────────────────────────
            Row(
              spacing: 12,
              children: [
                const SheetLabel('Receipt (optional)'),
                TapTooltip(
                  message:
                      'Attach proof of payment - Screenshot from Paytm, PhonePe, Google Pay, etc, Or any receipt given.',
                  child: const Icon(
                    Icons.info_outline_rounded,
                    color: AppTheme.textSecondary,
                    size: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickReceipt,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: sheetFieldDecoration(),
                child: Row(
                  children: [
                    Icon(
                      _receipt == null
                          ? Icons.upload_file_rounded
                          : Icons.description_rounded,
                      size: 18,
                      color: _receipt == null
                          ? AppTheme.textSecondary
                          : AppTheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _receipt?.name ??
                            'Attach JPG, PNG, WEBP or PDF (max 5MB)',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _receipt == null
                              ? AppTheme.textSecondary
                              : Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (_receipt != null)
                      GestureDetector(
                        onTap: () => setState(() => _receipt = null),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Notes ──────────────────────────────────────────────────────
            const SheetLabel('Notes (optional)'),
            const SizedBox(height: 8),
            Container(
              decoration: sheetFieldDecoration(),
              child: TextField(
                controller: _notesCtrl,
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Any remarks about this renewal',
                  hintStyle: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(14),
                ),
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: AppTheme.error,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _error!,
                      style: const TextStyle(
                        color: AppTheme.error,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Renew Membership',
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

  Widget _buildRemainingOptions(double balance) {
    Widget option({
      required RemainingAction value,
      required String title,
      required String subtitle,
    }) {
      final selected = _remaining == value;
      return GestureDetector(
        onTap: () => setState(() => _remaining = value),
        behavior: HitTestBehavior.opaque,
        child: Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected
                ? AppTheme.primary.withAOpacity(0.1)
                : AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? AppTheme.primary.withAOpacity(0.5)
                  : Colors.white.withAOpacity(0.06),
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: selected ? AppTheme.primary : AppTheme.textSecondary,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: selected ? AppTheme.primary : Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final amount = balance.toStringAsFixed(balance % 1 == 0 ? 0 : 2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.info_outline_rounded,
              size: 14,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '₹$amount is less than the plan amount. What should happen to the rest?',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        option(
          value: RemainingAction.pending,
          title: 'Mark ₹$amount as pending',
          subtitle: 'The balance stays due and shows up as an unpaid fee.',
        ),
        option(
          value: RemainingAction.waive,
          title: 'Waive ₹$amount',
          subtitle:
              'The balance is written off and the fee is treated as fully settled.',
        ),
      ],
    );
  }
}
