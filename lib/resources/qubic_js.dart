// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter/services.dart' show Uint8List, rootBundle;
import 'package:qubic_wallet/config.dart';
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
              assetFilePath: "assets/qubic_js/qubic-helper-html-3_0_2.html");

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
        });

    await InAppWebView!.run();
    while (controller == null) {
      sleep(const Duration(milliseconds: 100));
    }
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
        "await runBrowser('createTransactionAssetMove','$seed', '$destinationId', '$assetName', '$assetIssuer', $numberOfUnits, $tick)";
    functionBody = "return $functionBody";

    initialize();
    CallAsyncJavaScriptResult? result =
        await controller!.callAsyncJavaScript(functionBody: functionBody);

    if (result == null) {
      throw Exception("Error trying to create asset transfer transcation");
    }
    if (result.error != null) {
      throw Exception(
          "Error trying to create asset transfer transcation: ${result.error}");
    }
    return result.value['transaction'];
  }

  Future<String> createTransaction(
      String seed, String destinationId, int value, int tick) async {
    String functionBody =
        "await runBrowser('createTransaction','${seed.replaceAll("'", "\\'")}', '${destinationId.replaceAll("'", "\\'")}', $value, $tick);";
    functionBody = "return $functionBody";
    debugPrint(functionBody);
    initialize();
    CallAsyncJavaScriptResult? result =
        await controller!.callAsyncJavaScript(functionBody: functionBody);

    if (result == null) {
      throw Exception("Error trying to create transcation");
    }
    if (result.error != null) {
      throw Exception("Error trying to create transcation: ${result.error}");
    }
    return result.value['transaction'];
  }

  Future<String> getPublicIdFromSeed(String seed) async {
    CallAsyncJavaScriptResult? result = await controller!.callAsyncJavaScript(
        functionBody:
            "return await runBrowser('createPublicId','${seed.replaceAll("'", "\\'")}');");

    if (result == null) {
      throw Exception('Error getting public id from seed: Generic error');
    }
    if (result.error != null) {
      throw Exception('Error getting public id from seed:  ${result.error!}');
    }
    return result.value['publicId'];
  }

  /// Return base64  vault file
  Future<Uint8List> createVaultFile(
      String password, List<QubicVaultExportSeed> seeds) async {
    CallAsyncJavaScriptResult? result = await controller!.callAsyncJavaScript(
        functionBody:
            "return await runBrowser('wallet.createVaultFile','${password.replaceAll("'", "\\'")}','${jsonEncode(seeds.map((e) => e.toJson()).toList()).replaceAll("'", "\\'")}'");
    if (result == null) {
      throw Exception('Error getting vault file: Generic error');
    }
    if (result.error != null) {
      throw Exception('Error getting vault file:  ${result.error!}');
    }
    if (result.value['base64'] == null) {
      throw Exception(
          'Failed to create vault file. Helper returned empty vault file');
    }

    return base64Decode(result.value['base64']!);
  }
}
