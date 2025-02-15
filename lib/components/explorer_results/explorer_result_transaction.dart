import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:qubic_wallet/components/gradient_foreground.dart';
import 'package:qubic_wallet/dtos/explorer_query_dto.dart';
import 'package:qubic_wallet/extensions/asThousands.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/explorer/explorer_result_page.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

class ExplorerResultTransaction extends StatelessWidget {
  final ExplorerQueryDto item;

  const ExplorerResultTransaction({super.key, required this.item});

  Widget getInfoLabel(BuildContext context, String text) {
    return Text(text,
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            fontWeight: FontWeight.bold, fontFamily: ThemeFonts.secondary));
  }

  Widget getCardButtons(BuildContext context, ExplorerQueryDto info) {
    final l10n = l10nOf(context);

    return Row(children: [
      ThemedControls.primaryButtonNormal(
        onPressed: () {
          pushScreen(
            context,
            screen: ExplorerResultPage(
                resultType: ExplorerResultType.tick,
                tick: info.tick,
                focusedTransactionHash: item.id),

            withNavBar: false, // OPTIONAL VALUE. True by default.
            pageTransitionAnimation: PageTransitionAnimation.cupertino,
          );
        },
        text: l10n.transactionItemButtonViewDetails,
      )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);

    return ThemedControls.card(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Row(children: [
        const GradientForeground(child: Icon(Icons.compare_arrows)),
        Text(" ${l10n.generalLabelTransaction}", style: TextStyles.labelText),
      ]),
      ThemedControls.spacerVerticalNormal(),
      Flex(
          direction: Axis.horizontal,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                flex: 2, child: getInfoLabel(context, l10n.generalLabelID)),
            Expanded(flex: 10, child: Text(item.id)),
          ]),
      Flex(direction: Axis.horizontal, children: [
        Expanded(flex: 2, child: getInfoLabel(context, l10n.generalLabelTick)),
        Expanded(
            flex: 10,
            child: Text(item.description != null
                ? int.parse(item.description!.replaceAll("Tick: ", ""))
                    .asThousands()
                : "")),
      ]),
      ThemedControls.spacerVerticalNormal(),
      getCardButtons(context, item)
    ]));
  }
}
