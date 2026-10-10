import 'dart:async';

import 'package:club_fitness/config/theme/theme.dart';
import 'package:club_fitness/core/entities/id_name_entity.dart';
import 'package:club_fitness/core/utils/utils.dart';
import 'package:club_fitness/features/member_manager/domain/entities/membership_plan_mini_entity.dart';
import 'package:club_fitness/features/member_manager/presentation/bloc/members_config_bloc/members_config_bloc.dart';
import 'package:club_fitness/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/offers_entities.dart';
import '../bloc/offers_bloc/offers_bloc.dart';

/// Lightweight plan option so the rest of this file doesn't depend on your
/// plan model. Adapt ONLY this function if your plan fields differ.
class PlanOption {
  final String id;
  final String name;
  final num price;
  const PlanOption(this.id, this.name, {this.price = 0});
}

List<PlanOption> _plansFrom(List<MembershipPlanMiniEntity> plans) {
  return plans.map((p) => PlanOption(p.id, p.name, price: p.price)).toList();
}

const _months = [
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
String _fmtDate(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';
String _fmtNum(double v) => v.roundWithFixed;

const _appliesToLabels = {
  'NEW_MEMBER': 'New members',
  'RENEWAL': 'Renewals',
  'BOTH': 'New & renewals',
};

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class OffersView extends StatefulWidget {
  const OffersView({super.key});

  @override
  State<OffersView> createState() => _OffersViewState();
}

class _OffersViewState extends State<OffersView>
    with SingleTickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;
  Timer? _debounceTimer;
  OfferFilters filter = const OfferFilters();

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _fadeCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: error ? AppTheme.error : AppTheme.surface,
        ),
      );
  }

  Future<void> _openForm({
    OfferEntity? offer,
    required List<MembershipPlanMiniEntity> plans,
  }) async {
    final bloc = context.read<OffersBloc>();
    final planOptions = _plansFrom(plans);
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => OfferFormSheet(
        offer: offer,
        plans: planOptions,
        onSubmit: (body) async {
          final isEdit = offer != null;

          final result = bloc.stream.firstWhere((s) {
            if (isEdit) return s is OffersUpdated || s is OffersError;
            return s is OfferCreated || s is OffersError;
          });
          bloc.add(isEdit ? UpdateOfferEvent(body) : CreateOfferEvent(body));
          final state = await result;
          return state is OffersError ? state.failure.message : null;
        },
      ),
    );
    if (saved == true) {
      _snack(offer == null ? 'Offer created' : 'Offer updated');
    }
  }

  Future<void> _confirmDelete(OfferEntity o) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppTheme.error.withAOpacity(0.14),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.delete_rounded,
            color: AppTheme.error,
            size: 26,
          ),
        ),
        title: const Text(
          'Delete offer?',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        content: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13.5,
              height: 1.4,
            ),
            children: [
              TextSpan(
                text: o.name,
                style: const TextStyle(
                  color: AppTheme.error,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              const TextSpan(text: ' will be permanently removed.'),
            ],
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
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
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    context.read<OffersBloc>().add(DeleteOfferEvent(o.id));
  }

  void _toggle(OfferEntity o) {
    context.read<OffersBloc>().add(
      UpdateOfferEvent(OfferEntity(id: o.id, isActive: !o.isActive)),
    );
  }

  void _debounceQuery() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      context.read<OffersBloc>().add(
        GetOffersEvent(
          filters: filter.copyWith(search: _searchCtrl.text.trim()),
        ),
      );
    });
  }

  void _reload() {
    context.read<OffersBloc>().add(GetOffersEvent(filters: filter));
  }

  @override
  Widget build(BuildContext context) {
    final plans = context.watch<MembersConfigBloc>().state.membershipPlans;
    final planOptions = _plansFrom(plans);

    return Scaffold(
      backgroundColor: AppTheme.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(plans: plans),
        backgroundColor: AppTheme.primary,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
        label: const Text(
          'New Offer',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ),
      body: BlocConsumer<OffersBloc, OffersState>(
        listener: (context, state) {
          if (filter != state.filters) {
            setState(() => filter = state.filters);
          }
        },
        builder: (context, state) {
          return FadeTransition(
            opacity: _fadeAnim,
            child: LiquidRefresh(
              onRefresh: () => _reload(),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  _buildAppBar(plans),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSummaryRow(state.offers),
                          const SizedBox(height: 20),
                          _buildSearchBar(),
                          const SizedBox(height: 14),
                          _FilterBar(
                            plans: planOptions,
                            filters: state.filters,
                          ),
                          const SizedBox(height: 14),
                          _buildCountRow(state.offers.length),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                  _buildListSliver(state, plans),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── App bar ────────────────────────────────────────────────────────────────
  Widget _buildAppBar(List<MembershipPlanMiniEntity> plans) {
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
        'Offers',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
      ),
      actions: [
        IconButton(
          icon: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.local_offer_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          onPressed: () => _openForm(plans: plans),
        ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(height: 0.5, color: Colors.white12),
      ),
    );
  }

  // ── Summary ────────────────────────────────────────────────────────────────
  Widget _buildSummaryRow(List<OfferEntity> offers) {
    int count(OfferLifecycle l) => offers.where((o) => o.lifecycle == l).length;

    final items = [
      (
        '${offers.length}',
        'Total',
        AppTheme.primary,
        Icons.local_offer_rounded,
      ),
      (
        '${count(OfferLifecycle.active)}',
        'Active',
        const Color(0xFF4CAF50),
        Icons.check_circle_rounded,
      ),
      (
        '${count(OfferLifecycle.scheduled)}',
        'Scheduled',
        const Color(0xFFFFA000),
        Icons.schedule_rounded,
      ),
      (
        '${count(OfferLifecycle.expired)}',
        'Expired',
        const Color(0xFFE53935),
        Icons.timer_off_rounded,
      ),
    ];

    return Row(
      children: items.asMap().entries.map((e) {
        final i = e.key;
        final s = e.value;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < items.length - 1 ? 10 : 0),
            padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 10),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: s.$3.withAOpacity(0.18), width: 1),
            ),
            child: Column(
              children: [
                Icon(s.$4, color: s.$3, size: 18),
                const SizedBox(height: 5),
                Text(
                  s.$1,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  s.$2,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 9,
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

  // ── Search ─────────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    final hasText = _searchCtrl.text.isNotEmpty;
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasText
              ? AppTheme.primary.withAOpacity(0.5)
              : Colors.white.withAOpacity(0.06),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (_) {
          setState(() {});
          _debounceQuery();
        },
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search by offer name or code…',
          hintStyle: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppTheme.textSecondary,
            size: 20,
          ),
          suffixIcon: hasText
              ? GestureDetector(
                  onTap: () {
                    _searchCtrl.clear();
                    setState(() {});
                    context.read<OffersBloc>().add(
                      GetOffersEvent(filters: filter.copyWith(search: '')),
                    );
                  },
                  child: const Icon(
                    Icons.close_rounded,
                    color: AppTheme.textSecondary,
                    size: 18,
                  ),
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildCountRow(int count) {
    return Text(
      '$count ${count == 1 ? 'offer' : 'offers'}',
      style: const TextStyle(
        color: AppTheme.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // ── List ───────────────────────────────────────────────────────────────────
  Widget _buildListSliver(
    OffersState state,
    List<MembershipPlanMiniEntity> plans,
  ) {
    if (state is OffersInitial || state is OffersLoading) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    if (state is OffersError) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _Message(
          icon: Icons.error_outline_rounded,
          title: 'Something went wrong',
          text: state.failure.message,
          action: 'Retry',
          onAction: () => context.read<OffersBloc>().add(
            GetOffersEvent(filters: state.filters),
          ),
        ),
      );
    }

    if (state.offers.isEmpty) {
      final filtered = state.filters.hasAny;
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _Message(
          icon: filtered
              ? Icons.search_off_rounded
              : Icons.local_offer_outlined,
          title: filtered ? 'No offers found' : 'No offers yet',
          text: filtered
              ? 'Try a different search or filter'
              : 'Tap "New Offer" to create one',
          action: filtered ? 'Clear filters' : null,
          onAction: () {
            _searchCtrl.clear();
            setState(() => filter = const OfferFilters());
            context.read<OffersBloc>().add(GetOffersEvent(filters: filter));
          },
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((_, i) {
          final o = state.offers[i];
          return _OfferCard(
            offer: o,
            onEdit: () => _openForm(offer: o, plans: plans),
            onDelete: () => _confirmDelete(o),
            onToggle: () => _toggle(o),
          );
        }, childCount: state.offers.length),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Filters
// ─────────────────────────────────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.plans, required this.filters});
  final List<PlanOption> plans;
  final OfferFilters filters;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<OffersBloc>();
    final f = filters;
    return SizedBox(
      height: 34,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _DropdownChip<String?>(
            icon: Icons.card_membership_rounded,
            label: 'Plan',
            value: f.planId?.orNull(),
            selectedText: plans
                .where((p) => p.id == f.planId)
                .map((p) => p.name)
                .firstOrNull,
            items: [
              const MapEntry(null, 'All plans'),
              ...plans.map((p) => MapEntry<String?, String>(p.id, p.name)),
            ],
            onChanged: (v) =>
                bloc.add(GetOffersEvent(filters: f.copyWith(planId: v ?? ''))),
          ),
          const SizedBox(width: 8),
          _DropdownChip<bool?>(
            icon: Icons.toggle_on_outlined,
            label: 'Status',
            value: f.active,
            selectedText: f.active == null
                ? null
                : (f.active! ? 'Active' : 'Inactive'),
            items: const [
              MapEntry(null, 'All'),
              MapEntry(true, 'Active'),
              MapEntry(false, 'Inactive'),
            ],
            onChanged: (v) => bloc.add(
              GetOffersEvent(filters: f.copyWith(active: v, forceActive: true)),
            ),
          ),
          const SizedBox(width: 8),
          _DropdownChip<String?>(
            icon: Icons.person_add_alt_rounded,
            label: 'Applies to',
            value: f.appliesTo?.orNull(),
            selectedText: _appliesToLabels[f.appliesTo],
            items: [
              const MapEntry(null, 'All'),
              ..._appliesToLabels.entries.map(
                (e) => MapEntry<String?, String>(e.key, e.value),
              ),
            ],
            onChanged: (v) => bloc.add(
              GetOffersEvent(filters: f.copyWith(appliesTo: v ?? '')),
            ),
          ),
          const SizedBox(width: 8),
          _ToggleChip(
            label: 'Valid now',
            selected: f.validNow,
            onTap: () => bloc.add(
              GetOffersEvent(filters: f.copyWith(validNow: !f.validNow)),
            ),
          ),
          if (f.count > 0) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () =>
                  bloc.add(const GetOffersEvent(filters: OfferFilters())),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withAOpacity(0.08)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.clear_rounded,
                      size: 14,
                      color: AppTheme.textSecondary,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Clear',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  const _ToggleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : AppTheme.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? AppTheme.primary
                : Colors.white.withAOpacity(0.08),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _DropdownChip<T> extends StatelessWidget {
  const _DropdownChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.selectedText,
  });

  final IconData icon;
  final String label;
  final T value;
  final String? selectedText;
  final List<MapEntry<T, String>> items;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final active = value != null;
    return PopupMenuButton<int>(
      color: AppTheme.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.white.withAOpacity(0.08)),
      ),
      onSelected: (i) => onChanged(items[i].key),
      itemBuilder: (_) => [
        for (var i = 0; i < items.length; i++)
          PopupMenuItem(
            value: i,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    items[i].value,
                    style: TextStyle(
                      color: items[i].key == value
                          ? AppTheme.primary
                          : Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
                if (items[i].key == value)
                  const Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: AppTheme.primary,
                  ),
              ],
            ),
          ),
      ],
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.only(left: 12, right: 6),
        decoration: BoxDecoration(
          color: active ? AppTheme.primary : AppTheme.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active ? AppTheme.primary : Colors.white.withAOpacity(0.08),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: active ? Colors.white : AppTheme.textSecondary,
            ),
            const SizedBox(width: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 120),
              child: Text(
                selectedText ?? label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: active ? Colors.white : AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_drop_down_rounded,
              size: 20,
              color: active ? Colors.white : AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card
// ─────────────────────────────────────────────────────────────────────────────

class _OfferCard extends StatelessWidget {
  const _OfferCard({
    required this.offer,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  final OfferEntity offer;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggle;

  (String, Color) get _status => switch (offer.lifecycle) {
    OfferLifecycle.active => ('Active', const Color(0xFF4CAF50)),
    OfferLifecycle.inactive => ('Inactive', AppTheme.textSecondary),
    OfferLifecycle.scheduled => ('Scheduled', const Color(0xFFFFA000)),
    OfferLifecycle.expired => ('Expired', const Color(0xFFE53935)),
  };

  @override
  Widget build(BuildContext context) {
    final o = offer;
    final (statusText, statusColor) = _status;
    final discount = o.isPercentage
        ? '${_fmtNum(o.discountValue.toNum.toDouble())}% OFF'
        : '₹${_fmtNum(o.discountValue.toNum.toDouble())} OFF';

    String validity;
    if (o.validFromDate == null && o.validUntilDate == null) {
      validity = 'No expiry';
    } else {
      validity =
          '${o.validFromDate != null ? _fmtDate(o.validFromDate!) : 'Any time'} → '
          '${o.validUntilDate != null ? _fmtDate(o.validUntilDate!) : 'No end'}';
    }

    final hasCode = o.code.orNull() != null;

    return GestureDetector(
      onTap: onEdit,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: o.lifecycle == OfferLifecycle.expired
                ? const Color(0xFFE53935).withAOpacity(0.2)
                : Colors.white.withAOpacity(0.05),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            // ── Main row ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withAOpacity(0.14),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          o.isPercentage
                              ? Icons.percent_rounded
                              : Icons.currency_rupee_rounded,
                          color: AppTheme.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    o.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _Pill(text: statusText, color: statusColor),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Text(
                                  discount,
                                  style: const TextStyle(
                                    color: AppTheme.primary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                if (o.isPercentage && o.maxDiscountAmount != 0)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Text(
                                      'up to ₹${_fmtNum(o.maxDiscountAmount.toDouble())}',
                                      style: const TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                const Spacer(),
                                if (hasCode)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.surface,
                                      borderRadius: BorderRadius.circular(7),
                                      border: Border.all(
                                        color: Colors.white.withAOpacity(0.08),
                                      ),
                                    ),
                                    child: Text(
                                      o.code,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (o.description.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      o.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  _InfoRow(Icons.event_rounded, validity),
                  _InfoRow(
                    Icons.person_add_alt_rounded,
                    _appliesToLabels[o.appliesTo] ?? o.appliesTo,
                  ),
                  if (o.maxRedemptions != 0 || o.perUserLimit != 0)
                    _InfoRow(
                      Icons.confirmation_number_outlined,
                      [
                        if (o.maxRedemptions != 0)
                          'Max ${o.maxRedemptions} uses',
                        if (o.perUserLimit != 0) '${o.perUserLimit} per member',
                      ].join(' • '),
                    ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (o.appliesToAllPlans)
                        const _Pill(text: 'All plans', color: AppTheme.primary)
                      else
                        ...o.plans.map(
                          (p) => _Pill(text: p.name, color: Colors.white54),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            // ── Action bar ────────────────────────────────────────────────
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
                  _OfferAction(
                    icon: Icons.edit_rounded,
                    label: 'Edit',
                    color: const Color(0xFF29B6F6),
                    onTap: onEdit,
                  ),
                  const _OfferVDivider(),
                  _OfferAction(
                    icon: o.isActive
                        ? Icons.pause_circle_outline_rounded
                        : Icons.play_circle_outline_rounded,
                    label: o.isActive ? 'Disable' : 'Enable',
                    color: o.isActive
                        ? const Color(0xFFFFA000)
                        : const Color(0xFF4CAF50),
                    onTap: onToggle,
                  ),
                  const _OfferVDivider(),
                  _OfferAction(
                    icon: Icons.delete_outline_rounded,
                    label: 'Delete',
                    color: AppTheme.error,
                    onTap: onDelete,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfferVDivider extends StatelessWidget {
  const _OfferVDivider();
  @override
  Widget build(BuildContext context) =>
      Container(width: 0.5, height: 36, color: Colors.white10);
}

class _OfferAction extends StatelessWidget {
  const _OfferAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.icon, this.text);
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 4),
    child: Row(
      children: [
        Icon(icon, size: 13, color: AppTheme.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.color});
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withAOpacity(0.12),
      borderRadius: BorderRadius.circular(7),
      border: Border.all(color: color.withAOpacity(0.35), width: 1),
    ),
    child: Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.3,
      ),
    ),
  );
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.title,
    required this.text,
    this.action,
    this.onAction,
  });
  final IconData icon;
  final String title;
  final String text;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: AppTheme.textSecondary.withAOpacity(0.4)),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
          if (action != null) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: onAction,
              child: Text(
                action!,
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Add / Edit form
// ─────────────────────────────────────────────────────────────────────────────

class OfferFormSheet extends StatefulWidget {
  const OfferFormSheet({
    super.key,
    this.offer,
    required this.plans,
    required this.onSubmit,
  });

  final OfferEntity? offer;
  final List<PlanOption> plans;

  /// Returns an error message, or null when saved successfully.
  final Future<String?> Function(OfferEntity body) onSubmit;

  @override
  State<OfferFormSheet> createState() => _OfferFormSheetState();
}

class _OfferFormSheetState extends State<OfferFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _code;
  late final TextEditingController _desc;
  late final TextEditingController _value;
  late final TextEditingController _maxDiscount;
  late final TextEditingController _maxRedemptions;
  late final TextEditingController _perUser;

  late String _discountType;
  late String _appliesTo;
  late bool _allPlans;
  late bool _isActive;
  late Set<String> _planIds;
  DateTime? _from;
  DateTime? _until;

  bool _saving = false;
  String? _error;
  String? _planError;

  bool get _isEdit => widget.offer != null;

  @override
  void initState() {
    super.initState();
    final o = widget.offer;
    _name = TextEditingController(text: o?.name ?? '');
    _code = TextEditingController(text: o?.code ?? '');
    _desc = TextEditingController(text: o?.description ?? '');
    _value = TextEditingController(
      text: o == null ? '' : _fmtNum(o.discountValue.toNum.toDouble()),
    );
    _maxDiscount = TextEditingController(
      text: o?.maxDiscountAmount == null
          ? ''
          : _fmtNum(o!.maxDiscountAmount.toDouble()),
    );
    _maxRedemptions = TextEditingController(
      text: o?.maxRedemptions.toString() ?? '',
    );
    _perUser = TextEditingController(text: o?.perUserLimit.toString() ?? '');
    _discountType = o?.discountType ?? 'PERCENTAGE';
    _appliesTo = o?.appliesTo ?? 'BOTH';
    _allPlans = o?.appliesToAllPlans ?? true;
    _isActive = o?.isActive ?? true;
    _planIds = {...?o?.plans.map((p) => p.id)};
    _from = o?.validFromDate;
    _until = o?.validUntilDate;
  }

  @override
  void dispose() {
    for (final c in [
      _name,
      _code,
      _desc,
      _value,
      _maxDiscount,
      _maxRedemptions,
      _perUser,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _pickDate(bool isFrom) async {
    final now = DateTime.now();
    final initial = (isFrom ? _from : _until) ?? now;
    final d = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
    );
    if (d != null) setState(() => isFrom ? _from = d : _until = d);
  }

  String? _optionalInt(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    final n = int.tryParse(v.trim());
    return (n == null || n < 1) ? 'Enter a whole number ≥ 1' : null;
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    final formOk = _formKey.currentState!.validate();

    String? planErr;
    if (!_allPlans && _planIds.isEmpty) {
      planErr = 'Select at least one plan, or choose "All plans"';
    }
    String? dateErr;
    if (_from != null && _until != null && _from!.isAfter(_until!)) {
      dateErr = 'Valid from must be before valid until';
    }
    setState(() {
      _planError = planErr;
      if (dateErr != null) _error = dateErr;
    });
    if (!formOk || planErr != null || dateErr != null) return;

    final isPct = _discountType == 'PERCENTAGE';
    final body = OfferEntity(
      id: widget.offer?.id ?? '',
      name: _name.text.trim(),
      code: _code.text.trim().toUpperCase(),
      description: _desc.text.trim(),
      discountType: _discountType,
      discountValue: _value.text.trim(),
      maxDiscountAmount: isPct && _maxDiscount.text.trim().isNotEmpty
          ? _maxDiscount.text.trim().toNum
          : 0,
      appliesTo: _appliesTo,
      appliesToAllPlans: _allPlans,
      plans: _planIds.map((e) => IdNameEntity(id: e)).toList(),
      validFrom: _from?.toIso8601String() ?? '',
      validUntil: _until?.toIso8601String() ?? '',
      maxRedemptions: _maxRedemptions.text.trim().toNum,
      perUserLimit: _perUser.text.trim().toNum,
      isActive: _isActive,
    );

    setState(() => _saving = true);
    final err = await widget.onSubmit(body);
    if (!mounted) return;
    if (err == null) {
      Navigator.pop(context, true);
    } else {
      setState(() {
        _saving = false;
        _error = err;
      });
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isPct = _discountType == 'PERCENTAGE';

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            controller: scrollCtrl,
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

              // Header
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withAOpacity(0.15),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(
                      _isEdit ? Icons.edit_rounded : Icons.local_offer_rounded,
                      color: AppTheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _isEdit ? 'Edit Offer' : 'New Offer',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Basics
              _field(
                controller: _name,
                label: 'Offer Name',
                icon: Icons.local_offer_outlined,
                hint: 'e.g. New Year Special',
                isRequired: true,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 14),
              _field(
                controller: _code,
                label: 'Coupon Code (optional)',
                icon: Icons.confirmation_number_outlined,
                hint: 'Leave empty for an automatic offer',
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 14),
              _field(
                controller: _desc,
                label: 'Description',
                icon: Icons.notes_rounded,
                hint: 'Short description shown to staff',
                textCapitalization: TextCapitalization.sentences,
                maxLines: 2,
              ),

              // Discount
              const SizedBox(height: 24),
              _label('Discount Type'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _selectChip(
                    label: 'Percentage %',
                    selected: _discountType == 'PERCENTAGE',
                    onTap: () => setState(() => _discountType = 'PERCENTAGE'),
                  ),
                  _selectChip(
                    label: 'Flat ₹',
                    selected: _discountType == 'FLAT',
                    onTap: () => setState(() => _discountType = 'FLAT'),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _field(
                      controller: _value,
                      label: isPct ? 'Percentage' : 'Amount (₹)',
                      icon: isPct
                          ? Icons.percent_rounded
                          : Icons.currency_rupee_rounded,
                      hint: isPct ? '10' : '500',
                      isRequired: true,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (v) {
                        final n = double.tryParse((v ?? '').trim());
                        if (n == null || n <= 0) {
                          return 'Must be greater than 0';
                        }
                        if (isPct && n > 100) return 'Cannot exceed 100';
                        return null;
                      },
                    ),
                  ),
                  if (isPct) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: _field(
                        controller: _maxDiscount,
                        label: 'Max Discount (₹)',
                        icon: Icons.vertical_align_top_rounded,
                        hint: 'Optional',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return null;
                          final n = double.tryParse(v.trim());
                          return (n == null || n <= 0) ? 'Must be > 0' : null;
                        },
                      ),
                    ),
                  ],
                ],
              ),

              // Applies to
              const SizedBox(height: 24),
              _label('Applies To'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _appliesToLabels.entries
                    .map(
                      (e) => _selectChip(
                        label: e.value,
                        selected: _appliesTo == e.key,
                        onTap: () => setState(() => _appliesTo = e.key),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 14),
              _switchRow(
                title: 'All membership plans',
                subtitle: 'Turn off to pick specific plans',
                value: _allPlans,
                onChanged: (v) => setState(() {
                  _allPlans = v;
                  _planError = null;
                }),
              ),
              if (!_allPlans) ...[
                const SizedBox(height: 12),
                if (widget.plans.isEmpty)
                  const Text(
                    'No membership plans available.',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.plans.map((p) {
                      return _selectChip(
                        label: "${p.name} (₹${p.price})",
                        selected: _planIds.contains(p.id),
                        onTap: () => setState(() {
                          _planIds.contains(p.id)
                              ? _planIds.remove(p.id)
                              : _planIds.add(p.id);
                          _planError = null;
                        }),
                      );
                    }).toList(),
                  ),
                if (_planError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _planError!,
                      style: const TextStyle(
                        color: AppTheme.error,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],

              // Validity
              const SizedBox(height: 24),
              _label('Validity'),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _dateField(
                      label: 'Valid From',
                      value: _from,
                      onTap: () => _pickDate(true),
                      onClear: () => setState(() => _from = null),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _dateField(
                      label: 'Valid Until',
                      value: _until,
                      onTap: () => _pickDate(false),
                      onClear: () => setState(() => _until = null),
                    ),
                  ),
                ],
              ),

              // Limits
              const SizedBox(height: 24),
              _label('Limits'),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _field(
                      controller: _maxRedemptions,
                      label: 'Total Redemptions',
                      icon: Icons.groups_rounded,
                      hint: 'Unlimited',
                      keyboardType: TextInputType.number,
                      validator: _optionalInt,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _field(
                      controller: _perUser,
                      label: 'Per Member',
                      icon: Icons.person_outline_rounded,
                      hint: 'Unlimited',
                      keyboardType: TextInputType.number,
                      validator: _optionalInt,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _switchRow(
                title: 'Active',
                subtitle: 'Inactive offers cannot be redeemed',
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
              ),

              // Error
              if (_error != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withAOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.error.withAOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: AppTheme.error,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
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
                ),
              ],

              // Submit
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _saving ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _isEdit ? 'Save Changes' : 'Create Offer',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Building blocks ───────────────────────────────────────────────────────

  Widget _label(String t) => Text(
    t,
    style: const TextStyle(
      color: AppTheme.textSecondary,
      fontSize: 12,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.3,
    ),
  );

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String hint = '',
    bool isRequired = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(isRequired ? '$label *' : label),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withAOpacity(0.06),
              width: 1,
            ),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            textCapitalization: textCapitalization,
            validator:
                validator ??
                (isRequired
                    ? (v) => (v == null || v.trim().isEmpty)
                          ? '$label is required'
                          : null
                    : null),
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
              prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 18),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              filled: false,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _selectChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : AppTheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? AppTheme.primary
                : Colors.white.withAOpacity(0.08),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppTheme.textSecondary,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _switchRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAOpacity(0.06)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: AppTheme.primary,
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.white12,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _dateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
    required VoidCallback onClear,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withAOpacity(0.06),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 15,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    value == null ? 'Not set' : _fmtDate(value),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: value == null
                          ? AppTheme.textSecondary
                          : Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (value != null)
                  GestureDetector(
                    onTap: onClear,
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
      ],
    );
  }
}
