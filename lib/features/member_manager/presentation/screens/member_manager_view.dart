import 'dart:async';

import 'package:club_fitness/config/navigation/routes_class.dart';
import 'package:club_fitness/config/theme/theme.dart';
import 'package:club_fitness/core/services/url_services.dart';
import 'package:club_fitness/core/utils/utils.dart';
import 'package:club_fitness/features/member_manager/member_manager.dart';
import 'package:club_fitness/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  Timer? _debounceTimer;
  Summary? _summary;

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

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _fadeCtrl.dispose();
    _searchCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
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

  void _debounceQuery() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), _refreshMembers);
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
            child: LiquidRefresh(
              onRefresh: () => _refreshMembers(),
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
                          _buildSortRow(
                            summary.total.toInt() + _members.length,
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                  _buildListSliver(state, members),
                ],
              ),
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
          (_, i) => MemberCard(
            member: members[i],
            onTap: () => _openMemberDetail(members[i]),
            onDelete: () => deleteMember(context, null, members[i]),
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
        textCapitalization: TextCapitalization.words,
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
                    _refreshMembers();
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
          return SelectChip(
            label: f,
            selected: _selectedFilter == f,
            small: true,
            onTap: () {
              setState(() => _selectedFilter = f);
              _refreshMembers();
            },
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
    final result = await showModalBottomSheet<AddMemberResult?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddMemberSheet(),
    );
    if (result == null || !mounted) return;
    setState(() => _members.insert(0, result.member));

    final send = await confirmDialog(
      context,
      icon: Icons.chat_rounded,
      color: const Color(0xFF25D366),
      title: 'Member Added',
      prefix: '',
      highlight: result.name,
      suffix: ' was added successfully. Send a welcome message on WhatsApp?',
      confirmLabel: 'Send on WhatsApp',
      cancelLabel: 'Skip',
    );
    if (!send || !mounted) return;

    await UrlServices.whatsappMessage(
      number: normalizePhone(result.phone),
      message: buildWelcomeMessage(result),
    );
  }

  void _openMemberDetail(MemberListEntity m) async {
    await context.pushNamed(
      RoutesName.memberDetails,
      pathParameters: {'id': m.id},
    );
    if (!mounted) return;
    _refreshMembers();
  }

  void _sendEmailReminder(BuildContext context, MemberListEntity m) async {
    final state = await dispatchMemberAction(
      context,
      SendReminderEvent(m.id),
      isDone: (s) =>
          s is SendReminderSuccessState || s is SendReminderFailureState,
    );
    if (!context.mounted) return;
    finishMemberAction(
      context,
      failure: state is SendReminderFailureState ? state.failure : null,
      memberId: null,
      successMessage: state is SendReminderSuccessState
          ? state.message
          : '${m.name} has been reminded about due.',
    );
    return;
  }

  void _sendReminder(MemberListEntity m) {
    showSendReminderDialog(
      context,
      name: m.name,
      onEmail: () => _sendEmailReminder(context, m),
      onWhatsapp: () => UrlServices.whatsappMessage(
        number: normalizePhone(m.phone),
        message: buildReminderMessage(null, m),
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
      builder: (_) => AdvancedFilterSheet(activeFilters: activeFilters),
    );
  }
}
