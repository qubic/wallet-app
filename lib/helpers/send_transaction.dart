import 'package:flutter/material.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/helpers/app_logger.dart';
import 'package:qubic_wallet/helpers/platform_helpers.dart';
import 'package:qubic_wallet/helpers/release_transfer_rights_helper.dart';
import 'package:qubic_wallet/helpers/show_alert_dialog.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/models/app_error.dart';
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
  int amount = QxInfo.transferAssetFee;
  try {
    transactionKey = await qubicCmd.createAssetTransferTransaction(seed,
        destinationId, assetName, issuer, numberOfAssets, destinationTick);
    final transactionId =
        await getIt.get<QubicLiveApi>().submitTransaction(transactionKey);

    // only storing locally the transfers (amount > 0)
    if (amount > 0) {
      final pendingTransaction = TransactionVm(
          id: transactionId,
          sourceId: sourceId,
          destId: QxInfo.address,
          amount: amount,
          targetTick: destinationTick,
          isPending: true,
          moneyFlow: amount > 0,
          type: QxInfo.transferAssetInputType,
          inputHex: null);
      getIt.get<ApplicationStore>().addStoredTransaction(pendingTransaction);
    }
    return SignedTransaction(
        transactionKey: transactionKey, transactionId: transactionId);
  } catch (e) {
    if (e is AppError && e.type == ErrorType.tamperedWallet) {
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

    // only storing locally the transfers (amount > 0)
    if (value > 0) {
      final pendingTransaction = TransactionVm(
        id: transactionId,
        sourceId: sourceId,
        destId: destinationId,
        amount: value,
        targetTick: destinationTick,
        isPending: true,
        moneyFlow: value > 0,
        type: inputType,
        inputHex: payload,
      );
      getIt.get<ApplicationStore>().addStoredTransaction(pendingTransaction);
    }
  } catch (e) {
    if (context.mounted) {
      showAlertDialog(
          context, l10n.sendItemDialogErrorGeneralTitle, e.toString());
    }
    return null;
  }
  return signedTransaction;
}

///
/// Sends a Release Transfer Rights transaction
/// This transfers the management rights of an asset from one contract to another
///
/// Parameters:
/// - [sourceId]: User's public ID (account that owns the asset)
/// - [issuerIdentity]: The issuer identity of the asset
/// - [assetName]: Name of the asset
/// - [numberOfShares]: Number of shares to transfer management rights for
/// - [sourceContractIndex]: Contract index that currently manages the asset
/// - [destinationContractIndex]: Contract index to transfer management rights to
/// - [contractAddress]: Address of the source contract (transaction destination)
/// - [procedureNumber]: Procedure number for the source contract
/// - [fee]: Transaction fee in QUBIC
/// - [destinationTick]: Target tick for the transaction
Future<SignedTransaction?> sendReleaseTransferRightsTransactionDialog(
  BuildContext context, {
  required String sourceId,
  required String issuerIdentity,
  required String assetName,
  required int numberOfShares,
  required int sourceContractIndex,
  required int destinationContractIndex,
  required String contractAddress,
  required int procedureNumber,
  required int fee,
  required int destinationTick,
}) async {
  final l10n = l10nOf(context);
  String seed = await getIt.get<ApplicationStore>().getSeedByPublicId(sourceId);
  QubicCmd qubicCmd = getIt.get<QubicCmd>();

  try {
    // Serialize the input structure
    final payload = await ReleaseTransferRightsHelper.serializeInput(
      issuerIdentity: issuerIdentity,
      assetName: assetName,
      numberOfShares: numberOfShares,
      newManagingContractIndex: destinationContractIndex,
    );

    appLogger.d('=== RELEASE TRANSFER RIGHTS PAYLOAD ===');
    appLogger.d('Issuer Identity: $issuerIdentity');
    appLogger.d('Asset Name: $assetName');
    appLogger.d('Number of Shares: $numberOfShares');
    appLogger.d('Source Contract Index: $sourceContractIndex');
    appLogger.d('Destination Contract Index: $destinationContractIndex');
    appLogger.d('Contract Address: $contractAddress');
    appLogger.d('Procedure Number: $procedureNumber');
    appLogger.d('Fee: $fee');
    appLogger.d('Target Tick: $destinationTick');
    appLogger.d('---');
    appLogger.d('Payload (base64): $payload');
    appLogger.d('=======================================');

    // Create the transaction
    final signedTransaction = await qubicCmd.createTransaction(
      seed,
      contractAddress,
      fee,
      destinationTick,
      inputType: procedureNumber,
      payload: payload,
    );

    final transactionKey = signedTransaction.transactionKey;
    final transactionId =
        await getIt.get<QubicLiveApi>().submitTransaction(transactionKey);

    // Store the transaction locally
    if (fee >= 0) {
      final pendingTransaction = TransactionVm(
        id: transactionId,
        sourceId: sourceId,
        destId: contractAddress,
        amount: fee,
        targetTick: destinationTick,
        isPending: true,
        moneyFlow: fee > 0,
        type: procedureNumber,
        inputHex: payload,
      );
      getIt.get<ApplicationStore>().addStoredTransaction(pendingTransaction);
    }

    return SignedTransaction(
      transactionKey: transactionKey,
      transactionId: transactionId,
    );
  } catch (e) {
    if (e is AppError && e.type == ErrorType.tamperedWallet) {
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
