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
import 'package:qubic_wallet/styles/edgeInsets.dart';
import 'package:qubic_wallet/styles/inputDecorations.dart';
import 'package:qubic_wallet/styles/textStyles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:qubic_wallet/timed_controller.dart';
import 'package:qubic_wallet/l10n/l10n.dart';

class AddAccount extends StatefulWidget {
  const AddAccount({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddAccountState createState() => _AddAccountState();
}

class _AddAccountState extends State<AddAccount> {
  final _formKey = GlobalKey<FormBuilderState>();
  final ApplicationStore appStore = getIt<ApplicationStore>();
  final QubicCmd qubicCmd = getIt<QubicCmd>();
  final GlobalSnackBar _globalSnackBar = getIt<GlobalSnackBar>();

  bool detected = false;
  bool generatingId = false;

  String? generatedPublicId;
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
                  key: _formKey,
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
                              var newId = await qubicCmd.getPublicIdFromSeed(
                                  value, context);
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
                                    l10n.addAccountErrorTamperedWalletMessage);
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
                                                if ((_formKey.currentState
                                                                ?.instantValue[
                                                            "privateSeed"]
                                                        as String)
                                                    .trim()
                                                    .isEmpty) {
                                                  return;
                                                }
                                                copyToClipboard(
                                                    _formKey.currentState
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
                      ThemedControls.spacerVerticalNormal(),
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
                                            l10n
                                                .addAccountHintAddressInvalidPrivateSeed,
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
              onPressed: saveIdHandler,
              child: Padding(
                  padding: const EdgeInsets.all(ThemePaddings.smallPadding + 3),
                  child: Text(l10n.generalButtonSave,
                      textAlign: TextAlign.center,
                      style: TextStyles.primaryButtonText))))
    ];
  }

  void saveIdHandler() async {
    final l10n = l10nOf(context);
    _formKey.currentState?.validate();
    if (generatingId) {
      return;
    }
    if (!_formKey.currentState!.isValid) {
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
      _formKey.currentState?.instantValue["accountName"] as String,
      generatedPublicId!,
      _formKey.currentState?.instantValue["privateSeed"] as String,
    );

    setState(() {
      isLoading = false;
    });
    Navigator.pop(context);
  }

  TextEditingController privateSeed = TextEditingController();

  bool showAccountInfoTooltip = false;
  bool showSeedInfoTooltip = false;
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          return Future.value(!isLoading);
        },
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
