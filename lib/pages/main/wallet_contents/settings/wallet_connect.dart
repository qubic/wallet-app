import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:qubic_wallet/components/copyable_text.dart';
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

  PairingMetadata? pairingMetadata;
  List<String> pairingMethods = [];
  List<String> pairingEvents = [];
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

    if (walletConnectEnabled) {
      walletConnectService.initialize().then((value) {
        setState(() {
          sessions.clear();
          sessions.addAll(walletConnectService.web3Wallet!.getActiveSessions());
          print("Loading " + sessions.keys.length.toString() + " sessions");
        });

        sessionConnectSubscription = walletConnectService
            .onSessionConnect.stream
            .listen((SessionConnect? onData) {
          print("Got session connect " + onData!.session.topic);
          setState(() {
            sessions.clear();
            sessions
                .addAll(walletConnectService.web3Wallet!.getActiveSessions());
          });
        });

        sessionDisconnectSubscription = walletConnectService
            .onSessionDisconnect.stream
            .listen((SessionDelete? onData) {
          print("Got session disconnect " + onData!.topic);
          setState(() {
            sessions.clear();
            sessions
                .addAll(walletConnectService.web3Wallet!.getActiveSessions());
          });
        });

        walletConnectService.onSessionProposal.stream
            .listen((SessionProposalEvent? args) {
          print("Got session proposal");
          print(args);
          setState(() {
            status = "Pending session proposal";
            if (args != null) {
              pairingId = args.id;
              pairingMetadata = args.params.proposer.metadata;

              //Manual parsing (without registering events and methods)
              // if ((args.params.requiredNamespaces.keys.firstOrNull != null) &&
              //     (args.params.requiredNamespaces.keys.firstOrNull ==
              //         "qubic:main")) {
              //   pairingMethods =
              //       args.params.requiredNamespaces.entries.first.value.methods;
              //   pairingEvents =
              //       args.params.requiredNamespaces.entries.first.value.events;
              // } else {
              //Automatic parsing (with registering events and methods)
              pairingMethods = args.params.generatedNamespaces != null
                  ? args.params.generatedNamespaces!.entries.first.value.methods
                  : [];
              pairingEvents = args.params.generatedNamespaces != null
                  ? args.params.generatedNamespaces!.entries.first.value.events
                  : [];
              pairingNamespaces = args.params.generatedNamespaces;
              //}
            }
          });
        });
      });

      // walletConnectService.initialize().then((value) {
      //   setState(() {
      //     isLoading = false;
      //     status = "Ready for connection";

      //     walletConnectService.web3Wallet!.onSessionProposal.subscribe((args) {
      //       print("Session proposal");

      //       });
      //     });
      //     walletConnectService.web3Wallet!.onSessionConnect.subscribe((args) {
      //       setState(() {
      //         status = "Session connected";
      //       });
      //       print("Sesion connect");
      //       print(args);
      //     });

      //     walletConnectService.web3Wallet!.onSessionProposalError
      //         .subscribe((args) {
      //       print("Session proposal error");
      //       print(args);
      //     });
      //   });
      // });
    }
  }

  List<String> getMethods(SessionData sessionData) {
    List<String> methods = [];
    if (sessionData.requiredNamespaces == null) {
      return [];
    }
    if (sessionData.requiredNamespaces!["qubic:main"] == null) {
      return [];
    }
    sessionData.requiredNamespaces?["qubic:main"]!.methods.forEach((string) {
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
                walletConnectService.web3Wallet!.disconnectSession(
                    reason: WalletConnectError(
                        code: -1, message: "User forcefully disconnected"),
                    topic: sessionData.topic);
              },
              child: Text("Revoke permissions"))
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
