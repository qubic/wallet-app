import 'package:flutter/material.dart';
import 'package:qubic_wallet/components/wallet_connect/approve_sign_transaction.dart';
import 'package:qubic_wallet/components/wallet_connect/approve_token_transfer.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/helpers/global_snack_bar.dart';
import 'package:qubic_wallet/helpers/target_tick.dart';
import 'package:qubic_wallet/models/wallet_connect.dart';
import 'package:qubic_wallet/models/wallet_connect/approval_data_model.dart';
import 'package:qubic_wallet/models/wallet_connect/request_send_qubic_event.dart';
import 'package:qubic_wallet/models/wallet_connect/request_send_qubic_result.dart';
import 'package:qubic_wallet/models/wallet_connect/request_send_transaction_event.dart';
import 'package:qubic_wallet/models/wallet_connect/request_send_transaction_result.dart';
import 'package:qubic_wallet/models/wallet_connect/request_sign_message_event.dart';
import 'package:qubic_wallet/models/wallet_connect/request_sign_message_result.dart';
import 'package:qubic_wallet/models/wallet_connect/request_sign_transaction_event.dart';
import 'package:qubic_wallet/models/wallet_connect/request_sign_transaction_result.dart';
import 'package:qubic_wallet/resources/apis/live/qubic_live_api.dart';
import 'package:reown_walletkit/reown_walletkit.dart';

import '../../components/wallet_connect/approve_sign.dart';

// Provides a unified place to handle WalletConnect modals
class WalletConnectModalsController {
  bool _wCDialogOpen = false;
  final _liveApi = getIt.get<QubicLiveApi>();
  final _globalSnackBar = getIt.get<GlobalSnackBar>();

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
    final navigator = Navigator.of(context);
    await _autoIgnoreRequestsWhenModalIsOpen(event.topic, event.requestId);
    _wCDialogOpen = true;
    var result =
        await navigator.push(MaterialPageRoute<RequestSignTransactionResult?>(
            builder: (BuildContext context) {
              return ApproveSignTransaction(
                method: WalletConnectMethod.signTransaction,
                data: TransactionApprovalDataModel(
                  pairingMetadata: event.pairingMetadata,
                  fromID: event.fromID,
                  fromName: event.fromIDName,
                  amount: event.amount,
                  toID: event.toID,
                  inputType: event.inputType,
                  payload: event.payload,
                  tick: event.tick,
                ),
              );
            },
            fullscreenDialog: true));
    _wCDialogOpen = false;
    return handleReturningResult(result);
  }

  RequestSignTransactionResult handleReturningResult(
      RequestSignTransactionResult? result) {
    if (result == null) {
      throw JsonRpcError(
        code: Errors.SDK_ERRORS[Errors.USER_REJECTED]!['code'] as int,
        message:
            Errors.SDK_ERRORS[Errors.USER_REJECTED]!['message']!.toString(),
      );
    }

    if (result.hasError) {
      throw JsonRpcError(
        code: result.errorCode ?? -1,
        message: result.errorMessage ?? "An error has occurred",
      );
    }

    return result;
  }

  Future<int> getTargetTick(int? tick) async {
    if (tick != null) {
      return tick;
    } else {
      int latestTick = (await _liveApi.getCurrentTick()).tick;
      return latestTick + defaultTargetTickType.value;
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
