import 'package:flutter/material.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/helpers/platform_helpers.dart';
import 'package:qubic_wallet/helpers/show_alert_dialog.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/models/signed_transaction.dart';
import 'package:qubic_wallet/models/transaction_vm.dart';
import 'package:qubic_wallet/resources/apis/live/qubic_live_api.dart';
import 'package:qubic_wallet/resources/qubic_cmd.dart';
import 'package:qubic_wallet/smart_contracts/qx_info.dart';
import 'package:qubic_wallet/stores/application_store.dart';

void showTamperedWalletAlert(BuildContext context) {
  final l10n = l10nOf(context);

  showAlertDialog(
      context,
      l10n.addAccountErrorTamperedWalletTitle,
      isAndroid
          ? l10n.addAccountErrorTamperedAndroidWalletMessage
          : isIOS
              ? l10n.addAccountErrorTamperediOSWalletMessage
              : l10n.addAccountErrorTamperedWalletMessage);
}

///
/// Sends a transaction of value QUBIC from the sourceId to the QX address
/// Also involves moving around tokens from the sourceId to the destinationId
Future<SignedTransaction?> sendAssetTransferTransactionDialog(
    BuildContext context,
    String sourceId,
    String destinationId,
    String assetName,
    String issuer,
    int numberOfAssets,
    int destinationTick) async {
  final l10n = l10nOf(context);
  String seed = await getIt.get<ApplicationStore>().getSeedByPublicId(sourceId);
  late String transactionKey;
  QubicCmd qubicCmd = getIt.get<QubicCmd>();
  try {
    transactionKey = await qubicCmd.createAssetTransferTransaction(seed,
        destinationId, assetName, issuer, numberOfAssets, destinationTick);
    final transactionId =
        await getIt.get<QubicLiveApi>().submitTransaction(transactionKey);
    final pendingTransaction = TransactionVm(
        id: transactionId,
        sourceId: sourceId,
        destId: destinationId,
        amount: QxInfo.transferAssetFee,
        status: ComputedTransactionStatus.pending.name,
        targetTick: destinationTick,
        isPending: true,
        moneyFlow: true);
    getIt.get<ApplicationStore>().addStoredTransaction(pendingTransaction);
    return SignedTransaction(
        transactionKey: transactionKey, transactionId: transactionId);
  } catch (e) {
    if (e.toString().startsWith("Exception: CRITICAL:")) {
      if (context.mounted) {
        showTamperedWalletAlert(context);
      }
      return null;
    }
    if (context.mounted) {
      showAlertDialog(
          context, l10n.sendItemDialogErrorGeneralTitle, e.toString());
    }
    return null;
  }
}

// Gets the transaction key to be submitted in the API for a transaction
Future<SignedTransaction?> getTransactionDialog(
    BuildContext context,
    String sourceId,
    String destinationId,
    int value,
    int destinationTick,
    int? inputType,
    String? payload) async {
  final l10n = l10nOf(context);
  String seed = await getIt.get<ApplicationStore>().getSeedByPublicId(sourceId);
  QubicCmd qubicCmd = getIt.get<QubicCmd>();
  try {
    return await qubicCmd.createTransaction(
        seed, destinationId, value, destinationTick,
        inputType: inputType, payload: payload);
  } catch (e) {
    if (e.toString().startsWith("Exception: CRITICAL:")) {
      if (context.mounted) {
        showTamperedWalletAlert(context);
      }
      return null;
    }
    if (context.mounted) {
      showAlertDialog(
          context, l10n.sendItemDialogErrorGeneralTitle, e.toString());
    }
    return null;
  }
}

///
/// Sends a transaction of value QUBIC from the sourceId to the destinationId
Future<SignedTransaction?> sendTransactionDialog(BuildContext context,
    String sourceId, String destinationId, int value, int destinationTick,
    {int? inputType, String? payload}) async {
  final l10n = l10nOf(context);

  late String? transactionKey;
  final signedTransaction = await getTransactionDialog(context, sourceId,
      destinationId, value, destinationTick, inputType, payload);
  transactionKey = signedTransaction?.transactionKey;
  if (transactionKey == null) {
    return null;
  }

  //We have the transaction, now let's call the API
  try {
    final transactionId =
        await getIt.get<QubicLiveApi>().submitTransaction(transactionKey);
    final pendingTransaction = TransactionVm(
        id: transactionId,
        sourceId: sourceId,
        destId: destinationId,
        amount: value,
        status: ComputedTransactionStatus.pending.name,
        targetTick: destinationTick,
        isPending: true,
        moneyFlow: value > 0);
    getIt.get<ApplicationStore>().addStoredTransaction(pendingTransaction);
  } catch (e) {
    if (context.mounted) {
      showAlertDialog(
          context, l10n.sendItemDialogErrorGeneralTitle, e.toString());
    }
    return null;
  }
  return signedTransaction;
}
