import 'dart:ui';

import 'package:flutter/material.dart';

class GlassBox extends StatelessWidget {
  final Color? color; // Background color with opacity
  final double blurX; // X-axis blur
  final double blurY; // Y-axis blur
  final BorderRadius? borderRadius;
  final BoxBorder? border;
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const GlassBox({
    super.key,
    this.color,
    this.blurX = 50.0,
    this.blurY = 50.0,
    this.borderRadius,
    this.border,
    this.child,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurX, sigmaY: blurY),
        child: Container(
          padding: padding,
          margin: margin,
          decoration: BoxDecoration(
            color: color ?? Colors.white.withAlpha(140),
            borderRadius: borderRadius ?? BorderRadius.circular(12),
            border: border,
          ),
          child: child,
        ),
      ),
    );
  }
}
