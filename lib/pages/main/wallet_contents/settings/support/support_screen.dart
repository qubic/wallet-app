import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/pages/main/tab_settings/components/settings_list_tile.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/settings/join_community/components/link_list_tile.dart';
import 'package:qubic_wallet/styles/app_icons.dart';
import 'package:qubic_wallet/styles/edge_insets.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:universal_platform/universal_platform.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});
  openEmailApp() async {
    String emailTo = "wallet+";
    String subject = "Feedback for Qubic Wallet - ";
    if (UniversalPlatform.isIOS) {
      emailTo += "ios@qubic.org";
      subject += "iOS";
    } else if (UniversalPlatform.isAndroid) {
      emailTo += "android@qubic.org";
      subject += "Android";
    } else if (UniversalPlatform.isMacOS) {
      emailTo += "macos@qubic.org";
      subject += "MacOS";
    }
    final Email email = Email(
      subject: subject,
      recipients: [emailTo],
      isHTML: false,
    );

    await FlutterEmailSender.send(email);
  }

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
          SettingsListTile(
            title: l10n.settingsSupportEmail,
            prefix: SvgPicture.asset(
              AppIcons.email,
            ),
            suffix: const SizedBox(),
            onPressed: openEmailApp,
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
