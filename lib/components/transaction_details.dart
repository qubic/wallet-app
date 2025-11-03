import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qubic_wallet/components/copy_button.dart';
import 'package:qubic_wallet/components/copyable_text.dart';
import 'package:qubic_wallet/components/transaction_status_item.dart';
import 'package:qubic_wallet/components/unit_amount.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/extensions/as_thousands.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/date_formatter.dart';
import 'package:qubic_wallet/helpers/explorer_helpers.dart';
import 'package:qubic_wallet/helpers/transaction_actions_helpers.dart';
import 'package:qubic_wallet/helpers/transaction_ui_helpers.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/models/qubic_asset_transfer.dart';
import 'package:qubic_wallet/models/qubic_list_vm.dart';
import 'package:qubic_wallet/models/qubic_send_many_transfer.dart';
import 'package:qubic_wallet/models/transaction_vm.dart';
import 'package:qubic_wallet/resources/qubic_cmd.dart';
import 'package:qubic_wallet/smart_contracts/qutil_info.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/stores/smart_contract_store.dart';
import 'package:qubic_wallet/styles/app_icons.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

import 'transaction_direction_item.dart';

enum CardItem { explorer, clipboardCopy }

class TransactionDetails extends StatefulWidget {
  final TransactionVm item;
  final QubicAssetTransfer? assetTransfer;

  const TransactionDetails({super.key, required this.item, this.assetTransfer});

  @override
  State<TransactionDetails> createState() => _TransactionDetailsState();
}

class _TransactionDetailsState extends State<TransactionDetails> {
  bool get isQxTransferShares => widget.assetTransfer != null;
  List<QubicSendManyTransfer> sendManyTransfers = [];
  final ApplicationStore appStore = getIt<ApplicationStore>();
  Future<List<QubicSendManyTransfer>> parseTransferSendManyPayload() async {
    return await getIt<QubicCmd>()
        .parseTransferSendManyPayload(widget.item.inputHex!);
  }

  bool get isQutilSendToMany =>
      QutilInfo.isSendToManyTransfer(widget.item.destId, widget.item.type);

  @override
  void initState() {
    super.initState();
    if (isQutilSendToMany) {
      parseTransferSendManyPayload().then((value) {
        setState(() {
          sendManyTransfers = value;
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
              child: TransactionActionHelpers.canViewInExplorer(widget.item)
                  ? ThemedControls.primaryButtonBigWithChild(
                      onPressed: () {
                        Navigator.pop(context);
                        viewTransactionInExplorer(context, widget.item.id);
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
            if (getIt<SmartContractStore>().isKnownEntity(accountId))
              Text(getIt<SmartContractStore>().getLabel(accountId)!,
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
                                    colorFilter: const ColorFilter.mode(
                                        LightThemeColors.textLightGrey,
                                        BlendMode.srcIn)),
                              ),
                            ],
                          ),
                          if (isQxTransferShares)
                            DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: LightThemeColors.primary40,
                                    width: 0.8),
                              ),
                              child: ThemedControls.cardWithBg(
                                bgColor: Colors.transparent,
                                child: Row(children: [
                                  const Icon(Icons.info_outline_rounded,
                                      color: LightThemeColors.primary40),
                                  ThemedControls.spacerHorizontalSmall(),
                                  Expanded(
                                      child: Text(
                                    l10n.qxTransferSharesWarning,
                                    style: TextStyles.secondaryText.copyWith(
                                        color: LightThemeColors.primary40),
                                  ))
                                ]),
                              ),
                            ),
                          ThemedControls.spacerVerticalNormal(),
                          TransactionStatusItem(item: widget.item),
                          SizedBox(
                              width: double.infinity,
                              child: FittedBox(
                                child: CopyableText(
                                  copiedText: isQxTransferShares
                                      ? widget.assetTransfer!.numberOfUnits
                                          .toString()
                                      : widget.item.amount.toString(),
                                  child: UnitAmount(
                                      type: isQxTransferShares
                                          ? widget.assetTransfer!.assetName
                                          : l10n.generalLabelCurrencyQubic,
                                      amount: isQxTransferShares
                                          ? int.tryParse(widget
                                              .assetTransfer!.numberOfUnits)
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
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              getCopyableDetails(
                                  context,
                                  l10n.transactionItemLabelTransactionId,
                                  widget.item.id),
                              ThemedControls.spacerVerticalSmall(),
                              getCopyableDetails(
                                  context,
                                  l10n.transactionItemLabelTransactionType,
                                  TransactionUIHelpers.getTransactionType(
                                      widget.item.type ?? 0,
                                      widget.item.destId)),
                              ThemedControls.spacerVerticalSmall(),
                              getFromTo(context, l10n.generalLabelFrom,
                                  widget.item.sourceId),
                              ThemedControls.spacerVerticalSmall(),
                              getFromTo(
                                  context,
                                  l10n.generalLabelTo,
                                  isQxTransferShares
                                      ? widget
                                          .assetTransfer!.newOwnerAndPossessor
                                      : widget.item.destId),
                              ThemedControls.spacerVerticalSmall(),
                              if (isQxTransferShares &&
                                  widget.assetTransfer != null) ...[
                                ThemedControls.spacerVerticalSmall(),
                                getCopyableDetails(
                                    context,
                                    l10n.generalLabelFee,
                                    "${widget.item.amount.asThousands()} ${l10n.generalLabelCurrencyQubic}"),
                                ThemedControls.spacerVerticalSmall(),
                              ],
                              getCopyableDetails(
                                  context,
                                  l10n.transactionItemLabelConfirmedDate,
                                  widget.item.timestamp != null
                                      ? DateFormatter.formatShortWithTime(
                                          widget.item.timestamp!)
                                      : l10n.generalLabelNotAvailable),
                              if (isQutilSendToMany &&
                                  sendManyTransfers.isNotEmpty) ...[
                                ThemedControls.spacerVerticalSmall(),
                                Text(l10n.generalLabelMultipleReceivers,
                                    style: TextStyles.lightGreyTextNormal),
                                ThemedControls.spacerVerticalMini(),
                                Column(
                                  children: sendManyTransfers
                                      .map((e) => Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(e.destId,
                                                  style: TextStyles.textSmall),
                                              Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  "${e.amount.asThousands()} ${l10n.generalLabelCurrencyQubic}",
                                                  style: TextStyles.textSmall,
                                                ),
                                              ),
                                              ThemedControls
                                                  .spacerVerticalSmall(),
                                            ],
                                          ))
                                      .toList(),
                                )
                              ]
                            ])),
                      )),
                      getButtonBar(context),
                    ]))));
  }
}
