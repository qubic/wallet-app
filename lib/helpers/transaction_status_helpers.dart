import 'package:flutter/material.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/transaction_actions_helpers.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/models/transaction_vm.dart';
import 'package:qubic_wallet/smart_contracts/qutil_info.dart';

class TransactionStatusHelpers {
  /// Determines if a transaction has definitive success/failure status from moneyFlew.
  /// This includes simple Qubic transfers (type 0 with amount > 0) and SendMany transactions.
  static bool hasDefinitiveStatus({
    required int? inputType,
    required int amount,
    required String? destId,
  }) {
    final isSendMany = QutilInfo.isSendToManyTransfer(destId, inputType);
    return TransactionActionHelpers.isSimpleTransferTransaction(
            inputType, amount) ||
        isSendMany;
  }

  static IconData getTransactionStatusIcon(ComputedTransactionStatus status) {
    switch (status) {
      case ComputedTransactionStatus.failure:
        return Icons.highlight_remove_outlined;
      case ComputedTransactionStatus.invalid:
        return Icons.remove_circle;
      case ComputedTransactionStatus.success:
        return Icons.check_circle;
      case ComputedTransactionStatus.pending:
        return Icons.access_time_filled;
      case ComputedTransactionStatus.executed:
        return Icons.check_circle_outlined;
    }
  }

  static Color getTransactionStatusColor(ComputedTransactionStatus status) {
    switch (status) {
      case ComputedTransactionStatus.failure:
        return LightThemeColors.error;
      case ComputedTransactionStatus.invalid:
        return LightThemeColors.error;
      case ComputedTransactionStatus.success:
        return LightThemeColors.successIncoming;
      case ComputedTransactionStatus.pending:
        return LightThemeColors.pending;
      case ComputedTransactionStatus.executed:
        return LightThemeColors.successIncoming;
    }
  }

  static String getTransactionStatusText(
      ComputedTransactionStatus status, BuildContext context) {
    final l10n = l10nOf(context);
    switch (status) {
      case ComputedTransactionStatus.failure:
        return l10n.transactionLabelStatusFailed;
      case ComputedTransactionStatus.invalid:
        return l10n.transactionLabelStatusInvalid;
      case ComputedTransactionStatus.success:
        return l10n.transactionLabelStatusSuccessful;
      case ComputedTransactionStatus.pending:
        return l10n.transactionLabelStatusPending;
      case ComputedTransactionStatus.executed:
        return l10n.transactionLabelStatusExecuted;
    }
  }

  static ComputedTransactionStatus getTransactionStatus(
      bool isPending,
      int? inputType,
      int amount,
      bool moneyFlew,
      bool isInvalid,
      String? destId) {
    ComputedTransactionStatus result;

    if (isPending) {
      result = ComputedTransactionStatus.pending;
    } else if (isInvalid) {
      result = ComputedTransactionStatus.invalid;
    } else {
      if (hasDefinitiveStatus(
          inputType: inputType, amount: amount, destId: destId)) {
        // For simple transfers and SendMany transactions:
        // The moneyFlew flag definitively tells us if the transfer succeeded
        result = moneyFlew
            ? ComputedTransactionStatus.success
            : ComputedTransactionStatus.failure;
      } else {
        // For other smart contract calls or 0-amount transactions:
        // We cannot determine success/failure from moneyFlew alone
        // So we show "executed" to indicate the tx was processed by the network
        result = ComputedTransactionStatus.executed;
      }
    }
    return result;
  }
}
