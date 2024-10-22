import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:qubic_wallet/components/confirmation_dialog.dart';
import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/wallet_connect_methods.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/add_wallet_connect/add_wallet_connect.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/settings/wallet_connect/components/wallet_connect_expansion_card.dart';
import 'package:qubic_wallet/services/wallet_connect_service.dart';
import 'package:qubic_wallet/stores/settings_store.dart';
import 'package:qubic_wallet/styles/app_icons.dart';
import 'package:qubic_wallet/styles/button_styles.dart';
import 'package:qubic_wallet/styles/edge_insets.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

class WalletConnectSettings extends StatefulWidget {
  const WalletConnectSettings({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AboutWalletState createState() => _AboutWalletState();
}

class _AboutWalletState extends State<WalletConnectSettings> {
  final WalletConnectService walletConnectService =
      getIt<WalletConnectService>();

  Map<String, SessionData> sessions = {};

  @override
  void initState() {
    super.initState();
    if (mounted) {
      setActiveSessions();
    }
  }

  setActiveSessions() {
    if ((walletConnectService.web3Wallet != null)) {
      walletConnectService.web3Wallet!
          .getActiveSessions()
          .forEach((key, value) {
        setState(() {
          sessions[key] = value;
        });
      });
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

  Future<void> launchQubicURL(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url, mode: LaunchMode.externalApplication);
    }
  }

  removeConnection(SessionData session) {
    final l10n = l10nOf(context);
    try {
      setState(() {
        sessions.remove(session.topic);
      });
      walletConnectService.web3Wallet!.disconnectSession(
          reason: WalletConnectError(
              code: -1, message: l10n.wcErrorUserDisconnected),
          topic: session.topic);
    } catch (e) {
      //Silently ignore
    }
  }

  removeAllConnections() {
    final l10n = l10nOf(context);
    try {
      sessions.forEach((key, sessionData) async {
        await walletConnectService.web3Wallet!.disconnectSession(
            reason: WalletConnectError(
                code: -1, message: l10n.wcErrorUserDisconnected),
            topic: sessionData.topic);
      });
      setState(() {
        sessions.clear();
      });
    } catch (e) {
      //Silently ignore
    }
  }

  showRemoveDialog({SessionData? sesstion}) {
    bool removeAll = sesstion == null;
    final l10n = l10nOf(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          title: removeAll
              ? "${l10n.wcDisconnectAll}?"
              : "${l10n.wcDisconnect} ${sesstion.peer.metadata.name}?",
          content: removeAll
              ? l10n.wcDisconnectAllConfirm
              : l10n.wcDisconnectConfirm,
          continueText: l10n.wcDisconnect,
          continueFunction: () {
            removeAll ? removeAllConnections() : removeConnection(sesstion);
          },
        );
      },
    );
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
            showRemoveDialog(sesstion: sessionData);
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
                      child: Text(l10n.wcNoPermissions),
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
        if (children.length > 1) ...[
          ThemedControls.spacerVerticalBig(),
          SizedBox(
            height: ButtonStyles.buttonHeight,
            width: double.infinity,
            child: ThemedControls.dangerButtonBigWithClild(
                onPressed: showRemoveDialog,
                child: Text(l10n.wcDisconnectAll,
                    style: TextStyles.destructiveButtonText)),
          )
        ]
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
          ThemedControls.spacerVerticalNormal(),
          getSessions(),
        ]));
  }

  Widget getEmptyView() {
    final l10n = l10nOf(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SvgPicture.asset(AppIcons.noConnection),
        ThemedControls.spacerVerticalNormal(),
        Text(
          l10n.wcDappsConnectedNone,
          style: TextStyles.alertHeader,
          textAlign: TextAlign.center,
        ),
        ThemedControls.spacerVerticalNormal(),
        Text(
          l10n.wcDappsConnectedNoneHint,
          textAlign: TextAlign.center,
          style: TextStyles.alertText,
        ),
        ThemedControls.spacerVerticalBig(),
        Center(
          child: SizedBox(
            width: 180,
            child: ThemedControls.primaryButtonNormal(
                onPressed: () async {
                  await pushScreen(
                    context,
                    screen: const AddWalletConnect(),
                    withNavBar: false,
                  );
                  //Update active sesstions returning after back
                  setActiveSessions();
                },
                text: l10n.wcAddConnection),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(l10n.settingsLabelWalletConnect,
              style: TextStyles.textExtraLargeBold),
          centerTitle: true,
        ),
        body: SafeArea(
            minimum: ThemeEdgeInsets.pageInsets,
            child: sessions.isEmpty
                ? getEmptyView()
                : Column(children: [
                    Expanded(child: getScrollView()),
                  ])));
  }
}
