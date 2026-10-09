
import 'package:club_fitness/config/theme/theme.dart';
import 'package:flutter/material.dart';

class MemberActionsMenu extends StatelessWidget {
  final List<(String, IconData, Color, void Function()?)> actions;
  const MemberActionsMenu({super.key, required this.actions});

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
