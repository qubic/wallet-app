part of '../approve_wc_method_screen.dart';

class _SmartContractWarningCard extends StatelessWidget {
  const _SmartContractWarningCard();

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return ThemedControls.card(
        borderColor: LightThemeColors.warning40,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            SvgPicture.asset(AppIcons.warning, height: 20),
            ThemedControls.spacerHorizontalSmall(),
            Text(
              l10n.wcSmartContractWarningTitle,
              style: TextStyles.labelText
                  .copyWith(color: LightThemeColors.warning40),
            )
          ]),
          ThemedControls.spacerVerticalSmall(),
          Text(
            l10n.wcSmartContractWarningDescription,
            style: TextStyles.secondaryText,
          )
        ]));
  }
}
