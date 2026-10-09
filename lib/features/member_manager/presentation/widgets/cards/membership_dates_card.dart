
import 'package:club_fitness/config/theme/theme.dart';
import 'package:club_fitness/features/member_manager/member_manager.dart';
import 'package:flutter/material.dart';

class MembershipDatesCard extends StatelessWidget {
  final DateTime start;
  final DateTime? end;
  final bool startIsAuto;
  final String autoStartHint;
  final VoidCallback onTapStart;
  final VoidCallback? onResetStart;

  const MembershipDatesCard({
    super.key,
    required this.start,
    required this.end,
    required this.startIsAuto,
    required this.autoStartHint,
    required this.onTapStart,
    this.onResetStart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onTapStart,
              behavior: HitTestBehavior.opaque,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const SheetLabel('START DATE'),
                      const Spacer(),
                      if (!startIsAuto && onResetStart != null)
                        GestureDetector(
                          onTap: onResetStart,
                          child: const Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        size: 16,
                        color: AppTheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          formatShortDate(start),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    startIsAuto ? autoStartHint : 'Tap to change',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 1,
            height: 72,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: Colors.white10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SheetLabel('END DATE'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.event_available_rounded,
                      size: 16,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        end == null ? '—' : formatShortDate(end!),
                        style: TextStyle(
                          color: end == null
                              ? AppTheme.textSecondary
                              : Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  end == null ? 'Select a plan' : 'Auto-adjusted by plan',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}