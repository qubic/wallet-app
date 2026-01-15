part of '../app_update_screen.dart';

class _AppUpdateInfoCard extends StatelessWidget {
  final AppVersionCheckModel versionInfo;
  final String? currentVersion;
  final VoidCallback onUpdatePressed;

  const _AppUpdateInfoCard({
    required this.versionInfo,
    required this.currentVersion,
    required this.onUpdatePressed,
  });

  bool get _hasAllOptions =>
      versionInfo.showLaterButton && versionInfo.showIgnoreButton;

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);

    return ThemedControls.card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AppUpdateInfoRow(
            label: l10n.updateScreenCurrentVersion,
            value: currentVersion ?? 'Unknown',
          ),
          ThemedControls.spacerVerticalSmall(),
          _AppUpdateInfoRow(
            label: l10n.updateScreenNewVersion,
            value: versionInfo.version,
          ),
          if (versionInfo.releaseNotes != null) ...[
            ThemedControls.spacerVerticalSmall(),
            Text(
              l10n.updateScreenWhatsNew,
              style: TextStyles.secondaryText,
            ),
            ThemedControls.spacerVerticalSmall(),
            Text(
              versionInfo.releaseNotes!,
              style: TextStyles.textNormal.copyWith(
                color: LightThemeColors.primary,
              ),
            ),
          ],
          if (_hasAllOptions) ...[
            ThemedControls.spacerVerticalBig(),
            SizedBox(
              width: double.infinity,
              child: ThemedControls.primaryButtonBig(
                onPressed: onUpdatePressed,
                text: l10n.updateButton,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AppUpdateInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _AppUpdateInfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyles.secondaryText,
        ),
        Text(
          value,
          style: TextStyles.textNormal.copyWith(
            fontWeight: FontWeight.w600,
            color: LightThemeColors.primary,
          ),
        ),
      ],
    );
  }
}
