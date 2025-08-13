import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qubic_wallet/dtos/explorer_id_info_dto.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

class ExplorerResultPageQubicIdHeader extends StatelessWidget {
  final ExplorerIdInfoDto idInfo;
  final DateFormat formatter = DateFormat('dd MMM yyyy \'at\' HH:mm:ss');
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

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Column(children: [
        ThemedControls.pageHeader(
            headerText: l10n.accountExplorerTitle, subheaderText: idInfo.id),
        ThemedControls.spacerVerticalNormal()
      ])
    ]);
  }
}
