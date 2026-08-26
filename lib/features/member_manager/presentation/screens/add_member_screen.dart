import 'dart:async';

import 'package:club_fitness/config/navigation/routes_class.dart';
import 'package:club_fitness/config/theme/theme.dart';
import 'package:club_fitness/core/constants/size_constant.dart';
import 'package:club_fitness/core/entities/member_status.dart';
import 'package:club_fitness/core/utils/utils.dart';
import 'package:club_fitness/di.dart';
import 'package:club_fitness/features/member_manager/member_manager.dart';
import 'package:club_fitness/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdminMembersScreen extends StatelessWidget {
  const AdminMembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          MembersListingBloc(sl())..add(const GetMembersListingEvent()),
      child: const AdminMembersView(),
    );
  }
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class AdminMembersView extends StatefulWidget {
  const AdminMembersView({super.key});
  @override
  State<AdminMembersView> createState() => _AdminMembersViewState();
}

class _AdminMembersViewState extends State<AdminMembersView>
    with SingleTickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  final _scrollController = ScrollController();
  String _searchQuery = '';
  String _selectedFilter = 'All';
  String _selectedSort = 'Name';
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  final _filters = ['All', 'Active', 'Expired', 'Suspended', 'Trial'];
  final _sorts = ['Name', 'Expiry', 'Fee Status', 'Streak'];
  final List<MemberListEntity> _members = [];
  List<MemberListEntity> get _activeMembers =>
      _members.where((element) => element.planId.isNotEmpty).toList();

  Map<String, dynamic> _advancedFilters = {};

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
    _scrollController.addListener(_scrollListener);
  }

  void _refreshMembers() {
    setState(() {
      _members.clear();
    });
    context.read<MembersListingBloc>().add(
      GetMembersListingEvent(
        search: _searchQuery,
        sortBy: _selectedSort.toPascalCase(),
      ),
    );
  }

  Timer? _debounceTimer;

  void _debounceQuery() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), _refreshMembers);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _searchCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        0.8 * _scrollController.position.maxScrollExtent) {
      context.read<MembersListingBloc>().add(const GetMoreMembersListingEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: BlocBuilder<MembersListingBloc, MembersListingState>(
        builder: (context, state) {
          switch (state) {
            case MembersListingInitial():
              return const Center(child: CircularProgressIndicator.adaptive());
            case MembersListingLoading():
              return const Center(child: CircularProgressIndicator.adaptive());
            case MembersListingSuccess():
              final members = [..._members, ...state.members];
              return FadeTransition(
                opacity: _fadeAnim,
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    _buildAppBar(),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSummaryRow(state.summary),
                            const SizedBox(height: 20),
                            _buildSearchBar(),
                            const SizedBox(height: 14),
                            _buildFilterRow(),
                            const SizedBox(height: 14),
                            _buildSortRow(
                              state.summary.total.toInt() + _members.length,
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    members.isEmpty
                        ? SliverFillRemaining(child: _buildEmptyState())
                        : SliverPadding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (_, i) => _MemberCard(
                                  member: members[i],
                                  onTap: () => _openMemberDetail(members[i]),
                                  onDelete: () => _confirmDelete(members[i]),
                                  onSendReminder: () =>
                                      _sendReminder(members[i]),
                                ),
                                childCount: members.length,
                              ),
                            ),
                          ),
                  ],
                ),
              );
            case MembersListingFailure():
              return FailureTextWidget(
                state.failure,
                onRetry: () => context.read<MembersListingBloc>().add(
                  const GetMembersListingEvent(),
                ),
              );
          }
        },
      ),
      floatingActionButton: _buildFAB(),
    );
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
        'Members',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.tune_rounded,
            color: AppTheme.textSecondary,
            size: 22,
          ),
          onPressed: () async {
            final result = await _showAdvancedFilter(_advancedFilters);
            if (result == null) return;
            if (result is! Map<String, dynamic>) return;
            if (!mounted) return;
            setState(() {
              _advancedFilters = result;
            });
            String? plan = result['plan'];
            String? trainer = result['trainer'];
            bool? checkedInToday = result['checkedInToday'];
            bool? overdueOnly = result['overdueOnly'];
            context.read<MembersListingBloc>().add(
              GetMembersListingEvent(
                search: _searchQuery,
                sortBy: _selectedSort.toPascalCase(),
                checkedInToday: checkedInToday ?? false,
                overdueOnly: overdueOnly ?? false,
                plan: plan == 'all' ? null : plan,
                trainer: trainer == 'all' ? null : trainer,
              ),
            );
          },
        ),
        IconButton(
          icon: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.person_add_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          onPressed: () => _openAddMember(),
        ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(height: 0.5, color: Colors.white12),
      ),
    );
  }

  // ── Summary Row ─────────────────────────────────────────────────────────────
  Widget _buildSummaryRow(Summary summary) {
    final items = [
      (
        '${summary.total + _members.length}',
        'Total',
        AppTheme.primary,
        Icons.people_alt_rounded,
      ),
      (
        '${summary.active + _activeMembers.length}',
        'Active',
        const Color(0xFF4CAF50),
        Icons.check_circle_rounded,
      ),
      (
        '${summary.expired}',
        'Expired',
        const Color(0xFFFFA000),
        Icons.timer_off_rounded,
      ),
      (
        '${summary.overdue}',
        'Overdue',
        const Color(0xFFE53935),
        Icons.warning_amber_rounded,
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
              border: Border.all(color: (s.$3).withAOpacity(0.18), width: 1),
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

  // ── Search Bar ──────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      height: 48,
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
        onChanged: (value) {
          setState(() => _searchQuery = value.toLowerCase());
          _debounceQuery();
        },
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search by name, phone or ID…',
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

  // ── Filter Chips ────────────────────────────────────────────────────────────
  Widget _buildFilterRow() {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final f = _filters[i];
          final selected = _selectedFilter == f;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedFilter = f);
              _refreshMembers();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: selected ? AppTheme.primary : AppTheme.card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: selected
                      ? AppTheme.primary
                      : Colors.white.withAOpacity(0.08),
                  width: 1,
                ),
              ),
              child: Text(
                f,
                style: TextStyle(
                  color: selected ? Colors.white : AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Sort Row ────────────────────────────────────────────────────────────────
  Widget _buildSortRow(int count) {
    return Row(
      children: [
        Text(
          '$count members',
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
          onTap: () async {
            final sortValue = _selectedSort;
            await _showSortSheet();
            if (!mounted) return;
            if (sortValue == _selectedSort) return;
            _refreshMembers();
          },
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
                  _selectedSort,
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

  // ── Empty State ─────────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            color: AppTheme.textSecondary.withAOpacity(0.4),
            size: 56,
          ),
          const SizedBox(height: 16),
          const Text(
            'No members found',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try a different search or filter',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ── FAB ─────────────────────────────────────────────────────────────────────
  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: _openAddMember,
      backgroundColor: AppTheme.primary,
      elevation: 4,
      icon: const Icon(Icons.person_add_rounded, color: Colors.white, size: 20),
      label: const Text(
        'Add Member',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 13,
        ),
      ),
    );
  }

  // ── Actions ─────────────────────────────────────────────────────────────────
  void _openAddMember() async {
    final member = await showModalBottomSheet<MemberListEntity?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddMemberSheet(),
    );
    if (member == null) return;
    if (!mounted) return;
    setState(() {
      if (_members.isEmpty) {
        _members.add(member);
      } else {
        _members.insert(0, member);
      }
    });
  }

  void _openMemberDetail(MemberListEntity m) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => MemberDetailScreen(member: m)));
  }

  void _sendReminder(MemberListEntity m) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Reminder sent to ${m.name}')));
  }

  void _confirmDelete(MemberListEntity m) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Remove Member',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        content: RichText(
          text: TextSpan(
            children: [
              const TextSpan(
                text: 'Are you sure you want to remove ',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
              TextSpan(
                text: m.name,
                style: const TextStyle(
                  color: AppTheme.error,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const TextSpan(
                text: ' from the members list? This cannot be undone.',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ],
          ),
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
              backgroundColor: AppTheme.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _showSortSheet() async {
    await showModalBottomSheet(
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
            ..._sorts.map(
              (s) => GestureDetector(
                onTap: () {
                  setState(() => _selectedSort = s);
                  Navigator.pop(context);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: _selectedSort == s
                        ? AppTheme.primary.withAOpacity(0.12)
                        : AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedSort == s
                          ? AppTheme.primary.withAOpacity(0.4)
                          : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        s,
                        style: TextStyle(
                          color: _selectedSort == s
                              ? AppTheme.primary
                              : Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      if (_selectedSort == s)
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
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<dynamic> _showAdvancedFilter([
    Map<String, dynamic>? activeFilters,
  ]) async {
    return await showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _AdvancedFilterSheet(activeFilters: activeFilters),
    );
  }
}

// ─── Member List Card ─────────────────────────────────────────────────────────

class _MemberCard extends StatelessWidget {
  final MemberListEntity member;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onSendReminder;

  const _MemberCard({
    required this.member,
    required this.onTap,
    required this.onDelete,
    required this.onSendReminder,
  });

  Color get _statusColor {
    return switch (member.memberStatus) {
      MemberStatus.active => const Color(0xFF4CAF50),
      MemberStatus.expired => const Color(0xFFFFA000),
      MemberStatus.suspended => const Color(0xFFE53935),
      MemberStatus.trial => const Color(0xFF29B6F6),
    };
  }

  String get _statusLabel {
    return member.memberStatus.label;
  }

  Color get _feeColor {
    return switch (member.feeStatus) {
      'paid' => const Color(0xFF4CAF50),
      'pending' => const Color(0xFFFFA000),
      _ => const Color(0xFFE53935),
    };
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: member.feeStatus == 'overdue'
                ? const Color(0xFFE53935).withAOpacity(0.2)
                : Colors.white.withAOpacity(0.05),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            // ── Main row ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Avatar
                  Stack(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: member.avatarColor.withAOpacity(0.2),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: member.avatarColor.withAOpacity(0.4),
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            member.initials,
                            style: TextStyle(
                              color: member.avatarColor,
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      if (member.checkedInToday)
                        Positioned(
                          right: -1,
                          top: -1,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.card,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                member.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            _StatusBadge(
                              label: _statusLabel,
                              color: _statusColor,
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Text(
                              member.plan,
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 3,
                              height: 3,
                              decoration: const BoxDecoration(
                                color: AppTheme.textSecondary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              member.id,
                              style: TextStyle(
                                color: Colors.white.withAOpacity(0.35),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            // Expiry
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 10,
                              color: member.daysLeft < 7
                                  ? const Color(0xFFFFA000)
                                  : AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              member.daysLeft > 0
                                  ? '${member.daysLeft}d left'
                                  : 'Expired ${(-member.daysLeft)}d ago',
                              style: TextStyle(
                                color: member.daysLeft < 7
                                    ? const Color(0xFFFFA000)
                                    : AppTheme.textSecondary,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Fee status
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _feeColor.withAOpacity(0.1),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                member.feeStatus.toUpperCase(),
                                style: TextStyle(
                                  color: _feeColor,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            // Streak
                            if (member.workoutStreak > 0) ...[
                              const Icon(
                                Icons.local_fire_department_rounded,
                                size: 11,
                                color: Color(0xFFFF5722),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${member.workoutStreak}d',
                                style: const TextStyle(
                                  color: Color(0xFFFF5722),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppTheme.textSecondary,
                    size: 20,
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
                  _ActionButton(
                    icon: Icons.fitness_center_rounded,
                    label: 'Workout',
                    color: const Color(0xFF7B1FA2),
                    onTap: () {},
                  ),
                  _Vdivider(),
                  _ActionButton(
                    icon: Icons.notifications_outlined,
                    label: 'Remind',
                    color: const Color(0xFF29B6F6),
                    onTap: onSendReminder,
                  ),
                  _Vdivider(),
                  _ActionButton(
                    icon: Icons.payments_outlined,
                    label: 'Fee',
                    color: const Color(0xFF4CAF50),
                    onTap: () {},
                  ),
                  _Vdivider(),
                  _ActionButton(
                    icon: Icons.delete_outline_rounded,
                    label: 'Remove',
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

class _Vdivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 0.5, height: 36, color: Colors.white10);
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

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

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAOpacity(0.12),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: color.withAOpacity(0.35), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ─── MemberListEntity Detail Screen ─────────────────────────────────────────────────────

class MemberDetailScreen extends StatelessWidget {
  final MemberListEntity member;
  const MemberDetailScreen({super.key, required this.member});

  Color get _statusColor => switch (member.memberStatus) {
    MemberStatus.active => const Color(0xFF4CAF50),
    MemberStatus.expired => const Color(0xFFFFA000),
    MemberStatus.suspended => const Color(0xFFE53935),
    MemberStatus.trial => const Color(0xFF29B6F6),
  };

  String get _statusLabel => switch (member.memberStatus) {
    MemberStatus.active => 'Active',
    MemberStatus.expired => 'Expired',
    MemberStatus.suspended => 'Suspended',
    MemberStatus.trial => 'Trial',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Profile header ────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
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
                  Icons.edit_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: Colors.white,
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
                      member.avatarColor.withAOpacity(0.3),
                      AppTheme.background,
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 80, 24, 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Large avatar
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: member.avatarColor.withAOpacity(0.25),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: member.avatarColor.withAOpacity(0.6),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            member.initials,
                            style: TextStyle(
                              color: member.avatarColor,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    member.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                ),
                                _StatusBadge(
                                  label: _statusLabel,
                                  color: _statusColor,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              member.id,
                              style: TextStyle(
                                color: Colors.white.withAOpacity(0.4),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Quick stats row
                _buildStatRow(),
                const SizedBox(height: 24),
                // Contact info
                _sectionTitle('Contact Information'),
                const SizedBox(height: 12),
                _buildInfoCard([
                  _InfoRow(Icons.phone_rounded, 'Phone', member.phone),
                  _InfoRow(Icons.email_rounded, 'Email', member.email),
                  _InfoRow(Icons.person_rounded, 'Trainer', member.trainer),
                ]),
                const SizedBox(height: 20),
                // Membership info
                _sectionTitle('Membership'),
                const SizedBox(height: 12),
                _buildMembershipCard(),
                const SizedBox(height: 20),
                // Fee history
                _sectionTitle('Fee History'),
                const SizedBox(height: 12),
                _buildFeeHistory(),
                const SizedBox(height: 20),
                // Actions
                _sectionTitle('Actions'),
                const SizedBox(height: 12),
                _buildActions(context),
                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow() {
    final items = [
      (
        member.workoutStreak > 0 ? '${member.workoutStreak}d' : '—',
        'Streak',
        Icons.local_fire_department_rounded,
        const Color(0xFFFF5722),
      ),
      (
        member.checkedInToday ? 'Yes' : 'No',
        'Here Today',
        Icons.how_to_reg_rounded,
        const Color(0xFF4CAF50),
      ),
      (
        member.daysLeft > 0 ? '${member.daysLeft}d' : '${-member.daysLeft}d',
        member.daysLeft > 0 ? 'Days Left' : 'Overdue',
        Icons.timer_rounded,
        const Color(0xFF29B6F6),
      ),
    ];

    return Row(
      children: items.asMap().entries.map((e) {
        final i = e.key;
        final s = e.value;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < items.length - 1 ? 10 : 0),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: (s.$4).withAOpacity(0.18), width: 1),
            ),
            child: Column(
              children: [
                Icon(s.$3, color: s.$4, size: 18),
                const SizedBox(height: 5),
                Text(
                  s.$1,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
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

  Widget _buildInfoCard(List<_InfoRow> rows) {
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              border: i < rows.length - 1
                  ? const Border(
                      bottom: BorderSide(color: Colors.white10, width: 0.5),
                    )
                  : null,
            ),
            child: Row(
              children: [
                Icon(row.icon, color: AppTheme.textSecondary, size: 17),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.label,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      row.value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMembershipCard() {
    final progress = member.daysLeft > 0
        ? (member.daysLeft / 30).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withAOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                member.plan,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                member.amount.toString(),
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _miniInfo('Joined', member.joinDate),
              _miniInfo('Expires', member.expiryDate),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                member.daysLeft > 0
                    ? '${member.daysLeft} days remaining'
                    : 'Membership expired',
                style: TextStyle(
                  color: member.daysLeft < 7
                      ? const Color(0xFFFFA000)
                      : Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.white.withAOpacity(0.08),
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeHistory() {
    final history = [
      ('Jun 7, 2025', 'Paid', member.amount, const Color(0xFF4CAF50)),
      ('May 7, 2025', 'Paid', member.amount, const Color(0xFF4CAF50)),
      ('Apr 7, 2025', 'Paid', member.amount, const Color(0xFF4CAF50)),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAOpacity(0.05), width: 1),
      ),
      child: Column(
        children: history.asMap().entries.map((e) {
          final i = e.key;
          final h = e.value;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              border: i < history.length - 1
                  ? const Border(
                      bottom: BorderSide(color: Colors.white10, width: 0.5),
                    )
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: (h.$4).withAOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.receipt_long_rounded,
                    color: h.$4,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        h.$1,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        member.plan,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      h.$3.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      h.$2,
                      style: TextStyle(
                        color: h.$4,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    final actions = [
      ('Assign Workout', Icons.fitness_center_rounded, const Color(0xFF7B1FA2)),
      ('Send Reminder', Icons.notifications_rounded, const Color(0xFF29B6F6)),
      ('Mark Fee Paid', Icons.payments_rounded, const Color(0xFF4CAF50)),
      ('Suspend Member', Icons.block_rounded, const Color(0xFFFFA000)),
      ('Extend Access', Icons.more_time_rounded, AppTheme.primary),
      ('Delete Member', Icons.delete_rounded, AppTheme.error),
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

  Widget _sectionTitle(String t) => Text(
    t,
    style: const TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.w800,
    ),
  );

  Widget _miniInfo(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
      Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}

class _InfoRow {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(this.icon, this.label, this.value);
}

// ─── Add Member Bottom Sheet ──────────────────────────────────────────────────

class _AddMemberSheet extends StatefulWidget {
  const _AddMemberSheet();
  @override
  State<_AddMemberSheet> createState() => _AddMemberSheetState();
}

class _AddMemberSheetState extends State<_AddMemberSheet> {
  String _selectedPlan = '';
  String _selectedTrainer = '';
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  void _refreshPlans() {
    final currentState = context.read<MembersConfigBloc>().state;
    if (currentState is MembersConfigSuccess ||
        currentState is MembersConfigLoading) {
      return;
    }
    context.read<MembersConfigBloc>().add(const GetMembershipPlansEvent(true));
  }

  @override
  void initState() {
    _refreshPlans();
    super.initState();
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      maxChildSize: 0.95,
      minChildSize: 0.5,
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
              // Title
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
                      Icons.person_add_rounded,
                      color: AppTheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Add New Member',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Fields
              _field(
                _nameController,
                'Full Name',
                Icons.person_outline_rounded,
                hint: 'e.g. Arjun Menon',
                isRequired: true,
              ),
              const SizedBox(height: 14),
              _field(
                _phoneController,
                'Phone Number',
                Icons.phone_rounded,
                hint: '+91 98765 43210',
                keyboardType: TextInputType.phone,
                isRequired: true,
              ),
              const SizedBox(height: 14),
              _field(
                _emailController,
                'Email Address',
                Icons.email_outlined,
                hint: 'member@email.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),
              _field(
                _dobController,
                'Date of Birth',
                Icons.cake_outlined,
                hint: 'DD / MM / YYYY',
                keyboardType: TextInputType.number,
                inputFormatters: [DateOfBirthFormatter()],
              ),
              const SizedBox(height: 20),
              // Plan selector
              _label('Membership Plan'),
              const SizedBox(height: 10),
              BlocBuilder<MembersConfigBloc, MembersConfigState>(
                builder: (context, state) {
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: state.membershipPlans
                        .map(
                          (p) => GestureDetector(
                            onTap: () => setState(() => _selectedPlan = p.id),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 9,
                              ),
                              decoration: BoxDecoration(
                                color: _selectedPlan == p.id
                                    ? AppTheme.primary
                                    : AppTheme.surface,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _selectedPlan == p.id
                                      ? AppTheme.primary
                                      : Colors.white.withAOpacity(0.08),
                                ),
                              ),
                              child: Text(
                                "${p.name} - ₹${p.price} (${p.durationDays} days)",
                                style: TextStyle(
                                  color: _selectedPlan == p.id
                                      ? Colors.white
                                      : AppTheme.textSecondary,
                                  fontSize: 13,
                                  fontWeight: _selectedPlan == p.id
                                      ? FontWeight.w800
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: 20),
              // Trainer selector
              _label('Assign Trainer'),
              const SizedBox(height: 10),
              BlocBuilder<MembersConfigBloc, MembersConfigState>(
                builder: (context, state) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: state.trainers
                          .mapIndexed(
                            (i, t) => SizedBox(
                              width: 30.percentToWidth,
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedTrainer = t.id),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  margin: EdgeInsets.only(
                                    right: t != state.trainers.last ? 8 : 0,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _selectedTrainer == t.id
                                        ? AppTheme.primary.withAOpacity(0.12)
                                        : AppTheme.surface,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: _selectedTrainer == t.id
                                          ? AppTheme.primary.withAOpacity(0.5)
                                          : Colors.white.withAOpacity(0.06),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      t.name,
                                      style: TextStyle(
                                        color: _selectedTrainer == t.id
                                            ? AppTheme.primary
                                            : AppTheme.textSecondary,
                                        fontSize: 11,
                                        fontWeight: _selectedTrainer == t.id
                                            ? FontWeight.w800
                                            : FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 28),
              // Submit
              BlocConsumer<MembersActionsBloc, MembersActionsState>(
                listener: (context, state) {
                  if (state is CreateMemberSuccessState) {
                    context.pop(state.member);
                  } else if (state is CreateMemberFailureState) {
                    context.showToastFromFailure(state.failure);
                  }
                },
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: () {
                      if (!_formKey.currentState!.validate()) return;
                      if (_selectedPlan.isEmpty) {
                        return context.showToast("Select a plan");
                      }
                      if (_selectedTrainer.isEmpty) {
                        return context.showToast("Select a trainer");
                      }
                      String? dobError = Validators.validateDateOfBirth(
                        _dobController.text,
                      );
                      if (dobError != null) {
                        return context.showToast(
                          dobError,
                          type: ToastificationType.error,
                        );
                      }
                      context.read<MembersActionsBloc>().add(
                        CreateMemberEvent(
                          name: _nameController.text.trim(),
                          dob: _dobController.text.trim(),
                          email: _emailController.text.trim(),
                          phone: _phoneController.text.trim(),
                          plan: _selectedPlan,
                          trainer: _selectedTrainer,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: state is CreateMemberLoadingState
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Add Member',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    String hint = '',
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool isRequired = false,
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
            inputFormatters: inputFormatters,
            validator: (value) {
              if (!isRequired) return null;
              if (value == null) return null;
              if (value.isEmpty) return '$label is required';
              return null;
            },
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
              prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 18),
              border: InputBorder.none,
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

  Widget _label(String t) => Text(
    t,
    style: const TextStyle(
      color: AppTheme.textSecondary,
      fontSize: 12,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.3,
    ),
  );
}

// ─── Advanced Filter Sheet ────────────────────────────────────────────────────

class _AdvancedFilterSheet extends StatefulWidget {
  final Map<String, dynamic>? activeFilters;
  const _AdvancedFilterSheet({this.activeFilters});
  @override
  State<_AdvancedFilterSheet> createState() => _AdvancedFilterSheetState();
}

class _AdvancedFilterSheetState extends State<_AdvancedFilterSheet> {
  String _plan = 'all';
  String _trainer = 'all';
  bool _checkedInToday = false;
  bool _overdueOnly = false;

  @override
  void initState() {
    super.initState();
    _plan = widget.activeFilters?['plan'] ?? 'all';
    _trainer = widget.activeFilters?['trainer'] ?? 'all';
    _checkedInToday = widget.activeFilters?['checkedInToday'] ?? false;
    _overdueOnly = widget.activeFilters?['overdueOnly'] ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Advanced Filter',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              TextButton(
                onPressed: () => setState(() {
                  _plan = 'all';
                  _trainer = 'all';
                  _checkedInToday = false;
                  _overdueOnly = false;
                }),
                child: const Text(
                  'Reset',
                  style: TextStyle(color: AppTheme.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _fLabel('Membership Plan'),
          const SizedBox(height: 8),
          BlocBuilder<MembersConfigBloc, MembersConfigState>(
            builder: (context, state) {
              return _chipRow(
                [
                  (key: "all", label: "All"),
                  ...state.membershipPlans.map((e) {
                    return (key: e.id, label: e.name);
                  }),
                ],
                _plan,
                (v) => setState(() => _plan = v),
              );
            },
          ),
          const SizedBox(height: 16),
          _fLabel('Trainer'),
          const SizedBox(height: 8),
          BlocBuilder<MembersConfigBloc, MembersConfigState>(
            builder: (context, state) {
              return _chipRow(
                [
                  (key: "all", label: "All"),
                  ...state.trainers.map((e) {
                    return (key: e.id, label: e.name);
                  }),
                ],
                _trainer,
                (v) => setState(() => _trainer = v),
              );
            },
          ),
          const SizedBox(height: 16),
          _toggle(
            'Checked in today',
            _checkedInToday,
            (v) => setState(() => _checkedInToday = v),
          ),
          _toggle(
            'Overdue fees only',
            _overdueOnly,
            (v) => setState(() => _overdueOnly = v),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, {
              'plan': _plan,
              'trainer': _trainer,
              'checkedInToday': _checkedInToday,
              'overdueOnly': _overdueOnly,
            }),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Apply Filters',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fLabel(String t) => Text(
    t,
    style: const TextStyle(
      color: AppTheme.textSecondary,
      fontSize: 12,
      fontWeight: FontWeight.w700,
    ),
  );

  Widget _chipRow(
    List<({String key, String label})> options,
    String selected,
    ValueChanged<String> onSelect,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options
          .map(
            (o) => GestureDetector(
              onTap: () => onSelect(o.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: selected == o.key
                      ? AppTheme.primary
                      : AppTheme.surface,
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(
                    color: selected == o.key
                        ? AppTheme.primary
                        : Colors.white.withAOpacity(0.07),
                  ),
                ),
                child: Text(
                  o.label,
                  style: TextStyle(
                    color: selected == o.key
                        ? Colors.white
                        : AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: selected == o.key
                        ? FontWeight.w800
                        : FontWeight.w500,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _toggle(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppTheme.primary,
        inactiveThumbColor: Colors.grey,
        inactiveTrackColor: Colors.white12,
      ),
    );
  }
}
