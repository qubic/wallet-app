import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

// ignore: depend_on_referenced_packages
import 'package:crypto/crypto.dart' as crypto;
import 'package:intl/intl.dart' show toBeginningOfSentenceCase;
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/globals/localization_manager.dart';
import 'package:qubic_wallet/helpers/app_logger.dart';
import 'package:qubic_wallet/models/qubic_asset_transfer.dart';
import 'package:qubic_wallet/models/qubic_helper_config.dart';
import 'package:qubic_wallet/models/qubic_import_vault_seed.dart';
import 'package:qubic_wallet/models/qubic_js.dart';
import 'package:qubic_wallet/models/qubic_send_many_transfer.dart';
import 'package:qubic_wallet/models/qubic_sign_result.dart';
import 'package:qubic_wallet/models/qubic_vault_export_seed.dart';
import 'package:qubic_wallet/models/qublic_cmd_response.dart';
import 'package:qubic_wallet/models/signed_transaction.dart';
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

  Future<String> _getHelperFileFullPath({bool isExecutionPath = true}) async {
    var directory = await getApplicationSupportDirectory();

    String scriptPath = path.join(directory.path, _getConfig().filename);

    if (UniversalPlatform.isMacOS && isExecutionPath) {
      // copy the script to the temporary directory from where it can be executed
      scriptPath = await copyScriptToTempDirectory(scriptPath);
    }

    return scriptPath;
  }

  Future<bool> verifyIdentity(String publicId) async {
    await validateFileStreamSignature();

    String scriptPath = await _getHelperFileFullPath();

    // Execute the command
    final p = await Process.run(
        scriptPath, [QubicJSFunctions.verifyIdentity, publicId],
        runInShell: true);

    if (p.exitCode != 0) {
      appLogger.e('Script execution failed with exit code ${p.exitCode}');
      appLogger.e(p.stderr);
      throw Exception(LocalizationManager
          .instance.appLocalization.cmdErrorVerifyingIdentityGeneric);
    }

    late dynamic parsedJson;
    try {
      parsedJson = jsonDecode(p.stdout.toString());
    } catch (e) {
      // throw Exception(LocalizationManager.instance.appLocalization.cmdErrorVerifyingIdentityParsingOutput);
      throw Exception(LocalizationManager
          .instance.appLocalization.cmdErrorVerifyIdentityJsonDecoding);
    }

    QubicCmdResponse response;
    try {
      response = QubicCmdResponse.fromJson(parsedJson);
    } catch (e) {
      // throw Exception(LocalizationManager.instance.appLocalization.cmdErrorVerifyingIdentityParsingOutput);
      throw Exception(LocalizationManager
          .instance.appLocalization.cmdErrorVerifyIdentityParsingError);
    }

    if (!response.status) {
      throw Exception(LocalizationManager.instance.appLocalization
          .cmdErrorVerifyingIdentity(response.error ?? ""));
    }

    return response.isValid ?? false;
  }

  Future<bool> checkIfUtilitiesExist() async {
    return await File(await _getHelperFileFullPath(isExecutionPath: false))
        .exists();
  }

  Future<bool> checkUtilitiesChecksum() async {
    String generatedChecksum = await _getFileChecksum(
            await _getHelperFileFullPath(isExecutionPath: false)) ??
        "";
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
          QubicJSFunctions.createVaultFile,
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

  Future<String> copyScriptToTempDirectory(String originalScriptPath) async {
    // Read the file from the original path
    File originalFile = File(originalScriptPath);

    // Get the temporary directory
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = '${tempDir.path}/${_getConfig().filename}';

    File tempFile = File(tempPath);
    if (!await tempFile.exists()) {
      // Copy the script to the temporary directory if does not exists already
      tempFile = await originalFile.copy(tempPath);

      // Make the script executable
      await Process.run('chmod', ['+x', tempPath]);
    }

    return tempFile.path;
  }

  Future<String> getPublicIdFromSeed(String seed) async {
    await validateFileStreamSignature();

    String scriptPath = await _getHelperFileFullPath();

    final p = await Process.run(
        scriptPath, [QubicJSFunctions.createPublicId, seed],
        runInShell: true);

    if (p.exitCode != 0) {
      appLogger.e('Script execution failed with exit code ${p.exitCode}');
      appLogger.e(p.stderr);
      throw Exception(LocalizationManager.instance.appLocalization
          .cmdErrorGettingPublicIdFromSeed(p.stderr));
    }

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

  Future<QubicAssetTransfer> parseAssetTransferPayload(String data) async {
    try {
      final result = await Process.run(
          await _getHelperFileFullPath(),
          [
            QubicJSFunctions.parseAssetTransferPayload,
            data,
          ],
          runInShell: true);
      final decodedResult = json.decode(result.stdout);
      final asset = QubicAssetTransfer.fromJson(decodedResult);
      return asset;
    } catch (e) {
      appLogger.e('Error parsing asset transfer: $e');
      rethrow;
    }
  }

  Future<List<QubicSendManyTransfer>> parseTransferSendManyPayload(
      String data) async {
    try {
      final result = await Process.run(
          await _getHelperFileFullPath(),
          [
            QubicJSFunctions.parseTransferSendManyPayload,
            data,
          ],
          runInShell: true);
      final Map<String, dynamic> decodedResult = json.decode(result.stdout);
      List<QubicSendManyTransfer> transfers = decodedResult.entries
          .where((entry) => entry.value is Map<String, dynamic>)
          .map((entry) => QubicSendManyTransfer.fromJson(entry.value))
          .toList();
      return transfers;
    } catch (e) {
      appLogger.e('Error parsing asset transfer: $e');
      rethrow;
    }
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
          QubicJSFunctions.createTransactionAssetMove,
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

  Future<SignedTransaction> createTransaction(String seed, String destinationId,
      int value, int tick, int? inputType, String? payload) async {
    await validateFileStreamSignature();
    final p = (inputType == null)
        ? await Process.run(
            await _getHelperFileFullPath(),
            [
              QubicJSFunctions.createTransaction,
              seed,
              destinationId,
              value.toString(),
              tick.toString()
            ],
            runInShell: true)
        : (payload == null)
            ? await Process.run(
                await _getHelperFileFullPath(),
                [
                  QubicJSFunctions.createTransactionWithPayload,
                  seed,
                  destinationId,
                  value.toString(),
                  tick.toString(),
                  inputType.toString(),
                ],
                runInShell: true)
            : await Process.run(await _getHelperFileFullPath(), [
                QubicJSFunctions.createTransactionWithPayload,
                seed,
                destinationId,
                value.toString(),
                tick.toString(),
                inputType.toString(),
                payload
              ]);

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

    return SignedTransaction(
        transactionKey: response.transaction!,
        transactionId: response.transactionId!);
  }

  Future<List<QubicImportVaultSeed>> importVaultFile(
      String password, String filePath) async {
    await validateFileStreamSignature();
    List<QubicImportVaultSeed>? seeds;

    final p = await Process.run(
        await _getHelperFileFullPath(),
        [
          QubicJSFunctions.importVaultFile,
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
            .instance.appLocalization.importVaultFileOrPasswordError);
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

  Future<QubicSignResult> signBase64(String seed, String base64) async {
    await validateFileStreamSignature();
    final p = await Process.run(
        await _getHelperFileFullPath(),
        [
          QubicJSFunctions.signRaw,
          seed,
          base64,
        ],
        runInShell: true);
    late dynamic parsedJson;
    try {
      parsedJson = jsonDecode(p.stdout.toString());
    } catch (e) {
      throw Exception(LocalizationManager
          .instance.appLocalization.cmdErrorCreatingSignatureGeneric);
    }
    QubicCmdResponse response;
    try {
      response = QubicCmdResponse.fromJson(parsedJson);
    } catch (e) {
      throw Exception(LocalizationManager.instance.appLocalization
          .cmdErrorCreatingSignature(e.toString()));
    }

    if (!response.status) {
      throw Exception(LocalizationManager.instance.appLocalization
          .cmdErrorCreatingSignature(response.error ?? ""));
    }

    if (response.digest == null) {
      throw Exception(LocalizationManager
          .instance.appLocalization.cmdErrorCreatingSignatureDigestEmpty);
    }

    if (response.signature == null) {
      throw Exception(LocalizationManager
          .instance.appLocalization.cmdErrorCreatingSignatureSignatureEmpty);
    }

    if (response.signedData == null) {
      throw Exception(LocalizationManager
          .instance.appLocalization.cmdErrorCreatingSignatureSignedDataEmpty);
    }

    return QubicSignResult.fromCMDResponse(response);
  }

  Future<QubicSignResult> signASCII(String seed, String asciiText) async {
    await validateFileStreamSignature();
    final p = await Process.run(
        await _getHelperFileFullPath(),
        [
          QubicJSFunctions.signASCII,
          seed,
          asciiText,
        ],
        runInShell: true);
    late dynamic parsedJson;
    try {
      parsedJson = jsonDecode(p.stdout.toString());
    } catch (e) {
      throw Exception(LocalizationManager
          .instance.appLocalization.cmdErrorCreatingSignatureGeneric);
    }
    QubicCmdResponse response;
    try {
      response = QubicCmdResponse.fromJson(parsedJson);
    } catch (e) {
      throw Exception(LocalizationManager.instance.appLocalization
          .cmdErrorCreatingSignature(e.toString()));
    }

    if (!response.status) {
      throw Exception(LocalizationManager.instance.appLocalization
          .cmdErrorCreatingSignature(response.error ?? ""));
    }

    if (response.digest == null) {
      throw Exception(LocalizationManager
          .instance.appLocalization.cmdErrorCreatingSignatureDigestEmpty);
    }

    if (response.signature == null) {
      throw Exception(LocalizationManager
          .instance.appLocalization.cmdErrorCreatingSignatureSignatureEmpty);
    }

    if (response.signedData == null) {
      throw Exception(LocalizationManager
          .instance.appLocalization.cmdErrorCreatingSignatureSignedDataEmpty);
    }

    return QubicSignResult.fromCMDResponse(response);
  }

  Future<QubicSignResult> signUTF8(String seed, String utf8Text) async {
    await validateFileStreamSignature();
    final p = await Process.run(
        await _getHelperFileFullPath(),
        [
          QubicJSFunctions.signUTF8,
          seed,
          utf8Text,
        ],
        runInShell: true);
    late dynamic parsedJson;
    try {
      parsedJson = jsonDecode(p.stdout.toString());
    } catch (e) {
      throw Exception(LocalizationManager
          .instance.appLocalization.cmdErrorCreatingSignatureGeneric);
    }
    QubicCmdResponse response;
    try {
      response = QubicCmdResponse.fromJson(parsedJson);
    } catch (e) {
      throw Exception(LocalizationManager.instance.appLocalization
          .cmdErrorCreatingSignature(e.toString()));
    }

    if (!response.status) {
      throw Exception(LocalizationManager.instance.appLocalization
          .cmdErrorCreatingSignature(response.error ?? ""));
    }

    if (response.digest == null) {
      throw Exception(LocalizationManager
          .instance.appLocalization.cmdErrorCreatingSignatureDigestEmpty);
    }

    if (response.signature == null) {
      throw Exception(LocalizationManager
          .instance.appLocalization.cmdErrorCreatingSignatureSignatureEmpty);
    }

    if (response.signedData == null) {
      throw Exception(LocalizationManager
          .instance.appLocalization.cmdErrorCreatingSignatureSignedDataEmpty);
    }

    return QubicSignResult.fromCMDResponse(response);
  }
}
