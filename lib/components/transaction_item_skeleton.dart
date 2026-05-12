import 'package:flutter/material.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:shimmer/shimmer.dart';

const Duration _shimmerPeriod = Duration(milliseconds: 1800);

class DayHeaderSkeleton extends StatelessWidget {
  const DayHeaderSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          top: ThemePaddings.normalPadding,
          bottom: ThemePaddings.smallPadding),
      child: Shimmer.fromColors(
        baseColor: LightThemeColors.shimmerBase,
        highlightColor: LightThemeColors.shimmerHighlight,
        period: _shimmerPeriod,
        child: Container(
          width: 80,
          height: 14,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: LightThemeColors.shimmerBase,
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
    Widget bar(double width, double height) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: LightThemeColors.shimmerBase,
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
          baseColor: LightThemeColors.shimmerBase,
          highlightColor: LightThemeColors.shimmerHighlight,
          period: _shimmerPeriod,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: LightThemeColors.shimmerBase,
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
