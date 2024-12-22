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
import 'package:qubic_wallet/models/wallet_connect/request_send_qubic_result.dart';
import 'package:qubic_wallet/models/wallet_connect/request_sign_transaction_result.dart';
import 'package:qubic_wallet/models/wallet_connect/wallet_connect_modals_controller.dart';
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

/// The result is one of the following:
/// 1- Navigator.of(context).pop() => User rejected
/// 2- Navigator.of(context).pop(RequestSignTransactionResult.success())
/// 3- Navigator.of(context).pop(RequestSignTransactionResult.error())
class ApproveSignTransaction extends StatefulWidget {
  final TransactionApprovalDataModel data;
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

  bool hasAccepted = false;
  String? toIdName;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();

    var item =
        appStore.currentQubicIDs.where((e) => e.publicId == widget.data.toID);
    if (item.isNotEmpty) {
      setState(() {
        toIdName = item.first.name;
      });
    }
  }

  void returnError<T extends RequestResult>(T requestResult) {
    Navigator.of(context).pop(requestResult);
    _globalSnackBar.showError(requestResult.errorMessage ?? "General Error");
  }

  onApproveSignTransaction() async {
    final navigator = Navigator.of(context);

    final l10n = l10nOf(context);
    bool authenticated = await reAuthDialog(context);
    if (!authenticated) {
      navigator.pop();
      return;
    }
    final targetTick = await wCModalsController.getTargetTick(widget.data.tick);
    SignedTransaction? result;
    if (!mounted) return;
    result = await getTransactionDialog(
        context,
        widget.data.fromID!,
        widget.data.toID,
        widget.data.amount,
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

  onApproveSendQubic() async {
    final navigator = Navigator.of(context);

    final l10n = l10nOf(context);
    bool authenticated = await reAuthDialog(context);
    if (!authenticated) {
      navigator.pop();
      return;
    }
    final targetTick = await wCModalsController.getTargetTick(widget.data.tick);
    SignedTransaction? result;
    if (!mounted) return;
    result = await sendTransactionDialog(
      context,
      widget.data.fromID!,
      widget.data.toID,
      widget.data.amount,
      targetTick,
    );
    if (result != null) {
      navigator.pop(RequestSendQubicResult.success(
          tick: targetTick, transactionId: result.tansactionId));
      _globalSnackBar.show(l10n.wcApprovedSignedTransaction);
    } else {
      returnError(RequestSendQubicResult.error(
          errorMessage: l10n.sendItemDialogErrorGeneralTitle));
    }
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
                    try {
                      setState(() {
                        isLoading = true;
                      });
                      switch (widget.method) {
                        case WalletConnectMethod.signTransaction:
                          onApproveSignTransaction();
                          break;
                        case WalletConnectMethod.sendQubic:
                          onApproveSendQubic();
                          break;
                        default:
                          break;
                      }
                    } catch (e) {
                      switch (widget.method) {
                        case WalletConnectMethod.signTransaction:
                          Navigator.of(context).pop(
                              RequestSignTransactionResult.error(
                                  errorMessage: e.toString()));
                          break;
                        case WalletConnectMethod.sendQubic:
                          Navigator.of(context).pop(
                              RequestSendQubicResult.error(
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
      case WalletConnectMethod.sendQubic:
        return l10n.wcApproveTransaction;
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
                    if (widget.method ==
                        WalletConnectMethod.signTransaction) ...[
                      Center(
                          child: Text("Sign the transfer of",
                              style: TextStyles.sliverHeader)),
                      ThemedControls.spacerVerticalNormal(),
                    ],
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      AmountValueHeader(
                          amount: widget.data.amount, suffix: "QUBIC"),
                    ]),
                    ThemedControls.spacerVerticalBig(),
                    Text(
                      l10n.generalLabelToFromAccount(
                          l10n.generalLabelFrom, widget.data.fromName ?? "-"),
                      style: TextStyles.lightGreyTextSmall,
                    ),
                    ThemedControls.spacerVerticalMini(),
                    Text(widget.data.fromID ?? "-",
                        style: TextStyles.textNormal),
                    ThemedControls.spacerVerticalSmall(),
                    toIdName != null
                        ? Text(
                            l10n.generalLabelToFromAccount(
                                l10n.generalLabelTo, toIdName!),
                            style: TextStyles.lightGreyTextSmall,
                          )
                        : Text(
                            l10n.generalLabelToFromAddress(l10n.generalLabelTo),
                            style: TextStyles.lightGreyTextSmall,
                          ),
                    ThemedControls.spacerVerticalMini(),
                    Text(widget.data.toID ?? "-", style: TextStyles.textNormal),
                    ThemedControls.spacerVerticalSmall(),
                    Text(
                      l10n.generalLabelTick,
                      style: TextStyles.lightGreyTextSmall,
                    ),
                    Text(widget.data.tick?.asThousands() ?? "-",
                        style: TextStyles.textNormal),
                    if (widget.data.inputType != null &&
                        widget.data.inputType != 0) ...[
                      ThemedControls.spacerVerticalSmall(),
                      Text(
                        l10n.generalLabelInputType,
                        style: TextStyles.lightGreyTextSmall,
                      ),
                      Text(widget.data.inputType!.toString(),
                          style: TextStyles.textNormal),
                    ],
                    if (widget.data.payload != null &&
                        widget.data.payload!.isNotEmpty) ...[
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
