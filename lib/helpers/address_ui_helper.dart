import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/stores/qubic_ecosystem_store.dart';

/// UI helper for displaying address labels in UI components.
class AddressUIHelper {
  static final _ecosystemStore = getIt<QubicEcosystemStore>();

  /// Returns the label for an address if it's a known entity
  /// (smart contract, token, or labeled address).
  ///
  /// Returns null if the address is not recognized.
  static String? getLabel(String address) {
    return _ecosystemStore.getEntityLabel(address);
  }

  static const _truncateLength = 4;

  /// Truncates an address to show first and last [_truncateLength] characters.
  /// Example: "ABCDEFGHIJKLMNOP..." becomes "ABCD...MNOP"
  static String truncateAddress(String address) {
    if (address.length <= _truncateLength * 2) return address;
    return '${address.substring(0, _truncateLength)}...${address.substring(address.length - _truncateLength)}';
  }
}
