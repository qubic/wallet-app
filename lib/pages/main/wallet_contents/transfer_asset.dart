import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:qubic_wallet/components/id_list_item_select.dart';
import 'package:qubic_wallet/components/scan_code_button.dart';
import 'package:qubic_wallet/components/transaction/advanced_tick_options.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/dtos/grouped_asset_dto.dart';
import 'package:qubic_wallet/extensions/as_thousands.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/global_snack_bar.dart';
import 'package:qubic_wallet/helpers/id_validators.dart';
import 'package:qubic_wallet/helpers/platform_helpers.dart';
import 'package:qubic_wallet/helpers/re_auth_dialog.dart';
import 'package:qubic_wallet/helpers/send_transaction.dart';
import 'package:qubic_wallet/helpers/target_tick.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/models/qubic_list_vm.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/transfers/transactions_for_id.dart';
import 'package:qubic_wallet/resources/apis/live/qubic_live_api.dart';
import 'package:qubic_wallet/resources/qubic_cmd.dart';
import 'package:qubic_wallet/services/qr_scanner_service.dart';
import 'package:qubic_wallet/smart_contracts/qx_info.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/stores/qubic_ecosystem_store.dart';
import 'package:qubic_wallet/styles/edge_insets.dart';
import 'package:qubic_wallet/styles/input_decorations.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:qubic_wallet/timed_controller.dart';

class TransferAsset extends StatefulWidget {
  final QubicListVm item;
  final GroupedAssetDto groupedAsset;
  const TransferAsset(
      {super.key, required this.item, required this.groupedAsset});

  @override
  // ignore: library_private_types_in_public_api
  _TransferAssetState createState() => _TransferAssetState();
}

class _TransferAssetState extends State<TransferAsset> {
  final _formKey = GlobalKey<FormBuilderState>();
  final ApplicationStore appStore = getIt<ApplicationStore>();
  final _liveApi = getIt<QubicLiveApi>();
  final QubicCmd qubicCmd = getIt<QubicCmd>();
  final TimedController _timedController = getIt<TimedController>();
  final GlobalKey<_TransferAssetState> widgetKey = GlobalKey();
  final GlobalSnackBar _globalSnackBar = getIt<GlobalSnackBar>();
  final QubicEcosystemStore _ecosystemStore = getIt<QubicEcosystemStore>();
  String? transferError;
  TargetTickTypeEnum targetTickType = defaultTargetTickType;

  final NumberFormat formatter = NumberFormat.decimalPatternDigits(
    locale: 'en_us',
    decimalDigits: 0,
  );

  List<bool> expanded = [false];

  String? generatedPublicId;

  late List<QubicListVm> knownQubicIDs;

  /// Find the QX contribution from the grouped asset (same data shown in list)
  int get transferableUnits {
    final qxContract = _ecosystemStore.getQxContract();
    if (qxContract == null) return 0;

    final qxContribution = widget.groupedAsset.contractContributions
        .firstWhereOrNull(
            (c) => c.managingContractIndex == qxContract.contractIndex);
    return qxContribution?.numberOfUnits ?? 0;
  }

  /// Token name from the grouped asset
  String get tokenName => widget.groupedAsset.tokenName;

  /// Issuer identity from the grouped asset
  String get issuerIdentity => widget.groupedAsset.issuedAsset.issuerIdentity;

  @override
  void initState() {
    knownQubicIDs = appStore.currentQubicIDs
        .where((account) => account.publicId != widget.item.publicId)
        .toList();

    super.initState();
  }

  CurrencyInputFormatter getInputFormatter(BuildContext context) {
    return CurrencyInputFormatter(
        trailingSymbol: tokenName,
        useSymbolPadding: true,
        thousandSeparator: ThousandSeparator.Comma,
        mantissaLength: 0);
  }

  @override
  void dispose() {
    super.dispose();
  }

  int getAssetAmount() {
    return int.parse(numberOfSharesCtrl.text
        .substring(0, numberOfSharesCtrl.text.indexOf(" "))
        .replaceAll(" ", "")
        .replaceAll(",", ""));
  }

  showAlertDialog(BuildContext context, String title, String message) {
    final l10n = l10nOf(context);
    // set up the button
    Widget okButton = TextButton(
      child: Text(l10n.generalButtonOK),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  //Shows the bottom sheet allowing to select a Public ID from the wallet
  void showPickerBottomSheet() {
    final l10n = l10nOf(context);
    showModalBottomSheet<void>(
        context: context,
        useSafeArea: true,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return SafeArea(
              child: SizedBox(
            height: 400,
            child: Center(
                child: Padding(
              padding: const EdgeInsets.all(0),
              child: Flex(
                direction: Axis.vertical,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Padding(
                      padding: const EdgeInsets.fromLTRB(
                          ThemePaddings.bigPadding,
                          ThemePaddings.normalPadding,
                          ThemePaddings.bigPadding,
                          0),
                      child: ThemedControls.pageHeader(
                          headerText:
                              l10n.sendItemLabelSelectSenderAddressLineOne,
                          subheaderText:
                              l10n.sendItemLabelSelectSenderAddressLineTwo)),
                  Expanded(
                    child: ListView.separated(
                        itemCount: knownQubicIDs.length,
                        separatorBuilder: (context, index) {
                          return const Divider(
                            indent: ThemePaddings.bigPadding,
                            endIndent: ThemePaddings.bigPadding,
                            color: LightThemeColors.primary,
                          );
                        },
                        itemBuilder: (BuildContext context, int index) {
                          return InkWell(
                            child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: ThemePaddings.bigPadding,
                                    vertical: ThemePaddings.smallPadding),
                                child: IdListItemSelect(
                                    item: knownQubicIDs[index])),
                            onTap: () {
                              destinationID.text =
                                  knownQubicIDs[index].publicId;

                              Navigator.pop(context);
                            },
                          );
                        }),
                  )
                ],
              ),
            )),
          ));
        });
  }

  Widget getDestinationQubicId() {
    final l10n = l10nOf(context);
    return FormBuilderTextField(
      name: "destinationID",
      readOnly: isLoading,
      controller: destinationID,
      enableSuggestions: false,
      keyboardType: TextInputType.visiblePassword,
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(
            errorText: l10n.generalErrorRequiredField),
        CustomFormFieldValidators.isPublicID(context: context),
        verifyPublicId(l10n.accountSendSectionInvalidDestinationAddress),
      ]),
      maxLines: 2,
      style: TextStyles.inputBoxSmallStyle,
      maxLength: 60,
      decoration: ThemeInputDecorations.normalMultiLineInputbox.copyWith(
          hintText: "",
          hintMaxLines: 3,
          // This line is the one that causes the error
          suffixIcon: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                appStore.currentQubicIDs.length > 1
                    ? IconButton(
                        onPressed: () async {
                          showPickerBottomSheet();
                        },
                        icon: LightThemeColors.shouldInvertIcon
                            ? ThemedControls.invertedColors(
                                child: Image.asset(
                                    "assets/images/bookmark-24.png"))
                            : Image.asset("assets/images/bookmark-24.png"))
                    //const Icon(Icons.book))
                    : Container(),
                ThemedControls.spacerHorizontalMini()
              ])),
      autocorrect: false,
      autofillHints: null,
    );
  }

  Widget getPredefinedAmountOptions() {
    final l10n = l10nOf(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ThemedControls.transparentButtonSmall(
            text: l10n.accountSendButtonMax,
            onPressed: () {
              if (transferableUnits > 0) {
                numberOfSharesCtrl.value = getInputFormatter(context)
                    .formatEditUpdate(
                        const TextEditingValue(text: ''),
                        TextEditingValue(
                            text: (transferableUnits).toString()));
              }
            }),
        (transferableUnits > 1)
            ? ThemedControls.transparentButtonSmall(
                text: l10n.accountSendButtonMaxMinusOne,
                onPressed: () {
                  if (transferableUnits > 1) {
                    numberOfSharesCtrl.value = getInputFormatter(context)
                        .formatEditUpdate(
                            const TextEditingValue(text: ''),
                            TextEditingValue(
                                text: (transferableUnits - 1)
                                    .toString()));
                  }
                })
            : Container()
      ],
    );
  }

  Widget getAmountBox() {
    final l10n = l10nOf(context);
    return FormBuilderTextField(
      decoration:
          ThemeInputDecorations.normalInputbox.copyWith(hintMaxLines: 1),
      name: "Amount",
      readOnly: isLoading,
      controller: numberOfSharesCtrl,
      enableSuggestions: false,
      textAlign: TextAlign.end,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: false, // Set to true if you want to allow decimal numbers
        signed: false, // Set to true if you want to allow signed numbers
      ),
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(
            errorText: l10n.generalErrorRequiredField),
        CustomFormFieldValidators.isLessThanParsedAsset(
          context: context,
          lessThan: transferableUnits,
        ),
      ]),
      inputFormatters: [getInputFormatter(context)],
      maxLines: 1,
      autocorrect: false,
      autofillHints: null,
    );
  }

  Widget getOwnershipInfo() {
    final l10n = l10nOf(context);
    return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
              l10n.transferAssetLabelOwned(tokenName,
                  formatter.format(transferableUnits)),
              style: TextStyles.secondaryText),
        ]);
  }

  /// Qubic balance from passed account (consistent with list)
  int get currentQubicBalance => widget.item.amount ?? 0;

  Widget getTotalQubicInfo() {
    final l10n = l10nOf(context);
    return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
              l10n.assetsLabelCurrentBalance(
                  formatter.format(currentQubicBalance)),
              style: TextStyles.secondaryText)
        ]);
  }

  Widget getCostInfo() {
    final l10n = l10nOf(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(l10n.generalLabelFee, style: TextStyles.labelTextNormal),
      ThemedControls.spacerVerticalMini(),
      FormBuilderTextField(
        name: "fee",
        readOnly: true,
        textAlign: TextAlign.center,
        controller: TextEditingController(
            text:
                "${QxInfo.transferAssetFee.asThousands()} ${l10n.generalLabelCurrencyQubic}"),
        validator: FormBuilderValidators.compose([
          CustomFormFieldValidators.isLessThanParsed(
              lessThan: currentQubicBalance, context: context),
        ]),
        decoration: ThemeInputDecorations.normalInputbox,
      ),
      ThemedControls.spacerVerticalMini(),
      getTotalQubicInfo()
    ]);
  }

  Widget getScrollView() {
    final l10n = l10nOf(context);
    return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Row(children: [
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ThemedControls.pageHeader(
                  headerText:
                      l10n.transferAssetHeader(tokenName),
                  subheaderText: l10n.transferAssetSubHeader(widget.item.name)),
              ThemedControls.spacerVerticalSmall(),
              Text(l10n.transferAssetNoticeQxOnly,
                  style: TextStyles.secondaryText),
              ThemedControls.spacerVerticalNormal(),
              Text(l10n.accountSendLabelDestinationAddress,
                  style: TextStyles.labelTextNormal),
              ThemedControls.spacerVerticalMini(),
              FormBuilder(
                  key: _formKey,
                  child: Column(
                    children: [
                      getDestinationQubicId(),
                      if (isMobile)
                        ScanCodeButton(onPressed: () {
                          getIt<QrScannerService>().scanAndSetPublicId(
                            context: context,
                            controller: destinationID,
                          );
                        }),
                      ThemedControls.spacerVerticalMini(),
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        Expanded(
                            child: Text(l10n.accountSendLabelAmount,
                                style: TextStyles.labelTextNormal)),
                        getPredefinedAmountOptions()
                      ]),
                      getAmountBox(),
                      ThemedControls.spacerVerticalMini(),
                      getOwnershipInfo(),
                      ThemedControls.spacerVerticalBig(),
                      getCostInfo(),
                      ThemedControls.spacerVerticalBig(),
                      ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Material(
                              elevation: 0,
                              borderOnForeground: false,
                              shadowColor: Colors.transparent,
                              child: ExpansionPanelList(
                                  elevation: 0,
                                  expansionCallback:
                                      (int index, bool isExpanded) {
                                    setState(() {
                                      expanded[index] = !expanded[index];
                                    });
                                  },
                                  children: [
                                    ExpansionPanel(
                                      canTapOnHeader: true,
                                      backgroundColor:
                                          LightThemeColors.cardBackground,
                                      headerBuilder: (BuildContext context,
                                          bool isExpanded) {
                                        return ListTile(
                                          title: Text(l10n
                                              .accountSendSectionAdvanceOptionsTitle),
                                        );
                                      },
                                      body: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                            ThemePaddings.normalPadding,
                                            0,
                                            ThemePaddings.normalPadding,
                                            ThemePaddings.normalPadding,
                                          ),
                                          child: AdvancedTickOptions(
                                            targetTickType: targetTickType,
                                            onTargetTickTypeChanged:
                                                (TargetTickTypeEnum? value) {
                                              setState(() {
                                                targetTickType = value!;
                                              });
                                            },
                                            tickController: tickController,
                                            currentTick: appStore.currentTick,
                                            isLoading: isLoading,
                                          )),
                                      isExpanded: expanded[0],
                                    )
                                  ])))
                    ],
                  )),
              const SizedBox(height: ThemePaddings.normalPadding),
            ],
          ))
        ]));
  }

  List<Widget> getButtons() {
    final l10n = l10nOf(context);

    return [
      !isLoading
          ? Expanded(
              child: ThemedControls.transparentButtonBigWithChild(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(ThemePaddings.smallPadding),
                    child: Text(l10n.generalButtonCancel,
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            )),
                  )))
          : Container(),
      ThemedControls.spacerHorizontalNormal(),
      Expanded(
          child: ThemedControls.primaryButtonBigWithChild(
              onPressed: transferNowHandler,
              child: Padding(
                  padding: const EdgeInsets.all(ThemePaddings.smallPadding + 3),
                  child: !isLoading
                      ? SizedBox(
                          width: double.infinity,
                          child: Text(l10n.sendAssetButtonTransfer,
                              textAlign: TextAlign.center,
                              style: TextStyles.primaryButtonText))
                      : Padding(
                          padding: const EdgeInsets.fromLTRB(57, 0, 57, 0),
                          child: SizedBox(
                              height: 23,
                              width: 23,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inversePrimary))))))
    ];
  }

  void transferNowHandler() async {
    final l10n = l10nOf(context);

    _formKey.currentState?.validate();
    if (!_formKey.currentState!.isValid) {
      return;
    }

    if (await qubicCmd.verifyIdentity(destinationID.text) == false) {
      setState(() {
        validPublicId = false;
      });
      _formKey.currentState?.validate();
      return;
    }
    if (!mounted) return;
    bool authenticated = await reAuthDialog(context);
    if (!authenticated) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      int? targetTick;

      if (targetTickType == TargetTickTypeEnum.manual) {
        targetTick = int.tryParse(tickController.text);
      } else {
        // fetch latest tick
        int latestTick = (await _liveApi.getCurrentTick()).tick;
        targetTick = latestTick + targetTickType.value;
      }
      if (!mounted) return;
      var result = await sendAssetTransferTransactionDialog(
          context,
          widget.item.publicId,
          destinationID.text,
          tokenName,
          issuerIdentity,
          getAssetAmount(),
          targetTick!);

      if (result == null) {
        return;
      }
      await _timedController.interruptFetchTimer();

      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      Navigator.pop(context);
      _globalSnackBar.show(l10n.generalSnackBarMessageTransactionSubmitted(
          targetTick.asThousands()));
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return TransactionsForId(
          publicQubicId: widget.item.publicId,
          item: widget.item,
        );
      }));
    } catch (e) {
      _globalSnackBar.showError(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  TextEditingController destinationID = TextEditingController();
  TextEditingController numberOfSharesCtrl = TextEditingController();
  TextEditingController transactionCostCtrl = TextEditingController();
  TextEditingController tickController = TextEditingController();

  bool isLoading = false;
  bool validPublicId = true;
  FormFieldValidator verifyPublicId(String message) {
    return (val) => !validPublicId ? message : null;
  }

  @override
  Widget build(BuildContext context) {
    validPublicId = true;
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
                  Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: getButtons())
                ]))));
  }
}
