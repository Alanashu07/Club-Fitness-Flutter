import 'package:flutter/material.dart';
import 'package:club_fitness/core/constants/constants.dart';
import 'package:shimmer/shimmer.dart';

class LoadingWidget extends StatelessWidget {
  final double? width;
  final double? height;
  final double curveRadius;
  final Color? color;
  final Color? highlightColor;

  const LoadingWidget({
    super.key,
    this.width,
    this.height,
    this.curveRadius = 0,
    this.color,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: color ?? Colors.grey.shade300,
      highlightColor: highlightColor ?? Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        constraints: width != null || height != null
            ? null
            : BoxConstraints(
                minWidth: 5.percentToWidth,
                minHeight: 5.percentToHeight,
              ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(curveRadius),
        ),
      ),
    );
  }
}
