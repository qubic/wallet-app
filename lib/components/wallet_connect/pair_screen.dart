// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qubic_wallet/components/wallet_connect/components/domain_verification_card.dart';
import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/app_logger.dart';
import 'package:qubic_wallet/helpers/wallet_connect_methods.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/add_wallet_connect/add_wallet_connect.dart';
import 'package:qubic_wallet/services/wallet_connect_service.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/styles/button_styles.dart';
import 'package:qubic_wallet/styles/edge_insets.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:reown_walletkit/reown_walletkit.dart';

class PairScreen extends StatefulWidget {
  final PairingMetadata? pairingMetadata;
  final List<String> pairingMethods;
  final List<String> pairingEvents;
  final int pairingId;
  final Map<String, Namespace>? pairingNamespaces;
  final DomainType domainType;

  const PairScreen({
    super.key,
    required this.pairingId,
    required this.pairingMethods,
    required this.pairingMetadata,
    required this.pairingEvents,
    required this.pairingNamespaces,
    required this.domainType,
  });

  @override
  // ignore: library_private_types_in_public_api
  _PairScreenState createState() => _PairScreenState();
}

class _PairScreenState extends State<PairScreen> {
  final ApplicationStore appStore = getIt<ApplicationStore>();
  final WalletConnectService wcService = getIt<WalletConnectService>();

  bool isLoading = false;
  String? wcError;
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

  bool isUnknown() => widget.domainType == DomainType.unknown;
  bool isScam() => widget.domainType == DomainType.scam;
  bool isMismatch() => widget.domainType == DomainType.mismatch;

  @override
  void dispose() {
    listener.cancel();
    super.dispose();
  }

  Widget getErrors() {
    if (wcError != null) {
      return Column(children: [
        ThemedControls.errorLabel(wcError ?? "-"),
        ThemedControls.spacerVerticalNormal(),
      ]);
    } else {
      return Container();
    }
  }

  // Gets the text for WC method available from connection
  Widget getMethod(String? text, {bool isGranted = true}) {
    return Row(
      children: [
        Image.asset(isGranted
            ? "assets/images/permission-granted.png"
            : "assets/images/permission-denied.png"),
        ThemedControls.spacerHorizontalNormal(),
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
    List<String> localizedStrings =
        getLocalizedPairingMethods(widget.pairingMethods, context);
    List<Widget> methods = [];

    for (var localizedString in localizedStrings) {
      methods.add(getMethod(localizedString));
      methods.add(ThemedControls.spacerVerticalMini());
    }
    return methods;
  }

  List<Widget> getButtons() {
    final l10n = l10nOf(context);

    return [
      ThemedControls.spacerVerticalSmall(),
      SizedBox(
        width: double.infinity,
        height: ButtonStyles.buttonHeight,
        child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: isScam() || isMismatch()
                  ? LightThemeColors.error40
                  : isUnknown()
                      ? LightThemeColors.warning40
                      : LightThemeColors.primary40,
            ),
            onPressed: () {
              if (!isLoading) handleProceed();
            },
            child: isLoading
                ? SizedBox(
                    height: 23,
                    width: 23,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: LightThemeColors.grey90),
                  )
                : Text(l10n.generalButtonApprove,
                    textAlign: TextAlign.center,
                    style: TextStyles.primaryButtonText)),
      ),
      ThemedControls.spacerVerticalSmall(),
      SizedBox(
          width: double.infinity,
          height: ButtonStyles.buttonHeight,
          child: ThemedControls.dangerButtonBigWithClild(
              child: Padding(
                  padding: const EdgeInsets.all(ThemePaddings.smallPadding),
                  child: Text(l10n.generalButtonReject,
                      style: isScam() || isMismatch()
                          ? TextStyles.transparentButtonText
                          : TextStyles.destructiveButtonText)),
              onPressed: () {
                Navigator.of(context).pop();
              })),
    ];
  }

  void handleProceed() async {
    final l10n = l10nOf(context);
    try {
      setState(() {
        isLoading = true;
      });
      ApproveResponse response = await wcService.web3Wallet!.approveSession(
          id: widget.pairingId, namespaces: widget.pairingNamespaces!);

      appLogger.d(response.toString());

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        appLogger.d(e.toString());
        wcError = (e is ReownSignError &&
                e.code ==
                    Errors.INTERNAL_ERRORS[Errors.NO_MATCHING_KEY]?["code"])
            ? l10n.wcErrorProposalExpired
            : (e is ReownSignError)
                ? e.message
                : e.toString();
      });
    }
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
                            Config.dAppDefaultImageName,
                          ),
                          imageErrorBuilder: (context, error, stackTrace) =>
                              Image.asset(Config.dAppDefaultImageName),
                          fit: BoxFit.contain,
                        )
                      : Image.asset(Config.dAppDefaultImageName),
                ),

                //dAPP title
                ThemedControls.spacerVerticalBig(),
                Text(
                  widget.pairingMetadata == null ||
                          widget.pairingMetadata?.name == null ||
                          widget.pairingMetadata!.name.isEmpty
                      ? l10n.wcUnknownDapp
                      : widget.pairingMetadata!.name,
                  style: TextStyles.walletConnectDappTitle,
                  textAlign: TextAlign.center,
                ),
                ThemedControls.spacerVerticalSmall(),
                Text(
                  widget.pairingMetadata == null ||
                          widget.pairingMetadata?.url == null ||
                          widget.pairingMetadata!.url.isEmpty
                      ? l10n.wcUnknownDapp
                      : widget.pairingMetadata!.url,
                  style: TextStyles.walletConnectDappUrl,
                  textAlign: TextAlign.center,
                ),
                //--------- End of header
                ThemedControls.spacerVerticalBig(),
                getErrors(),
                if (widget.domainType != DomainType.valid)
                  DomainVerificationCard(domainType: widget.domainType),
                //--------- Permissions
                if (getMethods().isNotEmpty)
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
                //--------- End of non permissions]
              ]))
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
                  Column(children: getButtons())
                ]))));
  }
}
