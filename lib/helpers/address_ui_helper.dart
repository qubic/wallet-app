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

  /// Truncates a string in the middle with "..." if it exceeds maxLength.
  static String truncateMiddle(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    final half = (maxLength - 3) ~/ 2;
    return '${text.substring(0, half)}...${text.substring(text.length - half)}';
  }
}