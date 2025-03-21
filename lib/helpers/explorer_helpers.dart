import 'package:flutter/material.dart';
import 'package:qubic_wallet/config.dart';
import 'package:url_launcher/url_launcher_string.dart';

void viewAddressInExplorer(BuildContext context, String address) {
  viewExplorerURL(context, "network/address/$address");
}

void viewTransactionInExplorer(BuildContext context, String trxId) {
  viewExplorerURL(context, "network/tx/$trxId");
}

void viewExplorerURL(BuildContext context, String pathToData) {
  // TODO: Get the base explorer URL from the new config
  launchUrlString("${Config.URL_WebExplorer}/$pathToData",
      mode: LaunchMode.inAppWebView);
}
