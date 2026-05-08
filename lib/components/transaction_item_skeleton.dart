import 'package:flutter/material.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

/// Placeholder cell that mimics the [TransactionItem] layout while
/// transaction data is loading. Used as the first-page progress indicator
/// in the transactions list to avoid a jarring spinner-to-cells transition
/// on initial load and pull-to-refresh.
class TransactionItemSkeleton extends StatelessWidget {
  const TransactionItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final fill = Theme.of(context)
        .textTheme
        .titleMedium!
        .color!
        .withValues(alpha: 0.08);

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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Badge placeholder
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
                      bar(110, 12), // type
                      bar(70, 12), // amount
                    ],
                  ),
                  const SizedBox(height: 6),
                  bar(180, 12), // from/to
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
