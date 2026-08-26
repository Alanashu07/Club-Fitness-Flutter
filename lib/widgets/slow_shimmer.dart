import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SlowShimmer extends StatelessWidget {
  final double? width;
  final double? height;
  final double curveRadius;
  final Color? color;
  final Color? highlightColor;
  final Widget child;
  final int slowSeconds;

  const SlowShimmer({
    super.key,
    this.width,
    this.height,
    this.curveRadius = 0,
    this.color,
    this.highlightColor,
    required this.child,
    this.slowSeconds = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Shimmer.fromColors(
          baseColor: Colors.transparent,
          highlightColor: (highlightColor ?? Colors.white).withAlpha(60),
          period: Duration(seconds: slowSeconds),
          child: child,
        ),
      ],
    );
  }
}
