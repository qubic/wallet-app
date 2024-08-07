import 'package:intl/intl.dart' show toBeginningOfSentenceCase;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as Path;

import 'package:path_provider/path_provider.dart';
import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/models/qubic_helper_config.dart';
import 'package:qubic_wallet/models/qubic_id.dart';
import 'package:qubic_wallet/models/qubic_import_vault_seed.dart';
import 'package:qubic_wallet/models/qubic_vault_export_seed.dart';
import 'package:qubic_wallet/models/qublic_cmd_response.dart';
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
    throw Exception('Unsupported platform');
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
    return (Path.join(directory.path, _getConfig().filename));
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
      throw Exception(
          'Failed to create vault file. Invalid response from helper');
    }
    QubicCmdResponse response;
    try {
      response = QubicCmdResponse.fromJson(parsedJson);
    } catch (e) {
      throw Exception(
          'Failed to create vault file. Could not parse response from helper');
    }

    if (response.status == false) {
      throw Exception('Failed to create vault file. Error: ${response.error}');
    }

    if ((response.base64 == null) || (response.base64!.isEmpty)) {
      throw Exception(
          'Failed to create vault file. Helper returned empty vault file');
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
      throw Exception(
          'Failed to get public seed. Invalid response from helper');
    }
    QubicCmdResponse response;
    try {
      response = QubicCmdResponse.fromJson(parsedJson);
    } catch (e) {
      throw Exception(
          'Failed to get public seed. Could not parse response from helper');
    }

    if (!response.status) {
      throw Exception('Failed to get public seed. Error: ${response.error}');
    }

    if (response.publicId == null) {
      throw Exception(
          'Failed to get public seed. Helper returned empty public id');
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
      throw Exception(
          'Failed to create asset transfer transaction. Invalid response from helper');
    }
    QubicCmdResponse response;
    try {
      response = QubicCmdResponse.fromJson(parsedJson);
    } catch (e) {
      throw Exception(
          'Failed to create asset transfer transaction. Could not parse response from helper');
    }

    if (!response.status) {
      throw Exception(
          'Failed to create asset transfer transaction. Error: ${response.error}');
    }

    if (response.transaction == null) {
      throw Exception(
          'Failed to create asset transfer transaction. Helper returned empty transaction');
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
      throw Exception(
          'Failed to create transaction. Invalid response from helper');
    }
    QubicCmdResponse response;
    try {
      response = QubicCmdResponse.fromJson(parsedJson);
    } catch (e) {
      throw Exception(
          'Failed to create transaction. Could not parse response from helper');
    }

    if (!response.status) {
      throw Exception('Failed to create transaction. Error: ${response.error}');
    }

    if (response.transaction == null) {
      throw Exception(
          'Failed to create transaction. Helper returned empty transaction');
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
      throw Exception(
          'Failed to read vault file. Invalid response from helper');
    }
    QubicCmdResponse response;
    try {
      response = QubicCmdResponse.fromJson(parsedJson);
    } catch (e) {
      throw Exception(
          'Failed to read vault file. Could not parse response from helper. Error was ${e.toString()}');
    }

    if (!response.status) {
      if ((response.error == null) ||
          (!response.error!.contains(" Function"))) {
        throw Exception('Failed to read and decrypt vault file.');
      }

      throw Exception(toBeginningOfSentenceCase(response.error!
          .substring(0, response.error!.indexOf(" Function"))
          .toLowerCase()));
    }

    if (response.seeds == null) {
      throw Exception('Vault file is empty.');
    }
    if (response.seeds!.isEmpty) {
      throw Exception('Vault file contains no seeds');
    }

    seeds = <QubicImportVaultSeed>[];
    var i = 1;
    for (var seed in response.seeds!) {
      if ((seed.getAlias() == null) || (seed.getAlias()!.isEmpty)) {
        throw Exception('Entry number $i is missing alias/account name');
      }
      if (seed.getPublicId().isEmpty) {
        throw Exception('Entry number $i is missing public ID');
      }
      if ((seed.getSeed() == null)) {
        throw Exception('Entry number $i is missing seed');
      }

      if (seed.getSeed()!.isNotEmpty) {
        seeds.add(QubicImportVaultSeed(
            seed.getAlias()!, seed.getPublicId(), seed.getSeed()!));
      }
    }

    return seeds;
  }
}
