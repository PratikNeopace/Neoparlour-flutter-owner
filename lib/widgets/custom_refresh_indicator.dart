import 'package:flutter/material.dart';

class CustomRefreshIndicator extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;
  final Color color;

  const CustomRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
    this.color = const Color(0XFFFF0B01), // Default app brand color
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: color,
      child: child,
    );
  }
}
