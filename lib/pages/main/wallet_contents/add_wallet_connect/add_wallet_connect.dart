import 'dart:async';
import 'dart:developer';
import 'dart:ui';

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
import 'package:qubic_wallet/pages/main/wallet_contents/add_wallet_connect/components/scanner_corners_border.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/add_wallet_connect/components/scanner_overlay_clipper.dart';
import 'package:qubic_wallet/services/wallet_connect_service.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/styles/button_styles.dart';
import 'package:qubic_wallet/styles/edge_insets.dart';
import 'package:qubic_wallet/styles/input_decorations.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:reown_walletkit/reown_walletkit.dart';

part 'components/add_wallet_connect_desktop_view.dart';
part 'components/add_wallet_connect_mobile_view.dart';

enum DomainType { valid, unknown, scam, mismatch }

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

          List<String?> requiredNetworkIDs = [];
          args.params.requiredNamespaces.forEach((key, value) {
            requiredNetworkIDs.addAll(value.chains?.toList() ?? []);
          });
          for (var network in requiredNetworkIDs) {
            if (network != null && network != Config.walletConnectChainId) {
              notSupportedNetworks.add(network);
            }
          }
        }
        final invalidApp = args?.verifyContext?.validation.invalid;
        final unknown = args?.verifyContext?.validation.unknown;
        final scamApp = args?.verifyContext?.validation.scam;
        if (mounted) {
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
        _globalSnackBar.showError(l10n.wcErrorUsedURL);
        return;
      }
    } catch (e) {
      //This can be a ReownSignError , a ReownCoreError or a generic error
      _globalSnackBar.showError(e.toString());

      setState(() {
        isLoading = false;
      });
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isLoading,
      child: (isMobile)
          ? _AddWalletConnectMobileView(
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null && !isLoading) {
                    proceedHandler(barcode.rawValue);
                  }
                }
              },
              pasteAndProceed: pasteAndProceed,
              isLoading: isLoading,
            )
          : _AddWalletConnectDesktopView(
              isLoading: isLoading,
              proceedHandler: proceedHandler,
            ),
    );
  }
}
