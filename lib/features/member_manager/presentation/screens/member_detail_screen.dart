import 'package:club_fitness/config/navigation/routes_class.dart';
import 'package:club_fitness/config/theme/theme.dart';
import 'package:club_fitness/core/entities/member_status.dart';
import 'package:club_fitness/core/utils/utils.dart';
import 'package:club_fitness/features/admin_utils/domain/entities/admin_utils_entities.dart';
import 'package:club_fitness/features/member_manager/member_manager.dart';
import 'package:club_fitness/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MemberDetailScreen extends StatelessWidget {
  final String memberId;
  const MemberDetailScreen({super.key, required this.memberId});

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
          return LiquidRefresh(
            onRefresh: () => context.read<MemberDetailBloc>().add(
              GetMemberDetailsEvent(memberId),
            ),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── Profile header ──────────────────────────────────────────
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
                            child: AddMemberSheet(member: member),
                          ),
                        );
                        if (updated == true && context.mounted) {
                          context.read<MemberDetailBloc>().add(
                            GetMemberDetailsEvent(memberId),
                          );
                        }
                      },
                    ),
                    MemberActionsMenu(
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
                            AppTheme.primary.withAOpacity(0.18),
                            AppTheme.background,
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 80, 24, 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            MemberAvatar(
                              imageUrl: member.profileImageUrl,
                              initials: member.initials,
                              secondary: AppTheme.secondary,
                              primary: AppTheme.primary,
                              size: 72,
                              radius: 20,
                              fontSize: 24,
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
                                      StatusBadge(
                                        label: member.memberStatus.label,
                                        color: memberStatusColor(
                                          member.memberStatus,
                                        ),
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
                      _buildStatRow(member),
                      const SizedBox(height: 24),
                      _sectionTitle('Contact Information'),
                      const SizedBox(height: 12),
                      _buildInfoCard([
                        InfoRow(Icons.phone_rounded, 'Phone', member.phone),
                        InfoRow(Icons.email_rounded, 'Email', member.email),
                        InfoRow(
                          Icons.person_rounded,
                          'Trainer',
                          member.assignedTrainer,
                        ),
                      ]),
                      const SizedBox(height: 20),
                      _sectionTitle('Device Information'),
                      const SizedBox(height: 12),
                      _buildInfoCard([
                        InfoRow(Icons.pin, 'Device Pin', member.devicePin),
                        InfoRow(
                          Icons.lock,
                          'Status',
                          member.blocked ? 'Blocked' : 'Active',
                        ),
                      ]),
                      const SizedBox(height: 20),
                      _sectionTitle('Membership'),
                      const SizedBox(height: 12),
                      _buildMembershipCard(member),
                      const SizedBox(height: 20),
                      _sectionTitle('Fee History'),
                      const SizedBox(height: 12),
                      _buildFeeHistory(feeHistory),
                      const SizedBox(height: 20),
                      if (state.detail.offerRedemptions.isNotEmpty) ...[
                        _sectionTitle('Offers Used'),
                        const SizedBox(height: 12),
                        _buildOffers(state.detail.offerRedemptions),
                        const SizedBox(height: 20),
                      ],
                      _sectionTitle('Recent Attendance'),
                      const SizedBox(height: 12),
                      _buildAttendance(attendance),
                      const SizedBox(height: 20),
                      _sectionTitle('Actions'),
                      const SizedBox(height: 12),
                      _buildActions(context, member, feeHistory.firstOrNull),
                      const SizedBox(height: 20),
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _iconTile(IconData icon, {Color color = AppTheme.textSecondary}) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white.withAOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }

  BoxDecoration get _cardDecoration => BoxDecoration(
    color: AppTheme.card,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Colors.white.withAOpacity(0.05), width: 1),
  );

  Widget _buildOffers(List<OfferRedemptionEntity> items) {
    return Container(
      decoration: _cardDecoration,
      child: Column(
        children: items.mapIndexed((i, o) {
          final d = o.redeemedAt.toDateTime;
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
                _iconTile(Icons.local_offer_rounded),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        o.offerName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      if (o.offerCode.orNull() != null)
                        Text(
                          'Code: ${o.offerCode}',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  '${d.monthShort} ${d.day}, ${d.year}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAttendance(List<AttendanceEntity> attendance) {
    if (attendance.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: _cardDecoration,
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
      decoration: _cardDecoration,
      child: Column(
        children: items.mapIndexed((i, a) {
          final checkIn = a.checkInAt.toDateTime;
          final checkOut = a.checkOutAt.isNotEmpty
              ? a.checkOutAt.toDateTime
              : null;
          final date = "${checkIn.monthShort} ${checkIn.day}, ${checkIn.year}";
          final timeRange = checkOut == null
              ? '${formatTime(checkIn)} - In gym'
              : '${formatTime(checkIn)} - ${formatTime(checkOut)}';
          final duration = checkOut == null
              ? null
              : formatDuration(checkOut.difference(checkIn));

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
                _iconTile(Icons.how_to_reg_rounded),
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

  Widget _buildStatRow(MemberEntity member) {
    final items = [
      (
        member.workoutStreak > 0 ? '${member.workoutStreak}d' : '—',
        'Streak',
        Icons.local_fire_department_rounded,
      ),
      (
        member.checkedInToday ? 'Yes' : 'No',
        'Here Today',
        Icons.how_to_reg_rounded,
      ),
      (
        member.daysLeft > 0 ? '${member.daysLeft}d' : '${-member.daysLeft}d',
        member.daysLeft > 0 ? 'Days Left' : 'Overdue',
        Icons.timer_rounded,
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
              border: Border.all(color: AppTheme.cardBorder, width: 1),
            ),
            child: Column(
              children: [
                Icon(s.$3, color: AppTheme.textSecondary, size: 18),
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

  Widget _buildInfoCard(List<InfoRow> rows) {
    return Container(
      decoration: _cardDecoration,
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
        border: Border.all(color: AppTheme.cardBorder, width: 1),
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
          Text(
            member.daysLeft > 0
                ? '${member.daysLeft} days remaining'
                : 'Membership expired',
            style: TextStyle(
              color: member.daysLeft < 7 ? AppTheme.error : Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
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
      decoration: _cardDecoration,
      child: Column(
        children: history.mapIndexed((i, h) {
          DateTime paidDate = h.paidDate.toDateTime;
          String date =
              "${paidDate.monthShort} ${paidDate.day}, ${paidDate.year}";
          return InkWell(
            onTap: () => RoutesClass.context!.pushNamed(
              RoutesName.feeDetails,
              pathParameters: {'id': h.id},
            ),
            child: Container(
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
                  _iconTile(Icons.receipt_long_rounded),
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
                      if (h.discountAmount > 0)
                        Text(
                          '-₹${h.discountAmount} off',
                          style: const TextStyle(
                            color: AppTheme.success,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
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
    const neutral = AppTheme.secondary;
    return [
      (
        'Assign Workout',
        Icons.fitness_center_rounded,
        neutral,
        () => context.pushNamed(
          RoutesName.assignWorkout,
          queryParameters: {'memberId': m.id},
        ),
      ),
      if (m.membershipEndDate.isBefore(DateTime.now()))
        (
          'Send Reminder',
          Icons.notifications_rounded,
          neutral,
          null, // no reminder event in MembersActionsBloc yet
        ),
      if (lastFee != null && lastFee.statusEnum == FeeStatus.pending)
        (
          'Mark Fee Paid',
          Icons.payments_rounded,
          neutral,
          null, // no mark-paid event in MembersActionsBloc yet
        ),
      if (canSuspend)
        (
          'Suspend Member',
          Icons.block_rounded,
          neutral,
          () => suspendMember(context, m),
        )
      else
        (
          'Reactivate Member',
          Icons.check_rounded,
          neutral,
          () => reactivateMember(context, m),
        ),
      (
        'Renew Membership',
        Icons.more_time_rounded,
        AppTheme.success,
        () => renewMember(context, m),
      ),
      (
        'Revert Last Renewal',
        Icons.undo_rounded,
        neutral,
        () => revertLastRenewal(context, m),
      ),
      (
        'Delete Member',
        Icons.delete_rounded,
        AppTheme.error,
        () => deleteMember(context, m, null),
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
                  border: Border.all(
                    color: a.$3 == AppTheme.textSecondary
                        ? AppTheme.cardBorder
                        : a.$3.withAOpacity(0.35),
                    width: 1,
                  ),
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