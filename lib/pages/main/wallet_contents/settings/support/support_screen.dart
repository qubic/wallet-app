import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/settings/join_community/components/link_list_tile.dart';
import 'package:qubic_wallet/styles/app_icons.dart';
import 'package:qubic_wallet/styles/edge_insets.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(l10n.settingsLabelSupport,
            style: TextStyles.textExtraLargeBold),
        centerTitle: true,
      ),
      body: ListView(
        padding: ThemeEdgeInsets.pageInsets,
        children: [
          ThemedControls.card(
              borderColor: LightThemeColors.warning40,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      SvgPicture.asset(AppIcons.warning, height: 20),
                      ThemedControls.spacerHorizontalSmall(),
                      Expanded(
                          child: Text(
                        l10n.settingsSupportWarningTitle,
                        style: TextStyles.labelText
                            .copyWith(color: LightThemeColors.warning40),
                      ))
                    ]),
                    ThemedControls.spacerVerticalSmall(),
                    Text(
                      l10n.settingsSupportWarningDescription,
                      style: TextStyles.secondaryText,
                    )
                  ])),
          const SizedBox(height: ThemePaddings.normalPadding),
          LinkListTile(
            title: l10n.settingsSupportDiscord,
            prefixIconPath: AppIcons.discord,
            url:
                "https://discord.com/channels/768887649540243497/1074609434015322132",
          ),
          LinkListTile(
            title: l10n.settingsSupportGithub,
            prefixIconPath: AppIcons.github,
            url: "https://github.com/qubic/wallet-app/issues/new",
          ),
        ],
      ),
    );
  }
}
