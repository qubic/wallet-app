import 'package:intl/intl.dart' show toBeginningOfSentenceCase;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;

import 'package:path_provider/path_provider.dart';
import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/globals/localization_manager.dart';
import 'package:qubic_wallet/models/qubic_helper_config.dart';
import 'package:qubic_wallet/models/qubic_import_vault_seed.dart';
import 'package:qubic_wallet/models/qubic_vault_export_seed.dart';
import 'package:qubic_wallet/models/qublic_cmd_response.dart';
// ignore: depend_on_referenced_packages
import 'package:crypto/crypto.dart' as crypto;
import 'package:universal_platform/universal_platform.dart';

class QubicCmdUtilsResult {}

class QubicCmdUtils {
  QubicHelperConfigEntry _getConfig() {
    if (UniversalPlatform.isWindows) {
      return Config.qubicHelper.win64;
    } else if (UniversalPlatform.isLinux) {
      return Config.qubicHelper.linux64;
    } else if (UniversalPlatform.isMacOS) {
      return Config.qubicHelper.macOs64;
    }
    throw Exception(
        LocalizationManager.instance.appLocalization.generalErrorUnsupportedOS);
  }

  Future<String?> _getFileChecksum(String filePath) async {
    final file = File(filePath);
    if (!file.existsSync()) return null;
    try {
      final stream = file.openRead();
      final hash = await crypto.md5.bind(stream).first;

      // NOTE: You might not need to convert it to base64
      return hash.toString();
    } catch (exception) {
      return null;
    }
  }

  Future<String> _getHelperFileFullPath() async {
    var directory = await getApplicationSupportDirectory();
    return (path.join(directory.path, _getConfig().filename));
  }

  Future<bool> checkIfUtilitiesExist() async {
    return await File(await _getHelperFileFullPath()).exists();
  }

  Future<bool> checkUtilitiesChecksum() async {
    String generatedChecksum =
        await _getFileChecksum(await _getHelperFileFullPath()) ?? "";
    String configChecksum = _getConfig().checksum;
    return (generatedChecksum == configChecksum);
  }

  Future<bool> canUseUtilities() async {
    return await checkIfUtilitiesExist() && await checkUtilitiesChecksum();
  }

  Future<void> validateFileStreamSignature() async {
    if (await checkUtilitiesChecksum() != true) {
      throw Exception(
          // TODO check if the message is valid
          "CRITICAL: YOUR INSTALLATION OF QUBIC WALLET IS TAMPERED. PLEASE UNINSTALL THE APP, DOWNLOAD IT FROM A TRUSTED SOURCE AND INSTALL IT AGAIN");
    }
  }

  /// Return base64  vault file
  Future<Uint8List> createVaultFile(
      String password, List<QubicVaultExportSeed> seeds) async {
    await validateFileStreamSignature();
    final p = await Process.run(
        await _getHelperFileFullPath(),
        [
          'wallet.createVaultFile',
          password,
          jsonEncode(seeds.map((e) => e.toJsonEsc()).toList())
        ],
        runInShell: true);
    late dynamic parsedJson;
    try {
      parsedJson = jsonDecode(p.stdout.toString());
    } catch (e) {
      throw Exception(LocalizationManager.instance.appLocalization
          .exportWalletVaultErrorGeneralMessage(e.toString()));
    }
    QubicCmdResponse response;
    try {
      response = QubicCmdResponse.fromJson(parsedJson);
    } catch (e) {
      throw Exception(LocalizationManager.instance.appLocalization
          .exportWalletVaultErrorGeneralMessage(e.toString()));
    }

    if (response.status == false) {
      throw Exception(LocalizationManager.instance.appLocalization
          .exportWalletVaultErrorGeneralMessage(response.error.toString()));
    }

    if ((response.base64 == null) || (response.base64!.isEmpty)) {
      throw Exception(LocalizationManager
          .instance.appLocalization.cmdErrorCreatingVaultFileGeneratedIsEmpty);
    }
    return base64Decode(response.base64!);
  }

  Future<String> getPublicIdFromSeed(String seed) async {
    await validateFileStreamSignature();
    final p = await Process.run(
        await _getHelperFileFullPath(), ['createPublicId', seed],
        runInShell: true);
    late dynamic parsedJson;
    try {
      parsedJson = jsonDecode(p.stdout.toString());
    } catch (e) {
      throw Exception(LocalizationManager
          .instance.appLocalization.cmdErrorGettingPublicIdFromSeedGeneric);
    }
    QubicCmdResponse response;
    try {
      response = QubicCmdResponse.fromJson(parsedJson);
    } catch (e) {
      throw Exception(LocalizationManager.instance.appLocalization
          .cmdErrorGettingPublicIdFromSeed(e.toString()));
    }

    if (!response.status) {
      throw Exception(LocalizationManager.instance.appLocalization
          .cmdErrorGettingPublicIdFromSeed(response.error ?? ""));
    }

    if (response.publicId == null) {
      throw Exception(LocalizationManager
          .instance.appLocalization.cmdErrorGettingPublicIdFromSeedEmpty);
    }

    return response.publicId!;
  }

  Future<String> createAssetTransferTransaction(
      String seed,
      String destinationId,
      String assetName,
      String issuer,
      int numberOfAssets,
      int tick) async {
    await validateFileStreamSignature();
    final p = await Process.run(
        await _getHelperFileFullPath(),
        [
          'createTransactionAssetMove',
          seed,
          destinationId,
          assetName,
          issuer,
          numberOfAssets.toString(),
          tick.toString()
        ],
        runInShell: true);
    late dynamic parsedJson;
    try {
      parsedJson = jsonDecode(p.stdout.toString());
    } catch (e) {
      throw Exception(LocalizationManager.instance.appLocalization
          .cmdErrorCreatingAssetTransferTransactionGeneric);
    }
    QubicCmdResponse response;
    try {
      response = QubicCmdResponse.fromJson(parsedJson);
    } catch (e) {
      throw Exception(LocalizationManager.instance.appLocalization
          .cmdErrorCreatingAssetTransferTransaction(e.toString()));
    }

    if (!response.status) {
      throw Exception(LocalizationManager.instance.appLocalization
          .cmdErrorCreatingAssetTransferTransaction(response.error ?? ""));
    }

    if (response.transaction == null) {
      throw Exception(LocalizationManager.instance.appLocalization
          .cmdErrorCreatingAssetTransferTransactionEmpty);
    }

    return response.transaction!;
  }

  Future<String> createTransaction(
      String seed, String destinationId, int value, int tick) async {
    await validateFileStreamSignature();
    final p = await Process.run(
        await _getHelperFileFullPath(),
        [
          'createTransaction',
          seed,
          destinationId,
          value.toString(),
          tick.toString()
        ],
        runInShell: true);
    late dynamic parsedJson;
    try {
      parsedJson = jsonDecode(p.stdout.toString());
    } catch (e) {
      throw Exception(LocalizationManager
          .instance.appLocalization.cmdErrorCreatingTransferTransactionGeneric);
    }
    QubicCmdResponse response;
    try {
      response = QubicCmdResponse.fromJson(parsedJson);
    } catch (e) {
      throw Exception(LocalizationManager.instance.appLocalization
          .cmdErrorCreatingTransferTransaction(e.toString()));
    }

    if (!response.status) {
      throw Exception(LocalizationManager.instance.appLocalization
          .cmdErrorCreatingTransferTransaction(response.error ?? ""));
    }

    if (response.transaction == null) {
      throw Exception(LocalizationManager
          .instance.appLocalization.cmdErrorCreatingTransferTransactionEmpty);
    }

    return response.transaction!;
  }

  Future<List<QubicImportVaultSeed>> importVaultFile(
      String password, String filePath) async {
    await validateFileStreamSignature();
    List<QubicImportVaultSeed>? seeds;

    final p = await Process.run(
        await _getHelperFileFullPath(),
        [
          'wallet.importVaultFile',
          password,
          filePath,
        ],
        runInShell: true);
    late dynamic parsedJson;
    try {
      parsedJson = jsonDecode(p.stdout.toString());
    } catch (e) {
      throw Exception(LocalizationManager
          .instance.appLocalization.importVaultFileGenericError);
    }
    QubicCmdResponse response;
    try {
      response = QubicCmdResponse.fromJson(parsedJson);
    } catch (e) {
      throw Exception(LocalizationManager.instance.appLocalization
          .importVaultFileErrorGeneralMessage(e.toString()));
    }

    if (!response.status) {
      if ((response.error == null) ||
          (!response.error!.contains(" Function"))) {
        throw Exception(LocalizationManager
            .instance.appLocalization.importVaultFilePasswordError);
      }

      throw Exception(LocalizationManager.instance.appLocalization
          .importVaultFileErrorGeneralMessage(toBeginningOfSentenceCase(response
              .error!
              .substring(0, response.error!.indexOf(" Function"))
              .toLowerCase())));
    }

    if (response.seeds == null) {
      throw Exception(LocalizationManager
          .instance.appLocalization.importVaultFileSeedsNullError);
    }
    if (response.seeds!.isEmpty) {
      throw Exception(LocalizationManager
          .instance.appLocalization.importVaultErrorNoAccountsFound);
    }

    seeds = <QubicImportVaultSeed>[];
    var i = 0;
    for (var seed in response.seeds!) {
      if ((seed.getAlias() == null) || (seed.getAlias()!.isEmpty)) {
        throw Exception(LocalizationManager.instance.appLocalization
            .importVaultFileAccountMissingName(i));
      }
      if (seed.getPublicId().isEmpty) {
        throw Exception(LocalizationManager.instance.appLocalization
            .importVaultFileAccountMissingPublicId(i));
      }

      if ((seed.getSeed() == null)) {
        throw Exception(LocalizationManager.instance.appLocalization
            .importVaultFileAccountMissingSeed(i));
      }

      seeds.add(QubicImportVaultSeed(
          seed.getAlias()!, seed.getPublicId(), seed.getSeed() ?? ""));
      i++;
    }

    return seeds;
  }
}
