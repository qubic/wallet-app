// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:io';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/services.dart' show Uint8List;
import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/globals/localization_manager.dart';
import 'package:qubic_wallet/models/qubic_sign_result.dart';
import 'package:qubic_wallet/helpers/app_logger.dart';
import 'package:qubic_wallet/models/qubic_import_vault_seed.dart';
import 'package:qubic_wallet/models/qubic_js.dart';
import 'package:qubic_wallet/models/qubic_vault_export_seed.dart';
import 'package:qubic_wallet/models/signed_transaction.dart';

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
      appLogger.d("QubicJS: Controller already set. No need to initialize");
      return;
    }
    InAppWebView = HeadlessInAppWebView(
      onWebViewCreated: (WVcontroller) async {
        WVcontroller.loadFile(assetFilePath: Config.qubicJSAssetPath);
        controller = WVcontroller;
      },
      onConsoleMessage: (controller, consoleMessage) {
        appLogger.d(consoleMessage.toString());
      },
      onReceivedError: (controller, request, error) =>
          {appLogger.e(error.toString())},
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
    if (controller != null) {
      appLogger.d("Reinitialize skipped: Controller is still valid");
      return;
    }
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

  /// Runs an async JS function with the given parameters and returns the result
  Future<CallAsyncJavaScriptResult?> runFunction(
      String functionName, List<String> parameters) async {
    await initialize();
    parameters = parameters.map((e) => e.replaceAll("'", "\\'")).toList();
    String functionBody =
        "await window.runBrowser('$functionName', '${parameters.join("','")}')";

    functionBody = "return JSON.stringify($functionBody);";
    return await controller!.callAsyncJavaScript(functionBody: functionBody);
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

    CallAsyncJavaScriptResult? result =
        await runFunction(QubicJSFunctions.createTransactionAssetMove, [
      seed,
      destinationId,
      assetName,
      assetIssuer,
      numberOfUnits.toString(),
      tick.toString()
    ]);

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

  Future<SignedTransaction> createTransaction(String seed, String destinationId,
      int value, int tick, int? inputType, String? payload) async {
    try {
      CallAsyncJavaScriptResult? result = (inputType == null)
          ? await runFunction(QubicJSFunctions.createTransaction,
              [seed, destinationId, value.toString(), tick.toString()])
          : (payload == null)
              ? await runFunction(
                  QubicJSFunctions.createTransactionWithPayload, [
                  seed,
                  destinationId,
                  value.toString(),
                  tick.toString(),
                  inputType.toString()
                ])
              : await runFunction(
                  QubicJSFunctions.createTransactionWithPayload, [
                  seed,
                  destinationId,
                  value.toString(),
                  tick.toString(),
                  inputType.toString(),
                  payload
                ]);

      if (result == null) {
        throw Exception(LocalizationManager.instance.appLocalization
            .cmdErrorCreatingTransferTransactionGeneric);
      }
      if (result.error != null) {
        throw Exception(LocalizationManager.instance.appLocalization
            .cmdErrorCreatingTransferTransaction(result.error ?? ""));
      }
      final Map<String, dynamic> data = json.decode(result.value);
      return SignedTransaction.fromJson(data);
    } catch (e) {
      appLogger.e(e);
      rethrow;
    }
  }

  Future<String> getPublicIdFromSeed(String seed) async {
    CallAsyncJavaScriptResult? result =
        await runFunction(QubicJSFunctions.createPublicId, [
      seed,
    ]);

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
    CallAsyncJavaScriptResult? result =
        await runFunction(QubicJSFunctions.createVaultFile, [
      password,
      jsonEncode(seeds.map((e) => e.toJson()).toList()),
    ]);

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
    CallAsyncJavaScriptResult? result =
        await runFunction(QubicJSFunctions.verifyIdentity, [
      publicId,
    ]);

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

  Future<QubicSignResult> signBase64(String seed, String base64) async {
    CallAsyncJavaScriptResult? result =
        await runFunction(QubicJSFunctions.signRaw, [seed, base64]);

    if (result == null) {
      throw Exception(
          LocalizationManager.instance.appLocalization.signBase64GenericError);
    }
    if (result.error != null) {
      throw Exception(LocalizationManager.instance.appLocalization
          .importVaultFileErrorGeneralMessage(result.error ?? ""));
    }
    final Map<String, dynamic> data = json.decode(result.value);

    if (data['status'] == 'error') {
      throw Exception(LocalizationManager.instance.appLocalization
          .signBase64GenericError(data['error'] ?? ""));
    }
    return QubicSignResult.fromJson(data);
  }

  Future<QubicSignResult> signASCII(String seed, String ASCIIText) async {
    CallAsyncJavaScriptResult? result =
        await runFunction(QubicJSFunctions.signASCII, [seed, ASCIIText]);

    if (result == null) {
      throw Exception(
          LocalizationManager.instance.appLocalization.signASCIIGenericError);
    }
    if (result.error != null) {
      throw Exception(LocalizationManager.instance.appLocalization
          .signASCIIGenericError(result.error ?? ""));
    }
    final Map<String, dynamic> data = json.decode(result.value);
    return QubicSignResult.fromJson(data);
  }

  Future<QubicSignResult> signUTF8(String seed, String UTF8Text) async {
    CallAsyncJavaScriptResult? result =
        await runFunction(QubicJSFunctions.signUTF8, [seed, UTF8Text]);

    if (result == null) {
      throw Exception(
          LocalizationManager.instance.appLocalization.signUTF8GenericError);
    }
    if (result.error != null) {
      throw Exception(LocalizationManager.instance.appLocalization
          .signUTF8GenericError(result.error ?? ""));
    }
    final Map<String, dynamic> data = json.decode(result.value);
    return QubicSignResult.fromJson(data);
  }

  Future<List<QubicImportVaultSeed>> importVault(
      String password, String baseFileContents) async {
    List<QubicImportVaultSeed>? seeds;
    List<dynamic>? parsedSeeds;

    CallAsyncJavaScriptResult? result = await runFunction(
        QubicJSFunctions.importVault, [password, baseFileContents]);

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
