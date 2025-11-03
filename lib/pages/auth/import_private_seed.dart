import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:qubic_wallet/components/scan_code_button.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/clipboard_helper.dart';
import 'package:qubic_wallet/helpers/global_snack_bar.dart';
import 'package:qubic_wallet/helpers/id_validators.dart';
import 'package:qubic_wallet/helpers/platform_helpers.dart';
import 'package:qubic_wallet/helpers/show_alert_dialog.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/models/app_error.dart';
import 'package:qubic_wallet/pages/auth/add_biometrics_password.dart';
import 'package:qubic_wallet/pages/auth/create_password.dart';
import 'package:qubic_wallet/resources/qubic_cmd.dart';
import 'package:qubic_wallet/resources/secure_storage.dart';
import 'package:qubic_wallet/services/qr_scanner_service.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/stores/settings_store.dart';
import 'package:qubic_wallet/styles/edge_insets.dart';
import 'package:qubic_wallet/styles/input_decorations.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

enum AuthFlow {
  biometric,
  password,
}

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
  AuthFlow authFlow = AuthFlow.password;

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

    // Using addPostFrameCallback to ensure localization is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final l10n = l10nOf(context);
      accountNameCtrl.text = l10n.importPrivateSeedDefaultAccountName;
    });

    auth.canCheckBiometrics.then((value) {
      setState(() {
        authFlow = value ? AuthFlow.biometric : AuthFlow.password;
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

  //Gets the loading indicator inside button
  Widget _getLoadingProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: SizedBox(
          width: 21,
          height: 21,
          child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Theme.of(context).colorScheme.inversePrimary)),
    );
  }

  List<Widget> getSeedForm() {
    final l10n = l10nOf(context);
    return [
      FormBuilderTextField(
        name: "accountName",
        controller: accountNameCtrl,
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(
              errorText: l10n.generalErrorRequiredField),
          FormBuilderValidators.minLength(3,
              errorText: l10n.generalErrorMinCharLength(3))
        ]),
        onSubmitted: (String? a) async {
          await handleProceed();
        },
        enabled: !isLoading,
        obscureText: false,
        enableSuggestions: false,
        autocorrect: false,
        autofillHints: null,
        style: TextStyles.inputBoxSmallStyle,
        decoration: ThemeInputDecorations.normalInputbox
            .copyWith(hintText: l10n.addAccountLabelAccountName),
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
          FormBuilderValidators.required(
              errorText: l10n.generalErrorRequiredField),
          CustomFormFieldValidators.isSeed(context: context),
          CustomFormFieldValidators.isPublicIdAvailable(
              context: context, currentQubicIDs: appStore.currentQubicIDs)
        ]),
        onSubmitted: (value) async {
          await handleProceed();
        },
        onChanged: (value) async {
          var v = CustomFormFieldValidators.isSeed(context: context);
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
              if (e is AppError && e.type == ErrorType.tamperedWallet) {
                if (!mounted) return;
                showTamperedWalletAlert(context);
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
            hintText: l10n.addAccountLabelPrivateSeed,
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
                            ClipboardHelper.copyToClipboard(
                                _formKey
                                    .currentState?.instantValue["privateSeed"],
                                context);
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
        // Wait for the current frame to complete before proceeding
        await Future.delayed(Duration.zero);
        if (!mounted) return;
        if (authFlow == AuthFlow.biometric) {
          // Device supports biometric authentication
          // Show biometrics setup panel since device supports and requires biometric authentication
          pushScreen(
            context,
            screen: AddBiometricsPassword(onAddedBiometrics: (bool eb) async {
              enabledBiometrics = eb;

              await doCreateWallet();
            }),
            withNavBar: false,
            pageTransitionAnimation: PageTransitionAnimation.cupertino,
          );
        } else {
          await doCreateWallet();
        }
      }),
      withNavBar: false,
      pageTransitionAnimation: PageTransitionAnimation.cupertino,
    );
  }

  Future<void> doCreateWallet() async {
    final l10n = l10nOf(context);

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
      } catch (e) {
        if (!mounted) return;
        showAlertDialog(
            context, l10n.generalErrorContactingQubicNetwork, e.toString());
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
        if (!mounted) return;
        showAlertDialog(
            context, l10n.signUpErrorStoringBiometricInfo, e.toString());
      }

      appStore.checkWalletIsInitialized();
      settingsStore.setBiometrics(enabledBiometrics);
      if (!mounted) return;
      context.goNamed("mainScreen");
      _globalSnackbar
          .show(l10n.generalSnackBarMessageWalletImportedSuccessfully);
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget getGeneratedPublicId() {
    final l10n = l10nOf(context);

    if (generatedPublicId == null) {
      return Container();
    }
    return Column(
      children: [
        ThemedControls.spacerVerticalNormal(),
        Text(l10n.generalLabeQubicAddressAndPublicID,
            style: TextStyles.secondaryText),
        ThemedControls.spacerVerticalSmall(),
        Text(generatedPublicId!, style: TextStyles.inputBoxSmallStyle),
      ],
    );
  }

  List<Widget> getButtons() {
    final l10n = l10nOf(context);
    return [
      Expanded(
          child: ThemedControls.primaryButtonBigWithChild(
              onPressed: () async {
                await handleProceed();
              },
              child: isLoading
                  ? _getLoadingProgressIndicator()
                  : Padding(
                      padding:
                          const EdgeInsets.all(ThemePaddings.smallPadding + 3),
                      child: Text(l10n.generalButtonProceed,
                          textAlign: TextAlign.center,
                          style: TextStyles.primaryButtonText),
                    )))
    ];
  }

  //Gets the container scroll view
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
                  headerText: l10n.importWalletLabelFromPrivateSeed,
                  subheaderText: ""),
              Text(l10n.importPrivateSeedSubHeader,
                  style: TextStyles.secondaryText),
              ThemedControls.spacerVerticalNormal(),
              FormBuilder(
                  key: _formKey, child: Column(children: getSeedForm())),
              if (isMobile)
                ScanCodeButton(onPressed: () {
                  getIt<QrScannerService>().scanAndSetSeed(
                    context: context,
                    controller: privateSeedCtrl,
                  );
                }),
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
            body: SafeArea(
              child: Padding(
                padding: ThemeEdgeInsets.pageInsets,
                child: Column(children: [
                  Expanded(child: getScrollView()),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: getButtons())
                ]),
              ),
            )));
  }
}
