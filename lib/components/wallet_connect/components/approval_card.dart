part of '../approve_wc_method_screen.dart';

class _ApprovalCard extends StatelessWidget {
  const _ApprovalCard({
    required this.data,
    required this.method,
  });

  final ApprovalDataModel data;
  final WalletConnectMethod method;

  /// "From"/"To" block for the WalletConnect signing surface:
  /// "From: <displayName>" (truncated) on one line, then the full address.
  /// Showing the full address on this screen is intentional — the user is
  /// authorizing a transfer to a dApp-supplied destination and must be
  /// able to verify it.
  Widget _buildFromTo(BuildContext context, String label, String accountId) {
    final appStore = getIt<ApplicationStore>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Observer(builder: (context) {
          final account = appStore.findAccountById(accountId);
          final String? displayName = account?.name ??
              AddressUIHelper.getLabel(context, accountId);
          final isSC = AddressUIHelper.isSmartContract(accountId);
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(displayName != null ? "$label: " : label,
                  style: TextStyles.lightGreyTextSmall),
              if (displayName != null) ...[
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
                        style: TextStyles.textNormal
                            .copyWith(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1)),
              ],
            ],
          );
        }),
        ThemedControls.spacerVerticalMini(),
        Text(accountId, style: TextStyles.textNormal),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return ThemedControls.card(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (method == WalletConnectMethod.signTransaction ||
            method == WalletConnectMethod.signMessage) ...[
          Center(
              child: Text(
                  method == WalletConnectMethod.signTransaction
                      ? l10n.wcApproveSignTransferOf
                      : l10n.wcApproveSignOf,
                  style: TextStyles.sliverHeader)),
          ThemedControls.spacerVerticalNormal(),
        ],
        if (data.message != null) ...[
          Center(
            child: Text(data.message!.replaceAll(r'\n', '\n'),
                textAlign: TextAlign.center, style: TextStyles.textNormal),
          ),
          ThemedControls.spacerVerticalBig(),
        ],
        if (data.amount != null) ...[
          Center(
              child: AmountValueHeader(
                  amount: data.amount!,
                  suffix: data.assetName ?? l10n.generalLabelCurrencyQubic)),
          ThemedControls.spacerVerticalBig(),
        ],
        _buildFromTo(context, l10n.generalLabelFrom, data.fromID),
        if (data.toID != null) ...[
          ThemedControls.spacerVerticalSmall(),
          _buildFromTo(context, l10n.generalLabelTo, data.toID!),
        ],
        if (data.tick != null) ...[
          ThemedControls.spacerVerticalSmall(),
          Text(
            l10n.generalLabelTick,
            style: TextStyles.lightGreyTextSmall,
          ),
          Text(data.tick?.asThousands() ?? "-",
              style: TextStyles.textNormal),
        ],
        if (data.inputType != null) ...[
          ThemedControls.spacerVerticalSmall(),
          Text(
            l10n.generalLabelInputType,
            style: TextStyles.lightGreyTextSmall,
          ),
          Text(
              TransactionUIHelpers.getTransactionType(
                  data.inputType ?? 0, data.toID!),
              style: TextStyles.textNormal),
        ],
        if (data.payload != null) ...[
          ThemedControls.spacerVerticalSmall(),
          Text(
            l10n.generalLabelPayload,
            style: TextStyles.lightGreyTextSmall,
          ),
          Text(data.payload!, style: TextStyles.textNormal)
        ],
        if (method == WalletConnectMethod.sendAsset) ...[
          ThemedControls.spacerVerticalSmall(),
          Text(
            l10n.generalLabelFee,
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
