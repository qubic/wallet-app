import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/models/network_model.dart';
import 'package:qubic_wallet/models/transaction_vm.dart';
import 'package:qubic_wallet/resources/secure_storage.dart';

enum HiveBoxesNames {
  storedTransactions,
  storedNetworks,
  currentNetworkName,
}

class HiveStorage {
  HiveStorage() {
    _init();
  }

  final _secureStorage = getIt<SecureStorage>();
  late final Box<TransactionVm> storedTransactions;
  late final Box<NetworkModel> storedNetworks;
  late final Box<String> _currentNetworkBox;
  late final HiveAesCipher _encryptionCipher;
  final currentNetworkKey = "current_network";

  Future<void> _init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TransactionVmAdapter());
    Hive.registerAdapter(NetworkAdapter());
    await _loadEncryptionKey();
    await openTransactionsBox();
    await openNetworksBox();
    await openCurrentNetworkBox();
  }

  /// Loads or generates a new encryption key and stores it securely.
  Future<void> _loadEncryptionKey() async {
    String? keyString = await _secureStorage.getHiveEncryptionKey();

    if (keyString == null) {
      final key = Hive.generateSecureKey();
      final encodedKey = base64UrlEncode(key);
      await _secureStorage.storeHiveEncryptionKey(encodedKey);
      _encryptionCipher = HiveAesCipher(key);
    } else {
      final key = base64Decode(keyString);
      _encryptionCipher = HiveAesCipher(key);
    }
  }

  Future<void> openTransactionsBox() async {
    storedTransactions = await Hive.openBox<TransactionVm>(
      HiveBoxesNames.storedTransactions.name,
      encryptionCipher: _encryptionCipher,
    );
  }

  Future<void> openNetworksBox() async {
    storedNetworks = await Hive.openBox<NetworkModel>(
      HiveBoxesNames.storedNetworks.name,
      encryptionCipher: _encryptionCipher,
    );
  }

  Future<void> openCurrentNetworkBox() async {
    _currentNetworkBox = await Hive.openBox<String>(
        HiveBoxesNames.currentNetworkName.name,
        encryptionCipher: _encryptionCipher);
  }

  void addStoredTransaction(TransactionVm transactionVm) {
    storedTransactions.put(transactionVm.id, transactionVm);
  }

  void removeStoredTransaction(String transactionId) {
    storedTransactions.delete(transactionId);
  }

  List<TransactionVm> getStoredTransactions() {
    return storedTransactions.values.toList();
  }

  addStoredNetwork(NetworkModel network) {
    storedNetworks.put(network.name, network);
  }

  List<NetworkModel> getStoredNetworks() {
    return storedNetworks.values.toList();
  }

  removeStoredNetwork(String networkName) {
    storedNetworks.delete(networkName);
  }

  void saveCurrentNetworkName(String networkName) {
    _currentNetworkBox.put(currentNetworkKey, networkName);
  }

  String? getCurrentNetworkName() {
    return _currentNetworkBox.get(currentNetworkKey);
  }

  Future<void> clear() async {
    await storedTransactions.clear();
    await storedNetworks.clear();
    _secureStorage.deleteHiveEncryptionKey();
  }
}
