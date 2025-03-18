// ignore: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:qubic_wallet/components/copy_button.dart';
import 'package:qubic_wallet/components/mid_text_with_ellipsis.dart';
import 'package:qubic_wallet/components/transaction_details.dart';
import 'package:qubic_wallet/components/transaction_status_item.dart';
import 'package:qubic_wallet/components/unit_amount.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/extensions/asThousands.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/copy_to_clipboard.dart';
import 'package:qubic_wallet/helpers/explorer_helpers.dart';
import 'package:qubic_wallet/helpers/transaction_actions_helpers.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/models/qubic_asset_transfer.dart';
import 'package:qubic_wallet/models/qubic_list_vm.dart';
import 'package:qubic_wallet/models/transaction_vm.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/send.dart';
import 'package:qubic_wallet/resources/qubic_cmd.dart';
import 'package:qubic_wallet/smart_contracts/qutil_info.dart';
import 'package:qubic_wallet/smart_contracts/qx_info.dart';
import 'package:qubic_wallet/smart_contracts/sc_info.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

import 'transaction_direction_item.dart';

enum CardItem { details, resend, explorer, clipboardCopy, delete }

class TransactionItem extends StatefulWidget {
  final TransactionVm item;

  const TransactionItem({super.key, required this.item});

  @override
  State<TransactionItem> createState() => _TransactionItemState();
}

class _TransactionItemState extends State<TransactionItem> {
  final ApplicationStore appStore = getIt<ApplicationStore>();
  QubicAssetTransfer? assetTransfer;
  bool get isQxTransferShares =>
      QxInfo.isQxTransferShares(widget.item.destId, widget.item.type);
  Future<QubicAssetTransfer> parseAssetTransferPayload() async {
    return await getIt<QubicCmd>()
        .parseAssetTransferPayload(widget.item.inputHex!);
  }

  @override
  void initState() {
    super.initState();
    if (isQxTransferShares) {
      parseAssetTransferPayload().then((value) {
        setState(() {
          assetTransfer = value;
        });
      });
    }
  }

  //Gets the dropdown menu
  Widget getCardMenu(BuildContext context) {
    final l10n = l10nOf(context);
    return PopupMenuButton<CardItem>(
        tooltip: "",
        icon: Icon(Icons.more_horiz,
            color: LightThemeColors.primary.withAlpha(140)),
        // Callback that sets the selected popup menu item.
        onSelected: (CardItem menuItem) async {
          if (menuItem == CardItem.explorer) {
            viewTransactionInExplorer(widget.item.id);
          }

          if (menuItem == CardItem.clipboardCopy) {
            copyToClipboard(widget.item.toReadableString(context), context);
          }

          if (menuItem == CardItem.resend) {
            pushScreen(
              context,
              screen: Send(
                  amount: widget.item.amount,
                  destId: widget.item.destId,
                  item: appStore.currentQubicIDs
                      .firstWhere((id) => id.publicId == widget.item.sourceId)),
              withNavBar: false,
              pageTransitionAnimation: PageTransitionAnimation.cupertino,
            );
          }

          if (menuItem == CardItem.details) {
            showDetails(context);
          }
          if (menuItem == CardItem.delete) {
            appStore.removeStoredTransaction(widget.item.id);
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<CardItem>>[
              PopupMenuItem<CardItem>(
                value: CardItem.details,
                child: Text(l10n.transactionItemButtonViewDetails),
              ),
              if (TransactionActionHelpers.canViewInExplorer(widget.item))
                PopupMenuItem<CardItem>(
                  value: CardItem.explorer,
                  child: Text(l10n.transactionItemButtonViewInExplorer),
                ),
              PopupMenuItem<CardItem>(
                value: CardItem.clipboardCopy,
                child: Text(l10n.transactionItemButtonCopyToClipboard),
              ),
              if (TransactionActionHelpers.canResend(widget.item))
                PopupMenuItem<CardItem>(
                  value: CardItem.resend,
                  child: Text(l10n.transactionItemButtonResend),
                ),
              if (TransactionActionHelpers.canDelete(widget.item))
                PopupMenuItem<CardItem>(
                  value: CardItem.delete,
                  child: Text(l10n.generalButtonDelete),
                )
            ]);
  }

  //Gets the labels for Source and Destination in transactions. Also copies to clipboard
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
                        style: TextStyles.secondaryText)),
              ]);
            }
            return Row(children: [
              Text(l10n.generalLabelToFromAddress(prepend),
                  textAlign: TextAlign.start, style: TextStyles.secondaryText)
            ]);
          }),
          if (QubicSCStore.isSC(accountId))
            Text(QubicSCStore.fromContractId(accountId)!),
          TextWithMidEllipsis(accountId,
              style: TextStyles.textNormal, textAlign: TextAlign.start),
        ]);
  }

  void showDetails(BuildContext context) {
    showModalBottomSheet<void>(
        useRootNavigator: true,
        showDragHandle: false,
        useSafeArea: true,
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
              child: TransactionDetails(
                  item: widget.item, assetTransfer: assetTransfer));
        });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);

    return Container(
        constraints: const BoxConstraints(minWidth: 400, maxWidth: 500),
        child: ThemedControls.card(
            child: Column(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Container(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: TransactionStatusItem(
                      item: widget.item,
                      key: ValueKey<String>(
                          "transactionStatus${widget.item.id}${widget.item.getStatus().toString()}"),
                    ),
                  ),
                  getCardMenu(context)
                ])),
            if (!isQxTransferShares ||
                (isQxTransferShares && assetTransfer != null))
              Center(
                  child: Container(
                      constraints: const BoxConstraints(maxWidth: 500),
                      width: double.infinity,
                      child: FittedBox(
                          child: UnitAmount(
                              type: isQxTransferShares
                                  ? assetTransfer!.assetName
                                  : l10n.generalLabelCurrencyQubic,
                              amount: isQxTransferShares
                                  ? int.tryParse(assetTransfer!.numberOfUnits)
                                  : widget.item.amount)))),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TransactionDirectionItem(item: widget.item),
                  Text(
                      l10n.generalLabelTickAndValue(
                          widget.item.targetTick.asThousands()),
                      textAlign: TextAlign.end,
                      style: TextStyles.secondaryText),
                ]),
            ThemedControls.spacerVerticalNormal(),
            Column(children: [
              Flex(direction: Axis.horizontal, children: [
                Expanded(
                    child: getFromTo(
                        context, l10n.generalLabelFrom, widget.item.sourceId)),
                CopyButton(copiedText: widget.item.sourceId),
              ]),
              ThemedControls.spacerVerticalSmall(),
              Flex(direction: Axis.horizontal, children: [
                Expanded(
                    child: getFromTo(
                        context, l10n.generalLabelTo, widget.item.destId)),
                CopyButton(copiedText: widget.item.destId),
              ]),
            ]),
          ]),
        ])));
  }
}
