import 'package:hive_flutter/hive_flutter.dart';
import 'package:qubic_wallet/helpers/app_logger.dart';
import 'package:qubic_wallet/models/transaction_vm.dart';

enum HiveBoxesNames {
  storedTransactions,
}

class HiveStorage {
  HiveStorage() {
    _init();
  }
  late final Box<TransactionVm> storedTransactions;

  Future<void> _init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TransactionVmAdapter());
    openTransactionsBox();
  }

  Future<void> openTransactionsBox() async {
    storedTransactions = await Hive.openBox<TransactionVm>(
        HiveBoxesNames.storedTransactions.name);
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
  }
}
