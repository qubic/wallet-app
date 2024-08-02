import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qubic_wallet/components/copyable_text.dart';
import 'package:qubic_wallet/components/gradient_foreground.dart';
import 'package:qubic_wallet/components/toggleable_qr_code.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/copy_to_clipboard.dart';
import 'package:qubic_wallet/helpers/global_snack_bar.dart';
import 'package:qubic_wallet/helpers/id_validators.dart';
import 'package:qubic_wallet/helpers/platform_helpers.dart';
import 'package:qubic_wallet/helpers/show_alert_dialog.dart';
import 'package:qubic_wallet/models/qubic_list_vm.dart';
import 'package:qubic_wallet/pages/auth/add_biometrics_password.dart';
import 'package:qubic_wallet/pages/auth/create_password.dart';
import 'package:qubic_wallet/pages/auth/create_password_sheet.dart';
import 'package:qubic_wallet/resources/qubic_cmd.dart';
import 'package:qubic_wallet/resources/qubic_li.dart';
import 'package:qubic_wallet/resources/secure_storage.dart';

import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/stores/settings_store.dart';
import 'package:qubic_wallet/styles/edgeInsets.dart';
import 'package:qubic_wallet/styles/inputDecorations.dart';
import 'package:qubic_wallet/styles/textStyles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_platform/universal_platform.dart';

class ImportPrivateSeed extends StatefulWidget {
  const ImportPrivateSeed({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ImportPrivateSeedState createState() => _ImportPrivateSeedState();
}

class _ImportPrivateSeedState extends State<ImportPrivateSeed> {
  bool isLoading = false; //Is the form loading

  final ApplicationStore appStore = getIt<ApplicationStore>();
  final SecureStorage secureStorage = getIt<SecureStorage>();
  final SettingsStore settingsStore = getIt<SettingsStore>();

  final _formKey = GlobalKey<FormBuilderState>();
  final GlobalSnackBar _globalSnackbar = getIt<GlobalSnackBar>();
  final QubicCmd qubicCmd = getIt<QubicCmd>();

  String? generatedPublicId;
  String enteredPassword = "";

  TextEditingController privateSeedCtrl = TextEditingController();
  TextEditingController accountNameCtrl = TextEditingController();

  bool detected = false; //Throttling QR code detection
  bool generatingId = false; //True if the public id is being generated

  int totalSteps = 1; //1 for no biometrics, 2 for biometrics

  //Variable for local authentication
  final LocalAuthentication auth = LocalAuthentication();
  bool? canCheckBiometrics; //If true, the device has biometrics
  List<BiometricType>? availableBiometrics; //Is empty, no biometric is enrolled
  bool? canUseBiometrics = false; //Are biometrics available in this device?
  bool enabledBiometrics =
      false; //Has the user enabled biometrics when signing up?

  @override
  void initState() {
    super.initState();
    accountNameCtrl.text = "Account 1";
    auth.canCheckBiometrics.then((value) {
      setState(() {
        totalSteps = 2;
        canCheckBiometrics = value;
      });

      if (value == true) {
        auth.getAvailableBiometrics().then((value) {
          setState(() {
            availableBiometrics = value;
            canUseBiometrics = value.isNotEmpty;
          });
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void showQRScanner() {
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
                    var validator = CustomFormFieldValidators.isSeed();
                    if (validator(barcode.rawValue) == null) {
                      privateSeedCtrl.text = barcode.rawValue!;
                      foundSuccess = true;
                    }
                  }

                  if (foundSuccess) {
                    if (!detected) {
                      Navigator.pop(context);

                      _globalSnackbar.show("Successfully scanned QR Code");
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
                    child: const Padding(
                        padding: EdgeInsets.all(ThemePaddings.normalPadding),
                        child: Text(
                            "Please point the camera to a QR Code containing the private seed",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center))))
          ]);
        });
  }

  List<Widget> getSeedForm() {
    return [
      FormBuilderTextField(
        name: "accountName",
        controller: accountNameCtrl,
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(
              errorText: "Please fill in an account name"),
          FormBuilderValidators.minLength(3,
              errorText: "Account names  must be at least 3 characters long")
        ]),
        onSubmitted: (String? a) async {
          await handleProceed();
        },
        decoration: ThemeInputDecorations.bigInputbox.copyWith(
          contentPadding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: ThemeInputDecorations.bigInputbox.contentPadding!.vertical /
                  2,
              bottom:
                  ThemeInputDecorations.bigInputbox.contentPadding!.vertical /
                      2),
          hintText: "Account name",
        ),
        enabled: !isLoading,
        obscureText: false,
        autocorrect: false,
        autofillHints: null,
      ),
      ThemedControls.spacerVerticalSmall(),
      FormBuilderTextField(
        name: "privateSeed",
        autofocus: true,
        readOnly: isLoading,
        controller: privateSeedCtrl,
        enableSuggestions: false,
        keyboardType: TextInputType.visiblePassword,
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(errorText: "Please fill in a seed"),
          CustomFormFieldValidators.isSeed(),
          CustomFormFieldValidators.isPublicIdAvailable(
              currentQubicIDs: appStore.currentQubicIDs)
        ]),
        onSubmitted: (value) async {
          await handleProceed();
        },
        onChanged: (value) async {
          var v = CustomFormFieldValidators.isSeed();
          if (value != null && value.trim().isNotEmpty && v(value) == null) {
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
                print("CRITICAL");

                showAlertDialog(context, "TAMPERED WALLET DETECTED",
                    "THE WALLET YOU ARE CURRENTLY USING IS TAMPERED.\n\nINSTALL AN OFFICIAL VERSION FROM QUBIC-HUB.COM OR RISK LOSS OF FUNDS");
              }
              setState(() {
                privateSeedCtrl.value = TextEditingValue.empty;
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
        decoration: ThemeInputDecorations.normalMultiLineInputbox.copyWith(
            hintText: "Private seed",
            suffixIcon: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                      padding: const EdgeInsets.only(
                          right: ThemePaddings.smallPadding),
                      child: IconButton(
                          onPressed: () async {
                            if ((_formKey.currentState
                                    ?.instantValue["privateSeed"] as String)
                                .trim()
                                .isEmpty) {
                              return;
                            }
                            copyToClipboard(_formKey
                                .currentState?.instantValue["privateSeed"]);
                          },
                          icon: LightThemeColors.shouldInvertIcon
                              ? ThemedControls.invertedColors(
                                  child: Image.asset(
                                      "assets/images/Group 2400.png"))
                              : Image.asset("assets/images/Group 2400.png")))
                ])),
        autocorrect: false,
        autofillHints: null,
      ),
    ];
  }

  //Handles the proceed button to go to next step (add password) and then to biometrics if needed
  Future<void> handleProceed() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    pushScreen(
      context,
      screen: CreatePassword(onPasswordCreated: (String password) async {
        enteredPassword = password;

        setState(() {
          isLoading = false;
        });
        if (enteredPassword.isEmpty) {
          return;
        }
        // VERY UGLY HACK. TODO: FIX THIS
        var timer = Timer(Duration(milliseconds: 300), () async {
          if (totalSteps == 2) {
            //Device has biometrics enabled, so show biometrics panel
            pushScreen(
              context,
              screen: AddBiometricsPassword(
                  onAddedBiometrics: (bool enabledBiometrics) async {
                enabledBiometrics = enabledBiometrics;

                await doCreateWallet();
              }),
              withNavBar: false, // OPTIONAL VALUE. True by default.
              pageTransitionAnimation: PageTransitionAnimation.cupertino,
            );
          } else {
            await doCreateWallet();
          }
        });
      }),
      withNavBar: false, // OPTIONAL VALUE. True by default.
      pageTransitionAnimation: PageTransitionAnimation.cupertino,
    );
  }

  Future<void> doCreateWallet() async {
    if (!context.mounted) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    if (await appStore.signUp(enteredPassword)) {
      try {
        await appStore.checkWalletIsInitialized();
        await appStore.addId(
            accountNameCtrl.text, generatedPublicId!, privateSeedCtrl.text);
        await getIt<QubicLi>().authenticate();
      } catch (e) {
        showAlertDialog(
            context, "Error contacting Qubic Network", e.toString());
        setState(() {
          isLoading = false;
        });
      }
      try {
        await settingsStore.loadSettings();
        await settingsStore.setBiometrics(enabledBiometrics);
        setState(() {
          isLoading = false;
        });
      } catch (e) {
        showAlertDialog(context, "Error storing biometric info", e.toString());
      }

      appStore.checkWalletIsInitialized();
      settingsStore.setBiometrics(enabledBiometrics);
      context.goNamed("mainScreen");
      _globalSnackbar.show("Wallet imported successfully");
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget getGeneratedPublicId() {
    if (generatedPublicId == null) {
      return Container();
    }
    return Column(
      children: [
        ThemedControls.spacerVerticalNormal(),
        Text("Your seed ", style: TextStyles.secondaryText),
        ThemedControls.spacerVerticalSmall(),
        Text(generatedPublicId!, style: TextStyles.inputBoxSmallStyle),
      ],
    );
  }

  List<Widget> getButtons() {
    return [
      Expanded(
          child: ThemedControls.primaryButtonBigWithChild(
              onPressed: () async {
                await handleProceed();
              },
              child: Padding(
                padding: const EdgeInsets.all(ThemePaddings.smallPadding + 3),
                child: Text("Proceed",
                    textAlign: TextAlign.center,
                    style: TextStyles.primaryButtonText),
              )))
    ];
  }

  //Gets the container scroll view
  Widget getScrollView() {
    return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Row(children: [
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ThemedControls.pageHeader(
                  headerText: "Enter Private Seed Phrase", subheaderText: ""),
              Text(
                  "Enter the 55 character seed phrase that you have saved when creating your account.",
                  style: TextStyles.secondaryText),
              ThemedControls.spacerVerticalHuge(),
              FormBuilder(
                  key: _formKey, child: Column(children: getSeedForm())),
              if (isMobile)
                Align(
                    alignment: Alignment.topLeft,
                    child: ThemedControls.primaryButtonNormal(
                        onPressed: () {
                          showQRScanner();
                        },
                        text: "Use QR Code",
                        icon: !LightThemeColors.shouldInvertIcon
                            ? ThemedControls.invertedColors(
                                child:
                                    Image.asset("assets/images/Group 2294.png"))
                            : Image.asset("assets/images/Group 2294.png"))),
              getGeneratedPublicId(),
              ThemedControls.spacerVerticalBig(),
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
            body: Padding(
              padding: ThemeEdgeInsets.pageInsets,
              child: Column(children: [
                Expanded(child: getScrollView()),
                Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: getButtons())
              ]),
            )));
  }
}
