import 'package:flutter/material.dart';
import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/pages/main/tab_dapps/webview_screen.dart';
import 'package:url_launcher/url_launcher_string.dart';

void viewAddressInExplorer(BuildContext context, String address) {
  viewExplorerURL(context, "network/address/$address");
}

void viewTransactionInExplorer(BuildContext context, String trxId) {
  viewExplorerURL(context, "network/tx/$trxId");
}

void viewExplorerURL(BuildContext context, String pathToData) {
  // TODO: display full screen and to get the base explorer URL from the new config
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return WebviewScreen(initialUrl: "${Config.URL_WebExplorer}/$pathToData");
  }));
}
