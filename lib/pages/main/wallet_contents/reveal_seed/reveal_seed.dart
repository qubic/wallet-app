import 'package:flutter/material.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/helpers/global_snack_bar.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/models/qubic_list_vm.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/reveal_seed/reveal_seed_contents.dart';
import 'package:qubic_wallet/services/screenshot_service.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/styles/edge_insets.dart';

class RevealSeed extends StatefulWidget {
  final QubicListVm item;
  const RevealSeed({super.key, required this.item});

  @override
  // ignore: library_private_types_in_public_api
  _RevealSeedState createState() => _RevealSeedState();
}

class _RevealSeedState extends State<RevealSeed> {
  final ApplicationStore appStore = getIt<ApplicationStore>();
  final screenshotService = getIt<ScreenshotService>();
  final GlobalSnackBar globalSnackBar = getIt<GlobalSnackBar>();

  bool hasAccepted = false;

  @override
  void initState() {
    super.initState();
    screenshotService.disableScreenshot();
    screenshotService.startListening(onScreenshot: (e) {
      if (l10nWrapper.l10n != null && e.wasScreenshotTaken == true) {
        globalSnackBar.show(l10nWrapper.l10n!.blockedScreenshotWarning);
      }
    });
  }

  @override
  void dispose() {
    screenshotService.disableScreenshot();
    screenshotService.stopListening();
    super.dispose();
  }

  Widget getContents() {
    return RevealSeedContents(item: widget.item);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
        ),
        body: SafeArea(
            minimum: ThemeEdgeInsets.pageInsets,
            child: Column(children: [Expanded(child: getContents())])));
  }
}
