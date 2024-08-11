import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qubic_wallet/components/change_foreground.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/styles/edge_insets.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:qubic_wallet/l10n/l10n.dart';

class JoinCommunity extends StatefulWidget {
  const JoinCommunity({super.key});

  @override
  State<JoinCommunity> createState() => _JoinCommunityState();
}

class _JoinCommunityState extends State<JoinCommunity> {
  Widget getHeader() {
    final l10n = l10nOf(context);

    return Padding(
        padding: const EdgeInsets.only(
            left: ThemePaddings.normalPadding,
            right: ThemePaddings.normalPadding,
            top: ThemePaddings.hugePadding,
            bottom: ThemePaddings.smallPadding),
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          Text(l10n.settingsLabelJoinCommunity, style: TextStyles.pageTitle)
        ]));
  }

  Future<void> launchQubicURL(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url, mode: LaunchMode.externalApplication);
    }
  }

  Widget getCommunityOptions() {
    final l10n = l10nOf(context);
    var theme = SettingsThemeData(
      settingsSectionBackground: LightThemeColors.cardBackground,
      //Theme.of(context).cardTheme.color,
      settingsListBackground: LightThemeColors.background,
      dividerColor: Colors.transparent,
      titleTextColor: Theme.of(context).colorScheme.onBackground,
    );

    return Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: SettingsList(
            shrinkWrap: true,
            applicationType: ApplicationType.material,
            contentPadding: const EdgeInsets.all(0),
            darkTheme: theme,
            lightTheme: theme,
            sections: [
              SettingsSection(
                title: null,
                tiles: <SettingsTile>[
                  SettingsTile.navigation(
                    leading: const ChangeForeground(
                        color: LightThemeColors.gradient1,
                        child: Icon(Icons.discord)),
                    title: Text(l10n.joinCommunityLabelDiscord,
                        style: TextStyles.textNormal),
                    trailing: Container(),
                    onPressed: (context) =>
                        {launchQubicURL("https://discord.com/invite/qubic")},
                  ),
                  SettingsTile.navigation(
                    leading: const ChangeForeground(
                        color: LightThemeColors.gradient1,
                        child: Icon(Icons.telegram)),
                    title: Text(l10n.joinCommunityLabelTelegram,
                        style: TextStyles.textNormal),
                    trailing: Container(),
                    onPressed: (context) =>
                        {launchQubicURL("https://t.me/qubic_network")},
                  ),
                  SettingsTile.navigation(
                    leading: const ChangeForeground(
                        color: LightThemeColors.gradient1,
                        child: Icon(FontAwesomeIcons.xTwitter)),
                    title: Text(l10n.joinCommunityLabelTwitter,
                        style: TextStyles.textNormal),
                    trailing: Container(),
                    onPressed: (context) =>
                        {launchQubicURL("https://twitter.com/_Qubic_")},
                  ),
                  SettingsTile.navigation(
                    leading: const ChangeForeground(
                        color: LightThemeColors.gradient1,
                        child: Icon(Icons.reddit)),
                    title: Text(l10n.joinCommunityLabelReddit,
                        style: TextStyles.textNormal),
                    trailing: Container(),
                    onPressed: (context) =>
                        {launchQubicURL("https://www.reddit.com/r/Qubic/")},
                  ),
                  SettingsTile.navigation(
                    leading: const ChangeForeground(
                        color: LightThemeColors.gradient1,
                        child: Icon(FontAwesomeIcons.youtube)),
                    title: Text(l10n.joinCommunityLabelYouTube,
                        style: TextStyles.textNormal),
                    trailing: Container(),
                    onPressed: (context) => {
                      launchQubicURL("https://www.youtube.com/@_qubic_/videos")
                    },
                  ),
                  SettingsTile.navigation(
                    leading: const ChangeForeground(
                        child: Icon(FontAwesomeIcons.github),
                        color: LightThemeColors.gradient1),
                    title: Text(l10n.joinCommunityLabelGitHub,
                        style: TextStyles.textNormal),
                    trailing: Container(),
                    onPressed: (context) =>
                        {launchQubicURL("https://github.com/qubic")},
                  ),
                  SettingsTile.navigation(
                    leading: const ChangeForeground(
                        color: LightThemeColors.gradient1,
                        child: Icon(FontAwesomeIcons.linkedin)),
                    title: Text(l10n.joinCommunityLabelLinkedIn,
                        style: TextStyles.textNormal),
                    trailing: Container(),
                    onPressed: (context) => {
                      launchQubicURL(
                          "https://www.linkedin.com/company/qubicnetwork/")
                    },
                  ),
                ],
              ),
            ]));
  }

  Widget getBody() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [getHeader(), getCommunityOptions()]);
  }

  Widget getSettingsHeader(String text, bool isFirst) {
    return Padding(
        padding: isFirst
            ? const EdgeInsets.fromLTRB(0, 0, 0, ThemePaddings.smallPadding)
            : const EdgeInsets.fromLTRB(
                0, ThemePaddings.bigPadding, 0, ThemePaddings.smallPadding),
        child: Transform.translate(
            offset: const Offset(-16, 0),
            child: Text(text, style: TextStyles.textBold)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
          minimum: ThemeEdgeInsets.pageInsets
              .copyWith(left: 0, right: 0, top: 0, bottom: 0),
          child: Column(children: [
            Expanded(
                child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: getBody()))
          ])),
    );
  }
}
