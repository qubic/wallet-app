import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/global_snack_bar.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/models/wallet_connect.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/settings/wallet_connect/components/wallet_connect_expansion_card.dart';
import 'package:qubic_wallet/resources/secure_storage.dart';
import 'package:qubic_wallet/services/qubic_hub_service.dart';
import 'package:qubic_wallet/services/wallet_connect_service.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/stores/qubic_hub_store.dart';
import 'package:qubic_wallet/stores/settings_store.dart';
import 'package:qubic_wallet/styles/edge_insets.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:url_launcher/url_launcher_string.dart';
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
    final l10n = l10nOf(context);

    List<String> methods = [];
    if (sessionData.requiredNamespaces == null) {
      return [];
    }
    if (sessionData.requiredNamespaces![Config.walletConnectChainId] == null) {
      return [];
    }
    sessionData.requiredNamespaces?[Config.walletConnectChainId]!.methods
        // ignore: avoid_function_literals_in_foreach_calls
        .forEach((string) {
      if ((string == WcMethods.wRequestAccounts)) {
        methods.add(l10n.wcScopeRequestAccounts);
      }
      if (string == WcMethods.wSendQubic) {
        methods.add(l10n.wcScopeSendQubic);
      }
      if (string == WcMethods.wSendAsset) {
        methods.add(l10n.wcScopeSendAssets);
      }
    });
    return methods;
  }

  Future<void> launchQubicURL(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url, mode: LaunchMode.externalApplication);
    }
  }

  Widget getSessions() {
    final l10n = l10nOf(context);

    List<Widget> children = [];
    if (walletConnectService.web3Wallet == null) {
      return Container();
    }
    sessions.forEach((key, sessionData) {
      children.add(
        WallectConnectExpansionCard(
          onOpen: () {
            if (sessionData.peer.metadata.url.isNotEmpty) {
              launchQubicURL(sessionData.peer.metadata.url);
            }
          },
          onRemove: () {
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
          title: [
            Text(
                sessionData.peer.metadata.name.isEmpty
                    ? l10n.wcUnknownDapp
                    : sessionData.peer.metadata.name,
                style: TextStyles.walletConnectDappTitle),
            Text(
                formatValidity(DateTime.fromMillisecondsSinceEpoch(
                    sessionData.expiry * 1000)),
                style: TextStyles.secondaryText),
          ],
          content: ThemedControls.cardWithBg(
              child: getMethods(sessionData).isEmpty
                  ? Center(
                      child: Text(l10n.wcDappsConnectedNone),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.wcAppInfoHeader,
                            style: TextStyles.walletConnectDapPermissionHeader),
                        ThemedControls.spacerVerticalSmall(),
                        ...getMethods(sessionData).map((e) => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Image.asset(
                                        "assets/images/permission-granted.png"),
                                    ThemedControls.spacerHorizontalSmall(),
                                    Expanded(child: Text(e))
                                  ]),
                                  ThemedControls.spacerVerticalMini()
                                ])),
                      ],
                    ),
              bgColor: LightThemeColors.inputFieldBg),
        ),
      );
    });

    return Column(
      children: [
        ...children,
      ],
    );
  }

  String formatValidity(DateTime targetDate) {
    final l10n = l10nOf(context);
    final now = DateTime.now();
    final difference = targetDate.difference(now);

    if (difference.inDays > 1) {
      return l10n.wcExpiersInDays(difference.inDays.toString());
    } else if (difference.inDays == 1) {
      return l10n.wcExpiersInDay;
    } else {
      return l10n.wcExpiersInLessThanDay;
    }
  }

  Widget getScrollView() {
    return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          getSessions(),
        ]));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(l10n.settingsLabelWalletConnect),
        ),
        body: SafeArea(
            minimum: ThemeEdgeInsets.pageInsets,
            child: sessions.isEmpty
                ? Center(child: Text(l10n.wcDappsConnectedNone))
                : Column(children: [
                    Expanded(child: getScrollView()),
                  ])));
  }
}
