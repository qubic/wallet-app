import 'package:flutter/widgets.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/stores/qubic_ecosystem_store.dart';

/// UI helper for displaying address labels in UI components.
class AddressUIHelper {
  static final _ecosystemStore = getIt<QubicEcosystemStore>();

  /// Returns the localized label for an address if it's a known entity
  /// (smart contract, token issuer, exchange, or labeled address).
  ///
  /// Token issuers are formatted as "<TOKEN_NAME> Issuer" (localized) to
  /// match the qubic/explorer-frontend behavior.
  ///
  /// Returns null if the address is not recognized.
  static String? getLabel(BuildContext context, String address) {
    final contractName = _ecosystemStore.getContractName(address);
    if (contractName != null) return contractName;

    final tokenName = _ecosystemStore.getTokenName(address);
    if (tokenName != null) {
      return l10nOf(context).addressLabelTokenIssuer(tokenName);
    }

    return _ecosystemStore.getExchangeName(address) ??
        _ecosystemStore.getAddressLabel(address);
  }

  /// Returns true if the address is a known smart contract.
  static bool isSmartContract(String address) {
    return _ecosystemStore.getContractName(address) != null;
  }

  static const _truncateLength = 6;

  /// Truncates an address to show first and last [_truncateLength] characters.
  /// Example: "ABCDEFGHIJKLMNOP..." becomes "ABCD...MNOP"
  static String truncateAddress(String address) {
    if (address.length <= _truncateLength * 2) return address;
    return '${address.substring(0, _truncateLength)}...${address.substring(address.length - _truncateLength)}';
  }

  /// Truncates a string in the middle with "..." if it exceeds maxLength.
  static String truncateMiddle(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    final half = (maxLength - 3) ~/ 2;
    return '${text.substring(0, half)}...${text.substring(text.length - half)}';
  }
}
