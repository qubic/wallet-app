import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/models/transaction_vm.dart';
import 'package:qubic_wallet/stores/application_store.dart';

class TransactionActionHelpers {
  /// Returns true if this is a simple transfer (not a smart contract).
  /// Can be handled by the Send form.
  static bool isSimpleTransferTransaction(int? inputType, int amount) {
    return inputType == 0 && amount > 0;
  }

  static bool canResend(TransactionVm item) {
    final ApplicationStore appStore = getIt<ApplicationStore>();
    return (appStore.currentQubicIDs
            .any((e) => e.publicId == item.sourceId && !e.watchOnly) &&
        item.getStatus() != ComputedTransactionStatus.pending &&
        isSimpleTransferTransaction(item.type ?? 0, item.amount));
  }

  static bool canViewInExplorer(TransactionVm item) {
    return item.getStatus() != ComputedTransactionStatus.pending &&
        item.getStatus() != ComputedTransactionStatus.invalid;
  }

  static bool canDelete(TransactionVm item) {
    return item.getStatus() == ComputedTransactionStatus.invalid;
  }
}
