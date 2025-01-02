import 'package:flutter/material.dart';
import 'package:qubic_wallet/components/wallet_connect/approve_sign_transaction.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/helpers/target_tick.dart';
import 'package:qubic_wallet/models/wallet_connect.dart';
import 'package:qubic_wallet/models/wallet_connect/approval_data_model.dart';
import 'package:qubic_wallet/models/wallet_connect/request_result.dart';
import 'package:qubic_wallet/models/wallet_connect/request_send_transaction_event.dart';
import 'package:qubic_wallet/models/wallet_connect/request_send_transaction_result.dart';
import 'package:qubic_wallet/models/wallet_connect/request_sign_message_event.dart';
import 'package:qubic_wallet/models/wallet_connect/request_sign_message_result.dart';
import 'package:qubic_wallet/models/wallet_connect/request_sign_transaction_event.dart';
import 'package:qubic_wallet/models/wallet_connect/request_sign_transaction_result.dart';
import 'package:qubic_wallet/resources/apis/live/qubic_live_api.dart';
import 'package:reown_walletkit/reown_walletkit.dart';

// Provides a unified place to handle WalletConnect modals
class WalletConnectModalsController {
  bool _wCDialogOpen = false;
  final _liveApi = getIt.get<QubicLiveApi>();

  //If a WC modal is open, ignore the request
  _autoIgnoreRequestsWhenModalIsOpen(String topic, int requestId) async {
    if (_wCDialogOpen) {
      throw const JsonRpcError(
          code: WcErrors.qwUserUnavailable, message: "user unavailable ~");
    }
  }

  //Handles send transaction and send Qubic
  Future<RequestSendTransactionResult> handleSendTransaction(
      RequestSendTransactionEvent event, BuildContext context) async {
    final navigator = Navigator.of(context);
    await _autoIgnoreRequestsWhenModalIsOpen(event.topic, event.requestId);
    _wCDialogOpen = true;
    var result =
        await navigator.push(MaterialPageRoute<RequestSendTransactionResult?>(
            builder: (BuildContext context) {
              return ApproveSignTransaction(
                method: WalletConnectMethod.sendQubic,
                data: ApprovalDataModel(
                  pairingMetadata: event.pairingMetadata,
                  fromID: event.fromID,
                  fromName: event.fromIDName,
                  amount: event.amount,
                  toID: event.toID,
                  tick: event.tick,
                  inputType: event.inputType,
                  payload: event.payload,
                ),
              );
            },
            fullscreenDialog: true));
    _wCDialogOpen = false;
    return handleReturningResult(result);
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
                data: ApprovalDataModel(
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

  /// Takes T a child class from RequestResult and returns it if it has no error or
  /// throws a JsonRpcError if it has an error
  T handleReturningResult<T extends RequestResult>(T? result) {
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

  //Handles sign message
  Future<RequestSignMessageResult> handleSign(
      RequestSignMessageEvent event, BuildContext context) async {
    final navigator = Navigator.of(context);
    await _autoIgnoreRequestsWhenModalIsOpen(event.topic, event.requestId);
    _wCDialogOpen = true;
    var result =
        await navigator.push(MaterialPageRoute<RequestSignMessageResult?>(
            builder: (BuildContext context) {
              return ApproveSignTransaction(
                method: WalletConnectMethod.signMessage,
                data: ApprovalDataModel(
                  pairingMetadata: event.pairingMetadata,
                  fromID: event.fromID,
                  fromName: event.fromIDName,
                  message: event.message,
                ),
              );
            },
            fullscreenDialog: true));
    _wCDialogOpen = false;
    return handleReturningResult(result);

    // await _autoIgnoreRequestsWhenModalIsOpen(event.topic, event.requestId);
    // _wCDialogOpen = true;

    // try {
    //   var result = await Navigator.of(context)
    //       .push(MaterialPageRoute<RequestSignMessageResult?>(
    //           builder: (BuildContext context) {
    //             return ApproveSign(
    //               pairingMetadata: event.pairingMetadata!,
    //               fromID: event.fromID,
    //               fromName: event.fromIDName,
    //               message: event.message,
    //             );
    //           },
    //           fullscreenDialog: true));
    //   _wCDialogOpen = false;
    //   if (result == null) {
    //     throw Errors.getSdkError(Errors.USER_REJECTED);
    //   } else {
    //     if ((result.errorCode == null) && (result.errorMessage == null)) {
    //       return result;
    //     } else {
    //       throw JsonRpcError(
    //           code: result.errorCode ?? -1,
    //           message: result.errorMessage ?? "An error has occurred");
    //     }
    //   }
    // } catch (e) {
    //   _wCDialogOpen = false;
    //   rethrow;
    // }
  }
}
