import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:qubic_wallet/components/copy_button.dart';
import 'package:qubic_wallet/components/copyable_text.dart';
import 'package:qubic_wallet/components/explorer_transaction_status_item.dart';
import 'package:qubic_wallet/components/gradient_foreground.dart';
import 'package:qubic_wallet/components/qubic_amount.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/dtos/explorer_transaction_info_dto.dart';
import 'package:qubic_wallet/extensions/asThousands.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/models/qubic_list_vm.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

import '../../stores/application_store.dart';

class ExplorerResultPageTransactionItem extends StatelessWidget {
  final ExplorerTransactionDto transaction;
  final ApplicationStore appStore = getIt<ApplicationStore>();
  final DateFormat formatter = DateFormat('dd MMM yyyy \'at\' HH:mm:ss');

  final bool isFocused;
  final bool showTick;
  final bool? dataStatus;
  ExplorerResultPageTransactionItem(
      {super.key,
      required this.transaction,
      this.isFocused = false,
      this.showTick = false,
      this.dataStatus = false});

  TextStyle itemHeaderType(context) {
    return TextStyles.lightGreyTextSmallBold;
  }

  //Gets the labels for Source and Destination in transcations. Also copies to clipboard
  Widget getFromTo(BuildContext context, String prepend, String id) {
    final l10n = l10nOf(context);

    return Column(mainAxisAlignment: MainAxisAlignment.end, children: [
      Observer(builder: (context) {
        QubicListVm? source =
            appStore.currentQubicIDs.firstWhereOrNull((element) {
          return element.publicId == id;
        });
        if (source != null) {
          return Row(children: [
            Expanded(
                child: Text(
                    l10n.generalLabelToFromAccount(prepend, source.name),
                    textAlign: TextAlign.start,
                    style: TextStyles.lightGreyTextSmallBold)),
          ]);
        }
        return Row(children: [
          Text(l10n.generalLabelToFromAddress(prepend),
              textAlign: TextAlign.start,
              style: TextStyles.lightGreyTextSmallBold)
        ]);
      }),
      Text(id, style: TextStyles.textSmall, textAlign: TextAlign.start),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return ThemedControls.card(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ExplorerTransactionStatusItem(item: transaction),
        Container(
            width: double.infinity,
            child: FittedBox(
                fit: BoxFit.cover,
                child: QubicAmount(
                    amount: int.tryParse(transaction
                        .transaction.amount!))) // transaction.amount)),
            ),
        Flex(direction: Axis.horizontal, children: [
          showTick
              ? Expanded(
                  flex: 1,
                  child: CopyableText(
                      copiedText:
                          transaction.transaction.tickNumber?.toString() ?? "-",
                      child: Text(
                          l10n.generalLabelTickAndValue(transaction
                                  .transaction.tickNumber
                                  ?.asThousands() ??
                              "-"),
                          textAlign: TextAlign.right)))
              : Container()
        ]),
        ThemedControls.spacerVerticalSmall(),
        Flex(direction: Axis.horizontal, children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(l10n.transactionItemLabelTransactionId,
                    style: itemHeaderType(context)),
                Text(transaction.transaction.txId.toString()),
              ])),
          CopyButton(copiedText: transaction.transaction.txId.toString()),
        ]),
        ThemedControls.spacerVerticalSmall(),
        Flex(direction: Axis.horizontal, children: [
          Expanded(
              child: getFromTo(context, l10n.generalLabelFrom,
                  transaction.transaction.sourceId.toString())),
          CopyButton(copiedText: transaction.transaction.sourceId.toString()),
        ]),
        ThemedControls.spacerVerticalSmall(),
        Flex(direction: Axis.horizontal, children: [
          Expanded(
              child: getFromTo(context, l10n.generalLabelTo,
                  transaction.transaction.destId.toString())),
          CopyButton(copiedText: transaction.transaction.destId.toString()),
        ]),
      ]),
    );
  }
}
