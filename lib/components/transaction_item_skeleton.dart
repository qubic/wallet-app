import 'package:flutter/material.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:shimmer/shimmer.dart';

const Duration _shimmerPeriod = Duration(milliseconds: 1800);

Color _shimmerBase(BuildContext context) =>
    Theme.of(context).textTheme.titleMedium!.color!.withValues(alpha: 0.18);

Color _shimmerHighlight(BuildContext context) =>
    Theme.of(context).textTheme.titleMedium!.color!.withValues(alpha: 0.75);

class DayHeaderSkeleton extends StatelessWidget {
  const DayHeaderSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final fill = _shimmerBase(context);
    return Padding(
      padding: const EdgeInsets.only(
          top: ThemePaddings.normalPadding,
          bottom: ThemePaddings.smallPadding),
      child: Shimmer.fromColors(
        baseColor: fill,
        highlightColor: _shimmerHighlight(context),
        period: _shimmerPeriod,
        child: Container(
          width: 80,
          height: 14,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: fill,
          ),
        ),
      ),
    );
  }
}

class TransactionItemSkeleton extends StatelessWidget {
  const TransactionItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final fill = _shimmerBase(context);

    Widget bar(double width, double height) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: fill,
        ),
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 400, maxWidth: 500),
      child: ThemedControls.card(
        padding: const EdgeInsets.only(
            left: ThemePaddings.smallPadding,
            right: ThemePaddings.normalPadding,
            top: ThemePaddings.mediumPadding,
            bottom: ThemePaddings.mediumPadding),
        child: Shimmer.fromColors(
          baseColor: fill,
          highlightColor: _shimmerHighlight(context),
          period: _shimmerPeriod,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: fill,
                ),
              ),
              const SizedBox(width: ThemePaddings.smallPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        bar(110, 12),
                        bar(70, 12),
                      ],
                    ),
                    const SizedBox(height: 6),
                    bar(180, 12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
