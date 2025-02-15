// ignore: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:qubic_wallet/components/copy_button.dart';
import 'package:qubic_wallet/components/mid_text_with_ellipsis.dart';
import 'package:qubic_wallet/components/qubic_amount.dart';
import 'package:qubic_wallet/components/transaction_details.dart';
import 'package:qubic_wallet/components/transaction_status_item.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/extensions/asThousands.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/copy_to_clipboard.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/models/qubic_list_vm.dart';
import 'package:qubic_wallet/models/transaction_vm.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/explorer/explorer_result_page.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/send.dart';
import 'package:qubic_wallet/smart_contracts/qutil_info.dart';
import 'package:qubic_wallet/smart_contracts/qx_info.dart';
import 'package:qubic_wallet/smart_contracts/sc_info.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

import 'transaction_direction_item.dart';

enum CardItem { details, resend, explorer, clipboardCopy, delete }

class TransactionItem extends StatelessWidget {
  final TransactionVm item;

  TransactionItem({super.key, required this.item});
  final ApplicationStore appStore = getIt<ApplicationStore>();

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
            pushScreen(
              context,
              screen: ExplorerResultPage(
                resultType: ExplorerResultType.transaction,
                tick: item.targetTick,
                focusedTransactionHash: item.id,
              ),
              withNavBar: false,
              pageTransitionAnimation: PageTransitionAnimation.cupertino,
            );
          }

          if (menuItem == CardItem.clipboardCopy) {
            copyToClipboard(item.toReadableString(context), context);
          }

          if (menuItem == CardItem.resend) {
            pushScreen(
              context,
              screen: Send(
                  amount: item.amount,
                  destId: item.destId,
                  item: appStore.currentQubicIDs
                      .firstWhere((id) => id.publicId == item.sourceId)),
              withNavBar: false,
              pageTransitionAnimation: PageTransitionAnimation.cupertino,
            );
          }

          if (menuItem == CardItem.details) {
            showDetails(context);
          }
          if (menuItem == CardItem.delete) {
            appStore.removeStoredTransaction(item.id);
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<CardItem>>[
              PopupMenuItem<CardItem>(
                value: CardItem.details,
                child: Text(l10n.transactionItemButtonViewDetails),
              ),
              if (item.status == 'Success')
                PopupMenuItem<CardItem>(
                  value: CardItem.explorer,
                  child: Text(l10n.transactionItemButtonViewInExplorer),
                ),
              PopupMenuItem<CardItem>(
                value: CardItem.clipboardCopy,
                child: Text(l10n.transactionItemButtonCopyToClipboard),
              ),
              if (appStore.currentQubicIDs.any(
                      (e) => e.publicId == item.sourceId && !e.watchOnly) &&
                  item.getStatus() != ComputedTransactionStatus.pending &&
                  item.amount > 0 &&
                  item.destId != QxInfo.mainAssetIssuer &&
                  item.destId != QutilInfo.address &&
                  item.destId != QxInfo.address)
                PopupMenuItem<CardItem>(
                  value: CardItem.resend,
                  child: Text(l10n.transactionItemButtonResend),
                ),
              if (item.getStatus() == ComputedTransactionStatus.invalid)
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
          if (QubicSCID.isSC(accountId))
            Text(QubicSCID.fromContractId(accountId)!),
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
          return SafeArea(child: TransactionDetails(item: item));
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
                      item: item,
                      key: ValueKey<String>(
                          "transactionStatus${item.id}${item.getStatus().toString()}"),
                    ),
                  ),
                  getCardMenu(context)
                ])),
            Center(
                child: Container(
                    constraints: const BoxConstraints(maxWidth: 500),
                    width: double.infinity,
                    child: FittedBox(child: QubicAmount(amount: item.amount)))),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TransactionDirectionItem(item: item),
                  Text(
                      l10n.generalLabelTickAndValue(
                          item.targetTick.asThousands()),
                      textAlign: TextAlign.end,
                      style: TextStyles.secondaryText),
                ]),
            ThemedControls.spacerVerticalNormal(),
            Column(children: [
              Flex(direction: Axis.horizontal, children: [
                Expanded(
                    child: getFromTo(
                        context, l10n.generalLabelFrom, item.sourceId)),
                CopyButton(copiedText: item.sourceId),
              ]),
              ThemedControls.spacerVerticalSmall(),
              Flex(direction: Axis.horizontal, children: [
                Expanded(
                    child:
                        getFromTo(context, l10n.generalLabelTo, item.destId)),
                CopyButton(copiedText: item.destId),
              ]),
            ]),
          ]),
        ])));
  }
}
