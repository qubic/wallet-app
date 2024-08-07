import 'package:flutter/material.dart';

// ignore: unused_import
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:qubic_wallet/components/gradient_foreground.dart';
import 'package:qubic_wallet/dtos/explorer_query_dto.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/explorer/explorer_result_page.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

class ExplorerResultQubicId extends StatelessWidget {
  final ExplorerQueryDto item;
  final String? walletAccountName;
  const ExplorerResultQubicId(
      {super.key, required this.item, required this.walletAccountName});

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
                  resultType: ExplorerResultType.publicId, qubicId: item.id),

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
        GradientForeground(child: const Icon(Icons.computer_outlined)),
        Text(
            walletAccountName != null
                ? l10n
                    .generalLabelQubicAddressWithAccountName(walletAccountName!)
                : " ${l10n.generalLabeQubicAddress}",
            style: TextStyles.labelText),
      ]),
      ThemedControls.spacerVerticalNormal(),
      Text(item.id),
      ThemedControls.spacerVerticalNormal(),
      getCardButtons(context, item)
    ]));
  }
}
