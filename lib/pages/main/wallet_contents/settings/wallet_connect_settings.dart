import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/wallet_connect_methods.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/services/wallet_connect_service.dart';
import 'package:qubic_wallet/stores/settings_store.dart';
import 'package:qubic_wallet/styles/edge_insets.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

class WalletConnectSettings extends StatefulWidget {
  const WalletConnectSettings({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _WalletConnectSettingsState createState() => _WalletConnectSettingsState();
}

class _WalletConnectSettingsState extends State<WalletConnectSettings> {
  final SettingsStore settingsStore = getIt<SettingsStore>();
  final WalletConnectService walletConnectService =
      getIt<WalletConnectService>();

  bool walletConnectEnabled = false;
  void setupWCEvents() {}

  Map<String, SessionData> sessions = {};

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      walletConnectEnabled = settingsStore.settings.walletConnectEnabled;
    });
    if (mounted) {
      if ((walletConnectEnabled) && (walletConnectService.web3Wallet != null)) {
        walletConnectService.web3Wallet!
            .getActiveSessions()
            .forEach((key, value) {
          setState(() {
            sessions[key] = value;
          });
        });
      }
    }
  }

  List<String> getMethods(SessionData sessionData) {
    if (sessionData.requiredNamespaces == null) {
      return [];
    }
    if (sessionData.requiredNamespaces![Config.walletConnectChainId] == null) {
      return [];
    }
    List<String> localizedStrings = getLocalizedPairingMethods(
        sessionData.requiredNamespaces?[Config.walletConnectChainId]!.methods ??
            [],
        context);
    return localizedStrings;
  }

  Widget getSessions() {
    final l10n = l10nOf(context);

    var format = DateFormat('EEE, M/d/y HH:mm');

    List<Widget> children = [];
    if (walletConnectService.web3Wallet == null) {
      return Container();
    }
    sessions.forEach((key, sessionData) {
      children.add(ThemedControls.card(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
              sessionData.peer.metadata.name.isEmpty
                  ? l10n.wcUnknownDapp
                  : sessionData.peer.metadata.name,
              style: TextStyles.walletConnectDappTitle),
          Text(
              sessionData.peer.metadata.url.isEmpty
                  ? l10n.wcUnknownDapp
                  : sessionData.peer.metadata.url,
              style: TextStyles.walletConnectDappUrl),
          ThemedControls.spacerVerticalNormal(),
          Text(l10n.wcAppInfoHeader,
              style: TextStyles.walletConnectDapPermissionHeader),
          ThemedControls.spacerVerticalSmall(),
          ...getMethods(sessionData).map((e) =>
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Image.asset("assets/images/permission-granted.png"),
                  ThemedControls.spacerHorizontalSmall(),
                  Expanded(child: Text(e))
                ]),
                ThemedControls.spacerVerticalMini()
              ])),
          ThemedControls.spacerVerticalNormal(),
          ThemedControls.primaryButtonBigWithChild(
              onPressed: () {
                try {
                  setState(() {
                    sessions.remove(sessionData.topic);
                  });
                  walletConnectService.web3Wallet!.disconnectSession(
                      reason: WalletConnectError(
                          code: -1, message: l10n.wcErrorUserDisconnected),
                      topic: sessionData.topic);
                } catch (e) {
                  //Silently ignore
                }
              },
              child: Text(l10n.wcRevokePermissions)),
          ThemedControls.spacerVerticalMini(),
          Center(
              child: Text(
            l10n.wcValidUntil(format.format(DateTime.fromMillisecondsSinceEpoch(
                sessionData.expiry * 1000))),
            style: TextStyles.smallInfoText,
          )),
        ],
      )));
    });

    if (children.isEmpty) {
      return Text(l10n.wcDappsConnectedNone);
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ThemedControls.spacerVerticalSmall(),
      Text(l10n.wcDappsConnectedFollowing),
      ThemedControls.spacerVerticalBig(),
      ...children,
    ]);
  }

  Widget getWalletConnectEnabledRadio() {
    final l10n = l10nOf(context);

    var theme = SettingsThemeData(
      settingsSectionBackground: LightThemeColors.cardBackground,
      //Theme.of(context).cardTheme.color,
      settingsListBackground: LightThemeColors.background,
      dividerColor: Colors.transparent,
      titleTextColor: Theme.of(context).colorScheme.onSurface,
    );
    return Column(children: [
      SettingsList(
          shrinkWrap: true,
          applicationType: ApplicationType.material,
          contentPadding: const EdgeInsets.all(0),
          darkTheme: theme,
          lightTheme: theme,
          sections: [
            SettingsSection(
              tiles: <SettingsTile>[
                SettingsTile.switchTile(
                  onToggle: (value) async {
                    setState(() {
                      walletConnectEnabled = value;
                    });
                    if (value == true) {
                      await settingsStore.setWalletConnectEnabled(true);
                      await walletConnectService.initialize();
                    } else {
                      await settingsStore.setWalletConnectEnabled(false);
                      walletConnectService.disconnect();
                    }
                  },
                  initialValue: walletConnectEnabled,
                  title: Text(l10n.wcEnable, style: TextStyles.labelText),
                ),
              ],
            ),
          ])
    ]);
  }

  Widget getScrollView() {
    final l10n = l10nOf(context);

    return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          //Create a radio button
          getWalletConnectEnabledRadio(),
          ThemedControls.spacerVerticalNormal(),
          Text(l10n.wcApprovedConnections, style: TextStyles.sliverHeader),
          getSessions(),
        ]));
  }

  List<Widget> getButtons() {
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
        ),
        body: SafeArea(
            minimum: ThemeEdgeInsets.pageInsets,
            child: Column(children: [
              Expanded(child: getScrollView()),
              Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: getButtons())
            ])));
  }
}
