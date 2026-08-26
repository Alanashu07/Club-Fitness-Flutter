import 'dart:ui';

import 'package:flutter/material.dart';

class DottedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final double radius;

  DottedBorderPainter({
    this.color = Colors.black,
    this.strokeWidth = 2.0,
    this.dashWidth = 5.0,
    this.dashSpace = 3.0,
    this.radius = 8.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rRect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    final path = Path()..addRRect(rRect);

    // Dash the path
    final dashPath = _createDashedPath(path, dashWidth, dashSpace);
    canvas.drawPath(dashPath, paint);
  }

  /// Creates a dashed version of a given path
  Path _createDashedPath(Path source, double dashWidth, double dashSpace) {
    final Path dashedPath = Path();
    final PathMetrics pathMetrics = source.computeMetrics(forceClosed: true);

    for (final metric in pathMetrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double end = distance + dashWidth;
        dashedPath.addPath(
          metric.extractPath(distance, end.clamp(0.0, metric.length)),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }

    return dashedPath;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
