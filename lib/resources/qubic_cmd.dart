import 'dart:convert';
import 'dart:typed_data';
import 'package:qubic_wallet/globals/localization_manager.dart';
import 'package:qubic_wallet/models/qubic_import_vault_seed.dart';
import 'package:qubic_wallet/models/qubic_sign_result.dart';
import 'package:qubic_wallet/models/qubic_vault_export_seed.dart';
import 'package:qubic_wallet/resources/qubic_cmd_utils.dart';
import 'package:qubic_wallet/resources/qubic_js.dart';
import 'package:universal_platform/universal_platform.dart';

class QubicCmd {
  late QubicJs qubicJs;
  late QubicCmdUtils qubicCmdUtils;

  late bool useJs;

  Future<void> _initQubicJS() async {
    qubicJs = QubicJs();
    await qubicJs.initialize();
  }

  void _disploseQubicJS() {
    qubicJs.disposeController();
  }

  void _initQubicCMD() {
    qubicCmdUtils = QubicCmdUtils();
  }

  void _disposeQubicCMD() {}

  void reinitialize() {
    if ((UniversalPlatform.isAndroid) ||
        (UniversalPlatform.isIOS) ||
        (UniversalPlatform.isWindows) ||
        (UniversalPlatform.isMacOS)) {
      qubicJs.reInitialize();
    }
  }

  void dispose() {
    if ((UniversalPlatform.isAndroid) ||
        (UniversalPlatform.isIOS) ||
        (UniversalPlatform.isWindows) ||
        (UniversalPlatform.isMacOS)) {
      _disploseQubicJS();
    } else if (UniversalPlatform.isLinux) {
      _disposeQubicCMD();
    }
  }

  Future<void> initialize() async {
    if ((UniversalPlatform.isAndroid) ||
        (UniversalPlatform.isIOS) ||
        (UniversalPlatform.isWindows) ||
        (UniversalPlatform.isMacOS)) {
      useJs = true;
    } else if (UniversalPlatform.isDesktop && UniversalPlatform.isLinux) {
      useJs = false;
    } else {
      throw LocalizationManager
          .instance.appLocalization.generalErrorUnsupportedOS;
    }

    if (useJs) {
      await _initQubicJS();
    } else {
      _initQubicCMD();
    }
  }

  Future<String> getPublicIdFromSeed(String seed) async {
    if (useJs) {
      return await qubicJs.getPublicIdFromSeed(seed);
    } else {
      _initQubicCMD();
      return await qubicCmdUtils.getPublicIdFromSeed(seed);
    }
  }

  Future<String> createTransaction(
      String seed, String destinationId, int value, int tick) async {
    if (useJs) {
      return await qubicJs.createTransaction(seed, destinationId, value, tick);
    } else {
      return await qubicCmdUtils.createTransaction(
          seed, destinationId, value, tick);
    }
  }

  Future<String> createAssetTransferTransaction(
      String seed,
      String destinationId,
      String assetName,
      String assetIssuer,
      int numberOfAssets,
      int tick) async {
    if (useJs) {
      return await qubicJs.createAssetTransferTransaction(
          seed, destinationId, assetName, assetIssuer, numberOfAssets, tick);
    } else {
      return await qubicCmdUtils.createAssetTransferTransaction(
          seed, destinationId, assetName, assetIssuer, numberOfAssets, tick);
    }
  }

  Future<bool> verifyIdentity(String publicId) async {
    if (useJs) {
      return await qubicJs.verifyIdentity(publicId);
    } else {
      return await qubicCmdUtils.verifyIdentity(publicId);
    }
  }

  Future<Uint8List> createVaultFile(
      String password, List<QubicVaultExportSeed> seeds) async {
    if (useJs) {
      return await qubicJs.createVaultFile(password, seeds);
    } else {
      return await qubicCmdUtils.createVaultFile(password, seeds);
    }
  }

  Future<List<QubicImportVaultSeed>> importVaultFile(
      String password, String? filePath, Uint8List? fileContents) async {
    if (useJs) {
      if (fileContents == null) {
        throw "File contents base64 is required";
      }
      var base64String = base64Encode(fileContents);
      return await qubicJs.importVault(password, base64String);
    } else {
      if (filePath == null) {
        throw "File path is required";
      }
      return await qubicCmdUtils.importVaultFile(password, filePath);
    }
  }

  Future<QubicSignResult> signBase64(String seed, String base64) async {
    if (useJs) {
      return await qubicJs.signBase64(seed, base64);
    } else {
      return await qubicCmdUtils.signBase64(seed, base64);
    }
  }

  Future<QubicSignResult> signASCII(String seed, String asciiText) async {
    if (useJs) {
      return await qubicJs.signASCII(seed, asciiText);
    } else {
      return await qubicCmdUtils.signASCII(seed, asciiText);
    }
  }

  Future<QubicSignResult> signUTF8(String seed, String utf8Text) async {
    if (useJs) {
      return await qubicJs.signUTF8(seed, utf8Text);
    } else {
      return await qubicCmdUtils.signUTF8(seed, utf8Text);
    }
  }
}
