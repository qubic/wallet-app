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
    }
  }
}
