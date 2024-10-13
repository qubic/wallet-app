// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/services.dart' show Uint8List;
import 'package:qubic_wallet/globals/localization_manager.dart';
import 'package:qubic_wallet/models/qubic_import_vault_seed.dart';
import 'package:qubic_wallet/models/qubic_vault_export_seed.dart';

/// A class that handles the secure storage of the wallet. The wallet is stored in the secure storage of the device
/// The wallet password is encrypted using Argon2
class QubicJs {
  HeadlessInAppWebView? InAppWebView;
  InAppWebViewController? controller;
  bool validatedFileStream = false;
  final INDEX_MD5 =
      "a3395f6a38afa4326bf73a52e04530fd"; //MD5 of the index.html file to prevent tampering in run time
  initialize() async {
    if (controller != null) {
      debugPrint("QubicJS: Controller already set. No need to initialize");
      return;
    }
    InAppWebView = HeadlessInAppWebView(
      onWebViewCreated: (WVcontroller) async {
        WVcontroller.loadFile(
            assetFilePath: "assets/qubic_js/qubic-helper-html-3_0_8.html");

        controller = WVcontroller;
      },
      onConsoleMessage: (controller, consoleMessage) {
        debugPrint(consoleMessage.toString());
      },
      onReceivedError: (controller, request, error) =>
          {debugPrint(error.toString())},
      onLoadStart: (controller, url) {},
      onLoadStop: (controller, url) async {
        isReady = true;
      },
    );

    await InAppWebView!.run();
    while (controller == null) {
      sleep(const Duration(milliseconds: 100));
    }
  }

  reInitialize() async {
    disposeController();
    await initialize();
  }

  bool isReady = false;

  disposeController() {
    controller!.dispose();
    controller = null;
    isReady = false;
  }

  guardInitialized() {
    if (controller == null) {
      throw Exception('Controller not set');
    }
    if (!isReady) {
      throw Exception('WebView not initialized yet');
    }
  }

  setController(InAppWebViewController controller) {
    this.controller = controller;
  }

  Future<String> createAssetTransferTransaction(
      String seed,
      String destinationId,
      String assetName,
      String assetIssuer,
      int numberOfUnits,
      int tick) async {
    seed = seed.replaceAll("'", "\\'");
    destinationId = destinationId.replaceAll("'", "\\'");
    assetName = assetName.replaceAll("'", "\\'");
    assetIssuer = assetIssuer.replaceAll("'", "\\'");

    String functionBody =
        "await window.runBrowser('createTransactionAssetMove','$seed', '$destinationId', '$assetName', '$assetIssuer', $numberOfUnits, $tick)";
    functionBody = "return JSON.stringify($functionBody);";

    initialize();
    CallAsyncJavaScriptResult? result =
        await controller!.callAsyncJavaScript(functionBody: functionBody);

    if (result == null) {
      throw Exception(LocalizationManager.instance.appLocalization
          .cmdErrorCreatingAssetTransferTransactionGeneric);
    }
    if (result.error != null) {
      throw Exception(LocalizationManager.instance.appLocalization
          .cmdErrorCreatingAssetTransferTransaction(result.error ?? ""));
    }

    final Map<String, dynamic> data = json.decode(result.value);
    return data['transaction'];
  }

  Future<String> createTransaction(
      String seed, String destinationId, int value, int tick) async {
    String functionBody =
        "await window.runBrowser('createTransaction','${seed.replaceAll("'", "\\'")}', '${destinationId.replaceAll("'", "\\'")}', $value, $tick)";
    functionBody = "return JSON.stringify($functionBody);";

    initialize();
    CallAsyncJavaScriptResult? result =
        await controller!.callAsyncJavaScript(functionBody: functionBody);

    if (result == null) {
      throw Exception(LocalizationManager
          .instance.appLocalization.cmdErrorCreatingTransferTransactionGeneric);
    }
    if (result.error != null) {
      throw Exception(LocalizationManager.instance.appLocalization
          .cmdErrorCreatingTransferTransaction(result.error ?? ""));
    }
    final Map<String, dynamic> data = json.decode(result.value);
    return data['transaction'];
  }

  Future<String> getPublicIdFromSeed(String seed) async {
    String functionBody =
        "await window.runBrowser('createPublicId','${seed.replaceAll("'", "\\'")}')";
    functionBody = "return JSON.stringify($functionBody);";
    CallAsyncJavaScriptResult? result =
        await controller!.callAsyncJavaScript(functionBody: functionBody);

    if (result == null) {
      throw Exception(LocalizationManager
          .instance.appLocalization.cmdErrorGettingPublicIdFromSeedGeneric);
    }
    if (result.error != null) {
      throw Exception(LocalizationManager.instance.appLocalization
          .cmdErrorGettingPublicIdFromSeed(result.error ?? ""));
    }

    final Map<String, dynamic> data = json.decode(result.value);
    return data['publicId'];
  }

  /// Return base64  vault file
  Future<Uint8List> createVaultFile(
      String password, List<QubicVaultExportSeed> seeds) async {
    String functionBody =
        "await window.runBrowser('wallet.createVaultFile','${password.replaceAll("'", "\\'")}','${jsonEncode(seeds.map((e) => e.toJson()).toList()).replaceAll("'", "\\'")}')";
    functionBody = "return JSON.stringify($functionBody);";
    CallAsyncJavaScriptResult? result =
        await controller!.callAsyncJavaScript(functionBody: functionBody);
    if (result == null) {
      throw Exception(LocalizationManager
          .instance.appLocalization.cmdErrorCreatingVaultFileGeneric);
    }
    if (result.error != null) {
      throw Exception(LocalizationManager.instance.appLocalization
          .exportWalletVaultErrorGeneralMessage(result.error ?? ""));
    }
    final Map<String, dynamic> data = json.decode(result.value);
    if (data['status'] == 'error') {
      throw Exception(LocalizationManager.instance.appLocalization
          .exportWalletVaultErrorGeneralMessage(result.value['error'] ?? ""));
    }
    if (data['base64'] == null) {
      throw Exception(LocalizationManager
          .instance.appLocalization.cmdErrorCreatingVaultFileGeneratedIsEmpty);
    }
    return base64Decode(data['base64']!);
  }

  Future<bool> verifyIdentity(String publicId) async {
    await initialize();

    String functionBody =
        "await window.runBrowser('verifyIdentity', '${publicId.replaceAll("'", "\\'")}')";
    functionBody = "return JSON.stringify($functionBody);";

    CallAsyncJavaScriptResult? result =
        await controller!.callAsyncJavaScript(functionBody: functionBody);

    if (result == null) {
      throw Exception(LocalizationManager
          .instance.appLocalization.cmdErrorVerifyingIdentityGeneric);
    }

    if (result.error != null) {
      throw Exception(LocalizationManager.instance.appLocalization
          .cmdErrorVerifyingIdentity(result.error ?? ""));
    }

    final Map<String, dynamic> data = json.decode(result.value);
    return data['isValid'];
  }

  Future<List<QubicImportVaultSeed>> importVault(
      String password, String baseFileContents) async {
    List<QubicImportVaultSeed>? seeds;
    List<dynamic>? parsedSeeds;

    String functionBody =
        "await window.runBrowser('wallet.importVault','${password.replaceAll("'", "\\'")}','${baseFileContents.replaceAll("'", "\\'")}')";
    functionBody = "return JSON.stringify($functionBody);";

    CallAsyncJavaScriptResult? result =
        await controller!.callAsyncJavaScript(functionBody: functionBody);

    if (result == null) {
      throw Exception(LocalizationManager
          .instance.appLocalization.importVaultFileGenericError);
    }
    if (result.error != null) {
      throw Exception(LocalizationManager.instance.appLocalization
          .importVaultFileErrorGeneralMessage(result.error ?? ""));
    }
    final Map<String, dynamic> data = json.decode(result.value);

    if (data['status'] == 'error') {
      if (data['error'] == "Could not parse seeds JSON") {
        throw Exception(LocalizationManager
            .instance.appLocalization.importVaultFileOrPasswordError);
      }
      throw Exception(LocalizationManager.instance.appLocalization
          .importVaultFileErrorGeneralMessage(data['error'] ?? ""));
    }

    if (data['seeds'] == null) {
      throw Exception(LocalizationManager
          .instance.appLocalization.importVaultFileSeedsNullError);
    }
    if (data['seeds'].toString().isEmpty) {
      throw Exception(LocalizationManager
          .instance.appLocalization.importVaultErrorNoAccountsFound);
    }

    try {
      parsedSeeds = data['seeds'];
    } catch (e) {
      throw Exception(LocalizationManager
          .instance.appLocalization.importVaultFileSeedsMalformedError);
    }

    if (parsedSeeds == null) {
      throw Exception(LocalizationManager
          .instance.appLocalization.importVaultFileParsedSeedsNullError);
    }

    if (parsedSeeds.isEmpty) {
      throw Exception(LocalizationManager
          .instance.appLocalization.importVaultErrorNoAccountsFound);
    }

    seeds = <QubicImportVaultSeed>[];
    var i = 0;
    for (var seed in parsedSeeds) {
      if (seed['alias'] == null) {
        throw Exception(LocalizationManager.instance.appLocalization
            .importVaultFileAccountMissingName(i));
      }
      if (seed['publicId'] == null) {
        throw Exception(LocalizationManager.instance.appLocalization
            .importVaultFileAccountMissingPublicId(i));
      }
      if (seed['seed'] == null) {
        throw Exception(LocalizationManager.instance.appLocalization
            .importVaultFileAccountMissingSeed(i));
      }

      seeds.add(QubicImportVaultSeed(
          seed['alias'], seed['publicId'], seed['seed'] ?? ""));
      i++;
    }

    return seeds;
  }
}
