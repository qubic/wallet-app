import 'package:flutter/material.dart';
import 'package:qubic_wallet/components/wallet_connect/approve_sign_transaction.dart';
import 'package:qubic_wallet/components/wallet_connect/approve_token_transfer.dart';

import 'package:qubic_wallet/models/wallet_connect.dart';
import 'package:qubic_wallet/models/wallet_connect/approve_sign_generic_result.dart';
import 'package:qubic_wallet/models/wallet_connect/approve_sign_transaction_result.dart';
import 'package:qubic_wallet/models/wallet_connect/approve_token_transfer_result.dart';
import 'package:qubic_wallet/models/wallet_connect/request_send_qubic_event.dart';
import 'package:qubic_wallet/models/wallet_connect/request_sign_generic_event.dart';
import 'package:qubic_wallet/models/wallet_connect/request_sign_transaction_event.dart';

import 'package:reown_walletkit/reown_walletkit.dart';

import '../../components/wallet_connect/approve_sign.dart';

// Provides a unified place to handle WalletConnect modals
class WalletConnectModalsController {
  bool _wCDialogOpen = false;

  //If a WC modal is open, ignore the request
  _autoIgnoreRequestsWhenModalIsOpen(String topic, int requestId) async {
    if (_wCDialogOpen) {
      throw const JsonRpcError(
          code: WcErrors.qwUserUnavailable, message: "user unavailable ~");
    }
  }

  //Handles sending Qubic
  Future<ApproveTokenTransferResult> handleSendQubic(
      RequestSendQubicEvent event, BuildContext context) async {
    await _autoIgnoreRequestsWhenModalIsOpen(event.topic, event.requestId);
    _wCDialogOpen = true;

    try {
      var result = await Navigator.of(context)
          .push(MaterialPageRoute<ApproveTokenTransferResult?>(
              builder: (BuildContext context) {
                return ApproveTokenTransfer(
                    pairingMetadata: event.pairingMetadata!,
                    fromID: event.fromID,
                    fromName: event.fromIDName,
                    amount: event.amount,
                    toID: event.toID);
              },
              fullscreenDialog: true));
      _wCDialogOpen = false;
      if (result == null) {
        var err = Errors.getSdkError(Errors.USER_REJECTED);
        throw JsonRpcError(code: err.code, message: err.message);
      } else {
        if ((result.errorCode == null) && (result.errorMessage == null)) {
          return result;
        } else {
          throw JsonRpcError(
              code: result.errorCode ?? -1,
              message: result.errorMessage ?? "An error has occurred");
        }
      }
    } catch (e) {
      _wCDialogOpen = false;
      rethrow;
    }
  }

  //Handles sending Qubic
  Future<ApproveSignTransactionResult> handleSignTransaction(
      RequestSignTransactionEvent event, BuildContext context) async {
    await _autoIgnoreRequestsWhenModalIsOpen(event.topic, event.requestId);
    _wCDialogOpen = true;

    try {
      var result = await Navigator.of(context)
          .push(MaterialPageRoute<ApproveSignTransactionResult?>(
              builder: (BuildContext context) {
                return ApproveSignTransaction(
                    pairingMetadata: event.pairingMetadata!,
                    fromID: event.fromID,
                    fromName: event.fromIDName,
                    amount: event.amount,
                    tick: event.tick,
                    toID: event.toID);
              },
              fullscreenDialog: true));
      _wCDialogOpen = false;
      if (result == null) {
        var err = Errors.getSdkError(Errors.USER_REJECTED);
        throw JsonRpcError(code: err.code, message: err.message);
      } else {
        if ((result.errorCode == null) && (result.errorMessage == null)) {
          return result;
        } else {
          throw JsonRpcError(
              code: result.errorCode ?? -1,
              message: result.errorMessage ?? "An error has occurred");
        }
      }
    } catch (e) {
      _wCDialogOpen = false;
      rethrow;
    }
  }

  //Handles sending Qubic
  Future<ApproveSignGenericResult> handleSign(
      RequestSignGenericEvent event, BuildContext context) async {
    await _autoIgnoreRequestsWhenModalIsOpen(event.topic, event.requestId);
    _wCDialogOpen = true;

    try {
      var result = await Navigator.of(context)
          .push(MaterialPageRoute<ApproveSignGenericResult?>(
              builder: (BuildContext context) {
                return ApproveSign(
                  pairingMetadata: event.pairingMetadata!,
                  fromID: event.fromID,
                  fromName: event.fromIDName,
                  message: event.message,
                );
              },
              fullscreenDialog: true));
      _wCDialogOpen = false;
      if (result == null) {
        var err = Errors.getSdkError(Errors.USER_REJECTED);
        throw JsonRpcError(code: err.code, message: err.message);
      } else {
        if ((result.errorCode == null) && (result.errorMessage == null)) {
          return result;
        } else {
          throw JsonRpcError(
              code: result.errorCode ?? -1,
              message: result.errorMessage ?? "An error has occurred");
        }
      }
    } catch (e) {
      _wCDialogOpen = false;
      rethrow;
    }
  }
}
