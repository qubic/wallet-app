import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:qubic_wallet/components/copy_button.dart';
import 'package:qubic_wallet/components/mid_text_with_ellipsis.dart';
import 'package:qubic_wallet/components/qubic_amount.dart';
import 'package:qubic_wallet/components/transaction_details.dart';
import 'package:qubic_wallet/components/transaction_resend.dart';
import 'package:qubic_wallet/components/transaction_status_item.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/copy_to_clipboard.dart';
import 'package:qubic_wallet/helpers/re_auth_dialog.dart';
import 'package:qubic_wallet/helpers/sendTransaction.dart';
import 'package:qubic_wallet/helpers/global_snack_bar.dart';
import 'package:qubic_wallet/models/qubic_list_vm.dart';
import 'package:qubic_wallet/models/transaction_vm.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/explorer/explorer_result_page.dart';
import 'package:qubic_wallet/resources/apis/archive/qubic_archive_api.dart';
import 'package:qubic_wallet/resources/apis/live/qubic_live_api.dart';
import 'package:qubic_wallet/resources/qubic_li.dart';
import 'package:qubic_wallet/stores/application_store.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:qubic_wallet/timed_controller.dart';
import 'transaction_direction_item.dart';
import 'package:qubic_wallet/extensions/asThousands.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/helpers/target_tick.dart';

enum CardItem {
  details,
  resend,
  explorer,
  clipboardCopy,
}

class TransactionItem extends StatelessWidget {
  final TransactionVm item;

  TransactionItem({super.key, required this.item});
  final _timedController = getIt<TimedController>();
  final _globalSnackBar = getIt<GlobalSnackBar>();
  final QubicLi _apiService = getIt<QubicLi>();
  final _liveApi = getIt<QubicLiveApi>();
  final ApplicationStore appStore = getIt<ApplicationStore>();

  Future<void> showResendDialog(BuildContext context) async {
    final l10n = l10nOf(context);

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.sendItemDialogResendTitle,
              style: TextStyles.alertHeader),
          content: SingleChildScrollView(
            child: TransactionResend(item: item),
          ),
          actions: <Widget>[
            ThemedControls.transparentButtonBig(
              text: l10n.generalButtonCancel,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ThemedControls.primaryButtonBig(
              text: l10n.accountButtonSend,
              onPressed: () async {
                var result = await reAuthDialog(context);
                if (!result) {
                  return;
                }

                // get fresh latet tick
                int latestTick = (await _liveApi.getCurrentTick()).tick;
                int targetTick = latestTick + defaultTargetTickType.value;

                bool success = await sendTransactionDialog(context,
                    item.sourceId, item.destId, item.amount, targetTick);

                if (success) {
                  _globalSnackBar.show(
                      l10n.generalSnackBarMessageTransactionSubmitted(
                          targetTick!.asThousands()));
                }
                await _timedController.interruptFetchTimer();

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
          // setState(() {
          //   selectedMenu = item;
          // });
          if (menuItem == CardItem.explorer) {
            //showRenameDialog(context);
            pushScreen(
              context,
              screen: ExplorerResultPage(
                resultType: ExplorerResultType.transaction,
                tick: item.targetTick,
                focusedTransactionHash: item.id,
              ),
              withNavBar: false, // OPTIONAL VALUE. True by default.
              pageTransitionAnimation: PageTransitionAnimation.cupertino,
            );
          }

          if (menuItem == CardItem.clipboardCopy) {
            copyToClipboard(item.toReadableString(context), context);
          }

          if (menuItem == CardItem.resend) {
            showResendDialog(context);
          }

          if (menuItem == CardItem.details) {
            showDetails(context);
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<CardItem>>[
              PopupMenuItem<CardItem>(
                value: CardItem.details,
                child: Text(l10n.transactionItemButtonViewDetails),
              ),
              if (appStore.currentTick >= item.targetTick)
                PopupMenuItem<CardItem>(
                  value: CardItem.explorer,
                  child: Text(l10n.transactionItemButtonViewInExplorer),
                ),
              PopupMenuItem<CardItem>(
                value: CardItem.clipboardCopy,
                child: Text(l10n.transactionItemButtonCopyToClipboard),
              ),
              if (appStore.currentQubicIDs
                  .any((e) => e.publicId == item.sourceId))
                PopupMenuItem<CardItem>(
                  value: CardItem.resend,
                  child: Text(l10n.transactionItemButtonResend),
                )
            ]);
  }

  //Gets the labels for Source and Destination in transactions. Also copies to clipboard
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
                    style: TextStyles.secondaryText)),
          ]);
        }
        return Row(children: [
          Text(l10n.generalLabelToFromAddress(prepend),
              textAlign: TextAlign.start, style: TextStyles.secondaryText)
        ]);
      }),
      TextWithMidEllipsis(id,
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
                  //                      TransactionStatusItem(item: item)
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
