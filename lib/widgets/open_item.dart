import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

class OpenItem extends StatelessWidget {
  final Widget openChild;
  final Widget closedChild;

  const OpenItem(
      {super.key, required this.openChild, required this.closedChild});

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      openColor: Colors.transparent,
      closedColor: Colors.transparent,
      openElevation: 0,
      closedElevation: 0,
      closedBuilder: (context, action) => closedChild,
      openBuilder: (context, action) => openChild,
    );
  }
}
