import 'package:club_fitness/config/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class LiquidRefresh extends StatelessWidget {
  final VoidCallback onRefresh;

  final Widget child;
  final Color backgroundColor;
  final Color color;

  const LiquidRefresh({
    super.key,
    required this.onRefresh,
    required this.child,
    this.backgroundColor = AppTheme.surface,
    this.color = AppTheme.primary,
  });

  @override
  Widget build(BuildContext context) {
    return LiquidPullToRefresh(
      onRefresh: () async {
        onRefresh();
      },
      animSpeedFactor: 2,
      backgroundColor: backgroundColor,
      color: color,
      showChildOpacityTransition: false,
      child: child,
    );
  }
}
