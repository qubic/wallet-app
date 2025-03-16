import 'package:flutter/material.dart';
import 'package:qubic_wallet/components/amount_formatted.dart';
import 'package:qubic_wallet/dtos/explorer_id_info_dto.dart';
import 'package:qubic_wallet/extensions/asThousands.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

class ExplorerResultPageQubicIdHeader extends StatelessWidget {
  final ExplorerIdInfoDto idInfo;
  ExplorerResultPageQubicIdHeader({super.key, required this.idInfo});

  Widget incPanel(String title, String contents, BuildContext context) {
    final l10n = l10nOf(context);
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: LightThemeColors.cardBackground,
        ),
        child: Padding(
            padding: const EdgeInsets.all(ThemePaddings.smallPadding),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(title, style: TextStyles.secondaryTextSmall)),
                  FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(children: [
                        Text(contents, style: TextStyles.textExtraLargeBold),
                        ThemedControls.spacerHorizontalMini(),
                        Text(l10n.generalLabelCurrencyQubic,
                            style: TextStyles.secondaryTextSmall)
                      ]))
                ])));
  }

  //Shows the report of a peer. If IPs are specified
  //they are included
  Widget getPeerReport(
      BuildContext context,
      ExplorerIdInfoReportedValueDto info,
      // ignore: non_constant_identifier_names
      List<String>? IPs) {
    final l10n = l10nOf(context);
    TextStyle panelHeaderStyleMany = Theme.of(context)
        .textTheme
        .titleMedium!
        .copyWith(fontFamily: ThemeFonts.secondary);
    return Container(
        width: double.infinity,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          IPs != null
              ? Text(l10n.accountExplorerLabelCurrentValue,
                  style: TextStyles.secondaryTextSmall)
              : Text(l10n.accountExplorerLabelValueReportedBy(info.IP),
                  style: panelHeaderStyleMany),
          FittedBox(
              fit: BoxFit.scaleDown,
              child: AmountFormatted(
                  amount: info.incomingAmount - info.outgoingAmount,
                  isInHeader: false,
                  labelOffset: -0,
                  textStyle: TextStyles.textEnormous.copyWith(fontSize: 36),
                  labelStyle: TextStyles.accountAmountLabel,
                  currencyName: l10n.generalLabelCurrencyQubic)),
          ThemedControls.spacerVerticalSmall(),
          Row(children: [
            Expanded(
                child: incPanel(l10n.accountExplorerLabelTotalIncoming,
                    info.incomingAmount.asThousands().toString(), context)),
            ThemedControls.spacerHorizontalMini(),
            Expanded(
                child: incPanel(l10n.accountExplorerLabelTotalOutgoing,
                    info.outgoingAmount.asThousands().toString(), context)),
          ]),
          ThemedControls.spacerVerticalSmall(),
          IPs != null
              ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l10n.accountExplorerLabelReportedBy,
                      style: TextStyles.secondaryTextSmall,
                      textAlign: TextAlign.start),
                  Text(IPs.join(", "))
                ])
              : Container(),
        ]));
  }

  List<Widget> showPeerReports(BuildContext context) {
    List<Widget> output = [];
    if (!idInfo.areReportedValuesEqual) {
      for (var element in idInfo.reportedValues) {
        output.add(getPeerReport(context, element, null));
      }
    } else {
      output.add(
          getPeerReport(context, idInfo.reportedValues[0], idInfo.reportedIPs));
    }
    return output;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Column(children: [
        ThemedControls.pageHeader(
            headerText: l10n.accountExplorerTitle, subheaderText: idInfo.id),
        Column(children: showPeerReports(context)),
        ThemedControls.spacerVerticalNormal()
      ])
    ]);
  }
}
