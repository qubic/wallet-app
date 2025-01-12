part of '../approve_wc_method_screen.dart';

class _ApprovalCard extends StatefulWidget {
  const _ApprovalCard({
    required this.data,
    required this.method,
  });

  final ApprovalDataModel data;
  final WalletConnectMethod method;

  @override
  State<_ApprovalCard> createState() => _ApprovalCardState();
}

class _ApprovalCardState extends State<_ApprovalCard> {
  final ApplicationStore appStore = getIt<ApplicationStore>();
  String? toIdName;

  @override
  void initState() {
    super.initState();

    var item = appStore.findAccountById(widget.data.toID);
    setState(() {
      toIdName = item?.name;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return ThemedControls.card(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (widget.method == WalletConnectMethod.signTransaction ||
            widget.method == WalletConnectMethod.signMessage) ...[
          Center(
              child: Text(
                  widget.method == WalletConnectMethod.signTransaction
                      ? l10n.wcApproveSignTransferOf
                      : l10n.wcApproveSignOf,
                  style: TextStyles.sliverHeader)),
          ThemedControls.spacerVerticalNormal(),
        ],
        if (widget.data.message != null) ...[
          Center(
            child: Text(widget.data.message!.replaceAll(r'\n', '\n'),
                textAlign: TextAlign.center, style: TextStyles.textNormal),
          ),
          ThemedControls.spacerVerticalBig(),
        ],
        if (widget.data.amount != null) ...[
          Center(
              child: AmountValueHeader(
                  amount: widget.data.amount!,
                  suffix:
                      widget.data.assetName ?? l10n.generalLabelCurrencyQubic)),
          ThemedControls.spacerVerticalBig(),
        ],
        Text(
          l10n.generalLabelToFromAccount(
              l10n.generalLabelFrom, widget.data.fromName ?? "-"),
          style: TextStyles.lightGreyTextSmall,
        ),
        ThemedControls.spacerVerticalMini(),
        Text(widget.data.fromID, style: TextStyles.textNormal),
        if (widget.data.toID != null) ...[
          ThemedControls.spacerVerticalSmall(),
          toIdName != null
              ? Text(
                  l10n.generalLabelToFromAccount(
                      l10n.generalLabelTo, toIdName!),
                  style: TextStyles.lightGreyTextSmall,
                )
              : Text(
                  l10n.generalLabelToFromAddress(l10n.generalLabelTo),
                  style: TextStyles.lightGreyTextSmall,
                ),
          ThemedControls.spacerVerticalMini(),
          Text(widget.data.toID ?? "-", style: TextStyles.textNormal),
        ],
        if (widget.data.tick != null) ...[
          ThemedControls.spacerVerticalSmall(),
          Text(
            l10n.generalLabelTick,
            style: TextStyles.lightGreyTextSmall,
          ),
          Text(widget.data.tick?.asThousands() ?? "-",
              style: TextStyles.textNormal),
        ],
        if (widget.data.inputType != null) ...[
          ThemedControls.spacerVerticalSmall(),
          Text(
            l10n.generalLabelInputType,
            style: TextStyles.lightGreyTextSmall,
          ),
          Text(widget.data.inputType!.toString(), style: TextStyles.textNormal),
        ],
        if (widget.data.payload != null) ...[
          ThemedControls.spacerVerticalSmall(),
          Text(
            l10n.generalLabelPayload,
            style: TextStyles.lightGreyTextSmall,
          ),
          Text(widget.data.payload!, style: TextStyles.textNormal)
        ],
        if (widget.method == WalletConnectMethod.sendAsset) ...[
          ThemedControls.spacerVerticalSmall(),
          Text(
            l10n.sendAssetLabelTransactionCost,
            style: TextStyles.lightGreyTextSmall,
          ),
          Text(
              "${QxInfo.transferAssetFee.asThousands()} ${l10n.generalLabelCurrencyQubic}",
              style: TextStyles.textNormal)
        ]
      ]),
    );
  }
}
