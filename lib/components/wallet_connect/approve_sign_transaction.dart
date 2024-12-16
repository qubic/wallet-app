// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:qubic_wallet/components/wallet_connect/amount_value_header.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/extensions/asThousands.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/global_snack_bar.dart';
import 'package:qubic_wallet/helpers/re_auth_dialog.dart';
import 'package:qubic_wallet/helpers/sendTransaction.dart';
import 'package:qubic_wallet/helpers/target_tick.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/models/wallet_connect/approve_sign_transaction_result.dart';
import 'package:qubic_wallet/resources/apis/live/qubic_live_api.dart';
import 'package:qubic_wallet/resources/qubic_li.dart';
import 'package:qubic_wallet/services/wallet_connect_service.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/styles/button_styles.dart';
import 'package:qubic_wallet/styles/edge_insets.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:reown_walletkit/reown_walletkit.dart';

class ApproveSignTransaction extends StatefulWidget {
  final PairingMetadata? pairingMetadata;
  final String? fromID;
  final String? fromName;
  final int amount;
  final String? toID;
  final int? tick;
  const ApproveSignTransaction(
      {super.key,
      required this.pairingMetadata,
      required this.fromID,
      required this.fromName,
      required this.amount,
      required this.tick,
      required this.toID});

  @override
  // ignore: library_private_types_in_public_api
  _ApproveSignTransactionState createState() => _ApproveSignTransactionState();
}

class _ApproveSignTransactionState extends State<ApproveSignTransaction> {
  final ApplicationStore appStore = getIt<ApplicationStore>();
  final WalletConnectService wcService = getIt<WalletConnectService>();
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
                          //required to remove the warning
                          Navigator.pop(context);
                        }
                        return;
                      }
                    }
                    setState(() {
                      isLoading = true;
                    });

                    late int targetTick;
                    if (widget.tick != null) {
                      targetTick = widget.tick!;
                    } else {
                      int latestTick = (await _liveApi.getCurrentTick()).tick;
                      targetTick = latestTick + defaultTargetTickType.value;
                    }
                    //Generate the transaction
                    String? result;
                    if (mounted) {
                      result = await getTransactionDialog(
                          context,
                          widget.fromID!,
                          widget.toID!,
                          widget.amount,
                          targetTick);
                      if (result != null) {
                        setState(() {
                          isLoading = true;
                        });
                        if (mounted) {
                          Navigator.of(context)
                              .pop(ApproveSignTransactionResult(
                                  //Return the success and tick
                                  tick: targetTick,
                                  signedTransaction: result));
                          getIt<GlobalSnackBar>().show(
                              l10nOf(context).wcApprovedSignedTransaction);
                        }
                      } else {
                        //Else, generation falied
                        setState(() {
                          isLoading = false;
                        });
                        if (mounted) {
                          Navigator.of(context).pop(
                              ApproveSignTransactionResult(
                                  errorMessage: "Transaction generation failed",
                                  tick: null,
                                  signedTransaction: null));
                          getIt<GlobalSnackBar>()
                              .showError(l10nOf(context) //Show snackbar
                                  .sendItemDialogErrorGeneralTitle);
                        }
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
                : Text(l10n.wcSignTransaction,
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
                    Center(
                        child: Text("Sign the transfer of",
                            style: TextStyles.sliverHeader)),
                    ThemedControls.spacerVerticalNormal(),
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
                    Text(widget.fromID ?? "-", style: TextStyles.textNormal),
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
                    Text(widget.toID ?? "-", style: TextStyles.textNormal),
                    ThemedControls.spacerVerticalSmall(),
                    Text(
                      l10n.generalLabelTick,
                      style: TextStyles.lightGreyTextSmall,
                    ),
                    Text(widget.tick?.asThousands() ?? "-",
                        style: TextStyles.textNormal)
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
