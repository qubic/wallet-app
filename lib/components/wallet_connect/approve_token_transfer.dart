// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:qubic_wallet/components/wallet_connect/amount_value_header.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/app_logger.dart';
import 'package:qubic_wallet/helpers/global_snack_bar.dart';
import 'package:qubic_wallet/helpers/re_auth_dialog.dart';
import 'package:qubic_wallet/helpers/sendTransaction.dart';
import 'package:qubic_wallet/helpers/target_tick.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/models/signed_transaction.dart';
import 'package:qubic_wallet/models/wallet_connect/approve_send_transaction_result.dart';
import 'package:qubic_wallet/models/wallet_connect/approve_token_transfer_result.dart';
import 'package:qubic_wallet/resources/apis/live/qubic_live_api.dart';
import 'package:qubic_wallet/resources/qubic_li.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/styles/button_styles.dart';
import 'package:qubic_wallet/styles/edge_insets.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:reown_walletkit/reown_walletkit.dart';

class ApproveTokenTransfer extends StatefulWidget {
  final PairingMetadata? pairingMetadata;
  final String? fromID;
  final String? fromName;
  final int amount;
  final String? toID;
  final int? inputType;
  final String? payload;

  const ApproveTokenTransfer({
    super.key,
    required this.pairingMetadata,
    required this.fromID,
    required this.fromName,
    required this.amount,
    required this.toID,

    /// Optional parameters for send transaction
    this.inputType,
    this.payload,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ApproveTokenTransferState createState() => _ApproveTokenTransferState();
}

class _ApproveTokenTransferState extends State<ApproveTokenTransfer> {
  final ApplicationStore appStore = getIt<ApplicationStore>();
  final QubicLi _apiService = getIt<QubicLi>();
  final _liveApi = getIt<QubicLiveApi>();

  bool hasAccepted = false;
  String? toIdName;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();

    var item = appStore.currentQubicIDs.where((e) => e.publicId == widget.toID);
    if (item.isNotEmpty) {
      setState(() {
        toIdName = item.first.name;
      });
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
                    //Authenticate the user
                    if (mounted) {
                      bool authenticated = await reAuthDialog(context);
                      if (!authenticated) {
                        if (mounted) {
                          Navigator.pop(context);
                        }
                        return;
                      }
                    }
                    setState(() {
                      isLoading = true;
                    });
                    try {
                      //Get current tick
                      int latestTick = (await _liveApi.getCurrentTick()).tick;
                      int targetTick = latestTick + defaultTargetTickType.value;

                      //Send the transaction to backend
                      SignedTransaction? result;
                      if (mounted) {
                        result = await sendTransactionDialog(
                            context,
                            widget.fromID!,
                            widget.toID!,
                            widget.amount,
                            targetTick,
                            inputType: widget.inputType,
                            payload: widget.payload);

                        if (result == null) {
                          throw "Could not send transaction";
                        }
                        setState(() {
                          isLoading = true;
                        });
                        //If the transaction was successful

                        if (mounted) {
                          if (widget.inputType != null) {
                            Navigator.of(context).pop(
                                ApproveSendTransactionResult(
                                    transactionId: result.tansactionId));
                          } else {
                            Navigator.of(context).pop(
                                ApproveTokenTransferResult(
                                    tick: targetTick,
                                    transactionId: result.tansactionId));
                          }

                          getIt.get<PersistentTabController>().jumpToTab(1);
                          getIt<GlobalSnackBar>().show(
                              l10nOf(context) //Show snackbar
                                  .generalSnackBarMessageTransactionSubmitted(
                                      targetTick.toString()));
                        }
                      }
                    } catch (e) {
                      appLogger.d(e.toString());
                      setState(() {
                        isLoading = false;
                      });

                      if (mounted) {
                        Navigator.of(context).pop(ApproveTokenTransferResult(
                            errorMessage: e.toString(),
                            tick: null,
                            transactionId: null));
                        getIt<GlobalSnackBar>()
                            .showError(l10nOf(context) //Show snackbar
                                .sendItemDialogErrorGeneralTitle);
                      }
                    }
                  },
            child: isLoading
                ? SizedBox(
                    height: 23,
                    width: 23,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: LightThemeColors.grey90),
                  )
                : Text(l10n.wcApproveTransaction,
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
                child: widget.pairingMetadata != null &&
                        widget.pairingMetadata!.icons.isNotEmpty
                    ? FadeInImage(
                        image: NetworkImage(widget.pairingMetadata!.icons[0]),
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
                  widget.pairingMetadata == null ||
                          widget.pairingMetadata?.name == null ||
                          widget.pairingMetadata!.name.isEmpty
                      ? l10n.wcUnknownDapp
                      : widget.pairingMetadata!.name,
                  style: TextStyles.walletConnectDappTitle),
              ThemedControls.spacerVerticalSmall(),
              Text(
                  widget.pairingMetadata == null ||
                          widget.pairingMetadata?.url == null ||
                          widget.pairingMetadata!.url.isEmpty
                      ? l10n.wcUnknownDapp
                      : widget.pairingMetadata!.url,
                  style: TextStyles.walletConnectDappUrl),

              //--------- End of header
              ThemedControls.spacerVerticalBig(),
              ThemedControls.card(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      AmountValueHeader(amount: widget.amount, suffix: "QUBIC"),
                    ]),
                    ThemedControls.spacerVerticalBig(),
                    Text(
                      l10n.generalLabelToFromAccount(
                          l10n.generalLabelFrom, widget.fromName ?? "-"),
                      style: TextStyles.lightGreyTextSmall,
                    ),
                    ThemedControls.spacerVerticalMini(),
                    Text(widget.fromID!, style: TextStyles.textNormal),
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
                    Text(widget.toID!, style: TextStyles.textNormal),
                    if (widget.inputType != null) ...[
                      ThemedControls.spacerVerticalSmall(),
                      Text(
                        l10n.generalLabelInputType,
                        style: TextStyles.lightGreyTextSmall,
                      ),
                      Text(widget.inputType!.toString(),
                          style: TextStyles.textNormal),
                    ],
                    if (widget.payload != null &&
                        widget.payload!.isNotEmpty) ...[
                      ThemedControls.spacerVerticalSmall(),
                      Text(
                        l10n.generalLabelPayload,
                        style: TextStyles.lightGreyTextSmall,
                      ),
                      Text(widget.payload!, style: TextStyles.textNormal)
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
