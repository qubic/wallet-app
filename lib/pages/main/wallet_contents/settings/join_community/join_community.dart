import 'package:flutter/material.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/settings/join_community/components/link_list_tile.dart';
import 'package:qubic_wallet/styles/app_icons.dart';
import 'package:qubic_wallet/styles/edge_insets.dart';
import 'package:qubic_wallet/styles/text_styles.dart';

class JoinCommunity extends StatelessWidget {
  const JoinCommunity({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(l10n.settingsLabelJoinCommunity,
            style: TextStyles.textExtraLargeBold),
        centerTitle: true,
      ),
      body: ListView(
        padding: ThemeEdgeInsets.pageInsets,
        children: [
          LinkListTile(
              title: l10n.joinCommunityLabelDiscord,
              prefixIconPath: AppIcons.discord,
              url: "https://discord.com/invite/qubic"),
          LinkListTile(
              title: l10n.joinCommunityLabelTelegram,
              prefixIconPath: AppIcons.telegram,
              url: "https://t.me/qubic_network"),
          LinkListTile(
              title: l10n.joinCommunityLabelTwitter,
              prefixIconPath: AppIcons.x,
              url: "https://twitter.com/_Qubic_"),
          LinkListTile(
              title: l10n.joinCommunityLabelReddit,
              prefixIconPath: AppIcons.reddit,
              url: "https://www.reddit.com/r/Qubic/"),
          LinkListTile(
              title: l10n.joinCommunityLabelYouTube,
              prefixIconPath: AppIcons.youtube,
              url: "https://www.youtube.com/@_qubic_/videos"),
          LinkListTile(
              title: l10n.joinCommunityLabelGitHub,
              prefixIconPath: AppIcons.github,
              url: "https://github.com/qubic"),
          LinkListTile(
              title: l10n.joinCommunityLabelLinkedIn,
              prefixIconPath: AppIcons.linkedin,
              url: "https://www.linkedin.com/company/qubicnetwork/"),
          LinkListTile(
              title: l10n.joinCommunityLabelTiktok,
              prefixIconPath: AppIcons.tiktok,
              url: "https://www.tiktok.com/@_qubic_official"),
          LinkListTile(
              title: l10n.joinCommunityLabelInstagram,
              prefixIconPath: AppIcons.instagram,
              url: "https://www.instagram.com/_qubic_official/"),
        ],
      ),
    );
  }
}
