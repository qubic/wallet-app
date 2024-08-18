import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/copy_to_clipboard.dart';
import 'package:qubic_wallet/helpers/id_validators.dart';
import 'package:qubic_wallet/helpers/platform_helpers.dart';
import 'package:qubic_wallet/helpers/random.dart';
import 'package:qubic_wallet/helpers/show_alert_dialog.dart';
import 'package:qubic_wallet/helpers/global_snack_bar.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/add_account_warning_sheet.dart';
import 'package:qubic_wallet/resources/qubic_cmd.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qubic_wallet/styles/edge_insets.dart';
import 'package:qubic_wallet/styles/input_decorations.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:qubic_wallet/timed_controller.dart';
import 'package:qubic_wallet/l10n/l10n.dart';

class AddAccount extends StatefulWidget {
  final bool isWatchOnly;

  const AddAccount({super.key, required this.isWatchOnly});

  @override
  // ignore: library_private_types_in_public_api
  _AddAccountState createState() => _AddAccountState();
}

class _AddAccountState extends State<AddAccount> {
  final _createAccountFormKey = GlobalKey<FormBuilderState>();
  final _watchOnlyFormKey = GlobalKey<FormBuilderState>();
  final ApplicationStore appStore = getIt<ApplicationStore>();
  final QubicCmd qubicCmd = getIt<QubicCmd>();
  final GlobalSnackBar _globalSnackBar = getIt<GlobalSnackBar>();

  bool detected = false;
  bool generatingId = false;

  String? generatedPublicId;
  String? watchOnlyId;

  @override
  void initState() {
    super.initState();
    qubicCmd.initialize();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void showQRScanner() {
    final l10n = l10nOf(context);
    detected = false;
    showModalBottomSheet<void>(
        context: context,
        useSafeArea: true,
        builder: (BuildContext context) {
          bool foundSuccess = false;
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

                for (final barcode in barcodes) {
                  if (barcode.rawValue != null) {
                    var validator =
                        CustomFormFieldValidators.isSeed(context: context);
                    if (validator(barcode.rawValue) == null) {
                      privateSeed.text = barcode.rawValue!;
                      foundSuccess = true;
                    }
                  }

                  if (foundSuccess) {
                    if (!detected) {
                      Navigator.pop(context);

                      _globalSnackBar.show(
                          l10n.generalSnackBarMessageQRScannedWithSuccess);
                    }
                    detected = true;
                  }
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
                        child: Text(l10n.addAccountHeaderScanQRCodeInstructions,
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

  Widget getScrollView() {
    final l10n = l10nOf(context);
    return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Row(children: [
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ThemedControls.pageHeader(headerText: l10n.addAccountHeader),
              ThemedControls.spacerVerticalSmall(),
              Row(children: [
                Text(l10n.addAccountLabelAccountName,
                    style: TextStyles.labelTextNormal),
                ThemedControls.spacerHorizontalSmall(),
                Tooltip(
                    triggerMode: TooltipTriggerMode.tap,
                    showDuration: const Duration(seconds: 5),
                    message: l10n.addAccountTooltipAccountName,
                    child: LightThemeColors.shouldInvertIcon
                        ? ThemedControls.invertedColors(
                            child: Image.asset(
                                "assets/images/question-active-16.png"))
                        : Image.asset("assets/images/question-active-16.png")),
              ]),
              ThemedControls.spacerVerticalMini(),
              FormBuilder(
                  key: _createAccountFormKey,
                  child: Column(
                    children: [
                      FormBuilderTextField(
                        onSubmitted: (String? text) {
                          saveIdHandler();
                        },
                        name: "accountName",
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(
                              errorText: l10n.generalErrorRequiredField),
                          CustomFormFieldValidators.isNameAvailable(
                              currentQubicIDs: appStore.currentQubicIDs,
                              context: context)
                        ]),
                        readOnly: isLoading,
                        style: TextStyles.inputBoxSmallStyle,
                        decoration: ThemeInputDecorations.normalInputbox
                            .copyWith(hintText: l10n.addAccountHintAccountName),
                        autocorrect: false,
                        autofillHints: null,
                      ),
                      ThemedControls.spacerVerticalNormal(),
                      Row(children: [
                        Text(l10n.addAccountLabelPrivateSeed,
                            style: TextStyles.labelTextNormal),
                        ThemedControls.spacerHorizontalSmall(),
                        Tooltip(
                            triggerMode: TooltipTriggerMode.tap,
                            showDuration: const Duration(seconds: 5),
                            message: l10n.addAccountTooltipPrivateSeed,
                            child: LightThemeColors.shouldInvertIcon
                                ? ThemedControls.invertedColors(
                                    child: Image.asset(
                                        "assets/images/question-active-16.png"))
                                : Image.asset(
                                    "assets/images/question-active-16.png")),
                        Expanded(child: Container()),
                        ThemedControls.transparentButtonSmall(
                            onPressed: () {
                              if (generatingId) {
                                return;
                              }
                              FocusManager.instance.primaryFocus?.unfocus();

                              var seed = getRandomSeed();
                              privateSeed.text = seed;
                            },
                            text: l10n.addAccountButtonCreateRandom,
                            icon: LightThemeColors.shouldInvertIcon
                                ? ThemedControls.invertedColors(
                                    child: Image.asset(
                                        "assets/images/private seed-16.png"))
                                : Image.asset(
                                    "assets/images/private seed-16.png"))
                      ]),
                      FormBuilderTextField(
                        name: "privateSeed",
                        readOnly: isLoading,
                        controller: privateSeed,
                        enableSuggestions: false,
                        keyboardType: TextInputType.visiblePassword,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(
                              errorText: l10n.generalErrorRequiredField),
                          CustomFormFieldValidators.isSeed(context: context),
                          CustomFormFieldValidators.isPublicIdAvailable(
                              currentQubicIDs: appStore.currentQubicIDs,
                              context: context)
                        ]),
                        onSubmitted: (value) {
                          saveIdHandler();
                        },
                        onChanged: (value) async {
                          var v = CustomFormFieldValidators.isSeed(
                              context: context);
                          if (value != null &&
                              value.trim().isNotEmpty &&
                              v(value) == null) {
                            try {
                              setState(() {
                                generatingId = true;
                              });
                              var newId =
                                  await qubicCmd.getPublicIdFromSeed(value);
                              setState(() {
                                generatedPublicId = newId;
                                generatingId = false;
                              });
                            } catch (e) {
                              if (e
                                  .toString()
                                  .startsWith("Exception: CRITICAL:")) {
                                showAlertDialog(
                                    context,
                                    l10n.addAccountErrorTamperedWalletTitle,
                                    isAndroid
                                        ? l10n
                                            .addAccountErrorTamperedAndroidWalletMessage
                                        : isIOS
                                            ? l10n
                                                .addAccountErrorTamperediOSWalletMessage
                                            : l10n
                                                .addAccountErrorTamperedWalletMessage);
                              }
                              setState(() {
                                privateSeed.value = TextEditingValue.empty;
                                generatedPublicId = null;
                              });
                            }
                            return;
                          }
                          setState(() {
                            generatedPublicId = null;
                          });
                        },
                        maxLines: 2,
                        style: TextStyles.inputBoxSmallStyle,
                        maxLength: 55,
                        enabled: !generatingId,
                        decoration: ThemeInputDecorations
                            .normalMultiLineInputbox
                            .copyWith(
                                hintText: l10n.addAccountHintPrivateSeed,
                                suffixIcon: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Padding(
                                          padding: const EdgeInsets.only(
                                              right:
                                                  ThemePaddings.smallPadding),
                                          child: IconButton(
                                              onPressed: () async {
                                                if ((_createAccountFormKey
                                                                .currentState
                                                                ?.instantValue[
                                                            "privateSeed"]
                                                        as String)
                                                    .trim()
                                                    .isEmpty) {
                                                  return;
                                                }
                                                copyToClipboard(
                                                    _createAccountFormKey
                                                            .currentState
                                                            ?.instantValue[
                                                        "privateSeed"],
                                                    context);
                                              },
                                              icon: LightThemeColors
                                                      .shouldInvertIcon
                                                  ? ThemedControls.invertedColors(
                                                      child: Image.asset(
                                                          "assets/images/Group 2400.png"))
                                                  : Image.asset(
                                                      "assets/images/Group 2400.png")))
                                    ])),
                        autocorrect: false,
                        autofillHints: null,
                      ),
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
                      ThemedControls.spacerVerticalNormal(),
                      Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                              l10n.addAccountHeaderKeepPrivateSeedSecret,
                              style: TextStyles.assetSecondaryTextLabel)),
                      const SizedBox(height: ThemePaddings.normalPadding),
                    ],
                  ))
            ],
          ))
        ]));
  }

  Widget getWatchOnlyScrollView() {
    final l10n = l10nOf(context);
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Row(children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ThemedControls.pageHeader(headerText: "Watch Only"),
              ThemedControls.spacerVerticalSmall(),
              FormBuilder(
                key: _watchOnlyFormKey,
                child: Column(
                  children: [
                    const Text("Add a public Qubic address to watch. You do not have the permission to send or receive any transaction."),
                    ThemedControls.spacerVerticalHuge(),
                    Row(children: [
                      Text(l10n.addAccountLabelAccountName,
                          style: TextStyles.labelTextNormal),
                      Tooltip(
                          triggerMode: TooltipTriggerMode.tap,
                          showDuration: const Duration(seconds: 5),
                          message: l10n.addAccountTooltipAccountName,
                          child: LightThemeColors.shouldInvertIcon
                              ? ThemedControls.invertedColors(
                                  child: Image.asset(
                                      "assets/images/question-active-16.png"))
                              : Image.asset(
                                  "assets/images/question-active-16.png")),
                    ]),
                    ThemedControls.spacerVerticalSmall(),
                    FormBuilderTextField(
                      onSubmitted: (String? text) {
                        saveIdHandler();
                      },
                      name: "accountName",
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(
                            errorText: l10n.generalErrorRequiredField),
                        CustomFormFieldValidators.isNameAvailable(
                            currentQubicIDs: appStore.currentQubicIDs,
                            context: context)
                      ]),
                      readOnly: isLoading,
                      style: TextStyles.inputBoxSmallStyle,
                      decoration: ThemeInputDecorations.normalInputbox
                          .copyWith(hintText: l10n.addAccountHintAccountName),
                      autocorrect: false,
                      autofillHints: null,
                    ),
                    ThemedControls.spacerVerticalSmall(),
                    Row(children: [
                      Text(l10n.generalLabeQubicAddressAndPublicID,
                          style: TextStyles.labelTextNormal),
                      ThemedControls.spacerHorizontalSmall(),
                      Tooltip(
                          triggerMode: TooltipTriggerMode.tap,
                          showDuration: const Duration(seconds: 5),
                          message: "A Public ID is made of 60 upper cases.",
                          child: LightThemeColors.shouldInvertIcon
                              ? ThemedControls.invertedColors(
                                  child: Image.asset(
                                      "assets/images/question-active-16.png"))
                              : Image.asset(
                                  "assets/images/question-active-16.png")),
                    ]),
                    ThemedControls.spacerVerticalMini(),
                    FormBuilderTextField(
                      name: "publicAddress",
                      maxLength: 60,
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(
                            errorText: l10n.generalErrorRequiredField),
                        CustomFormFieldValidators.isPublicID(context: context)
                        // Use a validator suitable for public addresses
                      ]),
                      onChanged: (value) {
                        setState(() {
                          watchOnlyId = value;
                        });
                      },
                      onSubmitted: (value) {
                        savePublicIdHandler();
                      },
                      readOnly: isLoading,
                      style: TextStyles.inputBoxSmallStyle,
                      decoration: ThemeInputDecorations.normalInputbox
                          .copyWith(hintText: l10n.addAccountHintAccountName),
                      autocorrect: false,
                      autofillHints: null,
                    ),
                    ThemedControls.spacerVerticalNormal(),
                    ThemedControls.spacerVerticalNormal(),
                    const SizedBox(height: ThemePaddings.normalPadding),
                  ],
                ),
              ),
            ],
          ),
        ),
      ]),
    );
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
              onPressed:
                  widget.isWatchOnly ? savePublicIdHandler : saveIdHandler,
              child: Padding(
                  padding: const EdgeInsets.all(ThemePaddings.smallPadding + 3),
                  child: Text(l10n.generalButtonSave,
                      textAlign: TextAlign.center,
                      style: TextStyles.primaryButtonText))))
    ];
  }

  void savePublicIdHandler() async {
    final l10n = l10nOf(context);
    _watchOnlyFormKey.currentState?.validate();
    if (!_watchOnlyFormKey.currentState!.isValid) {
      return;
    }

    //Prevent duplicates
    if (appStore.currentQubicIDs
        .where(((element) =>
            element.publicId == watchOnlyId!.replaceAll(",", "_")))
        .isNotEmpty) {
      _globalSnackBar.show(l10n.generalSnackBarMessageAccountAlreadyExist);

      return;
    }

    await _savePublicId();
    getIt<TimedController>().interruptFetchTimer();
  }

  Future<void> _savePublicId() async {
    setState(() {
      isLoading = true;
    });

    await appStore.addId(
        _watchOnlyFormKey.currentState?.instantValue["accountName"] as String,
        watchOnlyId!,
        '-1');

    setState(() {
      isLoading = false;
    });

    if (!mounted) return;
    Navigator.pop(context);
  }

  void saveIdHandler() async {
    final l10n = l10nOf(context);
    _createAccountFormKey.currentState?.validate();
    if (generatingId) {
      return;
    }
    if (!_createAccountFormKey.currentState!.isValid) {
      return;
    }

    //Prevent duplicates
    if (appStore.currentQubicIDs
        .where(((element) =>
            element.publicId == generatedPublicId!.replaceAll(",", "_")))
        .isNotEmpty) {
      _globalSnackBar.show(l10n.generalSnackBarMessageAccountAlreadyExist);

      return;
    }

    showModalBottomSheet<void>(
        context: context,
        isDismissible: false,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: LightThemeColors.background,
        builder: (BuildContext context) {
          return SafeArea(
              child: AddAccountWarningSheet(onAccept: () async {
            if (!mounted) return;
            Navigator.pop(context);
            await _saveId();
            getIt<TimedController>().interruptFetchTimer();
          }, onReject: () async {
            Navigator.pop(context);
          }));
        });
  }

  Future<void> _saveId() async {
    setState(() {
      isLoading = true;
    });
    await appStore.addId(
      _createAccountFormKey.currentState?.instantValue["accountName"] as String,
      generatedPublicId!,
      _createAccountFormKey.currentState?.instantValue["privateSeed"] as String,
    );

    setState(() {
      isLoading = false;
    });
    if (!mounted) return;
    Navigator.pop(context);
  }

  TextEditingController privateSeed = TextEditingController();

  bool showAccountInfoTooltip = false;
  bool showSeedInfoTooltip = false;
  bool isLoading = false;

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
                  Expanded(
                    child: widget.isWatchOnly
                        ? getWatchOnlyScrollView() // Use the watch-only UI
                        : getScrollView(), // Use the old form UI without watch-only snippet
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: getButtons())
                ]))));
  }
}
