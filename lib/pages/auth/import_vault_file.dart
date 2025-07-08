import 'dart:async';
import 'dart:io';

// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/app_logger.dart';
import 'package:qubic_wallet/helpers/global_snack_bar.dart';
import 'package:qubic_wallet/helpers/platform_helpers.dart';
import 'package:qubic_wallet/helpers/show_alert_dialog.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/models/qubic_id.dart';
import 'package:qubic_wallet/models/qubic_import_vault_seed.dart';
import 'package:qubic_wallet/pages/auth/add_biometrics_password.dart';
import 'package:qubic_wallet/resources/qubic_cmd.dart';
import 'package:qubic_wallet/resources/secure_storage.dart';

import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/stores/settings_store.dart';
import 'package:qubic_wallet/styles/edge_insets.dart';
import 'package:qubic_wallet/styles/input_decorations.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

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
            color: LightThemeColors.primary.withValues(alpha: 0.02),
            border: Border(
                top: BorderSide(
                    color: LightThemeColors.primary.withValues(alpha: 0.03),
                    width: 1.0),
                left: BorderSide(
                    color: LightThemeColors.primary.withValues(alpha: 0.03),
                    width: 1.0),
                right: BorderSide(
                    color: LightThemeColors.primary.withValues(alpha: 0.03),
                    width: 1.0),
                bottom: BorderSide(
                    color: LightThemeColors.primary.withValues(alpha: 0.03),
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
    final l10n = l10nOf(context);

    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ThemedControls.darkButtonBigWithChild(
              error: selectedPathError,
              onPressed: () async {
                Directory? directory;
                try {
                  directory = await getDownloadsDirectory();
                } catch (e) {
                  appLogger
                      .e("Error getting application documents directory: $e");
                }
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                    dialogTitle: l10n.importVaultFilePickerLabel,
                    withData: isMobile || isWindows || isMacOS,
                    initialDirectory: directory?.path,
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
                                Text(l10n.generalLabelSelectFile,
                                    style: TextStyles.textBold),
                                ThemedControls.spacerVerticalSmall(),
                                Text(
                                    l10n.importVaultLabelSelectPathInstructions,
                                    style: TextStyles.secondaryText)
                              ]),
                        )
                      ]))),
          selectedPathError
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(ThemePaddings.bigPadding,
                      ThemePaddings.miniPadding, 0, 0),
                  child: Text(l10n.generalErrorFileRequired,
                      style: const TextStyle(
                          fontSize: ThemeFontSizes.errorLabel,
                          color: LightThemeColors.error)),
                )
              : Container()
        ]);
  }

  /// Handles the proceed button
  ///
  /// This function validates the form and imports the vault file
  /// If the number of accounts to be imported is more than 15, a dialog is shown to the user
  /// If the number of accounts to be imported is less than 15, the wallet is created
  Future<void> handleProceed() async {
    final l10n = l10nOf(context);

    bool result = await _validateForProceed();
    if (!result) {
      return;
    }

    int toBeImportedCount =
        importedSeeds!.where((element) => element.getSeed() != "").length;
    String messageTitle = "";
    String messageText = "";

    if (toBeImportedCount > 15) {
      // More than 15 accounts to be imported found
      messageTitle = l10n.importVaultDialogTitleTooManyAccounts;
      messageText = l10n.importVaultDialogMessageTooManyAccounts;
    }

    if ((messageTitle.isNotEmpty) && (messageText.isNotEmpty)) {
      if (context.mounted) {
        // ignore: use_build_context_synchronously
        showAlertDialog(context, messageTitle, messageText,
            primaryButtonFunction: () async {
          Navigator.of(context).pop();
          await _runCreateWalletSteps();
        }, primaryButtonLabel: l10n.generalButtonOK);
      }
      return;
    }

    await _runCreateWalletSteps();
  }

  /// Runs the create wallet steps
  /// Called by handleProceed.
  ///
  /// IF there's one step,  AddBiometricsPassword screen is loaded
  /// ELSE, doCreateWallet is called
  Future<void> _runCreateWalletSteps() async {
    if (totalSteps == 1) {
      setState(() {
        isLoading = false;
      });
      pushScreen(
        context,
        screen: AddBiometricsPassword(onAddedBiometrics: (bool eb) async {
          enabledBiometrics = eb;
          await _doCreateWallet();
        }),
        withNavBar: false, // OPTIONAL VALUE. True by default.
        pageTransitionAnimation: PageTransitionAnimation.cupertino,
      );
    } else {
      await _doCreateWallet();
    }
  }

  /// Validates the form and imports the vault file
  ///
  /// Called by handleProceed
  /// Returns true if input is ok, false if not
  Future<bool> _validateForProceed() async {
    final l10n = l10nOf(context);

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
      if (e.toString().startsWith("Exception: CRITICAL:")) {
        showTamperedWalletAlert(context);
        setState(() {
          isLoading = false;
        });
        return false;
      }
      setState(() {
        importError = e.toString().replaceAll("Exception: ", "");
      });
      setState(() {
        isLoading = false;
      });
      return false;
    }

    if (importedSeeds!.isEmpty) {
      setState(() {
        importError = l10n.importVaultErrorNoAccountsFound;
        isLoading = false;
      });
      return false;
    }

    return true;
  }

  /// Actually creates the wallet info
  /// Called by _runCreateWalletSteps
  ///
  /// Uses appStore to create new vault password
  /// Adds the imported seeds to the vault
  /// Stores the biometrics settings
  Future<void> _doCreateWallet() async {
    final l10n = l10nOf(context);
    setState(() {
      isLoading = true;
    });
    if (await appStore.signUp(vaultPassword)) {
      try {
        await appStore.checkWalletIsInitialized();
        List<QubicId> ids = [];
        for (var importedSeed in importedSeeds!) {
          ids.add(QubicId(importedSeed.getSeed(), importedSeed.getPublicId(),
              importedSeed.getAlias()!, 0));
        }
        await appStore.addManyIds(ids);
      } catch (e) {
        if (context.mounted) {
          showAlertDialog(
              // ignore: use_build_context_synchronously
              context,
              l10n.generalErrorContactingQubicNetwork,
              e.toString());
        }
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
        if (context.mounted) {
          showAlertDialog(
              // ignore: use_build_context_synchronously
              context,
              l10n.signUpErrorStoringBiometricInfo,
              e.toString());
        }
      }

      appStore.checkWalletIsInitialized();
      settingsStore.setBiometrics(enabledBiometrics);
      if (context.mounted) {
        // ignore: use_build_context_synchronously
        context.goNamed("mainScreen");
      }
      _globalSnackbar
          .show(l10n.generalSnackBarMessageWalletImportedSuccessfully);
    } else {
      setState(() {
        isLoading = false;
      });
    }
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

  /// Gets the bottom buttons
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

  /// Gets the form for entering the password
  Widget getPasswordForm() {
    final l10n = l10nOf(context);

    return FormBuilder(
        key: _formKey,
        child: Column(children: [
          FormBuilderTextField(
            name: "password",
            autofocus: true,
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(
                  errorText: l10n.generalErrorRequiredField),
              FormBuilderValidators.minLength(8,
                  errorText: l10n.generalErrorPasswordMinLength)
            ]),
            onSubmitted: (value) => handleProceed(),
            onChanged: (value) => vaultPassword = value ?? "",
            decoration: ThemeInputDecorations.bigInputbox.copyWith(
              hintText: l10n.importVaultLabelEnterPassword,
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
    final l10n = l10nOf(context);

    return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Row(children: [
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ThemedControls.pageHeader(
                  headerText: l10n.importWalletLabelFromVaultFile,
                  subheaderText: ""),
              Text(l10n.importVaultSubHeader, style: TextStyles.secondaryText),
              ThemedControls.spacerVerticalNormal(),
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
