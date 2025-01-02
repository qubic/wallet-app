// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:qubic_wallet/components/wallet_connect/amount_value_header.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/extensions/asThousands.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/global_snack_bar.dart';
import 'package:qubic_wallet/helpers/re_auth_dialog.dart';
import 'package:qubic_wallet/helpers/sendTransaction.dart';
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
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/styles/button_styles.dart';
import 'package:qubic_wallet/styles/edge_insets.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

enum WalletConnectMethod {
  signTransaction,
  signMessage,
  sendTransaction,
  sendQubic
}

/// The return from this widget is one of the following:
///
/// 1. Navigator.of(context).pop() => User rejected
/// 2. Navigator.of(context).pop(`RequestSignTransactionResult.success()`) => User approved with sucess
/// 3. Navigator.of(context).pop(`RequestSignTransactionResult.error()`) => User approved with error
///
/// Note that `RequestSignTransactionResult` is an example of any RequestResult child class
class ApproveSignTransaction extends StatefulWidget {
  final ApprovalDataModel data;
  final WalletConnectMethod method;
  const ApproveSignTransaction({
    super.key,
    required this.data,
    required this.method,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ApproveSignTransactionState createState() => _ApproveSignTransactionState();
}

class _ApproveSignTransactionState extends State<ApproveSignTransaction> {
  final ApplicationStore appStore = getIt<ApplicationStore>();
  final WalletConnectService wcService = getIt<WalletConnectService>();
  final wCModalsController = WalletConnectModalsController();
  final _globalSnackBar = getIt.get<GlobalSnackBar>();
  final QubicCmd qubicCmd = getIt.get<QubicCmd>();

  bool hasAccepted = false;
  String? toIdName;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();

    var item = appStore.findById(widget.data.toID);
    setState(() {
      toIdName = item?.name;
    });
  }

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
          transactionId: result.tansactionId));
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
    );
    if (result != null) {
      navigator.pop(RequestSendTransactionResult.success(
          tick: targetTick, transactionId: result.tansactionId));
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

  @override
  void dispose() {
    super.dispose();
  }

  List<Widget> getButtons() {
    final l10n = l10nOf(context);

    return [
      SizedBox(
        width: double.infinity,
        height: ButtonStyles.buttonHeight,
        child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: LightThemeColors.primary40,
            ),
            onPressed: isLoading
                ? null
                : () async {
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
                          onApproveSignTransaction();
                          break;
                        case WalletConnectMethod.sendQubic ||
                              WalletConnectMethod.sendTransaction:
                          onApproveSendTransaction();
                        case WalletConnectMethod.signMessage:
                          onApproveSignMessage();
                          break;
                        default:
                          break;
                      }
                    } catch (e) {
                      switch (widget.method) {
                        case WalletConnectMethod.signTransaction:
                          navigator.pop(RequestSignTransactionResult.error(
                              errorMessage: e.toString()));
                          break;
                        case WalletConnectMethod.sendQubic ||
                              WalletConnectMethod.sendTransaction:
                          navigator.pop(RequestSendTransactionResult.error(
                              errorMessage: e.toString()));
                        case WalletConnectMethod.signMessage:
                          navigator.pop(RequestSignMessageResult.error(
                              errorMessage: e.toString()));
                          break;
                        default:
                          break;
                      }
                    } finally {
                      setState(() {
                        isLoading = false;
                      });
                    }
                  },
            child: isLoading
                ? SizedBox(
                    height: 23,
                    width: 23,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: LightThemeColors.grey90),
                  )
                : Text(getTitleOfButton(),
                    textAlign: TextAlign.center,
                    style: TextStyles.primaryButtonText)),
      ),
      ThemedControls.spacerVerticalSmall(),
      SizedBox(
          width: double.infinity,
          height: ButtonStyles.buttonHeight,
          child: ThemedControls.dangerButtonBigWithClild(
              child: Padding(
                  padding: const EdgeInsets.all(ThemePaddings.smallPadding),
                  child: Text(l10n.generalButtonReject,
                      style: TextStyles.destructiveButtonText)),
              onPressed: () {
                Navigator.of(context).pop();
              })),
    ];
  }

  getTitleOfButton() {
    final l10n = l10nOf(context);
    switch (widget.method) {
      case WalletConnectMethod.signTransaction:
        return l10n.wcSignTransaction;
      case WalletConnectMethod.sendQubic || WalletConnectMethod.sendTransaction:
        return l10n.wcApproveTransaction;
      case WalletConnectMethod.signMessage:
        return l10n.wcSignMessage;
      default:
        return l10n.generalButtonApprove;
    }
  }

  Widget getScrollView() {
    final l10n = l10nOf(context);
    return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Row(children: [
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //---------- Header title url and image
              SizedBox(
                height: 80,
                width: 80,
                child: widget.data.pairingMetadata != null &&
                        widget.data.pairingMetadata!.icons.isNotEmpty
                    ? FadeInImage(
                        image:
                            NetworkImage(widget.data.pairingMetadata!.icons[0]),
                        placeholder: AssetImage(
                          'assets/images/dapp-default.png',
                        ),
                        imageErrorBuilder: (context, error, stackTrace) =>
                            Image.asset('assets/images/dapp-default.png'),
                        fit: BoxFit.contain,
                      )
                    : Image.asset('assets/images/dapp-default.png'),
              ),
              //dAPP title
              ThemedControls.spacerVerticalBig(),
              Text(
                  widget.data.pairingMetadata == null ||
                          widget.data.pairingMetadata?.name == null ||
                          widget.data.pairingMetadata!.name.isEmpty
                      ? l10n.wcUnknownDapp
                      : widget.data.pairingMetadata!.name,
                  style: TextStyles.walletConnectDappTitle),
              ThemedControls.spacerVerticalSmall(),
              Text(
                  widget.data.pairingMetadata == null ||
                          widget.data.pairingMetadata?.url == null ||
                          widget.data.pairingMetadata!.url.isEmpty
                      ? l10n.wcUnknownDapp
                      : widget.data.pairingMetadata!.url,
                  style: TextStyles.walletConnectDappUrl),

              //--------- End of header
              ThemedControls.spacerVerticalBig(),
              ThemedControls.card(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    if (widget.method == WalletConnectMethod.signTransaction ||
                        widget.method == WalletConnectMethod.signMessage) ...[
                      Center(
                          child: Text(
                              widget.method ==
                                      WalletConnectMethod.signTransaction
                                  ? l10n.wcApproveSignTransferOf
                                  : l10n.wcApproveSignOf,
                              style: TextStyles.sliverHeader)),
                      ThemedControls.spacerVerticalNormal(),
                    ],
                    if (widget.data.message != null) ...[
                      Center(
                        child: Text(
                            widget.data.message!.replaceAll(r'\n', '\n'),
                            textAlign: TextAlign.center,
                            style: TextStyles.textNormal),
                      ),
                      ThemedControls.spacerVerticalBig(),
                    ],
                    if (widget.data.amount != null) ...[
                      Center(
                          child: AmountValueHeader(
                              amount: widget.data.amount!, suffix: "QUBIC")),
                      ThemedControls.spacerVerticalBig(),
                    ],
                    Text(
                      l10n.generalLabelToFromAccount(
                          l10n.generalLabelFrom, widget.data.fromName ?? "-"),
                      style: TextStyles.lightGreyTextSmall,
                    ),
                    ThemedControls.spacerVerticalMini(),
                    Text(widget.data.fromID, style: TextStyles.textNormal),
                    if (widget.data.toID != null) ...[
                      ThemedControls.spacerVerticalSmall(),
                      toIdName != null
                          ? Text(
                              l10n.generalLabelToFromAccount(
                                  l10n.generalLabelTo, toIdName!),
                              style: TextStyles.lightGreyTextSmall,
                            )
                          : Text(
                              l10n.generalLabelToFromAddress(
                                  l10n.generalLabelTo),
                              style: TextStyles.lightGreyTextSmall,
                            ),
                      ThemedControls.spacerVerticalMini(),
                      Text(widget.data.toID ?? "-",
                          style: TextStyles.textNormal),
                    ],
                    if (widget.data.tick != null) ...[
                      ThemedControls.spacerVerticalSmall(),
                      Text(
                        l10n.generalLabelTick,
                        style: TextStyles.lightGreyTextSmall,
                      ),
                      Text(widget.data.tick?.asThousands() ?? "-",
                          style: TextStyles.textNormal),
                    ],
                    if (widget.data.inputType != null) ...[
                      ThemedControls.spacerVerticalSmall(),
                      Text(
                        l10n.generalLabelInputType,
                        style: TextStyles.lightGreyTextSmall,
                      ),
                      Text(widget.data.inputType!.toString(),
                          style: TextStyles.textNormal),
                    ],
                    if (widget.data.payload != null) ...[
                      ThemedControls.spacerVerticalSmall(),
                      Text(
                        l10n.generalLabelPayload,
                        style: TextStyles.lightGreyTextSmall,
                      ),
                      Text(widget.data.payload!, style: TextStyles.textNormal)
                    ]
                  ]))
            ],
          ))
        ]));
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
                child: Column(children: [
                  Expanded(child: getScrollView()),
                  ...getButtons()
                ]))));
  }
}
