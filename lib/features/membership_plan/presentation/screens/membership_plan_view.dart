import 'package:club_fitness/config/theme/theme.dart';
import 'package:club_fitness/core/services/search_services.dart';
import 'package:club_fitness/core/utils/utils.dart';
import 'package:club_fitness/features/member_manager/member_manager.dart';
import 'package:club_fitness/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MembershipPlanView extends StatelessWidget {
  const MembershipPlanView({super.key});

  @override
  Widget build(BuildContext context) {
    return const MembershipPlansScreen();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter / sort models (UI only)
// ─────────────────────────────────────────────────────────────────────────────

enum _StatusFilter { all, active, inactive }

enum _DurationFilter { all, upTo1, m2to3, m4to6, over6 }

enum _PlanSort { name, priceLow, priceHigh, duration }

const _statusLabels = {
  _StatusFilter.all: 'All',
  _StatusFilter.active: 'Active',
  _StatusFilter.inactive: 'Inactive',
};

const _durationLabels = {
  _DurationFilter.all: 'All durations',
  _DurationFilter.upTo1: 'Up to 1 month',
  _DurationFilter.m2to3: '2 - 3 months',
  _DurationFilter.m4to6: '4 - 6 months',
  _DurationFilter.over6: 'Over 6 months',
};

const _sortLabels = {
  _PlanSort.name: 'Name',
  _PlanSort.priceLow: 'Price: Low to High',
  _PlanSort.priceHigh: 'Price: High to Low',
  _PlanSort.duration: 'Duration',
};

bool _matchesDuration(int days, _DurationFilter f) => switch (f) {
  _DurationFilter.all => true,
  _DurationFilter.upTo1 => days <= 31,
  _DurationFilter.m2to3 => days > 31 && days <= 92,
  _DurationFilter.m4to6 => days > 92 && days <= 186,
  _DurationFilter.over6 => days > 186,
};

String _fmtPrice(num v) =>
    v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(2);

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class MembershipPlansScreen extends StatefulWidget {
  const MembershipPlansScreen({super.key});

  @override
  State<MembershipPlansScreen> createState() => _MembershipPlansScreenState();
}

class _MembershipPlansScreenState extends State<MembershipPlansScreen>
    with SingleTickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  String _query = '';
  _StatusFilter _status = _StatusFilter.all;
  _DurationFilter _duration = _DurationFilter.all;
  _PlanSort _sort = _PlanSort.name;

  bool get _hasFilters =>
      _status != _StatusFilter.all || _duration != _DurationFilter.all;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
    // Load every plan once (including inactive); filtering happens in the UI.
    _load();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _load() {
    context.read<MembersConfigBloc>().add(
      const GetMembershipPlansEvent(false, true),
    );
  }

  // ── Filtering ─────────────────────────────────────────────────────────────

  List<MembershipPlanMiniEntity> _apply(List<MembershipPlanMiniEntity> all) {
    final q = _query.trim().toLowerCase();
    final list = all.where((p) {
      if (_status == _StatusFilter.active && !p.isActive) return false;
      if (_status == _StatusFilter.inactive && p.isActive) return false;
      if (!_matchesDuration(p.durationDays.toInt(), _duration)) return false;
      return true;
    }).toList();
    final results = SearchService.fuzzySearch(
      list,
      q,
      (p) => "${p.name} ${p.price} ${p.durationDays}, ${p.features.join(', ')}",
    );

    results.sort((a, b) {
      switch (_sort) {
        case _PlanSort.name:
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        case _PlanSort.priceLow:
          return a.price.compareTo(b.price);
        case _PlanSort.priceHigh:
          return b.price.compareTo(a.price);
        case _PlanSort.duration:
          return a.durationDays.compareTo(b.durationDays);
      }
    });
    return results;
  }

  void _clearAll() {
    _searchCtrl.clear();
    setState(() {
      _query = '';
      _status = _StatusFilter.all;
      _duration = _DurationFilter.all;
    });
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _showPlanForm({MembershipPlanMiniEntity? plan}) async {
    final bloc = context.read<MembersConfigBloc>();
    final result = await showModalBottomSheet<MembershipPlanMiniEntity>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PlanFormSheet(plan: plan),
    );
    if (result == null) return;
    bloc.add(
      plan != null
          ? UpdateMembershipPlanEvent(result)
          : CreateMembershipPlanEvent(result),
    );
  }

  void _toggle(MembershipPlanMiniEntity p) {
    context.read<MembersConfigBloc>().add(
      UpdateMembershipPlanEvent(
        MembershipPlanMiniEntity(
          id: p.id,
          name: p.name,
          durationDays: p.durationDays,
          price: p.price,
          description: p.description,
          features: p.features,
          isActive: !p.isActive,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(MembershipPlanMiniEntity plan) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
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
          'Delete Plan',
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
              const TextSpan(text: 'Are you sure you want to delete '),
              TextSpan(
                text: plan.name,
                style: const TextStyle(
                  color: AppTheme.error,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              const TextSpan(text: '?'),
            ],
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
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
            onPressed: () => Navigator.pop(ctx, true),
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
    context.read<MembersConfigBloc>().add(DeleteMembershipPlanEvent(plan.id));
  }

  Future<void> _showSortSheet() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
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
              ..._sortLabels.entries.map((e) {
                final selected = _sort == e.key;
                return GestureDetector(
                  onTap: () {
                    setState(() => _sort = e.key);
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppTheme.primary.withAOpacity(0.12)
                          : AppTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected
                            ? AppTheme.primary.withAOpacity(0.4)
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          e.value,
                          style: TextStyle(
                            color: selected ? AppTheme.primary : Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        if (selected)
                          const Icon(
                            Icons.check_rounded,
                            color: AppTheme.primary,
                            size: 18,
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPlanForm(),
        backgroundColor: AppTheme.primary,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
        label: const Text(
          'New Plan',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ),
      body: BlocBuilder<MembersConfigBloc, MembersConfigState>(
        builder: (context, state) {
          final all = state.membershipPlans;
          final plans = _apply(all);

          return FadeTransition(
            opacity: _fadeAnim,
            child: LiquidRefresh(
              onRefresh: _load,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  _buildAppBar(),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSummaryRow(all),
                          const SizedBox(height: 20),
                          _buildSearchBar(),
                          const SizedBox(height: 14),
                          _buildFilterRow(),
                          const SizedBox(height: 14),
                          _buildSortRow(plans.length),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                  _buildListSliver(state, all, plans),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── App bar ───────────────────────────────────────────────────────────────

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
        'Membership Plans',
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
              Icons.card_membership_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          onPressed: () => _showPlanForm(),
        ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(height: 0.5, color: Colors.white12),
      ),
    );
  }

  // ── Summary ───────────────────────────────────────────────────────────────

  Widget _buildSummaryRow(List<MembershipPlanMiniEntity> all) {
    final active = all.where((p) => p.isActive).length;
    final inactive = all.length - active;
    final lowest = all.isEmpty
        ? '—'
        : '₹${_fmtPrice(all.map((p) => p.price).reduce((a, b) => a < b ? a : b))}';

    final items = [
      ('${all.length}', 'Total', AppTheme.primary, Icons.layers_rounded),
      (
        '$active',
        'Active',
        const Color(0xFF4CAF50),
        Icons.check_circle_rounded,
      ),
      (
        '$inactive',
        'Inactive',
        const Color(0xFFE53935),
        Icons.pause_circle_rounded,
      ),
      (lowest, 'Starts at', const Color(0xFFFFA000), Icons.sell_rounded),
    ];

    return Row(
      children: items.asMap().entries.map((e) {
        final i = e.key;
        final s = e.value;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < items.length - 1 ? 10 : 0),
            padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 6),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: s.$3.withAOpacity(0.18), width: 1),
            ),
            child: Column(
              children: [
                Icon(s.$4, color: s.$3, size: 18),
                const SizedBox(height: 5),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    s.$1,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
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

  // ── Search ────────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _query.isNotEmpty
              ? AppTheme.primary.withAOpacity(0.5)
              : Colors.white.withAOpacity(0.06),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) => setState(() => _query = v),
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search by name, price, feature…',
          hintStyle: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppTheme.textSecondary,
            size: 20,
          ),
          suffixIcon: _query.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchCtrl.clear();
                    setState(() => _query = '');
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

  // ── Filters ───────────────────────────────────────────────────────────────

  Widget _buildFilterRow() {
    return SizedBox(
      height: 34,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          // Status chips (same look as the members screen)
          for (final e in _statusLabels.entries) ...[
            _FilterChipButton(
              label: e.value,
              selected: _status == e.key,
              onTap: () => setState(() => _status = e.key),
            ),
            const SizedBox(width: 8),
          ],
          _DurationDropdown(
            value: _duration,
            onChanged: (v) => setState(() => _duration = v),
          ),
          if (_hasFilters || _query.isNotEmpty) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _clearAll,
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

  Widget _buildSortRow(int count) {
    return Row(
      children: [
        Text(
          '$count ${count == 1 ? 'plan' : 'plans'}',
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
                  _sortLabels[_sort]!,
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
    );
  }

  // ── List ──────────────────────────────────────────────────────────────────

  Widget _buildListSliver(
    MembersConfigState state,
    List<MembershipPlanMiniEntity> all,
    List<MembershipPlanMiniEntity> plans,
  ) {
    if (all.isEmpty) {
      if (state is MembersConfigLoading) {
        return const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator.adaptive()),
        );
      }
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: _EmptyState(
          icon: Icons.card_membership_outlined,
          title: 'No membership plans yet',
          text: 'Tap "New Plan" to create one',
        ),
      );
    }

    if (plans.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _EmptyState(
          icon: Icons.search_off_rounded,
          title: 'No plans found',
          text: 'Try a different search or filter',
          action: 'Clear filters',
          onAction: _clearAll,
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((_, i) {
          final p = plans[i];
          return _PlanCard(
            plan: p,
            onEdit: () => _showPlanForm(plan: p),
            onToggle: () => _toggle(p),
            onDelete: () => _confirmDelete(p),
          );
        }, childCount: plans.length),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter widgets
// ─────────────────────────────────────────────────────────────────────────────

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
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

class _DurationDropdown extends StatelessWidget {
  const _DurationDropdown({required this.value, required this.onChanged});
  final _DurationFilter value;
  final ValueChanged<_DurationFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final active = value != _DurationFilter.all;
    final fg = active ? Colors.white : AppTheme.textSecondary;
    return PopupMenuButton<_DurationFilter>(
      color: AppTheme.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.white.withAOpacity(0.08)),
      ),
      onSelected: onChanged,
      itemBuilder: (_) => _durationLabels.entries
          .map(
            (e) => PopupMenuItem(
              value: e.key,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      e.value,
                      style: TextStyle(
                        color: e.key == value ? AppTheme.primary : Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  if (e.key == value)
                    const Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: AppTheme.primary,
                    ),
                ],
              ),
            ),
          )
          .toList(),
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
            Icon(Icons.schedule_rounded, size: 14, color: fg),
            const SizedBox(width: 6),
            Text(
              active ? _durationLabels[value]! : 'Duration',
              style: TextStyle(
                color: fg,
                fontSize: 12,
                fontWeight: active ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
            Icon(Icons.arrow_drop_down_rounded, size: 20, color: fg),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card
// ─────────────────────────────────────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  final MembershipPlanMiniEntity plan;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  String get _durationText {
    final d = plan.durationDays.toInt();
    if (d >= 365 && d % 365 == 0) {
      final y = d ~/ 365;
      return '$y ${y == 1 ? 'year' : 'years'} ($d days)';
    }
    if (d >= 30 && d % 30 == 0) {
      final m = d ~/ 30;
      return '$m ${m == 1 ? 'month' : 'months'} ($d days)';
    }
    return '$d days';
  }

  @override
  Widget build(BuildContext context) {
    final p = plan;
    final statusColor = p.isActive
        ? const Color(0xFF4CAF50)
        : const Color(0xFFE53935);

    return GestureDetector(
      onTap: onEdit,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: p.isActive
                ? Colors.white.withAOpacity(0.05)
                : const Color(0xFFE53935).withAOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
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
                        child: const Icon(
                          Icons.card_membership_rounded,
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
                                    p.name,
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
                                _Pill(
                                  text: p.isActive ? 'Active' : 'Inactive',
                                  color: statusColor,
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '₹${_fmtPrice(p.price)}',
                              style: const TextStyle(
                                color: AppTheme.primary,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        size: 13,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _durationText,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (p.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      p.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                  if (p.features.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: p.features
                          .map((f) => _Pill(text: f, color: Colors.white54))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
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
                  _CardAction(
                    icon: Icons.edit_rounded,
                    label: 'Edit',
                    color: const Color(0xFF29B6F6),
                    onTap: onEdit,
                  ),
                  const _VDivider(),
                  _CardAction(
                    icon: p.isActive
                        ? Icons.pause_circle_outline_rounded
                        : Icons.play_circle_outline_rounded,
                    label: p.isActive ? 'Disable' : 'Enable',
                    color: p.isActive
                        ? const Color(0xFFFFA000)
                        : const Color(0xFF4CAF50),
                    onTap: onToggle,
                  ),
                  const _VDivider(),
                  _CardAction(
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

class _VDivider extends StatelessWidget {
  const _VDivider();
  @override
  Widget build(BuildContext context) =>
      Container(width: 0.5, height: 36, color: Colors.white10);
}

class _CardAction extends StatelessWidget {
  const _CardAction({
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({
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
// Add / Edit sheet
// ─────────────────────────────────────────────────────────────────────────────

class _PlanFormSheet extends StatefulWidget {
  const _PlanFormSheet({this.plan});
  final MembershipPlanMiniEntity? plan;

  @override
  State<_PlanFormSheet> createState() => _PlanFormSheetState();
}

class _PlanFormSheetState extends State<_PlanFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _duration;
  late final TextEditingController _price;
  late final TextEditingController _desc;
  late final TextEditingController _features;
  late bool _isActive;

  bool get _isEdit => widget.plan != null;

  static const _quickDurations = [
    (label: '1 Month', days: 30),
    (label: '3 Months', days: 90),
    (label: '6 Months', days: 180),
    (label: '1 Year', days: 365),
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.plan;
    _name = TextEditingController(text: p?.name ?? '');
    _duration = TextEditingController(
      text: p == null ? '' : p.durationDays.toInt().toString(),
    );
    _price = TextEditingController(text: p == null ? '' : _fmtPrice(p.price));
    _desc = TextEditingController(text: p?.description ?? '');
    _features = TextEditingController(text: p?.features.join(', ') ?? '');
    _isActive = p?.isActive ?? true;
  }

  @override
  void dispose() {
    for (final c in [_name, _duration, _price, _desc, _features]) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final features = _features.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    Navigator.pop(
      context,
      MembershipPlanMiniEntity(
        id: widget.plan?.id ?? '',
        name: _name.text.trim(),
        durationDays: _duration.text.trim().toNum,
        price: _price.text.trim().toNum,
        description: _desc.text.trim(),
        features: features,
        isActive: _isActive,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Form(
        key: _formKey,
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
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withAOpacity(0.15),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(
                      _isEdit
                          ? Icons.edit_rounded
                          : Icons.card_membership_rounded,
                      color: AppTheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _isEdit ? 'Edit Plan' : 'New Plan',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _field(
                controller: _name,
                label: 'Plan Name',
                icon: Icons.card_membership_outlined,
                hint: 'e.g. Quarterly Gold',
                isRequired: true,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _field(
                      controller: _duration,
                      label: 'Duration (days)',
                      icon: Icons.schedule_rounded,
                      hint: '30',
                      isRequired: true,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        final n = int.tryParse(v.trim());
                        if (n == null || n < 1) return 'Enter a valid number';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _field(
                      controller: _price,
                      label: 'Price (₹)',
                      icon: Icons.currency_rupee_rounded,
                      hint: '1500',
                      isRequired: true,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        final n = double.tryParse(v.trim());
                        if (n == null || n < 0) return 'Enter a valid price';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _quickDurations.map((q) {
                  final selected = _duration.text.trim() == q.days.toString();
                  return _selectChip(
                    label: q.label,
                    selected: selected,
                    onTap: () =>
                        setState(() => _duration.text = q.days.toString()),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              _field(
                controller: _desc,
                label: 'Description',
                icon: Icons.notes_rounded,
                hint: 'Optional',
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 14),
              _field(
                controller: _features,
                label: 'Features',
                icon: Icons.checklist_rounded,
                hint: 'Comma separated, e.g. Gym, Cardio, Steam',
                textCapitalization: TextCapitalization.words
              ),
              const SizedBox(height: 14),
              _switchRow(),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  _isEdit ? 'Update Plan' : 'Create Plan',
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
            onChanged: (_) => setState(() {}),
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

  Widget _switchRow() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAOpacity(0.06)),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Inactive plans cannot be assigned to members',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
          Switch(
            value: _isActive,
            activeThumbColor: AppTheme.primary,
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.white12,
            onChanged: (v) => setState(() => _isActive = v),
          ),
        ],
      ),
    );
  }
}
