import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/stores/qubic_data_store.dart';

/// UI helper for displaying address labels in UI components.
class AddressUIHelper {
  static final QubicDataStore _dataStore = getIt<QubicDataStore>();

  /// Returns the label for an address if it's a known entity
  /// (smart contract, token, or labeled address).
  ///
  /// Returns null if the address is not recognized.
  static String? getLabel(String address) {
    return _dataStore.getLabel(address);
  }
}
