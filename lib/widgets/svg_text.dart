import 'package:flutter/material.dart';
import 'package:club_fitness/core/constants/constants.dart';
import 'package:club_fitness/widgets/common_widgets.dart';

class SvgText extends StatelessWidget {
  final String icon;
  final String text;
  final Color color;
  final bool bold;
  final double maxWidthPercentage;
  final double size;
  final Color? textColor;
  final double? textSize;
  final double spacing;
  final bool revert;

  const SvgText({
    super.key,
    required this.icon,
    required this.text,
    this.color = Colors.black54,
    this.bold = true,
    this.maxWidthPercentage = 70,
    this.size = 14,
    this.textColor,
    this.textSize,
    this.revert = false,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: spacing.w,
      children: [
        if (!revert) SvgImage(icon, size: size.w, color: color),
        Container(
          constraints: BoxConstraints(
            maxWidth: context.percentToWidth(maxWidthPercentage),
          ),
          child: TextWidget(
            text,
            fontSize: textSize?.sp ?? size.sp,
            color: textColor ?? color,
            bold: bold,
          ),
        ),
        if (revert) SvgImage(icon, size: size.w, color: color),
      ],
    );
  }
}

class ExpandedSvgText extends StatelessWidget {
  final String icon;
  final String text;
  final Color color;
  final bool bold;
  final double maxWidthPercentage;
  final double size;
  final Color? textColor;
  final double? textSize;
  final double spacing;
  final bool revert;

  const ExpandedSvgText({
    super.key,
    required this.icon,
    required this.text,
    this.color = Colors.black54,
    this.bold = true,
    this.maxWidthPercentage = 70,
    this.size = 14,
    this.textColor,
    this.textSize,
    this.revert = false,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: spacing.w,
      children: [
        if (!revert) SvgImage(icon, size: size.w, color: color),
        Expanded(
          child: TextWidget(
            text,
            fontSize: textSize?.sp ?? size.sp,
            color: textColor ?? color,
            bold: bold,
            maxLines: null,
          ),
        ),
        if (revert) SvgImage(icon, size: size.w, color: color),
      ],
    );
  }
}
