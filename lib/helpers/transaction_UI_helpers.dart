import 'package:flutter/material.dart';
import 'package:qubic_wallet/components/change_foreground.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/models/transaction_vm.dart';
import 'package:qubic_wallet/styles/textStyles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

Widget getEmptyTransactions(
    {required BuildContext context,
    required bool hasFiltered,
    int? numberOfFilters,
    required void Function()? onTap}) {
  final l10n = l10nOf(context);
  String message = hasFiltered
      ? l10n.transfersLabelNoTransactionsFoundInWalletMatchingFilters
      : l10n.transfersLabelNoTransactionsFoundInWallet;

  return getEmptyTransactionsWidget(
      context: context,
      hasFiltered: hasFiltered,
      numberOfFilters: numberOfFilters,
      message: message,
      onTap: onTap);
}

Widget getEmptyTransactionsForSingleID(
    {required BuildContext context,
    required bool hasFiltered,
    int? numberOfFilters,
    required void Function()? onTap}) {
  final l10n = l10nOf(context);
  String message = hasFiltered
      ? l10n.transfersLabelNoTransactionsFoundInAccountMatchingFilters
      : l10n.transfersLabelNoTransactionsFoundInAccount;

  return getEmptyTransactionsWidget(
      context: context,
      hasFiltered: hasFiltered,
      numberOfFilters: numberOfFilters,
      message: message,
      onTap: onTap);
}

Widget getEmptyTransactionsWidget(
    {required BuildContext context,
    required bool hasFiltered,
    int? numberOfFilters,
    required String message,
    required void Function()? onTap}) {
  final l10n = l10nOf(context);
  return Column(children: [
    ThemedControls.spacerVerticalHuge(),
    ChangeForeground(
        color: LightThemeColors.gradient1,
        child: Image.asset('assets/images/transactions-color-146.png')),
    ThemedControls.spacerVerticalHuge(),
    Text(
      message,
      textAlign: TextAlign.center,
      style: TextStyles.secondaryText,
    ),
    ThemedControls.spacerVerticalHuge(),
    if ((hasFiltered) && (numberOfFilters != null))
      ThemedControls.primaryButtonNormal(
          onPressed: onTap, text: l10n.filterTransfersClearAllFilters)
  ]);
}

IconData getTransactionStatusIcon(ComputedTransactionStatus status) {
  switch (status) {
    case ComputedTransactionStatus.confirmed:
      return Icons.check_circle;
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

Color getTransactionStatusColor(ComputedTransactionStatus status) {
  switch (status) {
    case ComputedTransactionStatus.confirmed:
      return Colors.blue;
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

String getTransactionStatusText(
    ComputedTransactionStatus status, BuildContext context) {
  final l10n = l10nOf(context);
  switch (status) {
    case ComputedTransactionStatus.confirmed:
      return l10n.transactionLabelStatusConfirmed;
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
