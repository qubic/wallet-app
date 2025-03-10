import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:qubic_wallet/components/copy_button.dart';
import 'package:qubic_wallet/components/copyable_text.dart';
import 'package:qubic_wallet/components/explorer_transaction_status_item.dart';
import 'package:qubic_wallet/components/qubic_amount.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/dtos/explorer_transaction_info_dto.dart';
import 'package:qubic_wallet/extensions/asThousands.dart';
import 'package:qubic_wallet/helpers/transaction_UI_helpers.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/models/qubic_list_vm.dart';
import 'package:qubic_wallet/smart_contracts/qx_info.dart';
import 'package:qubic_wallet/smart_contracts/sc_info.dart';
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
  Widget getFromTo(BuildContext context, String prepend, String accountId) {
    final l10n = l10nOf(context);

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Observer(builder: (context) {
            QubicListVm? source = appStore.findAccountById(accountId);
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
          if (QubicSCStore.isSC(accountId)) ...[
            ThemedControls.spacerVerticalMini(),
            Text(QubicSCStore.fromContractId(accountId)!)
          ],
          Text(accountId,
              style: TextStyles.textSmall, textAlign: TextAlign.start),
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
                    amount: int.tryParse(
                        transaction.data.amount!))) // transaction.amount)),
            ),
        Flex(direction: Axis.horizontal, children: [
          showTick
              ? Expanded(
                  flex: 1,
                  child: CopyableText(
                      copiedText:
                          transaction.data.tickNumber?.toString() ?? "-",
                      child: Text(
                          l10n.generalLabelTickAndValue(
                              transaction.data.tickNumber?.asThousands() ??
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
                Text(transaction.data.txId.toString()),
              ])),
          CopyButton(copiedText: transaction.data.txId.toString()),
        ]),
        ThemedControls.spacerVerticalSmall(),
        Flex(direction: Axis.horizontal, children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(l10n.transactionItemLabelTransactionType,
                    style: itemHeaderType(context)),
                Text(TransactionUIHelpers.getTransactionType(
                    transaction.data.inputType ?? 0, transaction.data.destId!)),
              ])),
          CopyButton(copiedText: transaction.data.inputType.toString()),
        ]),
        ThemedControls.spacerVerticalSmall(),
        Flex(direction: Axis.horizontal, children: [
          Expanded(
              child: getFromTo(context, l10n.generalLabelFrom,
                  transaction.data.sourceId.toString())),
          CopyButton(copiedText: transaction.data.sourceId.toString()),
        ]),
        ThemedControls.spacerVerticalSmall(),
        Flex(direction: Axis.horizontal, children: [
          Expanded(
              child: getFromTo(context, l10n.generalLabelTo,
                  transaction.data.destId.toString())),
          CopyButton(copiedText: transaction.data.destId.toString()),
        ]),
      ]),
    );
  }
}
