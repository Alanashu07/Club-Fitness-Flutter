import 'package:club_fitness/config/theme/theme.dart';
import 'package:flutter/material.dart';

import '../../core/constants/constants.dart';

class SolidButton extends StatelessWidget {
  final double? height;
  final double? width;
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final Color color;
  final Color borderColor;
  final double margin;
  final double curveRadius;
  final List<BoxShadow>? shadows;
  final VoidCallback? onTap;
  final double borderThickness;
  final bool blockAlignment;
  final bool disabled;

  const SolidButton({
    super.key,
    this.height,
    this.width,
    this.child,
    this.margin = 0,
    this.curveRadius = 12,
    this.color = AppTheme.primary,
    this.borderColor = Colors.transparent,
    this.onTap,
    this.padding,
    this.shadows,
    this.borderThickness = 1.0,
    this.blockAlignment = false,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin.all,
      child: Material(
        color: disabled ? Colors.grey : color,
        borderRadius: BorderRadius.circular(curveRadius),
        elevation: shadows != null ? 2 : 0,
        // optional: mimic boxShadow with elevation
        shadowColor: shadows?.first.color,
        child: InkWell(
          borderRadius: BorderRadius.circular(curveRadius),
          onTap: disabled ? null : onTap,
          child: Container(
            height: height,
            width: width,
            padding: padding,
            alignment: blockAlignment ? null : Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(curveRadius),
              border: Border.all(color: borderColor, width: borderThickness),
              boxShadow: shadows,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
