import 'package:flutter/material.dart';
import 'package:qubic_wallet/components/confirmation_dialog.dart';
import 'package:qubic_wallet/l10n/l10n.dart';

/// Returns true only when the user explicitly taps Continue.
Future<bool> showSmartContractTransferWarning(BuildContext context,
    {required String contractName, required bool isDappRequest}) async {
  final l10n = l10nOf(context);
  bool proceed = false;
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return ConfirmationDialog(
        title: l10n.smartContractTransferWarningTitle,
        content: isDappRequest
            ? l10n.smartContractTransferWarningTextDApp(contractName)
            : l10n.smartContractTransferWarningText(contractName),
        continueText: l10n.generalButtonContinue,
        continueFunction: () => proceed = true,
      );
    },
  );
  return proceed;
}
