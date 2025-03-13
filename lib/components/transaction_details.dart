import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:qubic_wallet/components/copy_button.dart';
import 'package:qubic_wallet/components/copyable_text.dart';
import 'package:qubic_wallet/components/transaction_status_item.dart';
import 'package:qubic_wallet/components/unit_amount.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/extensions/asThousands.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/app_logger.dart';
import 'package:qubic_wallet/helpers/transaction_UI_helpers.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/models/qubic_asset_transfer.dart';
import 'package:qubic_wallet/models/qubic_list_vm.dart';
import 'package:qubic_wallet/models/transaction_vm.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/explorer/explorer_result_page.dart';
import 'package:qubic_wallet/resources/qubic_cmd.dart';
import 'package:qubic_wallet/smart_contracts/qx_info.dart';
import 'package:qubic_wallet/smart_contracts/sc_info.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/styles/app_icons.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

import 'transaction_direction_item.dart';

enum CardItem { explorer, clipboardCopy }

class TransactionDetails extends StatefulWidget {
  final TransactionVm item;

  const TransactionDetails({super.key, required this.item});

  @override
  State<TransactionDetails> createState() => _TransactionDetailsState();
}

class _TransactionDetailsState extends State<TransactionDetails> {
  final DateFormat formatter = DateFormat('dd MMM yyyy \'at\' HH:mm:ss');
  QubicAssetTransfer? assetTransfer;
  bool get isQxTransferShares =>
      widget.item.destId == QxInfo.address && widget.item.type == 2;
  Future<QubicAssetTransfer> parseAssetTransferPayload() async {
    return await getIt<QubicCmd>()
        .parseAssetTransferPayload(widget.item.inputHex!);
  }

  final ApplicationStore appStore = getIt<ApplicationStore>();

  @override
  void initState() {
    super.initState();
    if (isQxTransferShares) {
      parseAssetTransferPayload().then((value) {
        setState(() {
          assetTransfer = value;
          appLogger.e("message");
        });
      });
    }
  }

  Widget getButtonBar(BuildContext context) {
    final l10n = l10nOf(context);
    return Padding(
        padding: const EdgeInsets.fromLTRB(
            0, ThemePaddings.smallPadding, 0, ThemePaddings.smallPadding),
        child: Row(
          children: [
            Expanded(
                child: ThemedControls.transparentButtonBigWithChild(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(
                          text: widget.item.toReadableString(context)));
                    },
                    child: Text(
                      l10n.transactionItemButtonCopyToClipboard,
                      textAlign: TextAlign.center,
                      style:
                          TextStyles.transparentButtonText.copyWith(height: 1),
                    ))),
            ThemedControls.spacerHorizontalNormal(),
            Expanded(
              child: (widget.item.status == "Success")
                  ? ThemedControls.primaryButtonBigWithChild(
                      onPressed: () {
                        // Perform some action
                        pushScreen(
                          context,
                          screen: ExplorerResultPage(
                              resultType: ExplorerResultType.tick,
                              tick: widget.item.targetTick,
                              focusedTransactionHash: widget.item.id),
                          //TransactionsForId(publicQubicId: item.publicId),
                          withNavBar: false, // OPTIONAL VALUE. True by default.
                          pageTransitionAnimation:
                              PageTransitionAnimation.cupertino,
                        );
                      },
                      child: Text(l10n.transactionItemButtonViewInExplorer,
                          textAlign: TextAlign.center,
                          style: TextStyles.primaryButtonText))
                  : ThemedControls.primaryButtonBigDisabled(
                      text: l10n.transactionItemButtonViewInExplorer),
            ),
          ],
        ));
  }

  //Gets the from and To labels
  Widget getFromTo(BuildContext context, String prepend, String accountId) {
    final l10n = l10nOf(context);

    return Flex(direction: Axis.horizontal, children: [
      Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
            Observer(builder: (context) {
              QubicListVm? source = appStore.findAccountById(accountId);
              if (source != null) {
                return SizedBox(
                    width: double.infinity,
                    child: Text(
                        l10n.generalLabelToFromAccount(prepend, source.name),
                        textAlign: TextAlign.start,
                        style: TextStyles.lightGreyTextNormal));
              }
              return SizedBox(
                  width: double.infinity,
                  child: Text(l10n.generalLabelToFromAddress(prepend),
                      textAlign: TextAlign.start,
                      style: TextStyles.lightGreyTextNormal));
            }),
            if (QubicSCStore.isSC(accountId))
              Text(QubicSCStore.fromContractId(accountId)!,
                  style: TextStyles.textNormal),
            Text(accountId, style: TextStyles.textNormal),
          ])),
      CopyButton(copiedText: accountId)
    ]);
  }

  Widget getCopyableDetails(BuildContext context, String text, String value) {
    return Flex(direction: Axis.horizontal, children: [
      Expanded(
          child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        SizedBox(
            width: double.infinity,
            child: Text(text,
                textAlign: TextAlign.start,
                style: TextStyles.lightGreyTextNormal)),
        SizedBox(
            width: double.infinity,
            child: Text(value,
                textAlign: TextAlign.start, style: TextStyles.textNormal))
      ])),
      CopyButton(copiedText: value)
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return Container(
        constraints: BoxConstraints(
            minWidth: 400,
            maxWidth: 500,
            maxHeight: MediaQuery.of(context).size.height * 0.8),
        child: Card(
            child: Padding(
                padding: const EdgeInsets.fromLTRB(ThemePaddings.normalPadding,
                    ThemePaddings.smallPadding, ThemePaddings.normalPadding, 0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const IconButton(
                                  onPressed: null, icon: SizedBox.shrink()),
                              Text(
                                l10n.transactionItemLabelDetails,
                                textAlign: TextAlign.center,
                                style: TextStyles.labelText,
                              ),
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: SvgPicture.asset(AppIcons.close,
                                    color: LightThemeColors.textLightGrey),
                              ),
                            ],
                          ),
                          ThemedControls.spacerVerticalNormal(),
                          TransactionStatusItem(item: widget.item),
                          if (!isQxTransferShares ||
                              (isQxTransferShares && assetTransfer != null))
                            SizedBox(
                                width: double.infinity,
                                child: FittedBox(
                                  child: CopyableText(
                                    copiedText: widget.item.amount.toString(),
                                    child: UnitAmount(
                                        type: isQxTransferShares
                                            ? assetTransfer!.assetName
                                            : l10n.generalLabelCurrencyQubic,
                                        amount: isQxTransferShares
                                            ? int.tryParse(
                                                assetTransfer!.numberOfUnits)
                                            : widget.item.amount),
                                  ),
                                )),
                        ],
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TransactionDirectionItem(item: widget.item),
                            CopyableText(
                                copiedText: widget.item.targetTick.toString(),
                                child: Text(
                                    l10n.generalLabelTickAndValue(
                                        widget.item.targetTick.asThousands()),
                                    textAlign: TextAlign.end,
                                    style: TextStyles.assetSecondaryTextLabel))
                          ]),
                      ThemedControls.spacerVerticalNormal(),
                      Expanded(
                          child: Scrollbar(
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                            child: Column(children: [
                          getCopyableDetails(
                              context,
                              l10n.transactionItemLabelTransactionId,
                              widget.item.id),
                          ThemedControls.spacerVerticalSmall(),
                          getCopyableDetails(
                              context,
                              l10n.transactionItemLabelTransactionType,
                              TransactionUIHelpers.getTransactionType(
                                  widget.item.type ?? 0, widget.item.destId)),
                          ThemedControls.spacerVerticalSmall(),
                          getFromTo(context, l10n.generalLabelFrom,
                              widget.item.sourceId),
                          ThemedControls.spacerVerticalSmall(),
                          getFromTo(
                              context, l10n.generalLabelTo, widget.item.destId),
                          ThemedControls.spacerVerticalSmall(),
                          if (isQxTransferShares) ...[
                            getCopyableDetails(
                                context, "Destination", widget.item.id),
                            ThemedControls.spacerVerticalSmall(),
                            getCopyableDetails(context, "Fee",
                                "${widget.item.amount.asThousands()} ${l10n.generalLabelCurrencyQubic}"),
                            ThemedControls.spacerVerticalSmall(),
                          ],
                          getCopyableDetails(
                              context,
                              l10n.transactionItemLabelConfirmedDate,
                              widget.item.confirmed != null
                                  ? formatter
                                      .format(widget.item.confirmed!.toLocal())
                                  : l10n.generalLabelNotAvailable)
                        ])),
                      )),
                      getButtonBar(context),
                    ]))));
  }
}
