// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/models/wallet_connect.dart';
import 'package:qubic_wallet/services/wallet_connect_service.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/styles/edge_insets.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

class Pair extends StatefulWidget {
  final PairingMetadata? pairingMetadata;
  final List<String> pairingMethods;
  final List<String> pairingEvents;
  final int pairingId;
  final Map<String, Namespace>? pairingNamespaces;

  const Pair(
      {super.key,
      required this.pairingId,
      required this.pairingMethods,
      required this.pairingMetadata,
      required this.pairingEvents,
      required this.pairingNamespaces});

  @override
  // ignore: library_private_types_in_public_api
  _PairState createState() => _PairState();
}

class _PairState extends State<Pair> {
  final ApplicationStore appStore = getIt<ApplicationStore>();
  final WalletConnectService wcService = getIt<WalletConnectService>();
  bool hasAccepted = false;

  late final StreamSubscription<SessionProposalEvent?> listener;
  @override
  void initState() {
    super.initState();

    listener = wcService.onProposalExpire.stream.listen((event) {
      if (event!.id == widget.pairingId) {
        if (mounted) {
          Navigator.of(context).pop(false);
        }
      }
    });
  }

  @override
  void dispose() {
    listener.cancel();
    super.dispose();
  }

  // Gets the text for WC method available from connection
  Widget getMethod(String? text, {bool isGranted = true}) {
    return Row(
      children: [
        Image.asset(isGranted
            ? "assets/images/permission-granted.png"
            : "assets/images/permission-denied.png"),
        ThemedControls.spacerHorizontalSmall(),
        Expanded(
            child: Text(
          text!,
          style: TextStyles.walletConnectDapPermission,
        ))
      ],
    );
  }

  // Gets a list of all requested WC methods
  List<Widget> getMethods() {
    final l10n = l10nOf(context);

    List<Widget> methods = [];

    for (var string in widget.pairingMethods) {
      if ((string == WcMethods.wRequestAccounts)) {
        methods.add(getMethod(l10n.wcScopeRequestAccounts));
        methods.add(ThemedControls.spacerVerticalMini());
      }
      if (string == WcMethods.wSendQubic) {
        methods.add(getMethod(l10n.wcScopeSendQubic));
        methods.add(ThemedControls.spacerVerticalMini());
      }
      if (string == WcMethods.wSendAsset) {
        methods.add(getMethod(l10n.wcScopeSendAssets));
        methods.add(ThemedControls.spacerVerticalMini());
      }
    }
    return methods;
  }

  List<Widget> getButtons() {
    final l10n = l10nOf(context);

    return [
      Expanded(
          child: ThemedControls.transparentButtonBigWithChild(
              child: Padding(
                  padding: const EdgeInsets.all(ThemePaddings.smallPadding),
                  child: Text(l10n.generalButtonCancel,
                      style: TextStyles.transparentButtonText)),
              onPressed: () {
                Navigator.pop(context);
              })),
      ThemedControls.spacerHorizontalNormal(),
      Expanded(
          child: ThemedControls.primaryButtonBigWithChild(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Padding(
                  padding: const EdgeInsets.all(ThemePaddings.smallPadding + 3),
                  child: Text(l10n.generalButtonProceed,
                      textAlign: TextAlign.center,
                      style: TextStyles.primaryButtonText))))
    ];
  }

  Widget getScrollView() {
    final l10n = l10nOf(context);
    return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Row(children: [
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //---------- Header title url and image
              SizedBox(
                height: 80,
                width: 80,
                child: widget.pairingMetadata != null &&
                        widget.pairingMetadata!.icons.isNotEmpty
                    ? FadeInImage(
                        image: NetworkImage(widget.pairingMetadata!.icons[0]),
                        placeholder: AssetImage(
                          'assets/images/dapp-default.png',
                        ),
                        imageErrorBuilder: (context, error, stackTrace) =>
                            Image.asset('assets/images/dapp-default.png'),
                        fit: BoxFit.contain,
                      )
                    : Image.asset('assets/images/dapp-default.png'),
              ),
              //dAPP title
              ThemedControls.spacerVerticalBig(),
              Text(
                  widget.pairingMetadata == null ||
                          widget.pairingMetadata?.name == null ||
                          widget.pairingMetadata!.name.isEmpty
                      ? l10n.wcUnknownDapp
                      : widget.pairingMetadata!.name,
                  style: TextStyles.walletConnectDappTitle),
              ThemedControls.spacerVerticalSmall(),
              Text(
                  widget.pairingMetadata == null ||
                          widget.pairingMetadata?.url == null ||
                          widget.pairingMetadata!.url.isEmpty
                      ? l10n.wcUnknownDapp
                      : widget.pairingMetadata!.url,
                  style: TextStyles.walletConnectDappUrl),
              //--------- End of header
              ThemedControls.spacerVerticalBig(),
              //--------- Permissions
              ThemedControls.card(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(l10n.wcAppInfoHeaderPair,
                        style: TextStyles.walletConnectDapPermissionHeader),
                    ThemedControls.spacerVerticalSmall(),
                    ...getMethods()
                  ])),
              //--------- End of permissions
              ThemedControls.spacerVerticalNormal(),
              //--------- Non Permissions
              ThemedControls.card(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(l10n.wcAppInfoHeaderPairForbidden,
                        style: TextStyles.walletConnectDapPermissionHeader),
                    ThemedControls.spacerVerticalSmall(),
                    getMethod(l10n.wcScopeForbiddenTransfer, isGranted: false)
                  ]))
              //--------- End of non permissions
            ],
          ))
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: true,
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
            ),
            body: SafeArea(
                minimum: ThemeEdgeInsets.pageInsets
                    .copyWith(bottom: ThemePaddings.normalPadding),
                child: Column(children: [
                  Expanded(child: getScrollView()),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: getButtons())
                ]))));
  }
}
