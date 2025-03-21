import 'package:flutter/material.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/stores/network_store.dart';
import 'package:url_launcher/url_launcher_string.dart';

void viewAddressInExplorer(BuildContext context, String address) {
  viewExplorerURL(context, "network/address/$address");
}

void viewTransactionInExplorer(BuildContext context, String trxId) {
  viewExplorerURL(context, "network/tx/$trxId");
}

String getExplorerBaseUrl() {
  final NetworkStore networkStore = getIt<NetworkStore>();
  final String explorerUrl = networkStore.selectedNetwork.explorerUrl;
  return explorerUrl;
}

void viewExplorerURL(BuildContext context, String pathToData) {
  final String explorerUrl = getExplorerBaseUrl();
  launchUrlString("$explorerUrl/$pathToData", mode: LaunchMode.inAppWebView);
}
