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
  openEmailApp(BuildContext context) async {
    String platform = "";

    if (UniversalPlatform.isIOS) {
      platform = "iOS";
    } else if (UniversalPlatform.isAndroid) {
      platform = "Android";
    } else if (UniversalPlatform.isMacOS) {
      platform = "MacOS";
    } else if (UniversalPlatform.isWindows) {
      platform = "Windows";
    } else if (UniversalPlatform.isLinux) {
      platform = "Linux";
    }

    String emailTo = "wallet";
    String subject = l10nOf(context).emailFeedbackSubject;

    if (platform.isNotEmpty) {
      emailTo = "$emailTo+${platform.toLowerCase()}@qubic.org";
      subject = "$subject - $platform";
    } else {
      emailTo = "$emailTo@qubic.org";
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
            onPressed: () {
              openEmailApp(context);
            },
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
          LinkListTile(
            title: l10n.settingsSupportGoogleForm,
            prefixIconPath: AppIcons.google,
            url: "https://forms.gle/kDomnBQew161iAsn8",
          ),
        ],
      ),
    );
  }
}
