
import 'package:club_fitness/config/theme/theme.dart';
import 'package:flutter/material.dart';

class MemberCardDivider extends StatelessWidget {
  const MemberCardDivider({super.key});

  @override
  Widget build(BuildContext context) =>
      Container(width: 0.5, height: 36, color: Colors.white10);
}

class MemberActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const MemberActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppTheme.textSecondary,
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