import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/pages/main/tab_dapps/webview_screen.dart';
import 'package:qubic_wallet/stores/network_store.dart';

void viewAddressInExplorer(BuildContext context, String address) {
  viewExplorerURL(context, "network/address/$address");
}

void viewTransactionInExplorer(BuildContext context, String trxId) {
  viewExplorerURL(context, "network/tx/$trxId");
}

void viewExplorerURL(BuildContext context, String pathToData) {
  final String explorerUrl = getIt<NetworkStore>().explorerUrl;
  pushScreen(
    context,
    screen: SafeArea(
        top: false,
        child: WebviewScreen(initialUrl: "$explorerUrl/$pathToData")),
    pageTransitionAnimation: PageTransitionAnimation.slideUp,
    withNavBar: false,
  );
}
