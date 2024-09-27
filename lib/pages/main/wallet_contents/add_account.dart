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

enum AddAccountType { createAccount, watchOnly, importPrivateSeed }

class AddAccount extends StatefulWidget {
  final AddAccountType type;

  const AddAccount({super.key, required this.type});

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
  void didChangeDependencies() {
    if (widget.type == AddAccountType.createAccount) {
      generatePrivateSeed();
      onPrivateSeedChanged();
    }
    super.didChangeDependencies();
  }

  onPrivateSeedChanged() async {
    final l10n = l10nOf(context);
    final value = privateSeed.value.text;
    var v = CustomFormFieldValidators.isSeed(context: context);
    if (value.trim().isNotEmpty && v(value) == null) {
      try {
        setState(() {
          generatingId = true;
        });
        var newId = await qubicCmd.getPublicIdFromSeed(value);
        setState(() {
          generatedPublicId = newId;
          generatingId = false;
        });
      } catch (e) {
        if (e.toString().startsWith("Exception: CRITICAL:")) {
          showAlertDialog(
              context,
              l10n.addAccountErrorTamperedWalletTitle,
              isAndroid
                  ? l10n.addAccountErrorTamperedAndroidWalletMessage
                  : isIOS
                      ? l10n.addAccountErrorTamperediOSWalletMessage
                      : l10n.addAccountErrorTamperedWalletMessage);
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
  }

  generatePrivateSeed() {
    if (generatingId) {
      return;
    }
    var seed = getRandomSeed();
    privateSeed.text = seed;
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

  void showWatchOnlyQRScanner() {
    final l10n = l10nOf(context);

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
                    var value = publicId.text;
                    value = barcode.rawValue!
                        .replaceAll("https://wallet.qubic.org/payment/", "");
                    var validator =
                        CustomFormFieldValidators.isPublicID(context: context);
                    if (validator(value) == null) {
                      if (foundSuccess == true) {
                        break;
                      }
                      publicId.text = value;
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

  Widget getCreateAccountView() {
    final l10n = l10nOf(context);
    return getScrollView(
        title: l10n.addAccountHeader,
        isPrivateSeedReadOnly: true,
        hasPrivateSeedRandomButton: true,
        hasQrCodeButton: false,
        hasPrivateSeedTip: true);
  }

  Widget getImportAccountView() {
    final l10n = l10nOf(context);
    return getScrollView(
        title: l10n.importWalletLabelFromPrivateSeed,
        isPrivateSeedReadOnly: false,
        hasPrivateSeedRandomButton: false,
        hasQrCodeButton: true,
        hasPrivateSeedTip: false);
  }

  Widget getScrollView(
      {required String title,
      required bool isPrivateSeedReadOnly,
      required bool hasPrivateSeedRandomButton,
      required bool hasQrCodeButton,
      required bool hasPrivateSeedTip}) {
    final l10n = l10nOf(context);
    return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Row(children: [
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ThemedControls.pageHeader(headerText: title),
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
              ThemedControls.spacerVerticalSmall(),
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
                        if (hasPrivateSeedRandomButton)
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
                      // Spacer instead of the default button padding
                      if (!hasPrivateSeedRandomButton)
                        ThemedControls.spacerVerticalSmall(),
                      FormBuilderTextField(
                        name: "privateSeed",
                        readOnly: isPrivateSeedReadOnly || isLoading,
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
                        onChanged: (value) {
                          onPrivateSeedChanged();
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
                      if (isMobile && hasQrCodeButton)
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
                      if (hasPrivateSeedTip) ...[
                        ThemedControls.spacerVerticalNormal(),
                        Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                                l10n.addAccountHeaderKeepPrivateSeedSecret,
                                style: TextStyles.assetSecondaryTextLabel)),
                      ],
                      ThemedControls.spacerVerticalHuge(),
                      Align(
                          alignment: Alignment.topLeft,
                          child: Text(l10n.generalLabeQubicAddressAndPublicID,
                              style: TextStyles.labelTextNormal)),
                      ThemedControls.spacerVerticalMini(),
                      Builder(builder: (context) {
                        return ThemedControls.card(
                            child: Flex(direction: Axis.horizontal, children: [
                          Flexible(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                ThemedControls.spacerVerticalMini(),
                                generatedPublicId == null
                                    ? privateSeed.value.text.isEmpty
                                        ? Text(
                                            l10n
                                                .addAccountHintAddressNoPrivateSeed,
                                            textAlign: TextAlign.right,
                                            style: TextStyles.textNormal
                                                .copyWith(
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontStyle:
                                                        FontStyle.italic))
                                        : Text(
                                            !generatingId
                                                ? l10n
                                                    .addAccountHintAddressInvalidPrivateSeed
                                                : l10n.generalLabelLoading,
                                            style: TextStyles.textNormal
                                                .copyWith(
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontStyle:
                                                        FontStyle.italic))
                                    : SelectableText(generatedPublicId!,
                                        style: TextStyles.textNormal)
                              ])),
                          generatedPublicId == null
                              ? Container()
                              : IconButton(
                                  onPressed: () async {
                                    if (generatedPublicId == null) {
                                      return;
                                    }
                                    copyToClipboard(
                                        generatedPublicId!, context);
                                  },
                                  icon: LightThemeColors.shouldInvertIcon
                                      ? ThemedControls.invertedColors(
                                          child: Image.asset(
                                              "assets/images/Group 2400.png"))
                                      : Image.asset(
                                          "assets/images/Group 2400.png"))
                        ]));
                      })
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
              ThemedControls.pageHeader(
                  headerText: l10n.addAccountWatchOnlyPageTitle),
              ThemedControls.spacerVerticalSmall(),
              FormBuilder(
                key: _watchOnlyFormKey,
                child: Column(
                  children: [
                    Text(l10n.addAccountWatchOnlySubtitle),
                    ThemedControls.spacerVerticalHuge(),
                    // Account name & Tooltip
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
                              : Image.asset(
                                  "assets/images/question-active-16.png")),
                    ]),
                    ThemedControls.spacerVerticalSmall(),
                    // Account name form
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
                    ThemedControls.spacerVerticalHuge(),
                    // Qubic address and Tooltip
                    Row(children: [
                      Text(l10n.generalLabeQubicAddressAndPublicID,
                          style: TextStyles.labelTextNormal),
                      ThemedControls.spacerHorizontalSmall(),
                      Tooltip(
                          triggerMode: TooltipTriggerMode.tap,
                          showDuration: const Duration(seconds: 5),
                          message: l10n.addAccountWatchOnlyQubicAddressTooltip,
                          child: LightThemeColors.shouldInvertIcon
                              ? ThemedControls.invertedColors(
                                  child: Image.asset(
                                      "assets/images/question-active-16.png"))
                              : Image.asset(
                                  "assets/images/question-active-16.png")),
                    ]),
                    ThemedControls.spacerVerticalSmall(),
                    // Qubic Address form
                    FormBuilderTextField(
                      name: "publicAddress",
                      controller: publicId,
                      maxLength: 60,
                      maxLines: 2,
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
                      decoration: ThemeInputDecorations.normalInputbox.copyWith(
                          hintText: l10n.addAccountWatchOnlyHintQubicAddress),
                      autocorrect: false,
                      autofillHints: null,
                    ),
                    ThemedControls.spacerVerticalNormal(),
                    if (isMobile)
                      Align(
                          alignment: Alignment.topLeft,
                          child: ThemedControls.primaryButtonNormal(
                              onPressed: () {
                                showWatchOnlyQRScanner();
                              },
                              text: l10n.generalButtonUseQRCode,
                              icon: !LightThemeColors.shouldInvertIcon
                                  ? ThemedControls.invertedColors(
                                      child: Image.asset(
                                          "assets/images/Group 2294.png"))
                                  : Image.asset(
                                      "assets/images/Group 2294.png"))),
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
              onPressed: widget.type == AddAccountType.watchOnly
                  ? savePublicIdHandler
                  : saveIdHandler,
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

    String? publicId = _watchOnlyFormKey
        .currentState?.instantValue["publicAddress"] as String?;

    if (publicId == null || publicId.isEmpty) {
      _globalSnackBar.show(
          "Error! Please input your watch address. It should not be empty.");
      return;
    }

    try {
      // Verify the public ID
      bool isValid = await qubicCmd.verifyIdentity(publicId);

      if (!isValid) {
        // Show an error message if verification fails
        _globalSnackBar
            .showError(l10n.addAccountErrorVerifyIdentityWrongIdentity);
        return;
      }
    } catch (e) {
      // Handle errors during verification
      _globalSnackBar.showError(l10n.addAccountErrorVerifyIdentityError);
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
        '');

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
  TextEditingController publicId = TextEditingController();

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
                    child: widget.type == AddAccountType.watchOnly
                        ? getWatchOnlyScrollView() // Use the watch-only UI
                        : widget.type == AddAccountType.importPrivateSeed
                            ? getImportAccountView()
                            : getCreateAccountView(), // Use the old form UI without watch-only snippet
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: getButtons())
                ]))));
  }
}
