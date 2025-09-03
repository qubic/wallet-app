import 'dart:async';
import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/models/network_model.dart';
import 'package:qubic_wallet/helpers/app_logger.dart';
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
  late Box<TransactionVm> _storedTransactions;
  late Box<NetworkModel> _storedNetworks;
  late Box<String> _currentNetworkBox;
  final currentNetworkKey = "current_network";
  late HiveAesCipher _encryptionCipher;

  Future<void> _init() async {
    appLogger.i('[HiveStorage] Initializing Hive...');
    await Hive.initFlutter();
    Hive.registerAdapter(TransactionVmAdapter());
    Hive.registerAdapter(NetworkAdapter());
    initEncryptedBoxes();
  }

  initEncryptedBoxes() async {
    try {
      await _loadEncryptionKey();
      await openTransactionsBox();
      await openNetworksBox();
      await openCurrentNetworkBox();
    } catch (e) {
      appLogger.e("[HiveStorage] Error initializing hive storage: $e");
    }
  }

  /// Loads or generates a new encryption key and stores it securely.
  Future<void> _loadEncryptionKey() async {
    appLogger.d('[HiveStorage] Loading encryption key...');
    String? keyString = await _secureStorage.getHiveEncryptionKey();

    if (keyString == null) {
      appLogger
          .w('[HiveStorage] No encryption key found! Generating new key...');
      final key = Hive.generateSecureKey();
      final encodedKey = base64UrlEncode(key);
      await _secureStorage.storeHiveEncryptionKey(encodedKey);
      _encryptionCipher = HiveAesCipher(key);
      appLogger.w('[HiveStorage] New encryption key generated and stored.');
    } else {
      final key = base64Decode(keyString);
      _encryptionCipher = HiveAesCipher(key);
      appLogger.w('[HiveStorage] Existing encryption key loaded.');
    }
    appLogger.d(
        '[HiveStorage] Encryption key loaded - $_encryptionCipher - ${_encryptionCipher.calculateKeyCrc()}');
  }

  Future<void> openTransactionsBox() async {
    appLogger.d('[HiveStorage] Attempting to open transactions box...');
    try {
      _storedTransactions = await Hive.openBox<TransactionVm>(
        HiveBoxesNames.storedTransactions.name,
        encryptionCipher: _encryptionCipher,
      );
      appLogger.d(
          '[HiveStorage] Transactions box opened with ${_storedTransactions.length} items.');
    } catch (e, stack) {
      appLogger.e('[HiveStorage] Failed to open transactions box: $e');
      appLogger.e('[HiveStorage] Stacktrace: $stack');
    }
  }

  Future<void> openNetworksBox() async {
    _storedNetworks = await Hive.openBox<NetworkModel>(
      HiveBoxesNames.storedNetworks.name,
      encryptionCipher: _encryptionCipher,
    );
    appLogger.d(
        '[HiveStorage] Networks box opened with ${_storedNetworks.length} items.');
  }

  Future<void> openCurrentNetworkBox() async {
    _currentNetworkBox = await Hive.openBox<String>(
        HiveBoxesNames.currentNetworkName.name,
        encryptionCipher: _encryptionCipher);
    appLogger.d('[HiveStorage] Current network box opened.');
  }

  void addStoredTransaction(TransactionVm transactionVm) {
    appLogger.d('[HiveStorage] Adding transaction: ${transactionVm.id}');
    _storedTransactions.put(transactionVm.id, transactionVm);
  }

  void removeStoredTransaction(String transactionId) {
    appLogger.d('[HiveStorage] Removing transaction: $transactionId');
    _storedTransactions.delete(transactionId);
  }

  List<TransactionVm> getStoredTransactions() {
    appLogger.d(
        '[HiveStorage] Getting stored transactions (${_storedTransactions.length})');
    return _storedTransactions.values.toList();
  }

  addStoredNetwork(NetworkModel network) {
    _storedNetworks.put(network.name, network);
  }

  List<NetworkModel> getStoredNetworks() {
    return _storedNetworks.values.toList();
  }

  removeStoredNetwork(String networkName) {
    _storedNetworks.delete(networkName);
  }

  void saveCurrentNetworkName(String networkName) {
    _currentNetworkBox.put(currentNetworkKey, networkName);
  }

  String? getCurrentNetworkName() {
    return _currentNetworkBox.get(currentNetworkKey);
  }

  Future<void> clear() async {
    await _storedTransactions.clear();
    _storedTransactions.close();

    await _storedNetworks.clear();
    _storedNetworks.close();

    await _currentNetworkBox.clear();
    _currentNetworkBox.close();

    await _secureStorage.deleteHiveEncryptionKey();
    appLogger.w(
        '[HiveStorage] data cleared, boxes closed, and encryption key deleted.');
  }
}
