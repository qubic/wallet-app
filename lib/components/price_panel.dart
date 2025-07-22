import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/styles/text_styles.dart';

class PricePanel extends StatelessWidget {
  final ApplicationStore appStore = getIt<ApplicationStore>();

  PricePanel({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return Observer(builder: (context) {
      final price = appStore.marketInfo?.price;
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: price == null
            ? const SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.all(ThemePaddings.smallPadding),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(l10n.homeHeaderQubicPrice,
                          style: TextStyles.secondaryTextSmall),
                      Text(" \$${price.toString()}",
                          style: TextStyles.textSmall.copyWith(
                            color: LightThemeColors.primary40,
                          ))
                    ])),
      );
    });
  }
}
