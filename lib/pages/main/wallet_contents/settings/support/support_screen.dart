import 'package:flutter/material.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/settings/join_community/components/link_list_tile.dart';
import 'package:qubic_wallet/styles/app_icons.dart';
import 'package:qubic_wallet/styles/edge_insets.dart';
import 'package:qubic_wallet/styles/text_styles.dart';

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
          LinkListTile(
            title: l10n.settingsSupportGoogleForm,
            prefixIconPath: AppIcons.google,
            url: "https://forms.gle/kDomnBQew161iAsn8",
          ),
          LinkListTile(
            title: l10n.settingsSupportGithub,
            prefixIconPath: AppIcons.github,
            url: "https://github.com/qubic/wallet-app/issues/new",
          ),
          LinkListTile(
            title: l10n.settingsSupportDiscord,
            prefixIconPath: AppIcons.discord,
            url:
                "https://discord.com/channels/768887649540243497/1074609434015322132",
          ),
        ],
      ),
    );
  }
}
