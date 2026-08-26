import 'package:flutter/material.dart';
import 'package:club_fitness/core/constants/constants.dart';

import 'common_widgets.dart';

class CircleSvgText extends StatelessWidget {
  final String icon;
  final String text;
  final Color color;
  final Color boxColor;
  final bool bold;
  final double maxWidthPercentage;
  const CircleSvgText({
    super.key,
    required this.icon,
    required this.text,
    this.color = Colors.black54,
    this.bold = true,
    this.boxColor = const Color(0xFFF5F5F5),
    this.maxWidthPercentage = 70,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 8.w,
      children: [
        SolidButton(
          color: boxColor,
          curveRadius: context.width,
          padding: 6.w.all,
          child: SvgImage(icon, size: 14.w, color: color),
        ),
        Container(
          constraints: BoxConstraints(
            maxWidth: context.percentToWidth(maxWidthPercentage),
          ),
          child: TextWidget(text, fontSize: 14.sp, color: color, bold: bold),
        ),
      ],
    );
  }
}
