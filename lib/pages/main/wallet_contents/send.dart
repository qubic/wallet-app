import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:qubic_wallet/components/id_list_item_select.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/extensions/asThousands.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/id_validators.dart';
import 'package:qubic_wallet/helpers/platform_helpers.dart';
import 'package:qubic_wallet/helpers/re_auth_dialog.dart';
import 'package:qubic_wallet/helpers/sendTransaction.dart';
import 'package:qubic_wallet/helpers/global_snack_bar.dart';
import 'package:qubic_wallet/models/qubic_list_vm.dart';
import 'package:qubic_wallet/resources/apis/archive/qubic_archive_api.dart';
import 'package:qubic_wallet/resources/apis/live/qubic_live_api.dart';
import 'package:qubic_wallet/resources/qubic_cmd.dart';
import 'package:qubic_wallet/resources/qubic_li.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:intl/intl.dart';
import 'package:qubic_wallet/styles/edge_insets.dart';
import 'package:qubic_wallet/styles/input_decorations.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:qubic_wallet/timed_controller.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/helpers/target_tick.dart';

class Send extends StatefulWidget {
  final QubicListVm item;
  const Send({super.key, required this.item});

  @override
  // ignore: library_private_types_in_public_api
  _SendState createState() => _SendState();
}

class _SendState extends State<Send> {
  final _formKey = GlobalKey<FormBuilderState>();
  final ApplicationStore appStore = getIt<ApplicationStore>();
  final QubicLi apiService = getIt<QubicLi>();
  final _liveApi = getIt<QubicLiveApi>();
  final QubicCmd qubicCmd = getIt<QubicCmd>();
  final TimedController _timedController = getIt<TimedController>();
  final GlobalSnackBar _globalSnackBar = getIt<GlobalSnackBar>();
  String? transferError;
  TargetTickTypeEnum targetTickType = defaultTargetTickType;

  final NumberFormat formatter = NumberFormat.decimalPatternDigits(
    locale: 'en_us',
    decimalDigits: 0,
  );

  bool expanded = false;

  List<DropdownMenuItem<TargetTickTypeEnum>> getTickList() {
    final l10n = l10nOf(context);

    return TargetTickTypeEnum.values.map((targetTickTypeItem) {
      return DropdownMenuItem<TargetTickTypeEnum>(
        value: targetTickTypeItem,
        child: Text(
            targetTickTypeItem == TargetTickTypeEnum.manual
                ? l10n.sendItemLabelTargetTickManual
                : l10n
                    .sendItemLabelTargetTickAutomatic(targetTickTypeItem.value),
            style: TextStyles
                .inputBoxSmallStyle), // Display name without enum prefix
      );
    }).toList();
  }

  CurrencyInputFormatter getInputFormatter() {
    final l10n = l10nOf(context);

    return CurrencyInputFormatter(
        trailingSymbol: l10n.generalLabelCurrencyQubic,
        useSymbolPadding: true,
        thousandSeparator: ThousandSeparator.Comma,
        mantissaLength: 0);
  }

  String? generatedPublicId;
  late List<QubicListVm> knownQubicIDs;

  @override
  void initState() {
    knownQubicIDs = appStore.currentQubicIDs
        .where((account) => account.publicId != widget.item.publicId)
        .toList();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  int getQubicAmount() {
    final l10n = l10nOf(context);

    return int.parse(amount.text
        .replaceAll(",", "")
        .replaceAll(" ", "")
        .replaceAll(l10n.generalLabelCurrencyQubic, ""));
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

  void showQRScanner() {
    showModalBottomSheet<void>(
        context: context,
        useSafeArea: true,
        builder: (BuildContext context) {
          final l10n = l10nOf(context);

          return Stack(children: [
            MobileScanner(
              // fit: BoxFit.contain,
              controller: MobileScannerController(
                detectionSpeed: DetectionSpeed.normal,
                facing: CameraFacing.back,
                torchEnabled: false,
              ),

              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                bool foundSuccess = false;
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null) {
                    var value = destinationID.text;
                    value = barcode.rawValue!
                        .replaceAll("https://wallet.qubic.org/payment/", "");
                    var validator =
                        CustomFormFieldValidators.isPublicID(context: context);
                    if (validator(value) == null) {
                      if (foundSuccess == true) {
                        break;
                      }
                      destinationID.text = value;
                      foundSuccess = true;
                    }
                  }
                }
                if (foundSuccess) {
                  Navigator.pop(context);
                  _globalSnackBar
                      .show(l10n.generalSnackBarMessageQRScannedWithSuccess);
                }
              },
            ),
            Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                    color: Colors.white60,
                    width: double.infinity,
                    child: Padding(
                        padding:
                            const EdgeInsets.all(ThemePaddings.normalPadding),
                        child: Text(l10n.sendItemLabelQRScannerInstructions,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center))))
          ]);
        });
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
              child: Container(
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

  List<Widget> getOverrideTick() {
    final l10n = l10nOf(context);

    if ((targetTickType == TargetTickTypeEnum.manual) && (expanded == true)) {
      return [
        ThemedControls.spacerVerticalSmall(),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
                child: Text(l10n.generalLabelTick,
                    style: TextStyles.labelTextNormal)),
            ThemedControls.transparentButtonSmall(
                text: l10n.sendItemButtonSetCurrentTick(
                    appStore.currentTick.asThousands()),
                onPressed: () {
                  if (appStore.currentTick > 0) {
                    tickController.text = appStore.currentTick.toString();
                  }
                }),
          ],
        ),
        FormBuilderTextField(
          decoration: ThemeInputDecorations.normalInputbox,
          name: l10n.generalLabelTick,
          readOnly: isLoading,
          controller: tickController,
          enableSuggestions: false,
          keyboardType: TextInputType.number,
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(
                errorText: l10n.generalErrorRequiredField),
            FormBuilderValidators.numeric(),
          ]),
          maxLines: 1,
          autocorrect: false,
          autofillHints: null,
        )
      ];
    }
    return [Container()];
  }

  Widget getAdvancedOptions() {
    final l10n = l10nOf(context);

    return Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(l10n.sendItemLabelDetermineTargetTick,
              style: TextStyles.labelTextNormal),
          ThemedControls.spacerVerticalMini(),
          Theme(
              data: Theme.of(context).copyWith(
                  canvasColor: LightThemeColors.background,
                  scaffoldBackgroundColor: LightThemeColors.background,
                  brightness: Brightness.dark,
                  dropdownMenuTheme: DropdownMenuThemeData(
                    textStyle: TextStyles.inputBoxNormalStyle,
                  )),
              child: ThemedControls.dropdown<TargetTickTypeEnum>(
                items: getTickList(),
                onChanged: (TargetTickTypeEnum? value) {
                  setState(() {
                    targetTickType = value!;
                  });
                },
                value: targetTickType,
              )),
          Column(children: getOverrideTick())
        ]);
  }

  Widget getScrollView(BuildContext context) {
    final l10n = l10nOf(context);
    return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Row(children: [
          Container(
              child: Expanded(
                  child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ThemedControls.pageHeader(
                  headerText: l10n.accountSendTitle,
                  subheaderText: "from \"${widget.item.name}\""),
              ThemedControls.spacerVerticalSmall(),
              Text(l10n.accountSendLabelDestinationAddress,
                  style: TextStyles.labelTextNormal),
              ThemedControls.spacerVerticalMini(),
              FormBuilder(
                  key: _formKey,
                  child: Column(
                    children: [
                      Flex(direction: Axis.horizontal, children: [
                        Expanded(
                            flex: 10,
                            child: FormBuilderTextField(
                              name: "destinationID",
                              readOnly: isLoading,
                              controller: destinationID,
                              enableSuggestions: false,
                              onSubmitted: (value) => transferNowHandler(),
                              keyboardType: TextInputType.visiblePassword,
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(
                                    errorText: l10n.generalErrorRequiredField),
                                CustomFormFieldValidators.isPublicID(
                                    context: context),
                                verifyPublicId(l10n
                                    .accountSendSectionInvalidDestinationAddress),
                              ]),
                              maxLines: 2,
                              style: TextStyles.inputBoxSmallStyle,
                              maxLength: 60,
                              decoration: ThemeInputDecorations
                                  .normalMultiLineInputbox
                                  .copyWith(
                                      hintText: "",
                                      hintMaxLines: 3,
                                      // This line is the one that causes the error
                                      suffixIcon: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            appStore.currentQubicIDs.length > 1
                                                ? IconButton(
                                                    onPressed: () async {
                                                      showPickerBottomSheet();
                                                    },
                                                    icon: LightThemeColors
                                                            .shouldInvertIcon
                                                        ? ThemedControls
                                                            .invertedColors(
                                                                child: Image.asset(
                                                                    "assets/images/bookmark-24.png"))
                                                        : Image.asset(
                                                            "assets/images/bookmark-24.png"))
                                                //const Icon(Icons.book))
                                                : Container(),
                                            ThemedControls
                                                .spacerHorizontalMini()
                                          ])),
                              autocorrect: false,
                              autofillHints: null,
                            )),
                      ]),
                      if (isMobile)
                        Align(
                            alignment: Alignment.topLeft,
                            child: ThemedControls.primaryButtonNormal(
                                onPressed: () {
                                  showQRScanner();
                                },
                                text: l10n.generalButtonUseQRCode,
                                icon: !LightThemeColors.shouldInvertIcon
                                    ? ThemedControls.invertedColors(
                                        child: Image.asset(
                                            "assets/images/Group 2294.png"))
                                    : Image.asset(
                                        "assets/images/Group 2294.png"))),
                      ThemedControls.spacerVerticalMini(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                              child: Text(l10n.accountSendLabelAmount,
                                  style: TextStyles.labelTextNormal)),
                          ThemedControls.transparentButtonSmall(
                              text: l10n.accountSendButtonMax,
                              onPressed: () {
                                if (widget.item.amount == null) {
                                  return;
                                }
                                if (widget.item.amount! > 0) {
                                  amount.value = getInputFormatter()
                                      .formatEditUpdate(
                                          const TextEditingValue(text: ''),
                                          TextEditingValue(
                                              text: (widget.item.amount)
                                                  .toString()));
                                }
                              }),
                          (widget.item.amount != null &&
                                  widget.item.amount! > 1)
                              ? ThemedControls.transparentButtonSmall(
                                  text: l10n.accountSendButtonMaxMinusOne,
                                  onPressed: () {
                                    if (widget.item.amount == null) {
                                      return;
                                    }
                                    if (widget.item.amount! > 1) {
                                      amount.value = getInputFormatter()
                                          .formatEditUpdate(
                                              const TextEditingValue(text: ''),
                                              TextEditingValue(
                                                  text:
                                                      (widget.item.amount! - 1)
                                                          .toString()));
                                    }
                                  })
                              : Container()
                        ],
                      ),
                      FormBuilderTextField(
                        //decoration: const InputDecoration(labelText: 'Amount'),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal:
                              false, // Set to true if you want to allow decimal numbers
                          signed:
                              false, // Set to true if you want to allow signed numbers
                        ),
                        decoration: ThemeInputDecorations.normalInputbox
                            .copyWith(hintMaxLines: 1),
                        name: l10n.accountSendLabelAmount,
                        readOnly: isLoading,
                        controller: amount,
                        enableSuggestions: false,
                        textAlign: TextAlign.start,
                        onSubmitted: (value) => transferNowHandler(),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(
                              errorText: l10n.generalErrorRequiredField),
                          CustomFormFieldValidators.isLessThanParsed(
                              lessThan: widget.item.amount!, context: context),
                        ]),
                        inputFormatters: [getInputFormatter()],
                        maxLines: 1,
                        autocorrect: false,
                        autofillHints: null,
                      ),
                      const SizedBox(height: ThemePaddings.miniPadding),
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                l10n.assetsLabelCurrentBalance(
                                    formatter.format(widget.item.amount)),
                                style: TextStyles.secondaryText),
                          ]),
                      const SizedBox(height: ThemePaddings.bigPadding),
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
                                      expanded = !expanded;
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
                                          title: Text(
                                              l10n.accountSendSectionAdvanceOptionsTitle,
                                              style: TextStyles.labelText),
                                        );
                                      },
                                      body: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                            ThemePaddings.normalPadding,
                                            0,
                                            ThemePaddings.normalPadding,
                                            ThemePaddings.normalPadding,
                                          ),
                                          child: getAdvancedOptions()),
                                      isExpanded: expanded,
                                    )
                                  ])))
                    ],
                  )),
              const SizedBox(height: ThemePaddings.normalPadding),
            ],
          )))
        ]));
  }

  List<Widget> getButtons() {
    final l10n = l10nOf(context);

    return [
      Expanded(
          child: !isLoading
              ? ThemedControls.transparentButtonBigWithChild(
                  child: Padding(
                      padding: const EdgeInsets.all(ThemePaddings.smallPadding),
                      child: Text(l10n.generalButtonCancel,
                          style: TextStyles.transparentButtonText)),
                  onPressed: () {
                    Navigator.pop(context);
                  })
              : Container()),
      ThemedControls.spacerHorizontalNormal(),
      Expanded(
          child: ThemedControls.primaryButtonBigWithChild(
              onPressed: transferNowHandler,
              child: Padding(
                  padding: const EdgeInsets.all(ThemePaddings.smallPadding + 3),
                  child: !isLoading
                      ? Text(l10n.accountButtonSend,
                          textAlign: TextAlign.center,
                          style: TextStyles.primaryButtonText)
                      : SizedBox(
                          height: 23,
                          width: 23,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context)
                                  .colorScheme
                                  .inversePrimary)))))
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

    bool authenticated = await reAuthDialog(context);
    if (!authenticated) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    int? targetTick;

    if (targetTickType == TargetTickTypeEnum.manual) {
      targetTick = int.tryParse(tickController.text);
    } else {
      // fetch latest tick
      int latestTick = (await _liveApi.getCurrentTick()).tick;
      targetTick = latestTick + targetTickType.value;
    }

    bool result = await sendTransactionDialog(context, widget.item.publicId,
        destinationID.text, getQubicAmount(), targetTick!);
    if (!result) {
      setState(() {
        isLoading = false;
      });
      return;
    }
    await _timedController.interruptFetchTimer();

    //Clear the state
    setState(() {
      isLoading = false;
      getIt.get<PersistentTabController>().jumpToTab(1);
    });

    Navigator.pop(context);

    _globalSnackBar.show(l10n
        .generalSnackBarMessageTransactionSubmitted(targetTick!.asThousands()));
  }

  TextEditingController destinationID = TextEditingController();
  TextEditingController amount = TextEditingController();
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
                  Expanded(child: getScrollView(context)),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: getButtons())
                ]))));
  }
}
