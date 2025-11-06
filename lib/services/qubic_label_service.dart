import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/stores/qubic_data_store.dart';

/// Provides access to Qubic entity labels and metadata.
/// Wraps QubicDataStore for UI components.
class QubicLabelService {
  final QubicDataStore _dataStore = getIt<QubicDataStore>();

  /// Returns the label for an address (smart contract, token, or labeled address).
  /// Returns null if not recognized.
  String? getLabel(String address) {
    return _dataStore.getLabel(address);
  }

  /// Checks if an address is a known entity (smart contract, token, or labeled address).
  ///
  /// Returns true if the address exists in any of the known entity lists.
  ///
  /// Example:
  /// ```dart
  /// if (service.isKnownEntity(address)) {
  ///   // Show the label
  /// }
  /// ```
  bool isKnownEntity(String address) {
    return _dataStore.isKnownEntity(address);
  }

  /// Gets the procedure name for a smart contract transaction type.
  ///
  /// Returns null if:
  /// - The contractId is not a known smart contract
  /// - The type number doesn't match any procedure
  ///
  /// Example:
  /// ```dart
  /// final procName = service.getProcedureName(contractId, 1);
  /// // Returns: "Transfer" (if type 1 is Transfer procedure)
  /// ```
  String? getProcedureName(String contractId, int type) {
    return _dataStore.getProcedureName(contractId, type);
  }

  /// Loads all data from APIs (smart contracts, tokens, labeled addresses).
  ///
  /// Runs all loading operations in parallel.
  /// Should be called on app startup or when data needs to be refreshed.
  Future<void> loadAllData() async {
    return _dataStore.loadAllData();
  }

  /// Refreshes data only if it hasn't been loaded yet.
  ///
  /// Checks each data source and loads only the missing ones.
  /// Useful for lazy loading on demand.
  Future<void> refreshIfAbsent() async {
    return _dataStore.refreshIfAbsent();
  }
}
