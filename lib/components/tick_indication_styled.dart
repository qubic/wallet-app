import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/extensions/asThousands.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/l10n/l10n.dart';

import '../stores/application_store.dart';

class TickIndicatorStyled extends StatelessWidget {
  final ApplicationStore appStore = getIt<ApplicationStore>();
  final TextStyle textStyle;
  TickIndicatorStyled({super.key, required this.textStyle});

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);

    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(l10n.generalLabelTick, style: textStyle),
      Observer(builder: (context) {
        if (appStore.currentTick == 0) {
          return Text("...", style: textStyle);
        }
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: Text(
            ' ${appStore.currentTick.asThousands()}',
            style: textStyle,
            // This key causes the AnimatedSwitcher to interpret this as a "new"
            // child each time the count changes, so that it will begin its animation
            // when the count changes.
            key: ValueKey<String>("tck${appStore.currentTick}"),
          ),
        );
      }),
      Observer(builder: (context) {
        if (appStore.pendingRequests > 0) {
          return const SizedBox(
              width: 10,
              height: 10,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: LightThemeColors.buttonBackground));
        }

        return const SizedBox(width: 10, height: 10);
      })
    ]);
  }
}
