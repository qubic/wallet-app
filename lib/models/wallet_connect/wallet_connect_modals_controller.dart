import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:qubic_wallet/components/wallet_connect/approve_sign_transaction.dart';
import 'package:qubic_wallet/components/wallet_connect/approve_token_transfer.dart';
import 'package:qubic_wallet/helpers/app_logger.dart';
import 'package:qubic_wallet/models/wallet_connect.dart';
import 'package:qubic_wallet/models/wallet_connect/request_send_transaction_result.dart';
import 'package:qubic_wallet/models/wallet_connect/request_sign_message_result.dart';
import 'package:qubic_wallet/models/wallet_connect/request_sign_transaction_result.dart';
import 'package:qubic_wallet/models/wallet_connect/request_send_qubic_result.dart';
import 'package:qubic_wallet/models/wallet_connect/request_send_qubic_event.dart';
import 'package:qubic_wallet/models/wallet_connect/request_send_transaction_event.dart';
import 'package:qubic_wallet/models/wallet_connect/request_sign_message_event.dart';
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
  Future<RequestSendQubicResult> handleSendQubic(
      RequestSendQubicEvent event, BuildContext context) async {
    await _autoIgnoreRequestsWhenModalIsOpen(event.topic, event.requestId);
    _wCDialogOpen = true;

    try {
      var result = await Navigator.of(context)
          .push(MaterialPageRoute<RequestSendQubicResult?>(
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
        throw Errors.getSdkError(Errors.USER_REJECTED);
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

  Future<RequestSendTransactionResult> handleSendTransaction(
      RequestSendTransactionEvent event, BuildContext context) async {
    await _autoIgnoreRequestsWhenModalIsOpen(event.topic, event.requestId);
    _wCDialogOpen = true;

    try {
      var result = await Navigator.of(context)
          .push(MaterialPageRoute<RequestSendTransactionResult>(
              builder: (BuildContext context) {
                return ApproveTokenTransfer(
                    pairingMetadata: event.pairingMetadata!,
                    fromID: event.fromID,
                    fromName: event.fromIDName,
                    amount: event.amount,
                    toID: event.toID,
                    inputType: event.inputType,
                    payload: event.payload);
              },
              fullscreenDialog: true));
      _wCDialogOpen = false;
      if (result == null) {
        throw Errors.getSdkError(Errors.USER_REJECTED);
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

  //Handles sign transaction
  Future<RequestSignTransactionResult> handleSignTransaction(
      RequestSignTransactionEvent event, BuildContext context) async {
    await _autoIgnoreRequestsWhenModalIsOpen(event.topic, event.requestId);
    _wCDialogOpen = true;

    appLogger.e(event.toString());
    try {
      var result = await Navigator.of(context)
          .push(MaterialPageRoute<RequestSignTransactionResult?>(
              builder: (BuildContext context) {
                return ApproveSignTransaction(
                    pairingMetadata: event.pairingMetadata!,
                    fromID: event.fromID,
                    fromName: event.fromIDName,
                    amount: event.amount,
                    tick: event.tick,
                    inputType: event.inputType,
                    payload: event.payload,
                    toID: event.toID);
              },
              fullscreenDialog: true));
      _wCDialogOpen = false;
      if (result == null) {
        throw Errors.getSdkError(Errors.USER_REJECTED);
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
  Future<RequestSignMessageResult> handleSign(
      RequestSignMessageEvent event, BuildContext context) async {
    await _autoIgnoreRequestsWhenModalIsOpen(event.topic, event.requestId);
    _wCDialogOpen = true;

    try {
      var result = await Navigator.of(context)
          .push(MaterialPageRoute<RequestSignMessageResult?>(
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
        throw Errors.getSdkError(Errors.USER_REJECTED);
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
