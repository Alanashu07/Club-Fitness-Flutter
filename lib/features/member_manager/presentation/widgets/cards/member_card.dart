import 'package:club_fitness/config/navigation/routes_class.dart';
import 'package:club_fitness/config/theme/theme.dart';
import 'package:club_fitness/core/utils/utils.dart';
import 'package:club_fitness/features/member_manager/member_manager.dart';
import 'package:flutter/material.dart';

class MemberCard extends StatelessWidget {
  final MemberListEntity member;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onSendReminder;

  const MemberCard({
    super.key,
    required this.member,
    required this.onTap,
    required this.onDelete,
    required this.onSendReminder,
  });

  @override
  Widget build(BuildContext context) {
    final expiringSoon = member.daysLeft < 7;
    final expiryColor = expiringSoon ? AppTheme.error : AppTheme.textSecondary;
    final feeColor = feeStatusColor(member.feeStatus);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: member.feeStatus == 'overdue'
                ? AppTheme.error.withAOpacity(0.25)
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
                  Stack(
                    children: [
                      MemberAvatar(
                        imageUrl: member.profileImageUrl,
                        initials: member.initials,
                        secondary: AppTheme.secondary,
                        primary: AppTheme.primary,
                        size: 48,
                        radius: 14,
                        fontSize: 15,
                      ),
                      if (member.checkedInToday)
                        Positioned(
                          right: -1,
                          top: -1,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: AppTheme.success,
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                member.name.capitalizeEachWord,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            StatusBadge(
                              label: member.memberStatus.label,
                              color: memberStatusColor(member.memberStatus),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
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
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 10,
                              color: expiryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              member.daysLeft > 0
                                  ? '${member.daysLeft}d left'
                                  : 'Expired ${(-member.daysLeft)}d ago',
                              style: TextStyle(
                                color: expiryColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: feeColor.withAOpacity(0.1),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                member.feeStatus.toUpperCase(),
                                style: TextStyle(
                                  color: feeColor,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            if (member.workoutStreak > 0) ...[
                              const Icon(
                                Icons.local_fire_department_rounded,
                                size: 11,
                                color: AppTheme.primary,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${member.workoutStreak}d',
                                style: const TextStyle(
                                  color: AppTheme.primary,
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
                  MemberActionButton(
                    icon: Icons.fitness_center_rounded,
                    label: 'Workout',
                    onTap: () => context.pushNamed(
                      RoutesName.assignWorkout,
                      queryParameters: {'memberId': member.id},
                    ),
                  ),
                  const MemberCardDivider(),
                  MemberActionButton(
                    icon: Icons.notifications_outlined,
                    label: 'Remind',
                    onTap: onSendReminder,
                  ),
                  const MemberCardDivider(),
                  MemberActionButton(
                    icon: Icons.payments_outlined,
                    label: 'Mark as Paid',
                    onTap: () {
                      if (member.feeStatus == 'paid') {
                        return context.showToast(
                          'Already paid',
                          message: '${member.name} has already paid their fee.',
                          type: ToastificationType.warning,
                        );
                      }
                      context.pushNamed(
                        RoutesName.feeDetails,
                        pathParameters: {'id': member.lastFee},
                        queryParameters: {'open-mark-paid-sheet': 'true'},
                      );
                    },
                  ),
                  const MemberCardDivider(),
                  MemberActionButton(
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
