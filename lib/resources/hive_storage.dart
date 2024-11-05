import 'dart:developer';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:qubic_wallet/models/transaction_vm.dart';

enum HiveBoxesNames {
  pendingTransactions,
  ignoredTransactions,
}

class HiveStorage {
  HiveStorage() {
    _init();
  }
  late final Box<TransactionVm> pendingTransactions;
  late final Box<TransactionVm> ignoredTransactions;

  Future<void> _init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TransactionVmAdapter());
    openTransactionBoxes();
  }

  Future<void> openTransactionBoxes() async {
    pendingTransactions = await Hive.openBox<TransactionVm>(
        HiveBoxesNames.pendingTransactions.name);
    ignoredTransactions = await Hive.openBox<TransactionVm>(
        HiveBoxesNames.ignoredTransactions.name);
  }

  void addPendingTransaction(TransactionVm transactionVm) {
    pendingTransactions.put(transactionVm.id, transactionVm);
  }

  void removePendingTransaction(String transactionId) {
    pendingTransactions.delete(transactionId);
  }

  List<TransactionVm> getPendingTransactions() {
    return pendingTransactions.values.toList();
  }

  void addIgnoredTransaction(TransactionVm transactionVm) {
    ignoredTransactions.put(transactionVm.id, transactionVm);
  }

  void removeIgnoredTransaction(String transactionId) {
    ignoredTransactions.delete(transactionId);
  }

  List<TransactionVm> getIgnoredTransactions() {
    return ignoredTransactions.values.toList();
  }

  Future<void> clear() async {
    await Hive.deleteBoxFromDisk(HiveBoxesNames.pendingTransactions.name);
    await Hive.deleteBoxFromDisk(HiveBoxesNames.ignoredTransactions.name);
  }
}
