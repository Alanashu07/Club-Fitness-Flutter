import 'package:club_fitness/config/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:club_fitness/widgets/common_widgets.dart';

class LetterWidget extends StatelessWidget {
  final String letter;
  final int index;
  const LetterWidget({super.key, required this.letter, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppTheme.clampColor(index),
        shape: BoxShape.circle,
      ),
      child: TextWidget(
        letter.substring(0, 1),
        bold: true,
        color: Colors.white,
      ),
    );
  }
}
