import 'package:flutter/material.dart';

class DashedBorderContainer extends StatelessWidget {
  const DashedBorderContainer({
    super.key,
    required this.child,
    this.color = Colors.black,
    this.strokeWidth = 1,
    this.radius = 12,
    this.dashWidth = 6,
    this.dashSpace = 4,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final Color color;
  final double strokeWidth;
  final double radius;
  final double dashWidth;
  final double dashSpace;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: color,
        strokeWidth: strokeWidth,
        radius: radius,
        dashWidth: dashWidth,
        dashSpace: dashSpace,
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.radius,
    required this.dashWidth,
    required this.dashSpace,
  });

  final Color color;
  final double strokeWidth;
  final double radius;
  final double dashWidth;
  final double dashSpace;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rect);

    final dashedPath = _createDashedPath(
      path,
      dashWidth,
      dashSpace,
    );

    canvas.drawPath(dashedPath, paint);
  }

  Path _createDashedPath(
    Path source,
    double dashWidth,
    double dashSpace,
  ) {
    final dashedPath = Path();

    for (final metric in source.computeMetrics()) {
      double distance = 0;

      while (distance < metric.length) {
        final nextDistance = distance + dashWidth;

        dashedPath.addPath(
          metric.extractPath(
            distance,
            nextDistance.clamp(0, metric.length),
          ),
          Offset.zero,
        );

        distance += dashWidth + dashSpace;
      }
    }

    return dashedPath;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}