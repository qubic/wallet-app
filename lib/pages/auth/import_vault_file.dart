import 'dart:async';
import 'dart:io' as io;
import 'dart:io';
import 'package:path/path.dart' as path;
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:qubic_wallet/models/qubic_id.dart';
import 'package:qubic_wallet/models/qubic_import_vault_seed.dart';
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

class ImportVaultFile extends StatefulWidget {
  const ImportVaultFile({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ImportVaultFileState createState() => _ImportVaultFileState();
}

class _ImportVaultFileState extends State<ImportVaultFile> {
  bool isLoading = false; //Is the form loading

  final ApplicationStore appStore = getIt<ApplicationStore>();
  final SecureStorage secureStorage = getIt<SecureStorage>();
  final SettingsStore settingsStore = getIt<SettingsStore>();

  final _formKey = GlobalKey<FormBuilderState>();
  final GlobalSnackBar _globalSnackbar = getIt<GlobalSnackBar>();
  final QubicCmd qubicCmd = getIt<QubicCmd>();

  String vaultPassword = ""; //Password to import the vault file
  bool obscuringTextPass = true; //Hide password text

  bool detected = false; //Throttling QR code detection
  bool generatingId = false; //True if the public id is being generated

  String? selectedPath; //The selected file path (android and desktop)
  Uint8List? selectedFileBytes; //The selected file bytes (android and desktop)
  bool selectedPathError = false; //Error in selected path
  String? importError = "";

  List<QubicImportVaultSeed>? importedSeeds; //Imported seeds

  //Variable for local authentication
  final LocalAuthentication auth = LocalAuthentication();
  bool? canCheckBiometrics; //If true, the device has biometrics
  List<BiometricType>? availableBiometrics; //Is empty, no biometric is enrolled
  bool? canUseBiometrics = false; //Are biometrics available in this device?
  bool enabledBiometrics =
      false; //Has the user enabled biometrics when signing up?
  int totalSteps = 0;

  @override
  void initState() {
    super.initState();
    auth.canCheckBiometrics.then((value) {
      setState(() {
        totalSteps = 1;
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

  Widget getSelectedPathSelector() {
    return Container(
        decoration: BoxDecoration(
            color: LightThemeColors.primary.withOpacity(0.02),
            border: Border(
                top: BorderSide(
                    color: LightThemeColors.primary.withOpacity(0.03),
                    width: 1.0),
                left: BorderSide(
                    color: LightThemeColors.primary.withOpacity(0.03),
                    width: 1.0),
                right: BorderSide(
                    color: LightThemeColors.primary.withOpacity(0.03),
                    width: 1.0),
                bottom: BorderSide(
                    color: LightThemeColors.primary.withOpacity(0.03),
                    width: 1.0)),
            borderRadius: BorderRadius.circular(8.0)),
        child: Padding(
            padding: const EdgeInsets.all(ThemePaddings.bigPadding - 5),
            child: Flex(
                direction: Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/images/selected-file.png'),
                  ThemedControls.spacerHorizontalNormal(),
                  Expanded(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(path.basename(selectedPath!),
                              style: TextStyles.textBold),
                        ]),
                  ),
                  ThemedControls.spacerHorizontalNormal(),
                  IconButton(
                      onPressed: () {
                        if (isLoading) {
                          return;
                        }
                        setState(() {
                          selectedPath = null;
                          selectedFileBytes = null;
                          selectedPathError = false;
                          importedSeeds = null;
                          importError = null;
                        });
                      },
                      icon: Image.asset('assets/images/cancel.png'))
                ])));
  }

  Widget getEmptyPathSelector() {
    return ThemedControls.darkButtonBigWithChild(
        error: selectedPathError,
        onPressed: () async {
          FilePickerResult? result = await FilePicker.platform.pickFiles(
              dialogTitle: 'Please select a vault file to continue:',
              withData: isMobile,
              //allowedExtensions: ['qubic-vault'],
              lockParentWindow: true);
          if (result == null) {
            // User canceled the picker
            return;
          }
          setState(() {
            selectedPath = result.files[0].path;
            selectedFileBytes = result.files[0].bytes;
            selectedPathError = false;
            importedSeeds = null;
            importError = null;
          });
        },
        child: Padding(
            padding: const EdgeInsets.all(ThemePaddings.normalPadding),
            child: Flex(
                direction: Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.download, size: 24),
                  ThemedControls.spacerHorizontalNormal(),
                  Expanded(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Select file path", style: TextStyles.textBold),
                          ThemedControls.spacerVerticalSmall(),
                          Container(
                              child: Text(
                                  "Browse your device to select a location to save the vault file",
                                  style: TextStyles.secondaryText))
                        ]),
                  )
                ])));
  }

  //Handles the proceed button to go to next step (add password) and then to biometrics if needed
  Future<void> handleProceed() async {
    if (context.mounted == false) {
      return;
    }
    bool result = await _validateForProceed();
    if (!result) {
      return;
    }

    if (importedSeeds!.length > 15) {
      showAlertDialog(context, "Vault file contains more than 15 seeds",
          "The vault file you selected contains more than 15 seeds. Importing will continue, but you will not be able to view balances or send funds until you remove some seeds so that the total is 15 or less.",
          primaryButtonFunction: () async {
        await _runCreateWalletSteps();
      }, primaryButtonLabel: "OK");
      return;
    }

    await _runCreateWalletSteps();
  }

  Future<void> _runCreateWalletSteps() async {
    if (totalSteps == 1) {
      pushScreen(
        context,
        screen: AddBiometricsPassword(onAddedBiometrics: (bool eb) async {
          enabledBiometrics = eb;

          await doCreateWallet();
        }),
        withNavBar: false, // OPTIONAL VALUE. True by default.
        pageTransitionAnimation: PageTransitionAnimation.cupertino,
      );
    } else {
      await doCreateWallet();
    }
  }

  Future<bool> _validateForProceed() async {
    if (selectedPath == null) {
      setState(() {
        selectedPathError = true;
      });
      return false;
    }

    if (!_formKey.currentState!.validate()) {
      return false;
    }

    try {
      setState(() {
        isLoading = true;
      });
      importedSeeds = await qubicCmd.importVaultFile(
          vaultPassword, selectedPath, selectedFileBytes);
    } catch (e) {
      setState(() {
        importError = e.toString().replaceAll("Exception: ", "");
      });
      setState(() {
        isLoading = false;
      });
      return false;
    }

    if (importedSeeds == null) {
      setState(() {
        importError = "No seeds found in the vault file";
        isLoading = false;
      });
      return false;
    }

    if (importedSeeds!.isEmpty) {
      setState(() {
        importError =
            "Vault file contains no seeds (please note that watch only seeds are currently not supported and are ignored)";
        isLoading = false;
      });
      return false;
    }

    return true;
  }

  Future<void> doCreateWallet() async {
    if (!context.mounted) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    if (await appStore.signUp(vaultPassword)) {
      try {
        await appStore.checkWalletIsInitialized();
        List<QubicId> ids = [];
        for (var importedSeed in importedSeeds!) {
          ids.add(QubicId(importedSeed.getSeed(), importedSeed.getPublicId(),
              importedSeed.getAlias(), 0));
        }
        await appStore.addManyIds(ids);

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

  Widget getPasswordForm() {
    return FormBuilder(
        key: _formKey,
        child: Column(children: [
          FormBuilderTextField(
            name: "password",
            autofocus: true,
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(
                  errorText: "Please fill in the vault file password"),
              FormBuilderValidators.minLength(8,
                  errorText: "Password must be at least 8 characters long")
            ]),
            onSubmitted: (value) => handleProceed(),
            onChanged: (value) => vaultPassword = value ?? "",
            decoration: ThemeInputDecorations.bigInputbox.copyWith(
              hintText: "Enter vault password",
              suffixIcon: Padding(
                padding:
                    const EdgeInsets.only(right: ThemePaddings.smallPadding),
                child: IconButton(
                  icon: obscuringTextPass
                      ? Image.asset("assets/images/eye-open.png")
                      : Image.asset("assets/images/eye-closed.png"),
                  onPressed: () {
                    setState(() {
                      obscuringTextPass = !obscuringTextPass;
                    });
                  },
                ),
              ),
            ),
            enabled: !isLoading,
            obscureText: obscuringTextPass,
            autocorrect: false,
            autofillHints: null,
          )
        ]));
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
                  headerText: "Select Vault File", subheaderText: ""),
              Text("Choose a file with .qubic-vault extension",
                  style: TextStyles.secondaryText),
              ThemedControls.spacerVerticalHuge(),
              if (importError != null) ThemedControls.errorLabel(importError!),
              if (importError != null) ThemedControls.spacerVerticalSmall(),
              selectedPath == null
                  ? getEmptyPathSelector()
                  : getSelectedPathSelector(),
              ThemedControls.spacerVerticalNormal(),
              selectedPath != null ? getPasswordForm() : Container()
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
