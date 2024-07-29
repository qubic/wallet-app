import 'dart:io' as io;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:local_auth/local_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/global_snack_bar.dart';
import 'package:qubic_wallet/helpers/re_auth_dialog.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/models/qubic_vault_export_seed.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/stores/settings_store.dart';
import 'package:qubic_wallet/styles/edgeInsets.dart';
import 'package:qubic_wallet/styles/inputDecorations.dart';
import 'package:qubic_wallet/styles/textStyles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:qubic_wallet/resources/qubic_cmd.dart';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';

class ExportWalletVault extends StatefulWidget {
  const ExportWalletVault({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ExportWalletVaultState createState() => _ExportWalletVaultState();
}

class _ExportWalletVaultState extends State<ExportWalletVault> {
  // #region Variables
  final ApplicationStore appStore = getIt<ApplicationStore>();
  final LocalAuthentication auth = LocalAuthentication();
  final SettingsStore settingsStore = getIt<SettingsStore>();
  final QubicCmd qubicCmd = getIt<QubicCmd>();
  final _globalSnackBar = getIt<GlobalSnackBar>();
  final _formKey = GlobalKey<FormBuilderState>();

  String? selectedPath; //The selected file path (android and desktop)
  io.File? selectedFile; //The selected file (android and desktop)
  bool enabled = false; //The enabled state of the export button
  bool isLoading = false; //The loading state of the export button
  String exportError = ""; //The error message if export fails
  String currentPassword = ""; //Current vault password
  bool showingPassword = false; //Show password or not
  bool showingRepeatPassword = false; //Show repeat password or not
  bool emptyPathError = false;
  // #endregion

  bool shareWithOutputFolder = !UniversalPlatform.isIOS;
  // #region Bootstrapping
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }
  // #endregion

  // #region file and path selectors
  Widget getEmptyPathSelector() {
    final l10n = l10nOf(context);

    return ThemedControls.darkButtonBigWithChild(
        error: emptyPathError,
        onPressed: () async {
          if (UniversalPlatform.isAndroid) {
            String? outputFolder = await FilePicker.platform.getDirectoryPath(
                dialogTitle: l10n.exportWalletVaultDialogTitleSelectPath,
                lockParentWindow: true);
            if (outputFolder == null) {
              // User canceled the picker
              debugPrint("Did not select");
              return;
            }
            DateTime now = DateTime.now();
            String formattedDate = DateFormat('yyyy-MM-dd-kk-mm').format(now);
            setState(() {
              emptyPathError = false;
              selectedPath = outputFolder;
              selectedPath =
                  "${selectedPath!}/exported.$formattedDate.qubic-vault";
              selectedFile = io.File(selectedPath!);
            });
          } else {
            String? outputFile = await FilePicker.platform.saveFile(
                dialogTitle: l10n.exportWalletVaultDialogTitleSelectPath,
                allowedExtensions: ['qubic-vault'],
                type: FileType.custom,
                lockParentWindow: true,
                fileName: 'exported.qubic-vault');

            if (outputFile == null) {
              // User canceled the picker
              debugPrint("Did not select");
            }
            setState(() {
              selectedPath = outputFile!;
              if (!outputFile.endsWith(".qubic-vault")) {
                selectedPath = "${selectedPath!}.qubic-vault";
              }
              selectedFile = io.File(selectedPath!);
            });
          }
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
                          Text(l10n.exportWalletVaultLabelSelectFilePath,
                              style: TextStyles.textBold),
                          ThemedControls.spacerVerticalSmall(),
                          Text(
                              l10n.exportWalletVaultLabelSelectFilePathInstructions,
                              style: TextStyles.secondaryText)
                        ]),
                  )
                ])));
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
                          Text(path.basename(selectedFile!.path),
                              style: TextStyles.textBold),
                          ThemedControls.spacerVerticalSmall(),
                          Container(
                              child: Text(path.dirname(selectedFile!.path),
                                  style: TextStyles.secondaryText))
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
                        });
                      },
                      icon: Image.asset('assets/images/cancel.png'))
                ])));
  }
  // #endregion

  Widget getNonIOSContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ThemedControls.spacerVerticalSmall(),
        selectedPath == null
            ? getEmptyPathSelector()
            : getSelectedPathSelector()
      ],
    );
  }

  // #region Main Contents
  Widget getMainScrollView() {
    final l10n = l10nOf(context);

    return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Row(children: [
          Container(
              child: Expanded(
                  child: FormBuilder(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ThemedControls.pageHeader(
                    headerText: l10n.exportWalletVaultTitle),
                Text(l10n.exportWalletVaultLabelInstructions,
                    style: TextStyles.secondaryText),
                ThemedControls.spacerVerticalHuge(),
                FormBuilderTextField(
                  name: "password",
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(
                        errorText: l10n.exportWalletVaultErrorEmptyPassword),
                    FormBuilderValidators.minLength(8,
                        errorText:
                            l10n.exportWalletVaultErrorPasswordMinLength(8))
                  ]),
                  onChanged: (value) => currentPassword = value ?? "",
                  onSubmitted: (String? text) {
                    exportButtonHandler();
                  },
                  enabled: !isLoading,
                  decoration: ThemeInputDecorations.bigInputbox.copyWith(
                    hintText: l10n.exportWalletVaultTextFieldHintPassword,
                    suffixIcon: Padding(
                        padding: const EdgeInsets.only(
                            right: ThemePaddings.smallPadding),
                        child: IconButton(
                          icon: showingPassword
                              ? Image.asset("assets/images/eye-closed.png")
                              : Image.asset("assets/images/eye-open.png"),
                          onPressed: () {
                            setState(() => showingPassword = !showingPassword);
                          },
                        )),
                  ),
                  obscureText: !showingPassword,
                  autocorrect: false,
                  autofillHints: null,
                ),
                ThemedControls.spacerVerticalSmall(),
                FormBuilderTextField(
                  name: "passwordRepeat",
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(
                        errorText:
                            l10n.exportWalletVaultErrorEmptyRepeatPassword),
                    (value) {
                      if (value == currentPassword) return null;
                      return l10n.generalErrorSetPasswordNotMatching;
                    }
                  ]),
                  onSubmitted: (String? text) {
                    exportButtonHandler();
                  },
                  enabled: !isLoading,
                  decoration: ThemeInputDecorations.bigInputbox.copyWith(
                    hintText: l10n.exportWalletVaultTextFieldHintRepeatPassword,
                    suffixIcon: Padding(
                        padding: const EdgeInsets.only(
                            right: ThemePaddings.smallPadding),
                        child: IconButton(
                          icon: showingRepeatPassword
                              ? Image.asset("assets/images/eye-closed.png")
                              : Image.asset("assets/images/eye-open.png"),
                          onPressed: () {
                            setState(() =>
                                showingRepeatPassword = !showingRepeatPassword);
                          },
                        )),
                  ),
                  obscureText: !showingRepeatPassword,
                  autocorrect: false,
                  autofillHints: null,
                ),
                shareWithOutputFolder ? getNonIOSContent() : Container()
              ],
            ),
          )))
        ]));
  }

  Widget getFooterButtons() {
    final l10n = l10nOf(context);

    return Expanded(
        child: ThemedControls.primaryButtonBigWithChild(
            child: Padding(
                padding: const EdgeInsets.all(ThemePaddings.normalPadding),
                child: isLoading
                    ? const SizedBox(
                        height: 23,
                        width: 23,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: LightThemeColors.extraStrongBackground,
                        ))
                    : Text(l10n.exportWalletVaultButtonExport,
                        style: TextStyles.primaryButtonText)),
            onPressed: () async {
              await exportButtonHandler();
            }));
  }
  // #endregion

  // #region Handlers for android and desktops
  Future<void> exportButtonHandler() async {
    if (isLoading) {
      return;
    }
    setState(() {
      emptyPathError = false;
    });
    _formKey.currentState?.validate();
    if ((selectedPath == null) && (shareWithOutputFolder)) {
      setState(() {
        emptyPathError = true;
      });
    }
    if (!_formKey.currentState!.isValid) {
      return;
    }

    if ((selectedPath == null) && (shareWithOutputFolder)) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    await exportHandler();
    // await appStore.exportVault(selectedPath!);
    setState(() {
      isLoading = false;
    });
  }

  Future<List<QubicVaultExportSeed>> getSeeds() async {
    List<QubicVaultExportSeed> seeds = [];
    for (var element in appStore.currentQubicIDs) {
      var seed = await appStore.getSeedById(element.publicId);
      seeds.add(QubicVaultExportSeed(
          seed: seed, alias: element.name, publicId: element.publicId));
    }
    return seeds;
  }

  // Handles the export process for iOS
  Future<void> _exportHandlerIOS() async {
    final l10n = l10nOf(context);

    try {
      var bytes = await qubicCmd.createVaultFile(
          currentPassword, await getSeeds(), context);

      final res = await Share.shareXFiles(
          [XFile.fromData(bytes, name: "exported.qubic-vault")]);
      if (res.status == ShareResultStatus.success) {
        _globalSnackBar.show(l10n.exportWalletVaultSnackbarSuccessMessage);
        Navigator.pop(context);
      }
    } catch (e) {
      showErrorDialog(context, e.toString());
      setState(() {
        isLoading = false;
      });
    }
  }

  // Handles the actual export process (file saving) for android and desktop
  // called by the exportHandlerGeneric function and the overwrite dialog
  Future<void> _doExportGeneric() async {
    final l10n = l10nOf(context);

    try {
      if (await reAuthDialog(context) == false) {
        return;
      }
      var fileContents = await qubicCmd.createVaultFile(
          currentPassword, await getSeeds(), context);
      await io.File(selectedPath!).writeAsBytes(fileContents);
      setState(() {
        isLoading = false;
      });

      _globalSnackBar.show(selectedPath != null
          ? l10n.exportWalletVaultSnackbarSuccessMessageWithPath(selectedPath!)
          : l10n.exportWalletVaultSnackbarSuccessMessage);

      Navigator.pop(context);
    } catch (e) {
      showErrorDialog(context, e.toString());
      setState(() {
        isLoading = false;
      });
    }
  }

  // Handles the export process for android and desktop
  // (checks if file exists and shows overwrite dialog if needed)
  Future<void> _exportHandlerGeneric() async {
    if (await io.File(selectedPath!).exists()) {
      _showOverWriteDialog(context);
    } else {
      _doExportGeneric();
    }
  }

  /// Handles clicking of the export button
  Future<void> exportHandler() async {
    if (!shareWithOutputFolder) {
      await _exportHandlerIOS();
    } else {
      await _exportHandlerGeneric();
    }
  }

  // #endregion

  // #region Dialogs
  // Shows the error dialog when an error occurs while saving the vault file
  void showErrorDialog(BuildContext context, String errorText) {
    late BuildContext dialogContext;
    final l10n = l10nOf(context);

    Widget continueButton = ThemedControls.primaryButtonNormal(
        text: l10n.generalButtonOK,
        onPressed: () async {
          Navigator.pop(dialogContext);
        });

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(l10n.exportWalletDialogTitleErrorWhileSaving,
          style: TextStyles.alertHeader),
      scrollable: true,
      content: Text(errorText.replaceAll("Exception:", ""),
          style: TextStyles.alertText),
      actions: [
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        dialogContext = context;
        return alert;
      },
    );
  }

  // Shows the overwrite dialog when the file already exists in the selected path (android and desktop)
  void _showOverWriteDialog(BuildContext context) {
    late BuildContext dialogContext;
    final l10n = l10nOf(context);

    // set up the buttons
    Widget noButton = ThemedControls.transparentButtonNormal(
        onPressed: () {
          Navigator.pop(dialogContext);
        },
        text: l10n.generalLabelNo);

    Widget yesButton = ThemedControls.primaryButtonNormal(
        text: l10n.generalLabelYes,
        onPressed: () async {
          Navigator.pop(dialogContext);
          await _doExportGeneric();
        });

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(l10n.exportWalletDialogTitleOverwriteFile,
          style: TextStyles.alertHeader),
      scrollable: true,
      content: Text(l10n.exportWalletDialogMessageOverwriteFile,
          style: TextStyles.alertText),
      actions: [
        noButton,
        yesButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        dialogContext = context;
        return alert;
      },
    );
  }
  // #endregion

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
                  Expanded(child: getMainScrollView()),
                  Row(children: [getFooterButtons()]),
                ]))));
  }
}