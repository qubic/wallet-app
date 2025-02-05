import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:qubic_wallet/di.dart';
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
  late final Box<TransactionVm> storedTransactions;
  late final HiveAesCipher _encryptionCipher;

  Future<void> _init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TransactionVmAdapter());
    await _loadEncryptionKey();
    await openTransactionsBox();
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

  void addStoredTransaction(TransactionVm transactionVm) {
    storedTransactions.put(transactionVm.id, transactionVm);
  }

  void removeStoredTransaction(String transactionId) {
    storedTransactions.delete(transactionId);
  }

  List<TransactionVm> getStoredTransactions() {
    return storedTransactions.values.toList();
  }

  Future<void> clear() async {
    await storedTransactions.clear();
    _secureStorage.deleteHiveEncryptionKey();
  }
}
