import 'package:flutter/material.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/settings/join_community/components/community_list_tile.dart';
import 'package:qubic_wallet/styles/app_icons.dart';
import 'package:qubic_wallet/styles/edge_insets.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:universal_platform/universal_platform.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text("Support", style: TextStyles.textExtraLargeBold),
        centerTitle: true,
      ),
      body: ListView(
        padding: ThemeEdgeInsets.pageInsets,
        children: [
          CommunityListTile(
            title: "Send email",
            prefixIconPath: AppIcons.email,
            hasSuffixIcon: false,
            url: _getEmailUri(context),
          ),
          const CommunityListTile(
            title: "GitHub (File an issue)",
            prefixIconPath: AppIcons.github,
            url: "https://github.com/qubic/wallet-app/issues/new",
          ),
          const CommunityListTile(
            title: "Discord (Support channel)",
            prefixIconPath: AppIcons.discord,
            url:
                "https://discord.com/channels/768887649540243497/1074609434015322132",
          ),
        ],
      ),
    );
  }

  String _getEmailUri(BuildContext context) {
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
    return Uri(
      scheme: 'mailto',
      path: emailTo,
      query: 'subject=$subject',
    ).toString();
  }
}
