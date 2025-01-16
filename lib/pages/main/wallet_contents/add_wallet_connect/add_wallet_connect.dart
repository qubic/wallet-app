import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qubic_wallet/components/wallet_connect/pair_screen.dart';
import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/app_logger.dart';
import 'package:qubic_wallet/helpers/global_snack_bar.dart';
import 'package:qubic_wallet/helpers/platform_helpers.dart';
import 'package:qubic_wallet/helpers/wallet_connect_methods.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/add_wallet_connect/components/scanner_corners_border.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/add_wallet_connect/components/scanner_overlay_clipper.dart';
import 'package:qubic_wallet/services/wallet_connect_service.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/styles/button_styles.dart';
import 'package:qubic_wallet/styles/edge_insets.dart';
import 'package:qubic_wallet/styles/input_decorations.dart';
import 'package:qubic_wallet/styles/responsive_constants.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:reown_walletkit/reown_walletkit.dart';
import 'package:url_launcher/url_launcher_string.dart';

part 'components/add_wallet_connect_desktop_view.dart';
part 'components/add_wallet_connect_mobile_view.dart';

enum DomainType { valid, unknown, scam, mismatch }

class AddWalletConnect extends StatefulWidget {
  final String? connectionUrl;
  final bool isFromDeepLink;
  const AddWalletConnect(
      {super.key, this.connectionUrl, this.isFromDeepLink = false});

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
  StreamSubscription<SessionProposalEvent?>? sessionProposalSubscription;
  StreamSubscription<SessionProposalErrorEvent?>?
      sessionProposalErrorSubscription;
  Timer? pairingTimer;
  Timer? existsTimer;
  int? wcPairingId;
  PairingMetadata? wcPairingMetadata;
  List<String> wcPairingMethods = [];
  List<String> wcPairingEvents = [];
  Map<String, Namespace>? wcPairingNamespaces;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.connectionUrl != null) {
        proceedHandler(widget.connectionUrl);
      }
    });

    walletConnectService.initialize().then((value) {
      final l10n = l10nOf(context);

      sessionProposalErrorSubscription = walletConnectService
          .onSessionProposalError.stream
          .listen((SessionProposalErrorEvent? args) {
        if (args != null) {
          pairingTimer?.cancel();
          existsTimer?.cancel();
          if (args.error.code == 5100) {
            _globalSnackBar
                .showError(handleUnSupportedNetworkError(args, l10n));
          } else if (args.error.code == 5101) {
            _globalSnackBar.showError(l10n.wcErrorUnsupportedMethods);
          } else if (args.error.code == 5102) {
            _globalSnackBar.showError(l10n.wcErrorUnsupportedEvents);
          } else if (args.error.code == 5103) {
            _globalSnackBar.showError(l10n.wcErrorUnsupportedAccounts);
          } else if (args.error.code == 5104) {
            _globalSnackBar.showError(l10n.wcErrorUnsupportedNamespaces);
          } else {
            _globalSnackBar.showError(args.error.message);
          }

          if (args.error.code != 0) {
            setState(() {
              isLoading = false;
            });
          }
        }
      });

      sessionProposalSubscription = walletConnectService
          .onSessionProposal.stream
          .listen((SessionProposalEvent? args) async {
        pairingTimer?.cancel();
        existsTimer?.cancel();
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
        }
        final invalidApp = args?.verifyContext?.validation.invalid;
        final unknown = args?.verifyContext?.validation.unknown;
        final scamApp = args?.verifyContext?.validation.scam;
        if (mounted) {
          bool? userhasConfirmed =
              await Navigator.of(context).push(MaterialPageRoute<bool>(
                  builder: (BuildContext context) {
                    return PairScreen(
                      pairingId: wcPairingId!,
                      pairingEvents: wcPairingEvents,
                      pairingMethods: wcPairingMethods,
                      pairingNamespaces: wcPairingNamespaces,
                      pairingMetadata: wcPairingMetadata,
                      domainType: scamApp == true
                          ? DomainType.scam
                          : invalidApp == true
                              ? DomainType.mismatch
                              : unknown == true
                                  ? DomainType.unknown
                                  : DomainType.valid,
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
                isLoading = false;
              });
            }
          } else if (userhasConfirmed == null) {
            //Rejected
            setState(() {
              isLoading = false;
            });
            await walletConnectService.web3Wallet?.rejectSession(
                id: wcPairingId!,
                reason: Errors.getSdkError(Errors.USER_REJECTED).toSignError());

            if (mounted) {
              Navigator.of(context).pop();
              final l10n = l10nOf(context);
              _globalSnackBar.showError(l10n.wcConnectionRejected);
            }
          } else {
            // false : expired
            setState(() {
              isLoading = false;
            });

            if (mounted) {
              //double if to pacify the linter
              final l10n = l10nOf(context);
              Navigator.of(context).pop();
              _globalSnackBar.show(l10n.wcConnectionProposalTimeout);
            }
          }
          if (widget.isFromDeepLink) {
            redirectToDApp(args!);
          }
        }
      });
    });
  }

  Future<void> redirectToDApp(SessionProposalEvent? args) async {
    final redirect = args?.params.proposer.metadata.redirect;
    final universal = redirect?.universal;
    final native = redirect?.native;
    if (native != null && await canLaunchUrlString(native) == true) {
      launchUrlString(native);
    } else if (universal != null &&
        await canLaunchUrlString(universal) == true) {
      launchUrlString(universal);
    }
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
    pairingTimer?.cancel();
    existsTimer?.cancel();
    appLogger.d("Dispose!");
    super.dispose();
  }

  pasteAndProceed() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    String? clipboardText = clipboardData?.text;
    proceedHandler(clipboardText);
  }

  void proceedHandler(String? url) async {
    final l10n = l10nOf(context);
    if (validateWalletConnectURL(url, context) != null) {
      _globalSnackBar.showError(validateWalletConnectURL(url, context)!);
      return;
    }

    setState(() {
      isLoading = true;
    });
    try {
      if (walletConnectService.web3Wallet == null) {
        await walletConnectService.initialize();
      }
      if (!walletConnectService.web3Wallet!.core.relayClient.isConnected) {
        await walletConnectService.web3Wallet!.core.relayClient.connect();
      }
    } catch (e) {
      _globalSnackBar.showError(e.toString());
      setState(() {
        isLoading = false;
        if (pairingTimer != null) pairingTimer!.cancel();
      });
    }
    try {
      PairingInfo pairResult = await walletConnectService.pair(Uri.parse(url!));

      if (walletConnectService
          .sessionPairingTopicAlreadyExists(pairResult.topic)) {
        existsTimer = Timer(
            const Duration(seconds: Config.walletConnectExistsTimeoutSeconds),
            () async {
          if (mounted) {
            setState(() {
              isLoading = false;
            });
            _globalSnackBar.showError(l10n.wcErrorUsedURL);
          }
        });

        return;
      }

      pairingTimer = Timer(
          const Duration(seconds: Config.wallectConnectPairingTimeoutSeconds),
          () async {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
          _globalSnackBar.showError(l10n.wcErrorPairingTimeout);
        }
      });
    } catch (e) {
      //This can be a ReownSignError , a ReownCoreError or a generic error
      _globalSnackBar.showError(e.toString());

      setState(() {
        isLoading = false;
      });
    }
  }

  //Returns the child widget based on the platform
  //If the platform is desktop, it will return the desktop view
  //If the platform is mobile, and an app link is used it will return the desktop view
  //If the platform is mobile, and no app link is used it will return the mobile view

  Widget getChildWidget() {
    if (!isMobile) {
      return _AddWalletConnectDesktopView(
        isLoading: isLoading,
        proceedHandler: proceedHandler,
        connectionUrl: widget.connectionUrl,
      );
    }
    if (widget.connectionUrl != null) {
      return _AddWalletConnectDesktopView(
        isLoading: isLoading,
        proceedHandler: proceedHandler,
        connectionUrl: widget.connectionUrl,
      );
    }
    return _AddWalletConnectMobileView(
      onDetect: (capture) {
        final List<Barcode> barcodes = capture.barcodes;
        for (final barcode in barcodes) {
          if (barcode.rawValue != null && !isLoading) {
            proceedHandler(barcode.rawValue);
          }
        }
      },
      connectionUrl: widget.connectionUrl,
      proceedHandler: proceedHandler,
      pasteAndProceed: pasteAndProceed,
      isLoading: isLoading,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(canPop: !isLoading, child: getChildWidget());
  }
}
