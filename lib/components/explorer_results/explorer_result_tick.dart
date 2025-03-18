import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:qubic_wallet/components/gradient_foreground.dart';
import 'package:qubic_wallet/dtos/explorer_query_dto.dart';
import 'package:qubic_wallet/extensions/asThousands.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/date_formatter.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/explorer/explorer_result_page.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

class ExplorerResultTick extends StatelessWidget {
  final ExplorerQueryDto item;

  const ExplorerResultTick({super.key, required this.item});

  Widget getInfoLabel(BuildContext context, String text) {
    return Text(text,
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            fontWeight: FontWeight.bold, fontFamily: ThemeFonts.secondary));
  }

  //Get the tick description by parsing formatted output from the API
  Widget getDateTimeFromTickDescription(
      BuildContext context, String tickDescription) {
    final l10n = l10nOf(context);

    try {
      String cleaned =
          tickDescription.replaceAll("Tick: ", "").replaceAll("from ", "");
      List<String> parts = cleaned.split(" ");
      int tickNumber = int.parse(parts[0]);
      String unparsedDate = parts[1];
      String unparsedTime = parts[2];

      List<int> dateParts =
          unparsedDate.split("/").map((e) => int.parse(e)).toList();
      List<int> timeParts =
          unparsedTime.split(":").map((e) => int.parse(e)).toList();

      DateTime date = DateTime.utc(dateParts[2], dateParts[1], dateParts[0],
          timeParts[0], timeParts[1], timeParts[1]);

      return Column(children: [
        Flex(
            direction: Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  flex: 2, child: getInfoLabel(context, l10n.generalLabelTick)),
              Expanded(flex: 10, child: Text(tickNumber.asThousands()))
            ]),
        Flex(
            direction: Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  flex: 2, child: getInfoLabel(context, l10n.generalLabelDate)),
              Expanded(
                  flex: 10,
                  child:
                      Text(DateFormatter.formatShortWithTime(date.toLocal())))
            ])
      ]);
    } catch (e) {
      return Column(children: [
        Flex(
            direction: Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  flex: 2, child: getInfoLabel(context, l10n.generalLabelInfo)),
              Expanded(flex: 10, child: Text(tickDescription))
            ])
      ]);
    }
  }

  Widget getCardButtons(BuildContext context, ExplorerQueryDto info) {
    final l10n = l10nOf(context);

    return Row(children: [
      ThemedControls.primaryButtonNormal(
          onPressed: () {
            pushScreen(
              context,
              screen: ExplorerResultPage(
                  resultType: ExplorerResultType.tick, tick: info.tick),

              withNavBar: false, // OPTIONAL VALUE. True by default.
              pageTransitionAnimation: PageTransitionAnimation.cupertino,
            );
          },
          text: l10n.transactionItemButtonViewDetails)
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);

    return ThemedControls.card(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Row(children: [
        const GradientForeground(child: Icon(Icons.grid_view)),
        Text(" ${l10n.generalLabelTick}", style: TextStyles.labelText),
      ]),
      const SizedBox(height: ThemePaddings.normalPadding),
      getDateTimeFromTickDescription(context, item.description ?? "-"),
      ThemedControls.spacerVerticalNormal(),
      getCardButtons(context, item)
    ]));
  }
}
