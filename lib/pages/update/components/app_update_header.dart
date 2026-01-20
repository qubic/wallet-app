part of '../app_update_screen.dart';

class _AppUpdateHeader extends StatelessWidget {
  final bool isForceUpdate;

  const _AppUpdateHeader({required this.isForceUpdate});

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);

    return Column(
      children: [
        Text(
          isForceUpdate ? l10n.updateRequiredTitle : l10n.updateAvailableTitle,
          style: TextStyles.textEnormous.copyWith(
            fontWeight: FontWeight.bold,
            color: LightThemeColors.primary,
          ),
          textAlign: TextAlign.center,
        ),
        ThemedControls.spacerVerticalBig(),
        Text(
          isForceUpdate
              ? l10n.updateRequiredMessage
              : l10n.updateAvailableMessage,
          style: TextStyles.textNormal.copyWith(
            color: LightThemeColors.textColorSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
