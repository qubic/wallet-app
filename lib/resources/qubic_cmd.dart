import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:qubic_wallet/globals/localization_manager.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/models/qubic_import_vault_seed.dart';
import 'package:qubic_wallet/models/qubic_vault_export_seed.dart';
import 'package:qubic_wallet/resources/qubic_cmd_utils.dart';
import 'package:qubic_wallet/resources/qubic_js.dart';
import 'package:universal_platform/universal_platform.dart';

class QubicCmd {
  late QubicJs qubicJs;
  late QubicCmdUtils qubicCmdUtils;

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
    if ((UniversalPlatform.isAndroid) || (UniversalPlatform.isIOS)) {
      qubicJs.reInitialize();
    }
  }

  void dispose() {
    if ((UniversalPlatform.isAndroid) || (UniversalPlatform.isIOS)) {
      _disploseQubicJS();
    }
    if ((UniversalPlatform.isLinux) ||
        (UniversalPlatform.isWindows) ||
        (UniversalPlatform.isMacOS)) {
      _disposeQubicCMD();
    }
  }

  Future<void> initialize() async {
    if ((UniversalPlatform.isAndroid) || (UniversalPlatform.isIOS)) {
      await _initQubicJS();
    }
    if ((UniversalPlatform.isLinux) ||
        (UniversalPlatform.isWindows) ||
        (UniversalPlatform.isMacOS)) {
      _initQubicCMD();
    }
  }

  Future<String> getPublicIdFromSeed(String seed) async {
    if ((UniversalPlatform.isAndroid) || (UniversalPlatform.isIOS)) {
      return await qubicJs.getPublicIdFromSeed(seed);
    }
    if ((UniversalPlatform.isLinux) ||
        (UniversalPlatform.isWindows) ||
        (UniversalPlatform.isMacOS)) {
      _initQubicCMD();
      return await qubicCmdUtils.getPublicIdFromSeed(seed);
    }
    throw LocalizationManager
        .instance.appLocalization.generalErrorUnsupportedOS;
  }

  Future<String> createTransaction(
      String seed, String destinationId, int value, int tick) async {
    if ((UniversalPlatform.isAndroid) || (UniversalPlatform.isIOS)) {
      return await qubicJs.createTransaction(seed, destinationId, value, tick);
    }
    if ((UniversalPlatform.isLinux) ||
        (UniversalPlatform.isWindows) ||
        (UniversalPlatform.isMacOS)) {
      return await qubicCmdUtils.createTransaction(
          seed, destinationId, value, tick);
    }
    throw LocalizationManager
        .instance.appLocalization.generalErrorUnsupportedOS;
  }

  Future<String> createAssetTransferTransaction(
      String seed,
      String destinationId,
      String assetName,
      String assetIssuer,
      int numberOfAssets,
      int tick) async {
    if ((UniversalPlatform.isAndroid) || (UniversalPlatform.isIOS)) {
      return await qubicJs.createAssetTransferTransaction(
          seed, destinationId, assetName, assetIssuer, numberOfAssets, tick);
    }
    if ((UniversalPlatform.isLinux) ||
        (UniversalPlatform.isWindows) ||
        (UniversalPlatform.isMacOS)) {
      return await qubicCmdUtils.createAssetTransferTransaction(
          seed, destinationId, assetName, assetIssuer, numberOfAssets, tick);
    }
    throw LocalizationManager
        .instance.appLocalization.generalErrorUnsupportedOS;
  }

  Future<bool> verifyIdentity(String publicId) async {
    if (UniversalPlatform.isAndroid || UniversalPlatform.isIOS) {
      return await qubicJs.verifyIdentity(publicId);
    }
    if (UniversalPlatform.isLinux ||
        UniversalPlatform.isWindows ||
        UniversalPlatform.isMacOS) {
      return await qubicCmdUtils.verifyIdentity(publicId);
    }

    throw Exception(LocalizationManager.instance.appLocalization
        .generalErrorUnsupportedOS);
  }

  Future<Uint8List> createVaultFile(
      String password, List<QubicVaultExportSeed> seeds) async {
    if ((UniversalPlatform.isAndroid) || (UniversalPlatform.isIOS)) {
      return await qubicJs.createVaultFile(password, seeds);
    }
    if ((UniversalPlatform.isLinux) ||
        (UniversalPlatform.isWindows) ||
        (UniversalPlatform.isMacOS)) {
      return await qubicCmdUtils.createVaultFile(password, seeds);
    }
    throw LocalizationManager
        .instance.appLocalization.generalErrorUnsupportedOS;
  }

  Future<List<QubicImportVaultSeed>> importVaultFile(
      String password, String? filePath, Uint8List? fileContents) async {
    if ((UniversalPlatform.isAndroid) || (UniversalPlatform.isIOS)) {
      if (fileContents == null) {
        throw "File contents base64 is required";
      }
      var base64String = base64Encode(fileContents);
      return await qubicJs.importVault(password, base64String);
    }
    if ((UniversalPlatform.isLinux) ||
        (UniversalPlatform.isWindows) ||
        (UniversalPlatform.isMacOS)) {
      if (filePath == null) {
        throw "File path is required";
      }
      return await qubicCmdUtils.importVaultFile(password, filePath);
    }

    throw LocalizationManager
        .instance.appLocalization.generalErrorUnsupportedOS;
  }
}
