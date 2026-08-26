import 'package:flutter/material.dart';

class Separator extends StatelessWidget {
  const Separator(
      {super.key,
      this.height = 1,
      this.color = Colors.black,
      this.dashWidth = 10,
      this.count = 2});

  final double height;
  final Color color;
  final double count;
  final double dashWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        final dashHeight = height;
        final dashCount = (boxWidth / (count * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
        );
      },
    );
  }
}

class VerticalSeparator extends StatelessWidget {
  const VerticalSeparator({
    super.key,
    this.width = 1,
    this.color = Colors.black,
    this.dashHeight = 10,
    this.count = 2,
  });

  final double width;
  final Color color;
  final double dashHeight;
  final double count;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxHeight = constraints.constrainHeight();
        final dashCount = (boxHeight / (count * dashHeight)).floor();

        return Flex(
          direction: Axis.vertical,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: width,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: color,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}