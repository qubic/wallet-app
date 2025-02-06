import 'package:flutter/material.dart';
import 'package:qubic_wallet/components/wallet_connect/approve_wc_method_screen.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/helpers/global_snack_bar.dart';
import 'package:qubic_wallet/helpers/target_tick.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/models/wallet_connect.dart';
import 'package:qubic_wallet/models/wallet_connect/approval_data_model.dart';
import 'package:qubic_wallet/models/wallet_connect/request_result.dart';
import 'package:qubic_wallet/models/wallet_connect/request_send_assets_event.dart';
import 'package:qubic_wallet/models/wallet_connect/request_send_transaction_result.dart';
import 'package:qubic_wallet/models/wallet_connect/request_sign_message_event.dart';
import 'package:qubic_wallet/models/wallet_connect/request_sign_message_result.dart';
import 'package:qubic_wallet/models/wallet_connect/request_handle_transaction_event.dart';
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
          code: WcErrors.qwUserUnavailable, message: "User is unavailable");
    }
  }

  //Handles send transaction and send Qubic
  Future<RequestSendTransactionResult> handleSendTransaction(
      RequestHandleTransactionEvent event, BuildContext context) async {
    final navigator = Navigator.of(context);
    await _autoIgnoreRequestsWhenModalIsOpen(event.topic, event.requestId);
    _wCDialogOpen = true;
    var result =
        await navigator.push(MaterialPageRoute<RequestSendTransactionResult?>(
            builder: (BuildContext context) {
              return ApproveWcMethodScreen(
                method: (event.inputType == null || event.inputType == 0)
                    ? WalletConnectMethod.sendQubic
                    : WalletConnectMethod.sendTransaction,
                data: ApprovalDataModel(
                  pairingMetadata: event.pairingMetadata,
                  redirectUrl: event.redirectUrl,
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
      RequestHandleTransactionEvent event, BuildContext context) async {
    final navigator = Navigator.of(context);
    await _autoIgnoreRequestsWhenModalIsOpen(event.topic, event.requestId);
    _wCDialogOpen = true;
    var result =
        await navigator.push(MaterialPageRoute<RequestSignTransactionResult?>(
            builder: (BuildContext context) {
              return ApproveWcMethodScreen(
                method: WalletConnectMethod.signTransaction,
                data: ApprovalDataModel(
                  pairingMetadata: event.pairingMetadata,
                  redirectUrl: event.redirectUrl,
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

  //Handles sign message
  Future<RequestSignMessageResult> handleSign(
      RequestSignMessageEvent event, BuildContext context) async {
    final navigator = Navigator.of(context);
    await _autoIgnoreRequestsWhenModalIsOpen(event.topic, event.requestId);
    _wCDialogOpen = true;
    var result =
        await navigator.push(MaterialPageRoute<RequestSignMessageResult?>(
            builder: (BuildContext context) {
              return ApproveWcMethodScreen(
                method: WalletConnectMethod.signMessage,
                data: ApprovalDataModel(
                  pairingMetadata: event.pairingMetadata,
                  redirectUrl: event.redirectUrl,
                  fromID: event.fromID,
                  fromName: event.fromIDName,
                  message: event.message,
                ),
              );
            },
            fullscreenDialog: true));
    _wCDialogOpen = false;
    return handleReturningResult(result);
  }

  //Handles send assets
  Future<RequestSignTransactionResult> handleSendAssets(
      RequestSendAssetEvent event, BuildContext context) async {
    final navigator = Navigator.of(context);
    await _autoIgnoreRequestsWhenModalIsOpen(event.topic, event.requestId);
    _wCDialogOpen = true;
    var result =
        await navigator.push(MaterialPageRoute<RequestSignTransactionResult?>(
            builder: (BuildContext context) {
              return ApproveWcMethodScreen(
                method: WalletConnectMethod.sendAsset,
                data: ApprovalDataModel(
                  pairingMetadata: event.pairingMetadata,
                  redirectUrl: event.redirectUrl,
                  fromID: event.from,
                  fromName: event.fromIDName,
                  amount: event.amount,
                  assetName: event.assetName,
                  toID: event.to,
                  issuer: event.issuer,
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
    int latestTick = (await _liveApi.getCurrentTick()).tick;
    if (tick != null) {
      if (tick < latestTick) {
        getIt
            .get<GlobalSnackBar>()
            .showError(l10nWrapper.l10n!.wcErrorTickExpired);
        throw const JsonRpcError(
            code: WcErrors.qwTickBecameInPast,
            message: "Tick value is Expired");
      }
      return tick;
    } else {
      return latestTick + defaultTargetTickType.value;
    }
  }
}
