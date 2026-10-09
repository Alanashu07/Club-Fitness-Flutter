
import 'package:club_fitness/config/theme/theme.dart';
import 'package:club_fitness/features/member_manager/member_manager.dart';
import 'package:flutter/material.dart';

class DeleteModeSheet extends StatelessWidget {
  final String memberName;
  const DeleteModeSheet({super.key, required this.memberName});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SheetHandle(),
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
            DeleteOptionTile(
              icon: Icons.person_off_rounded,
              color: AppTheme.textSecondary,
              title: 'Deactivate',
              badge: 'RECOMMENDED',
              description:
                  'Blocks gym access and marks the member as suspended. Fees, attendance and history are kept. Removes face template from enrollment. Can be reversed anytime. Need face re-enrollment after reactivation.',
              onTap: () => Navigator.pop(context, DeleteMode.deactivate),
            ),
            const SizedBox(height: 12),
            DeleteOptionTile(
              icon: Icons.delete_forever_rounded,
              color: AppTheme.error,
              title: 'Delete permanently',
              description:
                  'Erases the member and all their fees, orders, bookings, attendance and measurements. This cannot be undone.',
              onTap: () => Navigator.pop(context, DeleteMode.permanent),
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