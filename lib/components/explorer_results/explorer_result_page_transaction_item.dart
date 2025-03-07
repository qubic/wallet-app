import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:intl/intl.dart';
import 'package:qubic_wallet/components/copy_button.dart';
import 'package:qubic_wallet/components/copyable_text.dart';
import 'package:qubic_wallet/components/explorer_transaction_status_item.dart';
import 'package:qubic_wallet/components/unit_amount.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/dtos/explorer_transaction_info_dto.dart';
import 'package:qubic_wallet/extensions/asThousands.dart';
import 'package:qubic_wallet/helpers/transaction_UI_helpers.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/models/qubic_asset_transfer.dart';
import 'package:qubic_wallet/models/qubic_list_vm.dart';
import 'package:qubic_wallet/smart_contracts/qx_info.dart';
import 'package:qubic_wallet/resources/qubic_cmd.dart';
import 'package:qubic_wallet/smart_contracts/sc_info.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

import '../../stores/application_store.dart';

class ExplorerResultPageTransactionItem extends StatefulWidget {
  final ExplorerTransactionDto transaction;
  final bool isFocused;
  final bool showTick;
  final bool? dataStatus;
  ExplorerResultPageTransactionItem(
      {super.key,
      required this.transaction,
      this.isFocused = false,
      this.showTick = false,
      this.dataStatus = false});

  @override
  State<ExplorerResultPageTransactionItem> createState() =>
      _ExplorerResultPageTransactionItemState();
}

class _ExplorerResultPageTransactionItemState
    extends State<ExplorerResultPageTransactionItem> {
  final ApplicationStore appStore = getIt<ApplicationStore>();
  QubicAssetTransfer? assetTransfer;

  Future<QubicAssetTransfer> parseAssetTransferPayload() async {
    return await getIt<QubicCmd>()
        .parseAssetTransferPayload(widget.transaction.transaction.inputHex!);
  }

  bool get isQx =>
      widget.transaction.transaction.destId == QubicSCID.qX.contractId;

  @override
  void initState() {
    super.initState();
    if (isQx) {
      parseAssetTransferPayload().then((value) {
        setState(() {
          assetTransfer = value;
        });
      });
    }
  }

  final DateFormat formatter = DateFormat('dd MMM yyyy \'at\' HH:mm:ss');

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
        ExplorerTransactionStatusItem(item: widget.transaction),
        if (!isQx || (isQx && assetTransfer != null))
          SizedBox(
              width: double.infinity,
              child: FittedBox(
                  fit: BoxFit.cover,
                  child: UnitAmount(
                      type: isQx
                          ? assetTransfer!.assetName
                          : l10n.generalLabelCurrencyQubic,
                      amount: int.tryParse(isQx
                          ? assetTransfer!.numberOfUnits
                          : widget.transaction.transaction
                              .amount!))) // transaction.amount)),
              ),
        Row(children: [
          widget.showTick
              ? Expanded(
                  flex: 1,
                  child: CopyableText(
                      copiedText: widget.transaction.transaction.tickNumber
                              ?.toString() ??
                          "-",
                      child: Text(
                          l10n.generalLabelTickAndValue(widget
                                  .transaction.transaction.tickNumber
                                  ?.asThousands() ??
                              "-"),
                          textAlign: TextAlign.right)))
              : Container()
        ]),
        ThemedControls.spacerVerticalSmall(),
        Row(children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(l10n.transactionItemLabelTransactionId,
                    style: itemHeaderType(context)),
                Text(widget.transaction.transaction.txId.toString()),
              ])),
          CopyButton(
              copiedText: widget.transaction.transaction.txId.toString()),
        ]),
        ThemedControls.spacerVerticalSmall(),
        Row(children: [
          Expanded(
              child: getFromTo(context, l10n.generalLabelFrom,
                  widget.transaction.transaction.sourceId.toString())),
          CopyButton(
              copiedText: widget.transaction.transaction.sourceId.toString()),
        ]),
        ThemedControls.spacerVerticalSmall(),
        Row(children: [
          Expanded(
              child: getFromTo(context, l10n.generalLabelTo,
                  widget.transaction.transaction.destId.toString())),
          CopyButton(
              copiedText: widget.transaction.transaction.destId.toString()),
        ]),
        if (isQx && assetTransfer != null) ...[
          ThemedControls.spacerVerticalSmall(),
          Row(children: [
            Expanded(
                child: getFromTo(
                    context, "Destination", assetTransfer!.assetIssuer)),
            CopyButton(
                copiedText: widget.transaction.transaction.destId.toString()),
          ]),
          ThemedControls.spacerVerticalSmall(),
          Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Fee", style: itemHeaderType(context)),
                  Text(
                      "${widget.transaction.transaction.amount!.asThousands()} ${l10n.generalLabelCurrencyQubic}"),
                ],
              ),
            ),
            CopyButton(
                copiedText: widget.transaction.transaction.destId.toString()),
          ]),
        ]
      ]),
    );
  }
}
