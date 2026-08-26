import 'package:club_fitness/config/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:club_fitness/core/constants/constants.dart';

class GradientButton extends StatelessWidget {
  final List<Color>? colors;
  final Widget? child;
  final VoidCallback? onTap;
  final double? height;
  final double? width;
  final double? margin;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;

  const GradientButton({
    super.key,
    this.colors,
    this.child,
    this.onTap,
    this.height,
    this.width,
    this.margin,
    this.begin = Alignment.centerLeft,
    this.end = Alignment.centerRight,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: (margin ?? 0).all,
        height: height ?? 50,
        width: width ?? double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors:
                colors ?? [AppTheme.primary, AppTheme.secondary],
            begin: begin,
            end: end,
          ),
        ),
        child: child,
      ),
    );
  }
}
