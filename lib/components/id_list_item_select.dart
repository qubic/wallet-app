import 'package:flutter/material.dart';
import 'package:qubic_wallet/components/amount_formatted.dart';
import 'package:qubic_wallet/components/mid_text_with_ellipsis.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/models/qubic_list_vm.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

enum CardItem { delete, rename }

class IdListItemSelect extends StatelessWidget {
  final QubicListVm item;

  final bool showAmount;
  IdListItemSelect({
    super.key,
    required this.item,
    this.showAmount = true,
  });

  final ApplicationStore appStore = getIt<ApplicationStore>();

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);

    return Container(
        constraints: const BoxConstraints(minWidth: 400, maxWidth: 500),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Expanded(
                child: Text(
              item.name,
              style: TextStyles.accountName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )),
            ThemedControls.spacerHorizontalSmall(),
            item.watchOnly
                ? const Icon(
                    Icons.remove_red_eye_rounded,
                    color: LightThemeColors.color4,
                  )
                : const SizedBox.shrink(),
          ]),
          AmountFormatted(
            key: ValueKey<String>("qubicAmount${item.publicId}-${item.amount}"),
            amount: item.amount,
            isInHeader: false,
            labelOffset: 0,
            labelHorizOffset: -6,
            textStyle: TextStyles.accountAmountLabel,
            labelStyle: TextStyles.accountAmountLabel,
            currencyName: l10n.generalLabelCurrencyQubic,
          ),
          TextWithMidEllipsis(item.publicId, style: TextStyles.accountPublicId),
        ]));
  }
}
