part of '../approve_wc_method_screen.dart';

class _ApprovalButtons extends StatelessWidget {
  final bool isLoading;
  final Function() onApprovalTap;
  final WalletConnectMethod method;
  const _ApprovalButtons(
      {required this.isLoading,
      required this.onApprovalTap,
      required this.method});

  String getApprovalButtonTitle(AppLocalizations l10n) {
    switch (method) {
      case WalletConnectMethod.signTransaction:
        return l10n.wcSignTransaction;
      case WalletConnectMethod.sendQubic:
        return l10n.wcApproveTransfer;
      case WalletConnectMethod.sendTransaction:
        return l10n.wcApproveTransaction;
      case WalletConnectMethod.signMessage:
        return l10n.wcSignMessage;
      default:
        return l10n.generalButtonApprove;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);

    return Column(mainAxisSize: MainAxisSize.min, children: [
      SizedBox(
        width: double.infinity,
        height: ButtonStyles.buttonHeight,
        child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: LightThemeColors.primary40,
            ),
            onPressed: isLoading ? null : onApprovalTap,
            child: isLoading
                ? SizedBox(
                    height: 23,
                    width: 23,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: LightThemeColors.grey90),
                  )
                : Text(getApprovalButtonTitle(l10n),
                    textAlign: TextAlign.center,
                    style: TextStyles.primaryButtonText)),
      ),
      ThemedControls.spacerVerticalSmall(),
      SizedBox(
          width: double.infinity,
          height: ButtonStyles.buttonHeight,
          child: ThemedControls.dangerButtonBigWithClild(
              child: Padding(
                  padding: const EdgeInsets.all(ThemePaddings.smallPadding),
                  child: Text(l10n.generalButtonReject,
                      style: TextStyles.destructiveButtonText)),
              onPressed: () {
                Navigator.of(context).pop();
              })),
    ]);
  }
}
