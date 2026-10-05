import 'dart:async';

import 'package:club_fitness/config/navigation/routes_class.dart';
import 'package:club_fitness/config/theme/theme.dart';
import 'package:club_fitness/core/entities/member_status.dart';
import 'package:club_fitness/core/entities/user_entity.dart';
import 'package:club_fitness/core/services/search_services.dart';
import 'package:club_fitness/core/utils/utils.dart';
import 'package:club_fitness/di.dart';
import 'package:club_fitness/features/admin_utils/domain/entities/admin_utils_entities.dart';
import 'package:club_fitness/features/member_manager/member_manager.dart';
import 'package:club_fitness/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:file_picker/file_picker.dart';

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
        status: _selectedFilter == 'All' ? '' : _selectedFilter.toUpperCase(),
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
    _debounceTimer?.cancel();
    _fadeCtrl.dispose();
    _searchCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (!_scrollController.hasClients) return;
    final bloc = context.read<MembersListingBloc>();
    if (bloc.state is! MembersListingSuccess) return;

    final max = _scrollController.position.maxScrollExtent;
    if (max > 0 && _scrollController.position.pixels >= 0.8 * max) {
      bloc.add(const GetMoreMembersListingEvent());
    }
  }

  Summary? _summary;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: BlocBuilder<MembersListingBloc, MembersListingState>(
        builder: (context, state) {
          if (state is MembersListingSuccess) _summary = state.summary;
          final summary = _summary;

          // First load only: nothing to show yet, so use a full-screen state
          if (summary == null) {
            if (state is MembersListingFailure) {
              return FailureTextWidget(
                state.failure,
                onRetry: () => context.read<MembersListingBloc>().add(
                  const GetMembersListingEvent(),
                ),
              );
            }
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          final members = state is MembersListingSuccess
              ? [..._members, ...state.members]
              : <MemberListEntity>[];

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
                        _buildSummaryRow(summary),
                        const SizedBox(height: 20),
                        _buildSearchBar(),
                        const SizedBox(height: 14),
                        _buildFilterRow(),
                        const SizedBox(height: 14),
                        _buildSortRow(summary.total.toInt() + _members.length),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                _buildListSliver(state, members),
              ],
            ),
          );
        },
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildListSliver(
    MembersListingState state,
    List<MemberListEntity> members,
  ) {
    if (state is MembersListingFailure) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: FailureTextWidget(state.failure, onRetry: _refreshMembers),
      );
    }

    // Loading / initial: spinner replaces only the list area
    if (state is! MembersListingSuccess) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    if (members.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _buildEmptyState(),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, i) => _MemberCard(
            member: members[i],
            onTap: () => _openMemberDetail(members[i]),
            onDelete: () => _delete(context, null, members[i]),
            onSendReminder: () => _sendReminder(members[i]),
          ),
          childCount: members.length,
        ),
      ),
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

  void _openMemberDetail(MemberListEntity m) async {
    await context.pushNamed(
      RoutesName.memberDetails,
      pathParameters: {'id': m.id},
    );
    if (!mounted) return;
    _refreshMembers();
  }

  void _sendReminder(MemberListEntity m) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Reminder sent to ${m.name}')));
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
                        // Row(
                        //   children: [
                        //     Text(
                        //       member.plan,
                        //       style: const TextStyle(
                        //         color: AppTheme.textSecondary,
                        //         fontSize: 11,
                        //       ),
                        //     ),
                        //     const SizedBox(width: 6),
                        //     Container(
                        //       width: 3,
                        //       height: 3,
                        //       decoration: const BoxDecoration(
                        //         color: AppTheme.textSecondary,
                        //         shape: BoxShape.circle,
                        //       ),
                        //     ),
                        //     const SizedBox(width: 6),
                        //     Text(
                        //       member.id,
                        //       style: TextStyle(
                        //         color: Colors.white.withAOpacity(0.35),
                        //         fontSize: 10,
                        //         fontWeight: FontWeight.w600,
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        Text(
                          member.plan,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 11,
                          ),
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
                    onTap: () => context.pushNamed(
                      RoutesName.assignWorkout,
                      queryParameters: {'memberId': member.id},
                    ),
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
                    label: 'Mark as Paid',
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

class MemberDetailProvider extends StatelessWidget {
  final String memberId;
  const MemberDetailProvider({super.key, required this.memberId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          MemberDetailBloc(sl())..add(GetMemberDetailsEvent(memberId)),
      child: MemberDetailScreen(memberId: memberId),
    );
  }
}

// ─── MemberListEntity Detail Screen ─────────────────────────────────────────────────────

class MemberDetailScreen extends StatelessWidget {
  final String memberId;
  const MemberDetailScreen({super.key, required this.memberId});

  Color _statusColor(MemberStatus status) => switch (status) {
    MemberStatus.active => const Color(0xFF4CAF50),
    MemberStatus.expired => const Color(0xFFFFA000),
    MemberStatus.suspended => const Color(0xFFE53935),
    MemberStatus.trial => const Color(0xFF29B6F6),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: BlocBuilder<MemberDetailBloc, MemberDetailState>(
        builder: (context, state) {
          if (state is MemberDetailLoading) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if (state is! MemberDetailSuccess) return const SizedBox.shrink();
          final member = state.detail.member;
          final attendance = state.detail.attendance;
          final feeHistory = state.detail.feeHistory;
          return CustomScrollView(
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
                    onPressed: () async {
                      final configBloc = context.read<MembersConfigBloc>();
                      final actionsBloc = context.read<MembersActionsBloc>();
                      final updated = await showModalBottomSheet<bool>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => MultiBlocProvider(
                          providers: [
                            BlocProvider.value(value: configBloc),
                            BlocProvider.value(value: actionsBloc),
                          ],
                          child: _AddMemberSheet(member: member),
                        ),
                      );
                      if (updated == true && context.mounted) {
                        context.read<MemberDetailBloc>().add(
                          GetMemberDetailsEvent(memberId),
                        );
                      }
                    },
                  ),
                  _MemberActionsMenu(
                    actions: _buildMemberActions(
                      context,
                      member,
                      feeHistory.firstOrNull,
                    ),
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
                                      label: member.memberStatus.label,
                                      color: _statusColor(member.memberStatus),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Joined: ${member.createdAtDate.fullDateWithShortMonth}",
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
                    _buildStatRow(member),
                    const SizedBox(height: 24),
                    // Contact info
                    _sectionTitle('Contact Information'),
                    const SizedBox(height: 12),
                    _buildInfoCard([
                      _InfoRow(Icons.phone_rounded, 'Phone', member.phone),
                      _InfoRow(Icons.email_rounded, 'Email', member.email),
                      _InfoRow(
                        Icons.person_rounded,
                        'Trainer',
                        member.assignedTrainer,
                      ),
                    ]),
                    const SizedBox(height: 20),
                    _sectionTitle('Device Information'),
                    const SizedBox(height: 12),
                    _buildInfoCard([
                      _InfoRow(Icons.pin, 'Device Pin', member.devicePin),
                      _InfoRow(
                        Icons.lock,
                        'Status',
                        member.blocked ? 'Blocked' : 'Active',
                      ),
                    ]),
                    const SizedBox(height: 20),
                    // Membership info
                    _sectionTitle('Membership'),
                    const SizedBox(height: 12),
                    _buildMembershipCard(member),
                    const SizedBox(height: 20),
                    // Fee history
                    _sectionTitle('Fee History'),
                    const SizedBox(height: 12),
                    _buildFeeHistory(feeHistory),
                    const SizedBox(height: 20),
                    // Attendance
                    _sectionTitle('Recent Attendance'),
                    const SizedBox(height: 12),
                    _buildAttendance(attendance),
                    const SizedBox(height: 20),
                    // Actions
                    _sectionTitle('Actions'),
                    const SizedBox(height: 12),
                    _buildActions(context, member, feeHistory.firstOrNull),
                    const SizedBox(height: 20),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAttendance(List<AttendanceEntity> attendance) {
    if (attendance.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withAOpacity(0.05), width: 1),
        ),
        child: const Center(
          child: Text(
            'No attendance records yet',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
        ),
      );
    }

    // API returns newest first; show only the latest 10
    final items = attendance.take(10).toList();

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAOpacity(0.05), width: 1),
      ),
      child: Column(
        children: items.mapIndexed((i, a) {
          final checkIn = a.checkInAt.toDateTime;
          final checkOut = a.checkOutAt.isNotEmpty
              ? a.checkOutAt.toDateTime
              : null;
          final date = "${checkIn.monthShort} ${checkIn.day}, ${checkIn.year}";
          final timeRange = checkOut == null
              ? '${_formatTime(checkIn)} - In gym'
              : '${_formatTime(checkIn)} - ${_formatTime(checkOut)}';
          final duration = checkOut == null
              ? null
              : _formatDuration(checkOut.difference(checkIn));

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              border: i < items.length - 1
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
                    color: const Color(0xFF4CAF50).withAOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.how_to_reg_rounded,
                    color: Color(0xFF4CAF50),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        date,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        timeRange,
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
                    if (duration != null)
                      Text(
                        duration,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    if (a.method.isNotEmpty)
                      Text(
                        a.method.toUpperCase(),
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
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

  String _formatTime(DateTime d) {
    final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final minute = d.minute.toString().padLeft(2, '0');
    final period = d.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String _formatDuration(Duration d) {
    if (d.isNegative) return '—';
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    return h > 0 ? '${h}h ${m}m' : '${m}m';
  }

  Widget _buildStatRow(MemberEntity member) {
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

  Widget _buildMembershipCard(MemberEntity member) {
    final totalDays = member.membershipEndDate
        .difference(member.membershipStartDate)
        .inDays;
    final progress = member.daysLeft > 0
        ? (member.daysLeft / totalDays).clamp(0.0, 1.0)
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
                member.membershipPlan.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                "₹ ${member.membershipPlan.price}",
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
              _miniInfo('Started', member.membershipStart),
              _miniInfo('Expires', member.membershipEnd),
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

  Widget _buildFeeHistory(List<FeeHistoryEntity> history) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAOpacity(0.05), width: 1),
      ),
      child: Column(
        children: history.mapIndexed((i, h) {
          DateTime paidDate = h.paidDate.toDateTime;
          String date =
              "${paidDate.monthShort} ${paidDate.day}, ${paidDate.year}";
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
                    color: h.statusEnum.color.withAOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.receipt_long_rounded,
                    color: h.statusEnum.color,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        date,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        h.plan.name,
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
                      "₹ ${h.paidAmount}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      h.statusEnum.label,
                      style: TextStyle(
                        color: h.statusEnum.color,
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

  List<(String, IconData, Color, void Function()?)> _buildMemberActions(
    BuildContext context,
    MemberEntity m,
    FeeHistoryEntity? lastFee,
  ) {
    final canSuspend = !m.blocked || m.memberStatus == MemberStatus.active;
    return [
      (
        'Assign Workout',
        Icons.fitness_center_rounded,
        const Color(0xFF7B1FA2),
        () => context.pushNamed(
          RoutesName.assignWorkout,
          queryParameters: {'memberId': m.id},
        ),
      ),
      if (m.membershipEndDate.isBefore(DateTime.now()))
        (
          'Send Reminder',
          Icons.notifications_rounded,
          const Color(0xFF29B6F6),
          null, // no reminder event in MembersActionsBloc yet
        ),
      if (lastFee != null && lastFee.statusEnum == FeeStatus.pending)
        (
          'Mark Fee Paid',
          Icons.payments_rounded,
          const Color(0xFF4CAF50),
          null, // no mark-paid event in MembersActionsBloc yet
        ),
      if (canSuspend)
        (
          'Suspend Member',
          Icons.block_rounded,
          const Color(0xFFFFA000),
          () => _suspend(context, m),
        )
      else
        (
          'Reactivate Member',
          Icons.check_rounded,
          const Color(0xFF4CAF50),
          () => _reactivate(context, m),
        ),
      (
        'Renew Membership',
        Icons.more_time_rounded,
        AppTheme.primary,
        () => _renew(context, m),
      ),
      (
        'Delete Member',
        Icons.delete_rounded,
        AppTheme.error,
        () => _delete(context, m, null),
      ),
    ];
  }

  Widget _buildActions(
    BuildContext context,
    MemberEntity m,
    FeeHistoryEntity? lastFee,
  ) {
    final actions = _buildMemberActions(context, m, lastFee);

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
              onTap: a.$4,
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
        value.toDateTime.fullDateWithShortMonth,
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

// ─── Sheet Mode ────────────────────────────────────────────────────────────

enum _SheetMode { form, selectPlan, selectTrainer }

// ─── Add Member Bottom Sheet ──────────────────────────────────────────────────

class _AddMemberSheet extends StatefulWidget {
  final MemberEntity? member;
  const _AddMemberSheet({this.member});
  @override
  State<_AddMemberSheet> createState() => _AddMemberSheetState();
}

class _AddMemberSheetState extends State<_AddMemberSheet> {
  String _selectedPlan = '';
  String _selectedTrainer = '';
  MembershipPlanMiniEntity? _selectedPlanEntity;

  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _dob;

  _SheetMode _sheetMode = _SheetMode.form;
  final _planSearchCtrl = TextEditingController();
  final _trainerSearchCtrl = TextEditingController();
  String _planSearchQuery = '';
  String _trainerSearchQuery = '';

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool get _isEdit => widget.member != null;

  @override
  void initState() {
    super.initState();
    _refreshPlans();
    final m = widget.member;
    if (m != null) _prefill(m);
  }

  void _prefill(MemberEntity m) {
    _nameController.text = m.name;
    _phoneController.text = m.phone;
    _emailController.text = m.email;
    _dob = m.dateOfBirth.isEmpty ? null : m.dateOfBirth.toDateTime;
    _selectedPlan = m.membershipPlan.id;
    _selectedTrainer = m.assignedTrainerId;
    _startDate = m.membershipStart.isEmpty
        ? null
        : m.membershipStart.toDateTime;
    _endDate = m.membershipEnd.isEmpty ? null : m.membershipEnd.toDateTime;
    _selectedRole = UserRole.member;
    _resolvePlanEntity();
  }

  // The end date picker and duration math need the plan entity, which may not
  // be loaded yet when the sheet opens.
  void _resolvePlanEntity() {
    if (_selectedPlan.isEmpty || _selectedPlanEntity != null) return;
    final plans = context.read<MembersConfigBloc>().state.membershipPlans;
    final match = plans.where((p) => p.id == _selectedPlan);
    if (match.isNotEmpty) _selectedPlanEntity = match.first;
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
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _planSearchCtrl.dispose();
    _trainerSearchCtrl.dispose();
    super.dispose();
  }

  // ── Date helpers ────────────────────────────────────────────────────────

  String _formatDate(DateTime d) {
    const months = [
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
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  int get _planDurationDays {
    final d = _selectedPlanEntity?.durationDays;
    return d == null ? 0 : d.toInt();
  }

  void _onPlanPicked(MembershipPlanMiniEntity plan) {
    setState(() {
      _selectedPlan = plan.id;
      _selectedPlanEntity = plan;
      _startDate ??= DateTime.now();
      _endDate = _startDate!.add(Duration(days: plan.durationDays as int));
      _sheetMode = _SheetMode.form;
    });
  }

  void _onTrainerPicked(TrainerMiniEntity trainer) {
    setState(() {
      _selectedTrainer = trainer.id;
      _sheetMode = _SheetMode.form;
    });
  }

  Future<void> _pickDob() async {
    final initial = _dob ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1000),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    setState(() {
      _dob = picked;
    });
  }

  Future<void> _pickStartDate() async {
    final initial = _startDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked == null) return;
    setState(() {
      _startDate = picked;
      if (_selectedPlanEntity != null) {
        _endDate = picked.add(Duration(days: _planDurationDays));
      }
    });
  }

  Future<void> _pickEndDate() async {
    if (_selectedPlanEntity == null) return; // disabled until a plan is picked
    final initial =
        _endDate ?? DateTime.now().add(Duration(days: _planDurationDays));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: (_startDate ?? DateTime.now()),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked == null) return;
    setState(() {
      _endDate = picked;
      _startDate = picked.subtract(Duration(days: _planDurationDays));
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MembersConfigBloc, MembersConfigState>(
      listener: (_, __) => setState(_resolvePlanEntity),
      child: DraggableScrollableSheet(
        initialChildSize: 0.88,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, scrollCtrl) => Container(
          decoration: const BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: switch (_sheetMode) {
            _SheetMode.form => _buildFormView(scrollCtrl),
            _SheetMode.selectPlan => _buildPlanSelectView(scrollCtrl),
            _SheetMode.selectTrainer => _buildTrainerSelectView(scrollCtrl),
          },
        ),
      ),
    );
  }

  UserRole _selectedRole = UserRole.member;

  // ── Form view ───────────────────────────────────────────────────────────

  Widget _buildFormView(ScrollController scrollCtrl) {
    return Form(
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
                  _isEdit ? Icons.edit_rounded : Icons.person_add_rounded,
                  color: AppTheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _isEdit ? 'Edit Member' : 'Add New Member',
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
          _dateField(
            label: 'Date of Birth',
            value: _dob,
            enabled: true,
            onTap: _pickDob,
          ),
          // _field(
          //   _dobController,
          //   'Date of Birth',
          //   Icons.cake_outlined,
          //   hint: 'DD / MM / YYYY',
          //   keyboardType: TextInputType.number,
          //   inputFormatters: [DateOfBirthFormatter()],
          // ),
          const SizedBox(height: 20),

          // ── Plan selector (limited to 3 lines) ─────────────────────────
          _label('Membership Plan'),
          const SizedBox(height: 10),
          BlocBuilder<MembersConfigBloc, MembersConfigState>(
            builder: (context, state) {
              return _LimitedChipWrap(
                itemLabels: state.membershipPlans
                    .map(
                      (p) => "${p.name} - ₹${p.price} (${p.durationDays} days)",
                    )
                    .toList(),
                maxLines: 3,
                onSeeMore: () =>
                    setState(() => _sheetMode = _SheetMode.selectPlan),
                chipBuilder: (i) {
                  final p = state.membershipPlans[i];
                  final selected = _selectedPlan == p.id;
                  return _selectChip(
                    label: "${p.name} - ₹${p.price} (${p.durationDays} days)",
                    selected: selected,
                    onTap: () => _onPlanPicked(p),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 20),

          // ── Trainer selector (limited to 3 lines) ───────────────────────
          _label('Assign Trainer'),
          const SizedBox(height: 10),
          BlocBuilder<MembersConfigBloc, MembersConfigState>(
            builder: (context, state) {
              return _LimitedChipWrap(
                itemLabels: state.trainers.map((t) => t.name).toList(),
                maxLines: 3,
                onSeeMore: () =>
                    setState(() => _sheetMode = _SheetMode.selectTrainer),
                chipBuilder: (i) {
                  final t = state.trainers[i];
                  final selected = _selectedTrainer == t.id;
                  return _selectChip(
                    label: t.name,
                    selected: selected,
                    onTap: () => _onTrainerPicked(t),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 20),

          // ── Start / End date ─────────────────────────────────────────────
          _label('Membership Duration'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _dateField(
                  label: 'Start Date',
                  value: _startDate,
                  enabled: true,
                  onTap: _pickStartDate,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _dateField(
                  label: 'End Date',
                  value: _endDate,
                  enabled: _selectedPlanEntity != null,
                  onTap: _pickEndDate,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (!_isEdit) ...[
            const SizedBox(height: 12),
            _UserRoleSelectorChip(
              selected: _selectedRole,
              onSelected: (value) => setState(() => _selectedRole = value),
            ),
          ],

          const SizedBox(height: 28),

          BlocConsumer<MembersActionsBloc, MembersActionsState>(
            listener: (context, state) {
              if (state is CreateMemberSuccessState) {
                context.pop(state.member);
              } else if (state is UpdateMemberSuccessState) {
                context.pop(true);
              } else if (state is CreateMemberFailureState) {
                context.showToastFromFailure(state.failure);
              } else if (state is UpdateMemberFailureState) {
                context.showToastFromFailure(state.failure);
              }
            },
            builder: (context, state) {
              final isLoading =
                  state is CreateMemberLoadingState ||
                  state is UpdateMemberLoadingState;
              return ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        if (!_formKey.currentState!.validate()) return;
                        if (_selectedPlan.isEmpty &&
                            _selectedRole == UserRole.member) {
                          return _showErrorToast("Select a plan");
                        }
                        if (_selectedTrainer.isEmpty &&
                            _selectedRole == UserRole.member) {
                          return _showErrorToast("Select a trainer");
                        }
                        if (_startDate == null || _endDate == null) {
                          return _showErrorToast("Select membership dates");
                        }
                        if (_dob == null) {
                          return _showErrorToast("Select date of birth");
                        }

                        final bloc = context.read<MembersActionsBloc>();
                        if (_isEdit) {
                          bloc.add(
                            UpdateMemberEvent(
                              id: widget.member!.id,
                              name: _nameController.text.trim(),
                              dob: _dob!.toIso8601String(),
                              email: _emailController.text.trim(),
                              phone: _phoneController.text.trim(),
                              plan: _selectedPlan,
                              trainer: _selectedTrainer,
                              startDate: _startDate!.toIso8601String(),
                            ),
                          );
                        } else {
                          bloc.add(
                            CreateMemberEvent(
                              name: _nameController.text.trim(),
                              dob: _dob!.toIso8601String(),
                              email: _emailController.text.trim(),
                              phone: _phoneController.text.trim(),
                              plan: _selectedPlan,
                              trainer: _selectedTrainer,
                              startDate: _startDate!.toIso8601String(),
                              userRole: _selectedRole.key,
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _isEdit ? 'Save Changes' : 'Add Member',
                        style: const TextStyle(
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
    );
  }

  void _showErrorToast(String message) =>
      context.showToast(message, type: ToastificationType.error);

  // ── Plan select view (full list + fuzzy search) ────────────────────────

  Widget _buildPlanSelectView(ScrollController scrollCtrl) {
    return BlocBuilder<MembersConfigBloc, MembersConfigState>(
      builder: (context, state) {
        final results = SearchService.fuzzySearch(
          state.membershipPlans,
          _planSearchQuery,
          (p) => "${p.name} ${p.price} ${p.durationDays}",
        );
        return _selectionScaffold(
          title: 'Select Membership Plan',
          searchCtrl: _planSearchCtrl,
          onSearchChanged: (v) => setState(() => _planSearchQuery = v),
          onBack: () => setState(() => _sheetMode = _SheetMode.form),
          scrollCtrl: scrollCtrl,
          itemCount: results.length,
          itemBuilder: (i) {
            final p = results[i];
            final selected = _selectedPlan == p.id;
            return _selectTile(
              title: p.name,
              subtitle: "₹${p.price}  •  ${p.durationDays} days",
              selected: selected,
              onTap: () => _onPlanPicked(p),
            );
          },
        );
      },
    );
  }

  // ── Trainer select view (full list + fuzzy search) ──────────────────────

  Widget _buildTrainerSelectView(ScrollController scrollCtrl) {
    return BlocBuilder<MembersConfigBloc, MembersConfigState>(
      builder: (context, state) {
        final results = SearchService.fuzzySearch(
          state.trainers,
          _trainerSearchQuery,
          (t) => t.name,
        );
        return _selectionScaffold(
          title: 'Select Trainer',
          searchCtrl: _trainerSearchCtrl,
          onSearchChanged: (v) => setState(() => _trainerSearchQuery = v),
          onBack: () => setState(() => _sheetMode = _SheetMode.form),
          scrollCtrl: scrollCtrl,
          itemCount: results.length,
          itemBuilder: (i) {
            final t = results[i];
            final selected = _selectedTrainer == t.id;
            return _selectTile(
              title: t.name,
              subtitle: null,
              selected: selected,
              onTap: () => _onTrainerPicked(t),
            );
          },
        );
      },
    );
  }

  // ── Shared selection scaffold ────────────────────────────────────────────

  Widget _selectionScaffold({
    required String title,
    required TextEditingController searchCtrl,
    required ValueChanged<String> onSearchChanged,
    required VoidCallback onBack,
    required ScrollController scrollCtrl,
    required int itemCount,
    required Widget Function(int) itemBuilder,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                onPressed: onBack,
              ),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withAOpacity(0.06),
                width: 1,
              ),
            ),
            child: TextField(
              controller: searchCtrl,
              onChanged: onSearchChanged,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search…',
                hintStyle: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
                suffixIcon: searchCtrl.text.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          searchCtrl.clear();
                          onSearchChanged('');
                        },
                        child: const Icon(
                          Icons.close_rounded,
                          color: AppTheme.textSecondary,
                          size: 18,
                        ),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: itemCount == 0
              ? const Center(
                  child: Text(
                    'No results found',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                )
              : ListView.builder(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  itemCount: itemCount,
                  itemBuilder: (_, i) => itemBuilder(i),
                ),
        ),
      ],
    );
  }

  Widget _selectTile({
    required String title,
    String? subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primary.withAOpacity(0.12)
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: selected ? AppTheme.primary : Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppTheme.primary,
                size: 20,
              ),
          ],
        ),
      ),
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

  Widget _dateField({
    required String label,
    required DateTime? value,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: enabled ? onTap : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: enabled
                  ? AppTheme.surface
                  : AppTheme.surface.withAOpacity(0.4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withAOpacity(0.06),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 15,
                  color: enabled
                      ? AppTheme.textSecondary
                      : AppTheme.textSecondary.withAOpacity(0.35),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    value != null
                        ? _formatDate(value)
                        : (enabled ? 'Select date' : 'Select a plan first'),
                    style: TextStyle(
                      color: enabled
                          ? Colors.white
                          : Colors.white.withAOpacity(0.3),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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

// ─── Limited chip wrap (up to N lines, then "See more") ────────────────────

class _LimitedChipWrap extends StatelessWidget {
  final List<String> itemLabels;
  final Widget Function(int index) chipBuilder;
  final VoidCallback onSeeMore;
  final int maxLines;
  final double spacing;
  final double runSpacing;

  const _LimitedChipWrap({
    required this.itemLabels,
    required this.chipBuilder,
    required this.onSeeMore,
    this.maxLines = 3,
    this.spacing = 8,
    this.runSpacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    if (itemLabels.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        const chipTextStyle = TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
        );
        const chipPadding = EdgeInsets.symmetric(horizontal: 14, vertical: 9);

        final visibleIndices = <int>[];
        int currentLine = 1;
        double currentLineWidth = 0;
        bool hasMore = false;

        for (int i = 0; i < itemLabels.length; i++) {
          final tp = TextPainter(
            text: TextSpan(text: itemLabels[i], style: chipTextStyle),
            textDirection: TextDirection.ltr,
          )..layout();
          final chipWidth = tp.width + chipPadding.horizontal;
          final widthNeeded = currentLineWidth == 0
              ? chipWidth
              : currentLineWidth + spacing + chipWidth;

          if (widthNeeded <= maxWidth) {
            currentLineWidth = widthNeeded;
            visibleIndices.add(i);
          } else {
            currentLine++;
            if (currentLine > maxLines) {
              hasMore = true;
              break;
            }
            currentLineWidth = chipWidth;
            visibleIndices.add(i);
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: spacing,
              runSpacing: runSpacing,
              children: visibleIndices.map(chipBuilder).toList(),
            ),
            if (hasMore) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: onSeeMore,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'See more',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppTheme.primary,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
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

class _UserRoleSelectorChip extends StatelessWidget {
  final UserRole selected;
  final ValueChanged<UserRole> onSelected;

  const _UserRoleSelectorChip({
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: UserRole.values.mapIndexed((i, e) {
        final bool isSelected = e == selected;
        return GestureDetector(
          onTap: () => onSelected(e),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primary : AppTheme.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? AppTheme.primary
                    : Colors.white.withAOpacity(0.08),
              ),
            ),
            child: Text(
              e.label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textSecondary,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _MemberActionsMenu extends StatelessWidget {
  final List<(String, IconData, Color, void Function()?)> actions;
  const _MemberActionsMenu({required this.actions});

  bool _isDestructive(Color c) => c == AppTheme.error;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      tooltip: 'Member actions',
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
      onSelected: (i) => actions[i].$4?.call(),
      itemBuilder: (_) {
        final items = <PopupMenuEntry<int>>[];
        for (int i = 0; i < actions.length; i++) {
          final (label, icon, color, onTap) = actions[i];
          final destructive = _isDestructive(color);

          if (destructive && items.isNotEmpty) {
            items.add(
              PopupMenuDivider(
                height: 12,
                color: Colors.white.withAOpacity(0.08),
              ),
            );
          }

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
                        style: TextStyle(
                          color: destructive ? AppTheme.error : Colors.white,
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

class _RenewResult {
  final String planId;
  final String? startOverride;
  final double? paidAmount;
  final String? paymentMethod;
  final String? notes;
  final String? receiptPath;
  const _RenewResult({
    required this.planId,
    this.startOverride,
    this.paidAmount,
    this.paymentMethod,
    this.notes,
    this.receiptPath,
  });
}

class _RenewMembershipSheet extends StatefulWidget {
  final MemberEntity member;
  const _RenewMembershipSheet({required this.member});

  @override
  State<_RenewMembershipSheet> createState() => _RenewMembershipSheetState();
}

class _RenewMembershipSheetState extends State<_RenewMembershipSheet> {
  static const _methods = [
    (key: 'CASH', label: 'Cash'),
    (key: 'UPI', label: 'UPI'),
    (key: 'BANK_TRANSFER', label: 'Bank Transfer'),
    (key: 'OTHER', label: 'Other'),
  ];

  late String _planId = widget.member.membershipPlan.id;
  DateTime? _startDate;
  String? _method;
  PlatformFile? _receipt;
  String? _error;

  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
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
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  DateTime get _earliestStart {
    final end = widget.member.membershipEndDate;
    return end.isAfter(DateTime.now())
        ? end
        : DateTime.now().subtract(const Duration(days: 365));
  }

  Future<void> _pickStart() async {
    final first = _earliestStart;
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? first,
      firstDate: first,
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
    Navigator.pop(
      context,
      _RenewResult(
        planId: _planId,
        startOverride: _startDate?.toIso8601String(),
        paidAmount: paid,
        paymentMethod: (paid ?? 0) > 0 ? _method : null,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        receiptPath: _receipt?.path,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final endLabel = widget.member.membershipEnd.isEmpty
        ? 'today'
        : widget.member.membershipEnd.toDateTime.fullDateWithShortMonth;

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

            // Plan
            _label('Plan'),
            const SizedBox(height: 10),
            BlocBuilder<MembersConfigBloc, MembersConfigState>(
              builder: (context, state) {
                if (state.membershipPlans.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Center(child: CircularProgressIndicator.adaptive()),
                  );
                }
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: state.membershipPlans.map((p) {
                    return _chip(
                      label: '${p.name} - ₹${p.price} (${p.durationDays} days)',
                      selected: _planId == p.id,
                      onTap: () => setState(() {
                        _planId = p.id;
                        _error = null;
                        _amountCtrl.text = p.price.toString();
                      }),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 20),

            // Start date
            _label('Start Date (optional)'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickStart,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: _fieldDecoration,
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
                        _startDate?.fullDateWithShortMonth ??
                            'After current membership ($endLabel)',
                        style: TextStyle(
                          color: _startDate == null
                              ? AppTheme.textSecondary
                              : Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (_startDate != null)
                      GestureDetector(
                        onTap: () => setState(() => _startDate = null),
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
            const SizedBox(height: 6),
            const Text(
              'The current plan stays active until its end date. The renewal takes over automatically.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
            ),
            const SizedBox(height: 20),

            // Payment
            _label('Amount Paid'),
            const SizedBox(height: 8),
            Container(
              decoration: _fieldDecoration,
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
            const SizedBox(height: 16),
            _label('Payment Method'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _methods
                  .map(
                    (o) => _chip(
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

            // Receipt
            Row(
              spacing: 12,
              children: [
                _label('Receipt (optional)'),
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
                decoration: _fieldDecoration,
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

            // Notes
            _label('Notes (optional)'),
            const SizedBox(height: 8),
            Container(
              decoration: _fieldDecoration,
              child: TextField(
                controller: _notesCtrl,
                maxLines: 2,
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

  BoxDecoration get _fieldDecoration => BoxDecoration(
    color: AppTheme.surface,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.white.withAOpacity(0.06), width: 1),
  );

  Widget _label(String t) => Text(
    t,
    style: const TextStyle(
      color: AppTheme.textSecondary,
      fontSize: 12,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.3,
    ),
  );

  Widget _chip({
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
}

enum _DeleteMode { deactivate, permanent }

class _DeleteModeSheet extends StatelessWidget {
  final String memberName;
  const _DeleteModeSheet({required this.memberName});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'Remove Member',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'What would you like to do with $memberName?',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 18),
            _DeleteOptionTile(
              icon: Icons.person_off_rounded,
              color: const Color(0xFFFFA000),
              title: 'Deactivate',
              badge: 'RECOMMENDED',
              description:
                  'Blocks gym access and marks the member as suspended. Fees, attendance and history are kept. Removes face template from enrollment. Can be reversed anytime. Need face re-enrollment after reactivation.',
              onTap: () => Navigator.pop(context, _DeleteMode.deactivate),
            ),
            const SizedBox(height: 12),
            _DeleteOptionTile(
              icon: Icons.delete_forever_rounded,
              color: AppTheme.error,
              title: 'Delete permanently',
              description:
                  'Erases the member and all their fees, orders, bookings, attendance and measurements. This cannot be undone.',
              onTap: () => Navigator.pop(context, _DeleteMode.permanent),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeleteOptionTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final String? badge;
  final VoidCallback onTap;

  const _DeleteOptionTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withAOpacity(0.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAOpacity(0.3), width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withAOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: color,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withAOpacity(0.18),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            badge!,
                            style: TextStyle(
                              color: color,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textSecondary,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PermanentDeleteDialog extends StatefulWidget {
  final String memberName;
  const _PermanentDeleteDialog({required this.memberName});

  @override
  State<_PermanentDeleteDialog> createState() => _PermanentDeleteDialogState();
}

class _PermanentDeleteDialogState extends State<_PermanentDeleteDialog> {
  final _ctrl = TextEditingController();

  bool get _matches => _ctrl.text.trim().toUpperCase() == 'DELETE';

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
      icon: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: AppTheme.error.withAOpacity(0.14),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.delete_forever_rounded,
          color: AppTheme.error,
          size: 26,
        ),
      ),
      title: const Text(
        'Delete permanently?',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13.5,
                height: 1.4,
              ),
              children: [
                TextSpan(
                  text: widget.memberName,
                  style: const TextStyle(
                    color: AppTheme.error,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const TextSpan(
                  text:
                      ' and all their fee records, orders, bookings, attendance and measurements will be erased. This cannot be undone.\n\nType DELETE to confirm.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withAOpacity(0.08)),
            ),
            child: TextField(
              controller: _ctrl,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              textAlign: TextAlign.center,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
              decoration: const InputDecoration(
                hintText: 'DELETE',
                hintStyle: TextStyle(
                  color: AppTheme.textSecondary,
                  letterSpacing: 2,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
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
            disabledBackgroundColor: AppTheme.error.withAOpacity(0.25),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: _matches ? () => Navigator.pop(context, true) : null,
          child: const Text(
            'Delete forever',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

// ── Action plumbing ─────────────────────────────────────────────────────────

/// Shows a blocking loader, fires [event], waits for the bloc to emit a
/// terminal state (per [isDone]), closes the loader and returns that state.
Future<MembersActionsState> _dispatch(
  BuildContext context,
  MembersActionsEvent event, {
  required bool Function(MembersActionsState) isDone,
}) async {
  final bloc = context.read<MembersActionsBloc>();
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const PopScope(
      canPop: false,
      child: Center(child: CircularProgressIndicator.adaptive()),
    ),
  );
  final result = bloc.stream.firstWhere(isDone);
  bloc.add(event);
  final state = await result;
  if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
  return state;
}

void _finish(
  BuildContext context, {
  Failure? failure,
  required String successMessage,
  required String? memberId,
}) {
  if (!context.mounted) return;
  if (failure != null) {
    context.showToastFromFailure(failure);
    return;
  }
  context.showToast(successMessage, type: ToastificationType.success);
  if (memberId != null) {
    context.read<MemberDetailBloc>().add(GetMemberDetailsEvent(memberId));
  }
}

Future<bool> _confirm(
  BuildContext context, {
  required IconData icon,
  required Color color,
  required String title,
  required String prefix,
  required String highlight,
  required String suffix,
  required String confirmLabel,
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: AppTheme.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      icon: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: color.withAOpacity(0.14),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 26),
      ),
      title: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
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
            TextSpan(text: prefix),
            TextSpan(
              text: highlight,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
            TextSpan(text: suffix),
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
            backgroundColor: color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            confirmLabel,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
  return ok == true;
}

// ── Suspend ─────────────────────────────────────────────────────────────────
Future<void> _suspend(BuildContext context, MemberEntity m) async {
  final ok = await _confirm(
    context,
    icon: Icons.block_rounded,
    color: const Color(0xFFFFA000),
    title: 'Suspend Member',
    prefix: 'Suspend ',
    highlight: m.name,
    suffix: '? They will be blocked from entering the gym until reactivated.',
    confirmLabel: 'Suspend',
  );
  if (!ok || !context.mounted) return;

  final state = await _dispatch(
    context,
    SuspendMemberEvent(id: m.id),
    isDone: (s) =>
        s is SuspendMemberSuccessState || s is SuspendMemberFailureState,
  );
  if (!context.mounted) return;
  _finish(
    context,
    failure: state is SuspendMemberFailureState ? state.failure : null,
    memberId: m.id,
    successMessage: state is SuspendMemberSuccessState
        ? state.message
        : '${m.name} has been suspended',
  );
}

// ── Reactivate ──────────────────────────────────────────────────────────────
Future<void> _reactivate(BuildContext context, MemberEntity m) async {
  final ok = await _confirm(
    context,
    icon: Icons.check_circle_rounded,
    color: const Color(0xFF4CAF50),
    title: 'Reactivate Member',
    prefix: 'Restore gym access for ',
    highlight: m.name,
    suffix: '?',
    confirmLabel: 'Reactivate',
  );
  if (!ok || !context.mounted) return;

  final state = await _dispatch(
    context,
    ReactivateMemberEvent(id: m.id),
    isDone: (s) =>
        s is ReactivateMemberSuccessState || s is ReactivateMemberFailureState,
  );
  if (!context.mounted) return;
  _finish(
    context,
    failure: state is ReactivateMemberFailureState ? state.failure : null,
    memberId: m.id,
    successMessage: state is ReactivateMemberSuccessState
        ? state.message
        : '${m.name} has been reactivated',
  );
}

// ── Delete (the endpoint de-activates unless force=true) ───────────────────
Future<void> _delete(
  BuildContext context,
  MemberEntity? m,
  MemberListEntity? ml,
) async {
  if (m == null && ml == null) return;
  final mode = await showModalBottomSheet<_DeleteMode>(
    context: context,
    backgroundColor: AppTheme.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _DeleteModeSheet(memberName: m?.name ?? ml!.name),
  );
  if (mode == null || !context.mounted) return;

  if (mode == _DeleteMode.deactivate) {
    final ok = await _confirm(
      context,
      icon: Icons.person_off_rounded,
      color: const Color(0xFFFFA000),
      title: 'Deactivate Member',
      prefix: 'Deactivate ',
      highlight: m?.name ?? ml!.name,
      suffix:
          '? They will be blocked from the gym and marked as suspended. All fees, attendance and history are kept, and you can reactivate them anytime.',
      confirmLabel: 'Deactivate',
    );
    if (!ok || !context.mounted) return;

    final state = await _dispatch(
      context,
      DeleteMemberEvent(id: m?.id ?? ml!.id),
      isDone: (s) =>
          s is DeleteMemberSuccessState || s is DeleteMemberFailureState,
    );
    if (!context.mounted) return;
    _finish(
      context,
      failure: state is DeleteMemberFailureState ? state.failure : null,
      memberId: m?.id,
      successMessage: '${m?.name ?? ml!.name} has been deactivated',
    );
    return;
  }

  // Permanent delete: requires typing DELETE
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => _PermanentDeleteDialog(memberName: m?.name ?? ml!.name),
  );
  if (confirmed != true || !context.mounted) return;

  final state = await _dispatch(
    context,
    DeleteMemberEvent(id: m?.id ?? ml!.id, force: true),
    isDone: (s) =>
        s is DeleteMemberSuccessState || s is DeleteMemberFailureState,
  );
  if (!context.mounted) return;

  if (state is DeleteMemberFailureState) {
    // e.g. 409 when the user authored workout plans, announcements or documents
    context.showToastFromFailure(state.failure);
    return;
  }
  context.showToast(
    state is DeleteMemberSuccessState
        ? state.message
        : '${m?.name ?? ml!.name} has been permanently deleted',
    type: ToastificationType.success,
  );
  // The member no longer exists, so reloading the details would 404. Leave the
  // screen; the list refreshes itself when the detail route pops.
  Navigator.of(context).pop();
}

// ── Renew ───────────────────────────────────────────────────────────────────
Future<void> _renew(BuildContext context, MemberEntity m) async {
  final configBloc = context.read<MembersConfigBloc>();
  final result = await showModalBottomSheet<_RenewResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: configBloc,
      child: _RenewMembershipSheet(member: m),
    ),
  );
  if (result == null || !context.mounted) return;

  final state = await _dispatch(
    context,
    RenewMembershipEvent(
      id: m.id,
      planId: result.planId,
      startOverride: result.startOverride,
      paidAmount: result.paidAmount ?? 0,
      paymentMethod: result.paymentMethod ?? '',
      notes: result.notes ?? '',
      receiptPath: result.receiptPath, // add this field (see notes)
    ),
    isDone: (s) =>
        s is RenewMembershipSuccessState || s is RenewMembershipFailureState,
  );
  if (!context.mounted) return;
  _finish(
    context,
    failure: state is RenewMembershipFailureState ? state.failure : null,
    memberId: m.id,
    successMessage: state is RenewMembershipSuccessState
        ? state.renew.message
        : 'Membership renewed',
  );
}
