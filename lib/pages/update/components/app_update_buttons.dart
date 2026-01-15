part of '../app_update_screen.dart';

class _AppUpdateButtons extends StatelessWidget {
  final AppVersionCheckModel versionInfo;
  final VoidCallback onUpdatePressed;
  final VoidCallback onLaterPressed;
  final VoidCallback onIgnorePressed;

  const _AppUpdateButtons({
    required this.versionInfo,
    required this.onUpdatePressed,
    required this.onLaterPressed,
    required this.onIgnorePressed,
  });

  bool get _hasAllOptions =>
      versionInfo.showLaterButton && versionInfo.showIgnoreButton;

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);

    // Scenario 1: Force update - only Update button at bottom
    if (versionInfo.updateType == UpdateType.force) {
      return ThemedControls.primaryButtonBig(
        onPressed: onUpdatePressed,
        text: l10n.updateButton,
      );
    }

    final showLater = versionInfo.showLaterButton;
    final showIgnore = versionInfo.showIgnoreButton;

    // Scenario 3: All three options - Update in card, Later & Skip in row
    if (_hasAllOptions) {
      return Row(
        children: [
          Expanded(
            child: ThemedControls.transparentButtonNormal(
              onPressed: onLaterPressed,
              text: l10n.laterButton,
            ),
          ),
          ThemedControls.spacerHorizontalNormal(),
          Expanded(
            child: ThemedControls.dangerButtonBigWithClild(
              onPressed: onIgnorePressed,
              child: Text(
                l10n.ignoreVersionButton,
                style: TextStyles.destructiveButtonText,
              ),
            ),
          ),
        ],
      );
    }

    // Scenario 2: Two options - Update first, then the other option
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ThemedControls.primaryButtonBig(
          onPressed: onUpdatePressed,
          text: l10n.updateButton,
        ),
        if (showLater)
          ThemedControls.transparentButtonNormal(
            onPressed: onLaterPressed,
            text: l10n.laterButton,
          ),
        if (showIgnore)
          ThemedControls.dangerButtonBigWithClild(
            onPressed: onIgnorePressed,
            child: Text(
              l10n.ignoreVersionButton,
              style: TextStyles.destructiveButtonText,
            ),
          ),
      ],
    );
  }
}
