import 'package:flutter/material.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/models/transaction_vm.dart';

class TransactionStatusHelpers {
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

  static ComputedTransactionStatus getTransactionStatus(bool isPending,
      int? inputType, int amount, bool moneyFlew, bool isInvalid) {
    ComputedTransactionStatus result;

    if (isPending) {
      result = ComputedTransactionStatus.pending;
    } else if (isInvalid) {
      result = ComputedTransactionStatus.invalid;
    } else {
      if (inputType == 0 && amount > 0) {
        // it's a "simple" transfer so we can say if worked or not
        result = moneyFlew
            ? ComputedTransactionStatus.success
            : ComputedTransactionStatus.failure;
      } else {
        result = ComputedTransactionStatus.executed;
      }
    }
    return result;
  }
}
