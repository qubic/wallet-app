import 'package:flutter/material.dart';
import 'package:qubic_wallet/config.dart';
import 'package:url_launcher/url_launcher_string.dart';

void viewAddressInExplorer(BuildContext context, String address) {
  viewExplorerURL(context, "network/address/$address");
}

void viewExplorerURL(BuildContext context, String pathToData) {
  launchUrlString("${Config.URL_WebExplorer}/$pathToData",
      mode: LaunchMode.externalApplication);
}
