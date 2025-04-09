// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qubic_wallet/components/wallet_connect/components/amount_value_header.dart';
import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/extensions/as_thousands.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/global_snack_bar.dart';
import 'package:qubic_wallet/helpers/re_auth_dialog.dart';
import 'package:qubic_wallet/helpers/send_transaction.dart';
import 'package:qubic_wallet/helpers/transaction_ui_helpers.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/models/signed_transaction.dart';
import 'package:qubic_wallet/models/wallet_connect/approval_data_model.dart';
import 'package:qubic_wallet/models/wallet_connect/request_result.dart';
import 'package:qubic_wallet/models/wallet_connect/request_send_transaction_result.dart';
import 'package:qubic_wallet/models/wallet_connect/request_sign_message_result.dart';
import 'package:qubic_wallet/models/wallet_connect/request_sign_transaction_result.dart';
import 'package:qubic_wallet/models/wallet_connect/wallet_connect_modals_controller.dart';
import 'package:qubic_wallet/resources/qubic_cmd.dart';
import 'package:qubic_wallet/services/wallet_connect_service.dart';
import 'package:qubic_wallet/smart_contracts/qx_info.dart';
import 'package:qubic_wallet/smart_contracts/sc_info.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/styles/app_icons.dart';
import 'package:qubic_wallet/styles/button_styles.dart';
import 'package:qubic_wallet/styles/edge_insets.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:url_launcher/url_launcher_string.dart';

part 'components/approval_buttons.dart';
part 'components/approval_card.dart';
part 'components/approval_header.dart';
part 'components/smart_contract_warning_card.dart';

enum WalletConnectMethod {
  signTransaction,
  signMessage,
  sendTransaction,
  sendQubic,
  sendAsset
}

/// The return from this widget is one of the following:
///
/// 1. Navigator.of(context).pop() => User rejected
/// 2. Navigator.of(context).pop(`RequestSignTransactionResult.success()`) => User approved with sucess
/// 3. Navigator.of(context).pop(`RequestSignTransactionResult.error()`) => User approved with error
///
/// Note that `RequestSignTransactionResult` is an example of any RequestResult child class
class ApproveWcMethodScreen extends StatefulWidget {
  final ApprovalDataModel data;
  final WalletConnectMethod method;
  const ApproveWcMethodScreen({
    super.key,
    required this.data,
    required this.method,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ApproveWcMethodScreenState createState() => _ApproveWcMethodScreenState();
}

class _ApproveWcMethodScreenState extends State<ApproveWcMethodScreen> {
  final WalletConnectService wcService = getIt<WalletConnectService>();
  final wCModalsController = WalletConnectModalsController();
  final _globalSnackBar = getIt.get<GlobalSnackBar>();
  final QubicCmd qubicCmd = getIt.get<QubicCmd>();
  final ApplicationStore appStore = getIt<ApplicationStore>();

  bool hasAccepted = false;
  bool isLoading = false;

  void returnError<T extends RequestResult>(T requestResult) {
    Navigator.of(context).pop(requestResult);
    _globalSnackBar.showError(requestResult.errorMessage ?? "General Error");
  }

  onApproveSignTransaction() async {
    final navigator = Navigator.of(context);
    final l10n = l10nOf(context);
    final targetTick = await wCModalsController.getTargetTick(widget.data.tick);
    SignedTransaction? result;
    if (!mounted) return;
    result = await getTransactionDialog(
        context,
        widget.data.fromID,
        widget.data.toID!,
        widget.data.amount!,
        targetTick,
        widget.data.inputType,
        widget.data.payload);
    if (result != null) {
      navigator.pop(RequestSignTransactionResult.success(
          tick: targetTick,
          signedTransaction: result.transactionKey,
          transactionId: result.transactionId));
      _globalSnackBar.show(l10n.wcApprovedSignedTransaction);
    } else {
      returnError(RequestSignTransactionResult.error(
          errorMessage: l10n.sendItemDialogErrorGeneralTitle));
    }
  }

  onApproveSendTransaction() async {
    final navigator = Navigator.of(context);
    final l10n = l10nOf(context);
    final targetTick = await wCModalsController.getTargetTick(widget.data.tick);
    SignedTransaction? result;
    if (!mounted) return;
    result = await sendTransactionDialog(
      context,
      widget.data.fromID,
      widget.data.toID!,
      widget.data.amount!,
      targetTick,
      inputType: widget.data.inputType,
      payload: widget.data.payload,
    );
    if (result != null) {
      navigator.pop(RequestSendTransactionResult.success(
          tick: targetTick, transactionId: result.transactionId));
      _globalSnackBar.show(l10n.wcApprovedSignedTransaction);
    } else {
      returnError(RequestSendTransactionResult.error(
          errorMessage: l10n.sendItemDialogErrorGeneralTitle));
    }
  }

  onApproveSignMessage() async {
    final navigator = Navigator.of(context);
    final l10n = l10nOf(context);
    final seed = await appStore.getSeedByPublicId(widget.data.fromID);
    final signedMessage = await qubicCmd.signUTF8(seed, widget.data.message!);
    navigator.pop(RequestSignMessageResult.success(result: signedMessage));
    _globalSnackBar.show(l10n.wcApprovedSignedMessage);
  }

  onApproveSendAsset() async {
    final navigator = Navigator.of(context);
    final l10n = l10nOf(context);
    final targetTick = await wCModalsController.getTargetTick(widget.data.tick);
    if (!mounted) return;
    final result = await sendAssetTransferTransactionDialog(
        context,
        widget.data.fromID,
        widget.data.toID!,
        widget.data.assetName!,
        widget.data.issuer!,
        widget.data.amount!,
        targetTick);
    if (result != null) {
      navigator.pop(RequestSignTransactionResult.success(
          signedTransaction: result.transactionKey,
          tick: targetTick,
          transactionId: result.transactionId));
      _globalSnackBar.show(l10n.wcApprovedSignedTransaction);
    } else {
      returnError(RequestSignTransactionResult.error(
          errorMessage: l10n.sendItemDialogErrorGeneralTitle));
    }
  }

  void redirectToDApp() {
    if (widget.data.redirectUrl != null) {
      Future.delayed(const Duration(milliseconds: 600), () {
        try {
          launchUrlString(widget.data.redirectUrl!);
        } catch (e) {
          _globalSnackBar.showError(e.toString());
        }
      });
    }
  }

  onApprovalTap() async {
    final navigator = Navigator.of(context);
    try {
      setState(() {
        isLoading = true;
      });
      bool authenticated = await reAuthDialog(context);
      if (!authenticated) {
        navigator.pop();
        return;
      }
      switch (widget.method) {
        case WalletConnectMethod.signTransaction:
          await onApproveSignTransaction();
          break;
        case WalletConnectMethod.sendQubic ||
              WalletConnectMethod.sendTransaction:
          await onApproveSendTransaction();
        case WalletConnectMethod.signMessage:
          await onApproveSignMessage();
          break;
        case WalletConnectMethod.sendAsset:
          await onApproveSendAsset();
          break;
      }
    } catch (e) {
      switch (widget.method) {
        case WalletConnectMethod.signTransaction:
          navigator.pop(
              RequestSignTransactionResult.error(errorMessage: e.toString()));
          break;
        case WalletConnectMethod.sendQubic ||
              WalletConnectMethod.sendTransaction:
          navigator.pop(
              RequestSendTransactionResult.error(errorMessage: e.toString()));
        case WalletConnectMethod.signMessage:
          navigator
              .pop(RequestSignMessageResult.error(errorMessage: e.toString()));
          break;
        case WalletConnectMethod.sendAsset:
          navigator.pop(
              RequestSignTransactionResult.error(errorMessage: e.toString()));
          break;
      }
    } finally {
      setState(() {
        isLoading = false;
      });
      redirectToDApp();
    }
  }

  Widget getBody() {
    final l10n = l10nOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _ApprovalHeader(data: widget.data),
        ThemedControls.spacerVerticalSmall(),
        if (widget.data.inputType != null &&
            widget.data.inputType! > 0 &&
            widget.data.toID != null &&
            QubicSCStore.isSC(widget.data.toID!)) ...[
          _SmartContractWarningCard(
              QubicSCStore.fromContractId(widget.data.toID!) ??
                  l10n.wcSmartContractUnknown),
          ThemedControls.spacerVerticalBig(),
        ],
        _ApprovalCard(data: widget.data, method: widget.method)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isLoading,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
        ),
        body: SafeArea(
          minimum: ThemeEdgeInsets.pageInsets
              .copyWith(bottom: ThemePaddings.normalPadding),
          child: LayoutBuilder(builder:
              (BuildContext context, BoxConstraints viewportConstraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: viewportConstraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      Expanded(child: getBody()),
                      ThemedControls.spacerVerticalNormal(),
                      _ApprovalButtons(
                        isLoading: isLoading,
                        method: widget.method,
                        onApprovalTap: onApprovalTap,
                        redirectToDApp: redirectToDApp,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
