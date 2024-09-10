import 'dart:async';
import 'dart:io' as io;
import 'dart:io';
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:qubic_wallet/styles/edge_insets.dart';
import 'package:qubic_wallet/styles/input_decorations.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:qubic_wallet/resources/qubic_cmd.dart';

// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;

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
  late BuildContext _buttonKey;

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

  bool useShareController =
      UniversalPlatform.isIOS || UniversalPlatform.isAndroid;

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

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ThemedControls.darkButtonBigWithChild(
          error: emptyPathError,
          onPressed: () async {
            Directory? directory;
            try {
              directory = await getDownloadsDirectory();
            } catch (e) {
              debugPrint("Error getting application documents directory: $e");
            }
            String? outputFile = await FilePicker.platform.saveFile(
                dialogTitle: l10n.exportWalletVaultDialogTitleSelectPath,
                initialDirectory: directory?.path,
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
                            Text(l10n.generalLabelSelectFilePath,
                                style: TextStyles.textBold),
                            ThemedControls.spacerVerticalSmall(),
                            Text(
                                l10n.exportWalletVaultLabelSelectFilePathInstructions,
                                style: TextStyles.secondaryText)
                          ]),
                    )
                  ]))),
      emptyPathError
          ? Padding(
              padding: const EdgeInsets.fromLTRB(
                  ThemePaddings.bigPadding, ThemePaddings.miniPadding, 0, 0),
              child: Text(l10n.generalErrorPathRequired,
                  style: const TextStyle(
                      fontSize: ThemeFontSizes.errorLabel,
                      color: LightThemeColors.error)),
            )
          : Container()
    ]);
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
                          Text(path.dirname(selectedFile!.path),
                              style: TextStyles.secondaryText)
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

  Widget getNonMobileContent() {
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
          Expanded(
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
                  textInputAction: TextInputAction.done,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(
                        errorText: l10n.exportWalletVaultErrorEmptyPassword),
                    FormBuilderValidators.minLength(8,
                        errorText:
                            l10n.exportWalletVaultErrorPasswordMinLength(8))
                  ]),
                  onChanged: (value) => currentPassword = value ?? "",
                  onSubmitted: (String? text) {
                    if (_formKey.currentState?.validate() == true) {
                      exportButtonHandler(_buttonKey);
                    }
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
                  textInputAction: TextInputAction.done,
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
                    if (_formKey.currentState?.validate() == true) {
                      exportButtonHandler(_buttonKey);
                    }
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
                useShareController ? Container() : getNonMobileContent()
              ],
            ),
          ))
        ]));
  }

  Widget getFooterButtons() {
    final l10n = l10nOf(context);

    return Builder(
      builder: (buttonContext) {
        _buttonKey = buttonContext;
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
                      ),
                    )
                  : Text(
                      l10n.exportWalletVaultButtonExport,
                      style: TextStyles.primaryButtonText,
                    ),
            ),
            onPressed: () async {
              await exportButtonHandler(buttonContext);
            },
          ),
        );
      },
    );
  }

  // #endregion

  // #region Handlers for android and desktops
  Future<void> exportButtonHandler(BuildContext context) async {
    if (isLoading) {
      return;
    }
    _formKey.currentState?.validate();
    if ((selectedPath == null) && (!useShareController)) {
      setState(() {
        emptyPathError = true;
      });
    }
    if (!_formKey.currentState!.isValid) {
      return;
    }

    if ((selectedPath == null) && (!useShareController)) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    Timer(const Duration(milliseconds: 1), () async {
      await exportHandler(context);
    });

    // await appStore.exportVault(selectedPath!);
    // setState(() {
    //   isLoading = false;
    // });
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
  Future<void> _exportHandlerMobile(BuildContext buttonContext) async {
    final l10n = l10nOf(context);

    try {
      var bytes =
          await qubicCmd.createVaultFile(currentPassword, await getSeeds());

      var filename = "export.qubic-vault";
      var tempRoot = (await getTemporaryDirectory()).path;
      final path = "$tempRoot/$filename";

      await File(path).writeAsBytes(bytes, flush: true);
      var xFile = XFile(path);

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final RenderBox box = buttonContext.findRenderObject() as RenderBox;
        final Offset position = box.localToGlobal(Offset.zero);
        final Size size = box.size;

        final Rect sharePositionOrigin =
            Rect.fromLTWH(position.dx, position.dy, size.width, size.height);

        final ShareResult res = await Share.shareXFiles(
          [xFile],
          subject: filename,
          sharePositionOrigin: sharePositionOrigin,
        );

        if (res.status == ShareResultStatus.success) {
          _globalSnackBar.show(l10n.exportWalletVaultSnackbarSuccessMessage);
          if (mounted) {
            Navigator.pop(context);
          }
        }

        File(path).writeAsBytes([], flush: true);
      });
    } catch (e) {
      showErrorDialog(l10n.exportWalletVaultErrorGeneralMessage(e.toString()));
      setState(() {
        isLoading = false;
      });
    }
  }

  // Handles the actual export process (file saving) for android and desktop
  // called by the exportHandlerGeneric function and the overwrite dialog
  Future<void> _doExportGeneric() async {
    setState(() {
      isLoading = true;
    });
    final l10n = l10nOf(context);

    try {
      if (await reAuthDialog(context) == false) {
        setState(() {
          isLoading = false;
        });
        return;
      }
      var fileContents =
          await qubicCmd.createVaultFile(currentPassword, await getSeeds());
      await io.File(selectedPath!).writeAsBytes(fileContents);

      _globalSnackBar.show(selectedPath != null
          ? l10n.exportWalletVaultSnackbarSuccessMessageWithPath(selectedPath!)
          : l10n.exportWalletVaultSnackbarSuccessMessage);

      if (mounted) {
        Navigator.pop(context);
      }
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      showErrorDialog(e.toString());
      setState(() {
        isLoading = false;
      });
    }
  }

  // Handles the export process for android and desktop
  // (checks if file exists and shows overwrite dialog if needed)
  Future<void> _exportHandlerGeneric() async {
    if (await io.File(selectedPath!).exists()) {
      _showOverWriteDialog();
    } else {
      _doExportGeneric();
    }
  }

  /// Handles clicking of the export button
  Future<void> exportHandler(BuildContext context) async {
    if (useShareController) {
      await _exportHandlerMobile(context);
      setState(() {
        isLoading = false;
      });
    } else {
      await _exportHandlerGeneric();
    }
  }

  // #endregion

  // #region Dialogs
  // Shows the error dialog when an error occurs while saving the vault file
  void showErrorDialog(String errorText) {
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
  void _showOverWriteDialog() {
    late BuildContext dialogContext;
    final l10n = l10nOf(context);

    // set up the buttons
    Widget noButton = ThemedControls.transparentButtonNormal(
        onPressed: () {
          Navigator.pop(dialogContext);
          setState(() {
            isLoading = false;
          });
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
