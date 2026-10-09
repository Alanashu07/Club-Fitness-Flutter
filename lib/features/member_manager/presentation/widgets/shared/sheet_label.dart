
import 'package:club_fitness/config/theme/theme.dart';
import 'package:flutter/material.dart';

class SheetLabel extends StatelessWidget {
  final String text;
  const SheetLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppTheme.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
      ),
    );
  }
}