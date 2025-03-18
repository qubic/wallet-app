import 'package:qubic_wallet/config.dart';
import 'package:url_launcher/url_launcher_string.dart';

void viewAddressInExplorer(String address) {
  launchUrlString("${Config.URL_WebExplorer}/network/address/$address",
      mode: LaunchMode.inAppWebView);
}

void viewTransactionInExplorer(String trxId) {
  launchUrlString("${Config.URL_WebExplorer}/network/tx/$trxId",
      mode: LaunchMode.inAppWebView);
}
