import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:qubic_wallet/components/copyable_text.dart';
import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/global_snack_bar.dart';
import 'package:qubic_wallet/resources/secure_storage.dart';
import 'package:qubic_wallet/services/qubic_hub_service.dart';
import 'package:qubic_wallet/services/wallet_connect_service.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/stores/qubic_hub_store.dart';
import 'package:qubic_wallet/stores/settings_store.dart';
import 'package:qubic_wallet/styles/edge_insets.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:url_launcher/link.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

class WalletConnect extends StatefulWidget {
  const WalletConnect({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AboutWalletState createState() => _AboutWalletState();
}

class _AboutWalletState extends State<WalletConnect> {
  final ApplicationStore appStore = getIt<ApplicationStore>();
  final SettingsStore settingsStore = getIt<SettingsStore>();
  final SecureStorage secureStorage = getIt<SecureStorage>();
  final QubicHubStore qubicHubStore = getIt<QubicHubStore>();
  final QubicHubService qubicService = getIt<QubicHubService>();
  final GlobalSnackBar snackBar = getIt<GlobalSnackBar>();
  final WalletConnectService walletConnectService =
      getIt<WalletConnectService>();
  bool isLoading = false;

  TextEditingController pairController = TextEditingController();

  String status = "Initializing...";

  String state =
      "idle"; //proposalWaiting, proposalRejected, proposalAccepted, sessionConnected

  int? pairingId;
  Map<String, Namespace>? pairingNamespaces;

  bool walletConnectEnabled = false;

  StreamSubscription<SessionConnect?>? sessionConnectSubscription;
  StreamSubscription<SessionDelete?>? sessionDisconnectSubscription;
  StreamSubscription<SessionProposalEvent?>? sessionProposalSubscription;
  void setupWCEvents() {}

  Map<String, SessionData> sessions = {};

  @override
  void dispose() {
    super.dispose();
    sessionConnectSubscription?.cancel();
    sessionDisconnectSubscription?.cancel();
    sessionProposalSubscription?.cancel();
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
    List<String> methods = [];
    if (sessionData.requiredNamespaces == null) {
      return [];
    }
    if (sessionData.requiredNamespaces![Config.walletConnectChainId] == null) {
      return [];
    }
    sessionData.requiredNamespaces?[Config.walletConnectChainId]!.methods
        .forEach((string) {
      if ((string == "wallet_requestAccounts")) {
        methods.add(
            "View your wallet accounts and their balance"); //<!-- TODO ADD TRANSLATION HERE
      }
      if (string == "sendQubic") {
        methods.add(
            "Ask you to send Qubic from your wallet accounts"); //<!-- TODO ADD TRANSLATION HERE
      }
      if (string == "sendAsset") {
        methods.add(
            "Ask you to send Qubic Assets from your wallet accounts"); //<!-- TODO ADD TRANSLATION HERE
      }
    });
    return methods;
  }

  Widget getSessions() {
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
          Text(sessionData.peer.metadata.name ?? "Unknown dApp",
              style: TextStyles.walletConnectDappTitle),
          Text(sessionData.peer.metadata.url ?? "Unknown dApp",
              style: TextStyles.walletConnectDappUrl),
          ThemedControls.spacerVerticalNormal(),
          Text("This app is be able to",
              style: TextStyles.walletConnectDapPermissionHeader),
          ThemedControls.spacerVerticalSmall(),
          ...getMethods(sessionData)
              .map((e) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Image.asset("assets/images/permission-granted.png"),
                          ThemedControls.spacerHorizontalSmall(),
                          Expanded(child: Text(e))
                        ]),
                        ThemedControls.spacerVerticalMini()
                      ]))
              .toList(),
          ThemedControls.spacerVerticalNormal(),
          ThemedControls.primaryButtonBigWithChild(
              onPressed: () {
                try {
                  setState(() {
                    sessions.remove(sessionData.topic);
                  });
                  walletConnectService.web3Wallet!.disconnectSession(
                      reason: WalletConnectError(
                          code: -1, message: "User forcefully disconnected"),
                      topic: sessionData.topic);
                } catch (e) {
                  //Silently ignore
                }
              },
              child: Text("Revoke permissions")),
          ThemedControls.spacerVerticalMini(),
          Center(
              child: Text(
            "valid until ${format.format(DateTime.fromMillisecondsSinceEpoch(sessionData.expiry * 1000))}",
            style: TextStyles.smallInfoText,
          )),
        ],
      )));
    });

    if (children.isEmpty) {
      return Text("Your wallet is not connected to any dApps");
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ThemedControls.spacerVerticalSmall(),
      Text("Your wallet is connected with the following dApps:"),
      ThemedControls.spacerVerticalBig(),
      ...children,
    ]);
  }

  Widget getWalletConnectEnabledRadio() {
    var theme = SettingsThemeData(
      settingsSectionBackground: LightThemeColors.cardBackground,
      //Theme.of(context).cardTheme.color,
      settingsListBackground: LightThemeColors.background,
      dividerColor: Colors.transparent,
      titleTextColor: Theme.of(context).colorScheme.onBackground,
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

                      sessionConnectSubscription?.cancel();
                      walletConnectService.disconnect();
                    }
                  },
                  initialValue: walletConnectEnabled,
                  title: Text("Enable Wallet Connect",
                      style: TextStyles.labelText),
                ),
              ],
            ),
          ])
    ]);
  }

  Widget getScrollView() {
    return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          //Create a radio button
          getWalletConnectEnabledRadio(),
          ThemedControls.spacerVerticalNormal(),
          Text("Approved connections", style: TextStyles.sliverHeader),
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
