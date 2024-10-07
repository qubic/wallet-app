import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:qubic_wallet/components/wallet_connect/pair.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/id_validators.dart';
import 'package:qubic_wallet/helpers/platform_helpers.dart';
import 'package:qubic_wallet/helpers/global_snack_bar.dart';
import 'package:qubic_wallet/resources/qubic_cmd.dart';
import 'package:qubic_wallet/services/wallet_connect_service.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qubic_wallet/stores/settings_store.dart';
import 'package:qubic_wallet/styles/edge_insets.dart';
import 'package:qubic_wallet/styles/input_decorations.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

class AddWalletConnect extends StatefulWidget {
  const AddWalletConnect({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddWalletConnectState createState() => _AddWalletConnectState();
}

class _AddWalletConnectState extends State<AddWalletConnect> {
  final _formKey = GlobalKey<FormBuilderState>();
  final settingsStore = getIt<SettingsStore>();
  final ApplicationStore appStore = getIt<ApplicationStore>();
  final QubicCmd qubicCmd = getIt<QubicCmd>();
  final GlobalSnackBar _globalSnackBar = getIt<GlobalSnackBar>();
  TextEditingController wcText = TextEditingController();
  final WalletConnectService walletConnectService =
      getIt<WalletConnectService>();

  bool detected = false;
  bool isLoading = false;
  bool foundSuccess = false; //True if QR code scanner worked correctly
  bool isConnecting = false;

  StreamSubscription<SessionProposalEvent?>? sessionProposalSubscription;
  StreamSubscription<SessionProposalErrorEvent?>?
      sessionProposalErrorSubscription;

  int? wcPairingId;
  PairingMetadata? wcPairingMetadata;
  List<String> wcPairingMethods = [];
  List<String> wcPairingEvents = [];
  Map<String, Namespace>? wcPairingNamespaces;
  String? wcError = "";
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
            setState(() {
              wcError = l10n.wcErrorUnsupportedChains;
              isLoading = false;
            });
          } else if (args.error.code == 5101) {
            setState(() {
              wcError = l10n.wcErrorUnsupportedMethods;
              isLoading = false;
            });
          } else if (args.error.code == 5102) {
            setState(() {
              wcError = l10n.wcErrorUnsupportedEvents;
              isLoading = false;
            });
          } else if (args.error.code == 5103) {
            setState(() {
              wcError = l10n.wcErrorUnsupportedAccounts;
              isLoading = false;
            });
          } else if (args.error.code == 5104) {
            setState(() {
              wcError = l10n.wcErrorUnsupportedNamespaces;
              isLoading = false;
            });
          } else {
            setState(() {
              wcError = args.error.message;
              isLoading = false;
            });
          }
        }
      });

      sessionProposalSubscription = walletConnectService
          .onSessionProposal.stream
          .listen((SessionProposalEvent? args) async {
        if (args != null) {
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
          //}
        }

        bool? userhasConfirmed =
            await Navigator.of(context).push(MaterialPageRoute<bool>(
                builder: (BuildContext context) {
                  return Pair(
                    pairingId: wcPairingId!,
                    pairingEvents: wcPairingEvents,
                    pairingMethods: wcPairingMethods,
                    pairingNamespaces: wcPairingNamespaces,
                    pairingMetadata: wcPairingMetadata,
                  );
                },
                fullscreenDialog: true));

        if (userhasConfirmed != null && userhasConfirmed) {
          //Accepted
          try {
            setState(() {
              isConnecting = true;
            });
            await walletConnectService.web3Wallet!.approveSession(
                id: wcPairingId!, namespaces: wcPairingNamespaces!);

            Timer(const Duration(seconds: 1), () {
              if (context.mounted) {
                Navigator.of(context).pop();
              }
              final l10n = l10nOf(context);
              _globalSnackBar.show(l10n.wcConnectionApproved);
            });
          } catch (e) {
            setState(() {
              isConnecting = false;
              isLoading = false;
              wcError = e.toString();
            });
          }
        } else if (userhasConfirmed == null) {
          //Rejected
          setState(() {
            isLoading = false;
            isConnecting = false;
          });
          await walletConnectService.web3Wallet!.rejectSession(
              id: wcPairingId!,
              reason: Errors.getSdkError(Errors.USER_REJECTED));

          if (mounted) {
            Navigator.of(context).pop();
            final l10n = l10nOf(context);
            _globalSnackBar.show(l10n.wcConnectionRejected);
          }
        } else {
          // false : expired
          setState(() {
            isLoading = false;
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

    super.dispose();
  }

  void showQRScanner() {
    final l10n = l10nOf(context);
    detected = false;
    showModalBottomSheet<void>(
        context: context,
        useSafeArea: true,
        builder: (BuildContext context) {
          bool foundSuccess = false;
          return Stack(children: [
            MobileScanner(
              // fit: BoxFit.contain,
              controller: MobileScannerController(
                detectionSpeed: DetectionSpeed.normal,
                facing: CameraFacing.back,
                torchEnabled: false,
              ),

              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;

                for (final barcode in barcodes) {
                  if (barcode.rawValue != null) {
                    var validator =
                        CustomFormFieldValidators.isSeed(context: context);
                    if (validator(barcode.rawValue) == null) {
                      wcText.text = barcode.rawValue!;
                      foundSuccess = true;
                    }
                  }

                  if (foundSuccess) {
                    if (!detected) {
                      Navigator.pop(context);

                      _globalSnackBar.show(
                          l10n.generalSnackBarMessageQRScannedWithSuccess);
                    }
                    detected = true;
                  }
                }
              },
            ),
            Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                    color: Colors.white60,
                    width: double.infinity,
                    child: Padding(
                        padding:
                            const EdgeInsets.all(ThemePaddings.normalPadding),
                        child: Text(l10n.wcPointCameraToQR,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center))))
          ]);
        });
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

  Widget getScrollView() {
    final l10n = l10nOf(context);
    return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Row(children: [
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ThemedControls.pageHeader(headerText: l10n.wcAddWcTitle),
              ThemedControls.spacerVerticalSmall(),
              getErrors(),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(l10n.wcAddURL,
                              style: TextStyles.labelTextNormal),
                        ]),
                  ]),
              ThemedControls.spacerVerticalSmall(),
              FormBuilder(
                  key: _formKey,
                  child: Column(
                    children: [
                      FormBuilderTextField(
                        onSubmitted: (String? text) {
                          proceedHandler();
                        },
                        controller: wcText,
                        name: "wcUrl",
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(
                              errorText: l10n.generalErrorRequiredField),
                          CustomFormFieldValidators
                              .isWalletConnectConnectionURL(context: context)
                        ]),
                        readOnly: isLoading,
                        style: TextStyles.inputBoxSmallStyle,
                        decoration: ThemeInputDecorations.normalInputbox
                            .copyWith(hintText: l10n.pasteURLHere),
                        autocorrect: false,
                        autofillHints: null,
                      ),
                      ThemedControls.spacerVerticalNormal(),
                    ],
                  )),
              if (isMobile)
                Align(
                    alignment: Alignment.topLeft,
                    child: ThemedControls.primaryButtonNormal(
                        onPressed: () {
                          showQRScanner();
                        },
                        text: l10n.generalButtonUseQRCode,
                        icon: !LightThemeColors.shouldInvertIcon
                            ? ThemedControls.invertedColors(
                                child:
                                    Image.asset("assets/images/Group 2294.png"))
                            : Image.asset("assets/images/Group 2294.png"))),
            ],
          ))
        ]));
  }

  List<Widget> getButtons() {
    final l10n = l10nOf(context);

    return [
      Expanded(
          child: !isLoading
              ? ThemedControls.transparentButtonBigWithChild(
                  child: Padding(
                      padding: const EdgeInsets.all(ThemePaddings.smallPadding),
                      child: Text(l10n.generalButtonCancel,
                          style: TextStyles.transparentButtonText)),
                  onPressed: () {
                    Navigator.pop(context);
                  })
              : Container()),
      ThemedControls.spacerHorizontalNormal(),
      Expanded(
          child: ThemedControls.primaryButtonBigWithChild(
              onPressed: proceedHandler,
              child: Padding(
                  padding: const EdgeInsets.all(ThemePaddings.smallPadding + 3),
                  child: isLoading
                      ? SizedBox(
                          height: 23,
                          width: 23,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color:
                                  Theme.of(context).colorScheme.inversePrimary),
                        )
                      : Text(l10n.generalButtonProceed,
                          textAlign: TextAlign.center,
                          style: TextStyles.primaryButtonText))))
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

  void proceedHandler() async {
    _formKey.currentState?.validate();

    if (!_formKey.currentState!.isValid) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    if (!walletConnectService.web3Wallet!.core.relayClient.isConnected) {
      await walletConnectService.web3Wallet!.core.relayClient.connect();
    }
    try {
      PairingInfo pairResult =
          await walletConnectService.pair(Uri.parse(wcText.text));

      if (walletConnectService
          .sessionPairingTopicAlreadyExists(pairResult.topic)) {
        if (mounted) {
          final l10n = l10nOf(context);

          setState(() {
            wcError = l10n.wcErrorUsedURL;
            isLoading = false;
          });
        } else {
          setState(() {
            wcError = "-";
            isLoading = false;
          });
          return;
        }
      }
    } catch (e) {
      if (e is WalletConnectError) {
        setState(() {
          wcError = e.message;
          isLoading = false;
        });
      } else {
        setState(() {
          wcError = e.toString();
          isLoading = false;
        });
      }
    }
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
                        Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: getButtons())
                      ]))));
  }
}
