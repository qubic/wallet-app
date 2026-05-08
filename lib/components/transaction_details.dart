import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:qubic_wallet/components/copy_button.dart';
import 'package:qubic_wallet/components/copyable_text.dart';
import 'package:qubic_wallet/helpers/transaction_status_helpers.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/extensions/as_thousands.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/address_ui_helper.dart';
import 'package:qubic_wallet/helpers/date_formatter.dart';
import 'package:qubic_wallet/helpers/explorer_helpers.dart';
import 'package:qubic_wallet/helpers/transaction_actions_helpers.dart';
import 'package:qubic_wallet/helpers/transaction_ui_helpers.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/models/qubic_asset_transfer.dart';
import 'package:qubic_wallet/models/qubic_list_vm.dart';
import 'package:qubic_wallet/models/qubic_send_many_transfer.dart';
import 'package:qubic_wallet/models/transaction_vm.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/send.dart';
import 'package:qubic_wallet/resources/qubic_cmd.dart';
import 'package:qubic_wallet/smart_contracts/qutil_info.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/styles/app_icons.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

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
  final NumberFormat _numberFormat = NumberFormat.decimalPattern("en_US");

  Future<List<QubicSendManyTransfer>> parseTransferSendManyPayload() async {
    return await getIt<QubicCmd>()
        .parseTransferSendManyPayload(widget.item.inputHex!);
  }

  bool get isQutilSendToMany =>
      QutilInfo.isSendToManyTransfer(widget.item.destId, widget.item.type);

  late final bool isIncoming;

  @override
  void initState() {
    super.initState();
    isIncoming = appStore.findAccountById(widget.item.destId) != null;
    if (isQutilSendToMany) {
      parseTransferSendManyPayload().then((value) {
        setState(() {
          sendManyTransfers = value;
        });
      });
    }
  }

  int get _amount => isQxTransferShares
      ? (int.tryParse(widget.assetTransfer!.numberOfUnits) ?? 0)
      : widget.item.amount;


  /// Amount with +/- prefix (no sign for 0)
  String get formattedAmount {
    final formatted = _numberFormat.format(_amount);
    if (_amount == 0) return formatted;
    final prefix = isIncoming ? "+" : "-";
    return "$prefix$formatted";
  }

  Widget _buildStatusLabel(BuildContext context) {
    final status = widget.item.getStatus();
    final statusText =
        TransactionStatusHelpers.getTransactionStatusText(status, context);
    final statusColor =
        TransactionStatusHelpers.getTransactionStatusColor(status);
    const textStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.24,
      height: 1.31,
    );

    Color bgColor;
    if (status == ComputedTransactionStatus.pending) {
      bgColor = LightThemeColors.warning90;
    } else if (status == ComputedTransactionStatus.failure ||
        status == ComputedTransactionStatus.invalid) {
      bgColor = LightThemeColors.error90;
    } else {
      bgColor = LightThemeColors.success90;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(statusText,
          style: textStyle.copyWith(color: statusColor)),
    );
  }

  Widget getButtonBar(BuildContext context) {
    final l10n = l10nOf(context);
    return Padding(
        padding: const EdgeInsets.fromLTRB(
            0, ThemePaddings.smallPadding, 0, ThemePaddings.smallPadding),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child:
                      TransactionActionHelpers.canViewInExplorer(widget.item)
                          ? ThemedControls.primaryButtonBigWithChild(
                              onPressed: () {
                                Navigator.pop(context);
                                viewTransactionInExplorer(
                                    context, widget.item.id,
                                    tick: widget.item.targetTick);
                              },
                              child: Text(
                                  l10n.transactionItemButtonViewInExplorer,
                                  textAlign: TextAlign.center,
                                  style: TextStyles.primaryButtonText))
                          : ThemedControls.primaryButtonBigDisabled(
                              text: l10n.transactionItemButtonViewInExplorer),
                ),
              ],
            ),
            if (TransactionActionHelpers.canResend(widget.item) ||
                TransactionActionHelpers.canDelete(widget.item))
              ThemedControls.spacerVerticalSmall(),
            Row(
              children: [
                if (TransactionActionHelpers.canResend(widget.item))
                  Expanded(
                    child: ThemedControls.transparentButtonBigWithChild(
                        onPressed: () {
                          Navigator.pop(context);
                          pushScreen(
                            context,
                            screen: Send(
                                amount: widget.item.amount,
                                destId: widget.item.destId,
                                item: appStore
                                    .findAccountById(widget.item.sourceId)!),
                            withNavBar: false,
                            pageTransitionAnimation:
                                PageTransitionAnimation.cupertino,
                          );
                        },
                        child: Text(l10n.transactionItemButtonResend,
                            textAlign: TextAlign.center,
                            style: TextStyles.transparentButtonText)),
                  ),
                if (TransactionActionHelpers.canDelete(widget.item)) ...[
                  if (TransactionActionHelpers.canResend(widget.item))
                    ThemedControls.spacerHorizontalSmall(),
                  Expanded(
                    child: ThemedControls.transparentButtonBigWithChild(
                        onPressed: () {
                          appStore.removeStoredTransaction(widget.item.id);
                          Navigator.pop(context);
                        },
                        child: Text(l10n.generalButtonDelete,
                            textAlign: TextAlign.center,
                            style: TextStyles.destructiveButtonText)),
                  ),
                ],
              ],
            ),
          ],
        ));
  }

  //Gets the from and To labels
  Widget getFromTo(BuildContext context, String label, String accountId) {
    return Flex(direction: Axis.horizontal, children: [
      Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
            // Simple "From" / "To" label.
            SizedBox(
                width: double.infinity,
                child: Text(label,
                    textAlign: TextAlign.start,
                    style: TextStyles.lightGreyTextNormal)),
            // Value: account name / contract label + (truncated address),
            // matching the format used in the transaction list cell.
            Observer(builder: (context) {
              final QubicListVm? account = appStore.findAccountById(accountId);
              final String displayName;
              if (account != null) {
                displayName = account.name;
              } else {
                displayName = AddressUIHelper.getLabel(context, accountId) ??
                    AddressUIHelper.truncateAddress(accountId);
              }
              final truncated = AddressUIHelper.truncateAddress(accountId);
              final hasName = displayName != truncated;
              final isSC = AddressUIHelper.isSmartContract(accountId);
              return Row(children: [
                if (isSC) ...[
                  SvgPicture.asset(AppIcons.smartContract,
                      width: 16,
                      height: 16,
                      colorFilter: ColorFilter.mode(
                          TextStyles.textNormal.color ?? Colors.white,
                          BlendMode.srcIn)),
                  const SizedBox(width: 4),
                ],
                Flexible(
                    child: Text(displayName,
                        style: TextStyles.textNormal,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1)),
                if (hasName)
                  Text(' ($truncated)', style: TextStyles.textNormal),
              ]);
            }),
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
                          if (isQxTransferShares) ...[
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
                            ThemedControls.spacerVerticalSmall(),
                          ],
                          Center(child: _buildStatusLabel(context)),
                          ThemedControls.spacerVerticalSmall(),
                          Center(
                            child: CopyableText(
                              copiedText: _amount.toString(),
                              child: FittedBox(
                                child: Text.rich(
                                  TextSpan(children: [
                                    TextSpan(
                                        text: formattedAmount,
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: -0.48,
                                          height: 1.33,
                                          color: Colors.white,
                                        )),
                                    TextSpan(
                                        text: "  ${isQxTransferShares ? widget.assetTransfer!.assetName : l10n.generalLabelCurrencyQubic}",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: -0.48,
                                          color: LightThemeColors
                                              .secondaryTypography,
                                        )),
                                  ]),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      ThemedControls.spacerVerticalNormal(),
                      Expanded(
                          child: Scrollbar(
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              // Order matches the wallet-extension transaction
                              // details page: id → type → from → to → tick →
                              // timestamp.
                              getCopyableDetails(
                                  context,
                                  l10n.transactionItemLabelTransactionId,
                                  widget.item.id),
                              ThemedControls.spacerVerticalSmall(),
                              Observer(
                                  builder: (context) => getCopyableDetails(
                                      context,
                                      l10n.transactionItemLabelTransactionType,
                                      TransactionUIHelpers
                                          .getTransactionTypeLong(
                                              widget.item.type ?? 0,
                                              widget.item.destId))),
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
                              getCopyableDetails(
                                  context,
                                  l10n.generalLabelTick,
                                  widget.item.targetTick.asThousands()),
                              ThemedControls.spacerVerticalSmall(),
                              getCopyableDetails(
                                  context,
                                  l10n.transactionItemLabelConfirmedDate,
                                  widget.item.timestamp != null
                                      ? DateFormatter.formatShortWithTime(
                                          widget.item.timestamp!)
                                      : l10n.generalLabelNotAvailable),
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
