import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/models/transaction_vm.dart';
import 'package:qubic_wallet/smart_contracts/qutil_info.dart';
import 'package:qubic_wallet/smart_contracts/qx_info.dart';
import 'package:qubic_wallet/stores/application_store.dart';

class TransactionActionHelpers {
  static bool canResend(TransactionVm item) {
    final ApplicationStore appStore = getIt<ApplicationStore>();

    final sourceAccount = appStore.currentQubicIDs
        .where((e) => e.publicId == item.sourceId && !e.watchOnly)
        .firstOrNull;

    // Check if source account exists and has balance data loaded
    if (sourceAccount == null || sourceAccount.amount == null) {
      return false;
    }

    return (item.getStatus() != ComputedTransactionStatus.pending &&
        item.amount > 0 &&
        item.destId != QxInfo.mainAssetIssuer &&
        item.destId != QutilInfo.address &&
        item.destId != QxInfo.address);
  }

  static bool canViewInExplorer(TransactionVm item) {
    return item.getStatus() != ComputedTransactionStatus.pending &&
        item.getStatus() != ComputedTransactionStatus.invalid;
  }

  static bool canDelete(TransactionVm item) {
    return item.getStatus() == ComputedTransactionStatus.invalid;
  }
}
