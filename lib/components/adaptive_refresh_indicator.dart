import 'package:flutter/material.dart';

class AdaptiveRefreshIndicator extends StatelessWidget {
  final Future Function() onRefresh;
  final Widget child;
  final double edgeOffset;
  final Color? backgroundColor;
  const AdaptiveRefreshIndicator(
      {super.key,
      required this.onRefresh,
      required this.child,
      this.backgroundColor,
      this.edgeOffset = 0});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator.adaptive(
      edgeOffset: edgeOffset,
      onRefresh: onRefresh,
      child: child,
    );
  }
}
