import 'dart:io' as io;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:local_auth/local_auth.dart';
import 'package:qubic_wallet/components/gradient_foreground.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/re_auth_dialog.dart';
import 'package:qubic_wallet/models/qubic_vault_export_seed.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/stores/settings_store.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:qubic_wallet/styles/edgeInsets.dart';
import 'package:qubic_wallet/styles/inputDecorations.dart';
import 'package:qubic_wallet/styles/textStyles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:qubic_wallet/timed_controller.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:qubic_wallet/resources/qubic_cmd.dart';
import 'package:path/path.dart' as path;

class ExportWalletVault extends StatefulWidget {
  const ExportWalletVault({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ExportWalletVaultState createState() => _ExportWalletVaultState();
}

class _ExportWalletVaultState extends State<ExportWalletVault> {
  final ApplicationStore appStore = getIt<ApplicationStore>();
  final LocalAuthentication auth = LocalAuthentication();
  final SettingsStore settingsStore = getIt<SettingsStore>();
  final QubicCmd qubicCmd = getIt<QubicCmd>();

  String? selectedPath;
  io.File? selectedFile;
  bool enabled = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget loadingIndicator() {
    return Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
          const SizedBox(height: ThemePaddings.hugePadding),
          const CircularProgressIndicator(),
          const SizedBox(height: ThemePaddings.normalPadding),
          Text("Loading...",
              style: Theme.of(context)
                  .textTheme
                  .displayMedium!
                  .copyWith(fontFamily: ThemeFonts.primary))
        ]));
  }

  Widget getEmptyPathSelector() {
    return ThemedControls.darkButtonBigWithChild(
        onPressed: () async {
          String? outputFile = await FilePicker.platform.saveFile(
            dialogTitle: 'Please select a save path for your qubic vault file:',
            allowedExtensions: ['qubic-vault'],
            type: FileType.custom,
            lockParentWindow: true,
            fileName: 'exported.qubic-vault',
          );

          if (outputFile == null) {
            // User canceled the picker
            debugPrint("Did not select");
          } else {
            setState(() {
              selectedPath = outputFile;
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
                          Text("Select file path", style: TextStyles.textBold),
                          ThemedControls.spacerVerticalSmall(),
                          Container(
                              child: Text(
                                  "Touch to select where the vault file will be saved in your device",
                                  style: TextStyles.secondaryText))
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

  Widget getScrollView() {
    return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Row(children: [
          Container(
              child: Expanded(
                  child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ThemedControls.pageHeader(headerText: "Export Wallet Vault File"),
              Text(
                  "Export the contents of this wallet in an encrypted vault file as a backup. This file can only be unlocked with your password. Always keep this file in a safe place.",
                  style: TextStyles.secondaryText),
              ThemedControls.spacerVerticalHuge(),
              selectedPath == null
                  ? getEmptyPathSelector()
                  : getSelectedPathSelector()
            ],
          )))
        ]));
  }

  Widget getButtons() {
    return Expanded(
        child: ThemedControls.primaryButtonBigWithChild(
            enabled: selectedPath != null,
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
                    : Text("Export", style: TextStyles.primaryButtonText)),
            onPressed: () async {
              if (selectedPath == null) {
                return null;
              }
              setState(() {
                isLoading = true;
              });
              await exportHandler();
              // await appStore.exportVault(selectedPath!);
              setState(() {
                isLoading = false;
              });
            }));
  }

  Future<void> exportHandler() async {
    if (await io.File(selectedPath!).exists()) {
      showOverWriteDialog(context);
    } else {
      await exportVault();
    }
  }

  Future<void> exportVault() async {
    var pass = await reAuthDialogGetPass(context);
    if (pass == null) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    debugPrint("Exporting vault to $selectedPath with password $pass");

    List<QubicVaultExportSeed> seeds = [];
    for (var element in appStore.currentQubicIDs) {
      var seed = await appStore.getSeedById(element.publicId);
      seeds.add(QubicVaultExportSeed(
          seed: seed, alias: element.name, publicId: element.publicId));
    }
    try {
      var fileContents = await qubicCmd.createVaultFile(pass, seeds);
      await io.File(selectedPath!).writeAsBytes(fileContents);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void showFinishedDialog(BuildContext context) {
    late BuildContext dialogContext;

    Widget continueButton = ThemedControls.primaryButtonNormal(
        text: "Ok",
        onPressed: () async {
          //Navigator.pop(dialogContext);
          Navigator.pop(context);
        });

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title:
          Text("Vault file successfully saved", style: TextStyles.alertHeader),
      scrollable: true,
      content: Text(
          "Your wallet has been successfully saved to the selected vault file",
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

  void showOverWriteDialog(BuildContext context) {
    late BuildContext dialogContext;

    // set up the buttons
    Widget cancelButton = ThemedControls.transparentButtonNormal(
        onPressed: () {
          Navigator.pop(dialogContext);
        },
        text: "No");

    Widget continueButton = ThemedControls.primaryButtonNormal(
        text: "Yes",
        onPressed: () async {
          Navigator.pop(dialogContext);
          await exportVault();
        });

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Overwrite file", style: TextStyles.alertHeader),
      scrollable: true,
      content: Text("The file already exists. Do you want to overwrite it?",
          style: TextStyles.alertText),
      actions: [
        cancelButton,
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
                  Expanded(child: getScrollView()),
                  Row(children: [getButtons()]),
                ]))));
  }
}
