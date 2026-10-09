
import 'package:club_fitness/config/theme/theme.dart';
import 'package:flutter/material.dart';

class PermanentDeleteDialog extends StatefulWidget {
  final String memberName;
  const PermanentDeleteDialog({super.key, required this.memberName});

  @override
  State<PermanentDeleteDialog> createState() => _PermanentDeleteDialogState();
}

class _PermanentDeleteDialogState extends State<PermanentDeleteDialog> {
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
