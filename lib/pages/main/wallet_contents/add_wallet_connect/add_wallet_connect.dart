import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qubic_wallet/components/wallet_connect/pair.dart';
import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/global_snack_bar.dart';
import 'package:qubic_wallet/helpers/platform_helpers.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/add_wallet_connect/scanner_corners_border.dart';
import 'package:qubic_wallet/services/wallet_connect_service.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/styles/button_styles.dart';
import 'package:qubic_wallet/styles/edge_insets.dart';
import 'package:qubic_wallet/styles/input_decorations.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

class AddWalletConnect extends StatefulWidget {
  const AddWalletConnect({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddWalletConnectState createState() => _AddWalletConnectState();
}

class _AddWalletConnectState extends State<AddWalletConnect> {
  final ApplicationStore appStore = getIt<ApplicationStore>();
  final GlobalSnackBar _globalSnackBar = getIt<GlobalSnackBar>();
  final WalletConnectService walletConnectService =
      getIt<WalletConnectService>();
  final TextEditingController urlController = TextEditingController();

  bool isLoading = false;
  bool isConnecting = false;
  bool canConnect = false;
  Timer? pairingTimer;
  StreamSubscription<SessionProposalEvent?>? sessionProposalSubscription;
  StreamSubscription<SessionProposalErrorEvent?>?
      sessionProposalErrorSubscription;

  int? wcPairingId;
  PairingMetadata? wcPairingMetadata;
  List<String> wcPairingMethods = [];
  List<String> wcPairingEvents = [];
  Map<String, Namespace>? wcPairingNamespaces;
  @override
  void initState() {
    super.initState();
    walletConnectService.initialize().then((value) {
      final l10n = l10nOf(context);

      sessionProposalErrorSubscription = walletConnectService
          .onSessionProposalError.stream
          .listen((SessionProposalErrorEvent? args) {
        if (args != null) {
          if (args.error.code == 5100) {
            _globalSnackBar.showError(l10n.wcErrorUnsupportedChains);
            setState(() {
              isLoading = false;
              if (pairingTimer != null) pairingTimer!.cancel();
            });
          } else if (args.error.code == 5101) {
            _globalSnackBar.showError(l10n.wcErrorUnsupportedMethods);
            setState(() {
              isLoading = false;
              if (pairingTimer != null) pairingTimer!.cancel();
            });
          } else if (args.error.code == 5102) {
            _globalSnackBar.showError(l10n.wcErrorUnsupportedEvents);
            setState(() {
              isLoading = false;
              if (pairingTimer != null) pairingTimer!.cancel();
            });
          } else if (args.error.code == 5103) {
            _globalSnackBar.showError(l10n.wcErrorUnsupportedAccounts);
            setState(() {
              isLoading = false;
              if (pairingTimer != null) pairingTimer!.cancel();
            });
          } else if (args.error.code == 5104) {
            _globalSnackBar.showError(l10n.wcErrorUnsupportedNamespaces);
            setState(() {
              isLoading = false;
              if (pairingTimer != null) pairingTimer!.cancel();
            });
          } else {
            _globalSnackBar.showError(args.error.message);
            setState(() {
              isLoading = false;
              if (pairingTimer != null) pairingTimer!.cancel();
            });
          }
        }
      });

      sessionProposalSubscription = walletConnectService
          .onSessionProposal.stream
          .listen((SessionProposalEvent? args) async {
        List<String> notSupportedNetworks = [];
        if (args != null) {
          log(args.toString());
          wcPairingId = args.id;
          wcPairingMetadata = args.params.proposer.metadata;
          //Automatic parsing (with registering events and methods)
          wcPairingMethods = args.params.generatedNamespaces != null
              ? args.params.generatedNamespaces!.entries.first.value.methods
              : [];
          wcPairingEvents = args.params.generatedNamespaces != null
              ? args.params.generatedNamespaces!.entries.first.value.events
              : [];
          wcPairingNamespaces = args.params.generatedNamespaces;

          List<String> requiredNetworkIDs = [];
          args.params.requiredNamespaces.forEach((key, value) {
            requiredNetworkIDs.addAll(value.chains as List<String>);
          });
          for (var network in requiredNetworkIDs) {
            if (network != Config.walletConnectChainId) {
              notSupportedNetworks.add(network);
            }
          }
        }

        if (pairingTimer != null) pairingTimer!.cancel();
        bool? userhasConfirmed =
            await Navigator.of(context).push(MaterialPageRoute<bool>(
                builder: (BuildContext context) {
                  return Pair(
                    pairingId: wcPairingId!,
                    pairingEvents: wcPairingEvents,
                    pairingMethods: wcPairingMethods,
                    pairingNamespaces: wcPairingNamespaces,
                    pairingMetadata: wcPairingMetadata,
                    unsupportedNetowrks: notSupportedNetworks,
                  );
                },
                fullscreenDialog: true));

        if (userhasConfirmed != null && userhasConfirmed) {
          //Accepted
          try {
            if (mounted) {
              Navigator.of(context).pop();
              final l10n = l10nOf(context);
              _globalSnackBar.show(l10n.wcConnectionApproved);
            }
          } catch (e) {
            _globalSnackBar.showError(e.toString());
            setState(() {
              isConnecting = false;
              isLoading = false;
              if (pairingTimer != null) pairingTimer!.cancel();
            });
          }
        } else if (userhasConfirmed == null) {
          //Rejected
          setState(() {
            isLoading = false;
            if (pairingTimer != null) pairingTimer!.cancel();
            isConnecting = false;
          });
          await walletConnectService.web3Wallet!.rejectSession(
              id: wcPairingId!,
              reason: Errors.getSdkError(Errors.USER_REJECTED));

          if (mounted) {
            Navigator.of(context).pop();
            final l10n = l10nOf(context);
            _globalSnackBar.showError(l10n.wcConnectionRejected);
          }
        } else {
          // false : expired
          setState(() {
            isLoading = false;
            if (pairingTimer != null) pairingTimer!.cancel();
            isConnecting = false;
          });

          if (mounted) {
            final l10n = l10nOf(context);
            Navigator.of(context).pop();
            _globalSnackBar.show(l10n.wcConnectionProposalTimeout);
          }
        }
      });
    });
  }

  @override
  void dispose() {
    if (sessionProposalSubscription != null) {
      sessionProposalSubscription!.cancel();
    }
    if (sessionProposalErrorSubscription != null) {
      sessionProposalErrorSubscription!.cancel();
    }
    urlController.dispose();
    super.dispose();
  }

  pasteAndProceed() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    String? clipboardText = clipboardData?.text;
    proceedHandler(clipboardText);
  }

  pasteToForm() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    String? clipboardText = clipboardData?.text;
    urlController.text = clipboardText ?? "";
  }

  void proceedHandler(String? url) async {
    final l10n = l10nOf(context);
    if (validateWalletConnectURL(url) != null) {
      _globalSnackBar.showError(validateWalletConnectURL(url)!);
      return;
    }

    setState(() {
      isLoading = true;
    });

    if (!walletConnectService.web3Wallet!.core.relayClient.isConnected) {
      await walletConnectService.web3Wallet!.core.relayClient.connect();
    }
    try {
      PairingInfo pairResult = await walletConnectService.pair(Uri.parse(url!));

      if (walletConnectService
          .sessionPairingTopicAlreadyExists(pairResult.topic)) {
        pairingTimer = Timer(const Duration(seconds: 10), () {
          if (mounted) {
            _globalSnackBar.showError(l10n.wcErrorUsedURL);
            setState(() {
              isLoading = false;
            });
          } else {
            setState(() {
              isLoading = false;
            });
          }
        });

        return;
      }
    } catch (e) {
      if (e is WalletConnectError) {
        _globalSnackBar.showError(e.message);
        setState(() {
          isLoading = false;
          if (pairingTimer != null) pairingTimer!.cancel();
        });
      } else {
        _globalSnackBar.showError(e.toString());
        setState(() {
          isLoading = false;
          if (pairingTimer != null) pairingTimer!.cancel();
        });
      }
    }
  }

  String? validateWalletConnectURL(String? valueCandidate) {
    final l10n = l10nOf(context);
    const requiredLength = Config.wallectConnectUrlLength;
    final requiredPatterns = ['wc:', 'expiryTimestamp=', 'symKey=', '@'];

    if (valueCandidate == null || valueCandidate.trim().isEmpty) {
      return l10n.wcErrorInvalidURL;
    }

    if (valueCandidate.length != requiredLength) {
      return l10n.wcErrorInvalidURL;
    }

    if (!requiredPatterns
        .every((pattern) => valueCandidate.contains(pattern))) {
      return l10n.wcErrorInvalidURL;
    }

    if (valueCandidate.contains("@1")) {
      return l10n.wcErrorDeprecatedURL;
    }

    return null;
  }

  Widget getScrollView() {
    final l10n = l10nOf(context);
    return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding:
            const EdgeInsets.symmetric(horizontal: ThemePaddings.hugePadding),
        child: Row(children: [
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ThemedControls.spacerVerticalHuge(),
              if (isMobile) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: LightThemeColors.inputBorderColor, width: 1),
                    ),
                    width: double.infinity,
                    height: 280,
                    child: CustomPaint(
                      foregroundPainter: ScannerCornerBorders(),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: MobileScanner(
                          fit: BoxFit.cover,
                          controller: MobileScannerController(
                            detectionSpeed: DetectionSpeed.noDuplicates,
                            facing: CameraFacing.back,
                            torchEnabled: false,
                          ),
                          onDetect: (capture) {
                            final List<Barcode> barcodes = capture.barcodes;
                            for (final barcode in barcodes) {
                              if (barcode.rawValue != null && !isLoading) {
                                _globalSnackBar.show(l10n
                                    .generalSnackBarMessageQRScannedWithSuccess);
                                proceedHandler(barcode.rawValue);
                              }
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                ThemedControls.spacerVerticalBig(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: ThemePaddings.normalPadding),
                  child: Text(
                    l10n.wcPointCameraToQR,
                    textAlign: TextAlign.center,
                    style: TextStyles.labelTextNormal
                        .copyWith(fontWeight: FontWeight.w400),
                  ),
                )
              ],
              if (!isMobile) ...[
                Text(
                  l10n.wcAddWcTitle,
                  style: TextStyles.pageTitle,
                ),
                ThemedControls.spacerVerticalNormal(),
                Text(
                  l10n.wcAddURL,
                  style: TextStyles.secondaryTextLarge,
                ),
                ThemedControls.spacerVerticalBig(),
                FormBuilderTextField(
                    name: "urlController",
                    controller: urlController,
                    onChanged: (val) {
                      canConnect =
                          (val?.length == Config.wallectConnectUrlLength)
                              ? true
                              : false;
                      setState(() {});
                    },
                    style: TextStyles.inputBoxSmallStyle,
                    decoration: ThemeInputDecorations.normalInputbox.copyWith(
                        hintText: l10n.pasteURLHere,
                        suffixIconConstraints:
                            const BoxConstraints(minHeight: 24, minWidth: 32),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(
                              right: ThemePaddings.normalPadding),
                          child: SizedBox(
                            height: 24,
                            child: ThemedControls.secondaryButtonWithChild(
                                onPressed: pasteToForm,
                                child: Text(l10n.generalButtonPaste,
                                    style: TextStyles.primaryButtonText
                                        .copyWith(
                                            color:
                                                LightThemeColors.primary40))),
                          ),
                        ))),
              ]
            ],
          ))
        ]));
  }

  List<Widget> getButtons() {
    final l10n = l10nOf(context);

    return [
      if (isMobile)
        SizedBox(
          width: double.infinity,
          height: ButtonStyles.buttonHeight,
          child: ThemedControls.secondaryButtonWithChild(
              onPressed: pasteAndProceed,
              child: Padding(
                  padding: const EdgeInsets.all(ThemePaddings.smallPadding + 3),
                  child: isLoading
                      ? const SizedBox(
                          height: 23,
                          width: 23,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: LightThemeColors.buttonPrimary),
                        )
                      : Text(
                          l10n.pasteURLHere,
                          style: TextStyles.primaryButtonText
                              .copyWith(color: LightThemeColors.primary40),
                        ))),
        ),
      if (!isMobile)
        SizedBox(
          width: double.infinity,
          height: ButtonStyles.buttonHeight,
          child: ThemedControls.primaryButtonBigWithChild(
              onPressed: canConnect ? pasteAndProceed : null,
              enabled: canConnect,
              child: Padding(
                  padding: const EdgeInsets.all(ThemePaddings.smallPadding + 3),
                  child: isLoading
                      ? const SizedBox(
                          height: 23,
                          width: 23,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: LightThemeColors.extraStrongBackground,
                          ),
                        )
                      : Text(
                          l10n.generalButtonConnect,
                          style: TextStyles.primaryButtonText,
                        ))),
        )
    ];
  }

  Widget getConnectingView() {
    final l10n = l10nOf(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 30,
                  width: 30,
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary)),
                ),
                ThemedControls.spacerHorizontalNormal(),
                ThemedControls.pageHeader(
                    headerText: l10n.approvingConnection,
                    subheaderText: l10n.pleaseWait)
              ]),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: !isLoading,
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
            ),
            body: SafeArea(
                minimum: ThemeEdgeInsets.pageInsets
                    .copyWith(bottom: ThemePaddings.normalPadding),
                child: isConnecting
                    ? Column(children: [Expanded(child: getConnectingView())])
                    : Column(children: [
                        Expanded(child: getScrollView()),
                        ...getButtons()
                      ]))));
  }
}
