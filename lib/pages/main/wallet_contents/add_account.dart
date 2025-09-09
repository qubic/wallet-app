import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:qubic_wallet/components/private_seed_warning.dart';
import 'package:qubic_wallet/components/scan_code_button.dart';
import 'package:qubic_wallet/services/qr_scanner_service.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/clipboard_helper.dart';
import 'package:qubic_wallet/helpers/global_snack_bar.dart';
import 'package:qubic_wallet/helpers/id_validators.dart';
import 'package:qubic_wallet/helpers/platform_helpers.dart';
import 'package:qubic_wallet/helpers/random.dart';
import 'package:qubic_wallet/helpers/show_alert_dialog.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/models/app_error.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/add_account_warning_sheet.dart';
import 'package:qubic_wallet/resources/qubic_cmd.dart';
import 'package:qubic_wallet/services/screenshot_service.dart';
import 'package:qubic_wallet/services/wallet_connect_service.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/styles/edge_insets.dart';
import 'package:qubic_wallet/styles/input_decorations.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:qubic_wallet/timed_controller.dart';

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
  final WalletConnectService walletConnectService =
      getIt<WalletConnectService>();
  final screenshotService = getIt<ScreenshotService>();
  final TextEditingController privateSeed = TextEditingController();
  final TextEditingController publicId = TextEditingController();
  final TextEditingController accountName = TextEditingController();

  bool firstOpen = true;
  bool showAccountInfoTooltip = false;
  bool showSeedInfoTooltip = false;
  bool isLoading = false;
  bool detected = false;
  bool generatingId = false;
  String? generatedPublicId;
  String? watchOnlyId;

  @override
  void didChangeDependencies() {
    if (firstOpen) {
      accountName.text = l10nOf(context)
          .generalLabelAccount(appStore.currentQubicIDs.length + 1);
      if (widget.type == AddAccountType.createAccount) {
        generatePrivateSeed();
        onPrivateSeedChanged();
      }
      if (widget.type != AddAccountType.watchOnly) {
        screenshotService.disableScreenshot();
        screenshotService.startListening(onScreenshot: (e) {
          if (l10nWrapper.l10n != null && e.wasScreenshotTaken == true) {
            _globalSnackBar.show(l10nWrapper.l10n!.blockedScreenshotWarning);
          }
        });
      }
      firstOpen = false;
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    if (widget.type != AddAccountType.watchOnly) {
      screenshotService.enableScreenshot();
      screenshotService.stopListening();
    }
    super.dispose();
  }

  onPrivateSeedChanged() async {
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
        if (e is AppError && e.type == ErrorType.tamperedWallet) {
          if (!mounted) return;
          showTamperedWalletAlert(context);
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

  Widget getCreateAccountView() {
    final l10n = l10nOf(context);
    return getScrollView(
        title: l10n.addAccountHeader,
        isPrivateSeedReadOnly: true,
        hasPrivateSeedRandomButton: false,
        hasQrCodeButton: false,
        hasPrivateSeedTip: true,
        hasPrivateSeedPasteButton: false);
  }

  Widget getImportAccountView() {
    final l10n = l10nOf(context);
    return getScrollView(
      title: l10n.importWalletLabelFromPrivateSeed,
      isPrivateSeedReadOnly: false,
      hasPrivateSeedRandomButton: false,
      hasQrCodeButton: true,
      hasPrivateSeedTip: false,
      hasPrivateSeedPasteButton: true,
    );
  }

  Widget getScrollView(
      {required String title,
      required bool isPrivateSeedReadOnly,
      required bool hasPrivateSeedRandomButton,
      required bool hasQrCodeButton,
      required bool hasPrivateSeedPasteButton,
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
                              namesList: appStore.qubicIDsNames,
                              context: context)
                        ]),
                        controller: accountName,
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
                        const Spacer(),
                        if (hasPrivateSeedPasteButton)
                          ThemedControls.transparentButtonSmall(
                              onPressed: () async {
                                if (privateSeed.text.isNotEmpty == true) {
                                  privateSeed.clear();
                                } else {
                                  final clipboardData = await Clipboard.getData(
                                      Clipboard.kTextPlain);
                                  if (clipboardData != null) {
                                    privateSeed.text = clipboardData.text!;
                                  }
                                }
                              },
                              text: privateSeed.text.isNotEmpty == true
                                  ? l10n.generalButtonClear
                                  : l10n.generalButtonPaste),
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
                      if (hasPrivateSeedTip) ...[
                        ThemedControls.spacerVerticalMini(),
                        PrivateSeedWarning(
                          title: l10n.revealSeedWarningTitle,
                          description:
                              l10n.addAccountHeaderKeepPrivateSeedSecret,
                        ),
                      ],
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
                                                ClipboardHelper.copyToClipboard(
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
                        ScanCodeButton(onPressed: () {
                          getIt<QrScannerService>().scanAndSetSeed(
                            context: context,
                            controller: privateSeed,
                          );
                        }),

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
                                    ClipboardHelper.copyToClipboard(
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
                      controller: accountName,
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(
                            errorText: l10n.generalErrorRequiredField),
                        CustomFormFieldValidators.isNameAvailable(
                            namesList: appStore.qubicIDsNames, context: context)
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
                      const Spacer(),
                      ThemedControls.transparentButtonSmall(
                          onPressed: () async {
                            if (watchOnlyId?.isNotEmpty == true) {
                              publicId.clear();
                            } else {
                              final clipboardData =
                                  await Clipboard.getData(Clipboard.kTextPlain);
                              if (clipboardData != null) {
                                publicId.text = clipboardData.text!;
                              }
                            }
                          },
                          text: watchOnlyId?.isNotEmpty == true
                              ? l10n.generalButtonClear
                              : l10n.generalButtonPaste),
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
                      ScanCodeButton(onPressed: () {
                        getIt<QrScannerService>().scanAndSetPublicId(
                          context: context,
                          controller: publicId,
                        );
                      }),
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

    walletConnectService.triggerAccountsChangedEvent();
    getIt<WalletConnectService>().registerAccount(generatedPublicId!);

    if (mounted) {
      Navigator.pop(context);
    }
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
