import 'package:flutter/widgets.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/models/wallet_connect.dart';

/// Returns a list of localized strings matching the available WC pairing methods
List<String> getLocalizedPairingMethods(
    List<String> pairingMethods, BuildContext context) {
  final l10n = l10nOf(context);
  List<String> methods = [];
  for (var pairingMethod in pairingMethods) {
    if (pairingMethod == WcMethods.wRequestAccounts) {
      methods.add(l10n.wcScopeRequestAccounts);
    } else if (pairingMethod == WcMethods.wSendQubic) {
      methods.add(l10n.wcScopeSendQubic);
    } else if (pairingMethod == WcMethods.wSendAsset) {
      methods.add(l10n.wcScopeSendAssets);
    } else if (pairingMethod == WcMethods.wSignTransaction) {
      methods.add(l10n.wcScopeSignTransaction);
    } else if (pairingMethod == WcMethods.wSign) {
      methods.add(l10n.wcScopeSign);
    }
  }
  return methods;
}
