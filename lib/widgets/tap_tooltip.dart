import 'package:flutter/material.dart';

class TapTooltip extends StatelessWidget {
  final Widget child;
  final String message;
  TapTooltip({super.key, required this.child, required this.message});

  final GlobalKey<TooltipState> _tooltipKey = GlobalKey<TooltipState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _tooltipKey.currentState?.ensureTooltipVisible();
      },
      child: Tooltip(
        key: _tooltipKey,
        message: message,
        child: child,
      ),
    );
  }
}
