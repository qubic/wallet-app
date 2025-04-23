import 'dart:async';
import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/helpers/app_logger.dart';
import 'package:qubic_wallet/models/transaction_vm.dart';
import 'package:qubic_wallet/resources/secure_storage.dart';

enum HiveBoxesNames {
  storedTransactions,
}

class HiveStorage {
  HiveStorage() {
    _init();
  }

  final _secureStorage = getIt<SecureStorage>();
  late Box<TransactionVm> storedTransactions;
  late HiveAesCipher _encryptionCipher;

  Future<void> _init() async {
    appLogger.i('[HiveStorage] Initializing Hive...');
    await Hive.initFlutter();
    Hive.registerAdapter(TransactionVmAdapter());
    initEncryptedBox();
  }

  initEncryptedBox() async {
    await _loadEncryptionKey();
    await openTransactionsBox();
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
      storedTransactions = await Hive.openBox<TransactionVm>(
        HiveBoxesNames.storedTransactions.name,
        encryptionCipher: _encryptionCipher,
      );
      appLogger.d(
          '[HiveStorage] Transactions box opened with ${storedTransactions.length} items.');
    } catch (e, stack) {
      appLogger.e('[HiveStorage] Failed to open transactions box: $e');
      appLogger.e('[HiveStorage] Stacktrace: $stack');
    }
  }

  void addStoredTransaction(TransactionVm transactionVm) {
    appLogger.d('[HiveStorage] Adding transaction: ${transactionVm.id}');
    storedTransactions.put(transactionVm.id, transactionVm);
  }

  void removeStoredTransaction(String transactionId) {
    appLogger.d('[HiveStorage] Removing transaction: $transactionId');
    storedTransactions.delete(transactionId);
  }

  List<TransactionVm> getStoredTransactions() {
    appLogger.d(
        '[HiveStorage] Getting stored transactions (${storedTransactions.length})');
    return storedTransactions.values.toList();
  }

  Future<void> clear() async {
    await storedTransactions.clear();
    storedTransactions.close();
    await _secureStorage.deleteHiveEncryptionKey();
    appLogger.w(
        '[HiveStorage] transactions cleared, encryption key deleted, boxes closed.');
  }
}
