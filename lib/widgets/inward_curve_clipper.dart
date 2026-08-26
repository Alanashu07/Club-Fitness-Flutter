import 'package:flutter/material.dart';

class InwardCurveClipper extends CustomClipper<Path> {
  final double curveRadius;
  final double width;

  InwardCurveClipper({this.curveRadius = 40, this.width = 30});

  @override
  Path getClip(Size size) {
    final path = Path();

    // Start at top-left
    path.moveTo(0, 0);

    // Line to before U
    final startX = (size.width - width) / 2;
    final endX = (size.width + width) / 2;
    path.lineTo(startX, 0);

    // Deep U shape
    path.cubicTo(
      startX + width * 0.25,
      0,
      startX + width * 0.25,
      curveRadius,
      startX + width * 0.5,
      curveRadius,
    );
    path.cubicTo(
      endX - width * 0.25,
      curveRadius,
      endX - width * 0.25,
      0,
      endX,
      0,
    );

    // Continue normal
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
