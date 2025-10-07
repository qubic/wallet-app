// ignore_for_file: non_constant_identifier_names

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:qubic_wallet/helpers/app_logger.dart';
import 'package:qubic_wallet/models/critical_settings.dart';
import 'package:qubic_wallet/models/qubic_id.dart';
import 'package:qubic_wallet/models/qubic_list_vm.dart';
import 'package:qubic_wallet/models/settings.dart';
import 'package:qubic_wallet/resources/keychain_migration.dart';
import 'dart:convert';
import 'dart:developer' as dev;
import 'package:cryptography/cryptography.dart';
import 'package:universal_platform/universal_platform.dart';

class SecureStorageKeys {
  static const prepend = kReleaseMode
      ? "QW_"
      : "QW_DEBUG_"; // The prefix of all the keys in the secure storage

  static const criticalSettings =
      "${prepend}_CSETTINGS"; //The critical settings

  static const passwordHash =
      "${prepend}_PH"; // The hash of the password used to sign in the wallet
  static const walletSchemaVersion =
      "${prepend}_WV"; // The version of the wallet schema
  static const numberOfIDs =
      "${prepend}_NIDs"; // The number of IDs in the wallet
  static const privateSeedsList = "${prepend}_PS"; // The private IDs
  static const publicIdsList = "${prepend}_PIDs"; // The public IDs
  static const namesList = "${prepend}_NAMEs"; // The names of the IDs
  static const settings = "${prepend}_SETTINGS"; // The settings of the wallet
  static const hiveEncryptionKey = "${prepend}_HIVE_KEY";
}

/// A class that handles the secure storage of the wallet. The wallet is stored in the secure storage of the device
/// The wallet password is encrypted using Argon2
class SecureStorage {
  // final ARGON2_TYPE = Argon2Type.id;
  static const argon2SaltSizeBytes = 32; //(256 bit)
  static const argon2Iterations = 64;
  static const argon2MemorySize = 1024;
  static const argon2Parallelism = 2;
  static const argon2Length = 32;
  late final FlutterSecureStorage storage;
  late String prepend;
  SecureStorage() {
    storage = const FlutterSecureStorage(
        aOptions: AndroidOptions(
          encryptedSharedPreferences: true,
        ),
        iOptions: IOSOptions(
          synchronizable: false,
          accessibility: KeychainAccessibility.passcode,
        ));
  }

  Future<void> initialize() async {
    if (UniversalPlatform.isIOS) {
      await KeychainMigration.migrateKeychain();
    }
  }

  final _argon2idAlgorithm = Argon2id(
    memory: argon2MemorySize,
    iterations: argon2Iterations,
    parallelism: argon2Parallelism,
    hashLength: argon2Length,
  );
  Future<String?> getHiveEncryptionKey() async {
    try {
      final keyString =
          await storage.read(key: SecureStorageKeys.hiveEncryptionKey);
      return keyString;
    } catch (e) {
      appLogger.e("Error reading Hive key: ${e.toString()}");
      return null;
    }
  }

  Future<void> storeHiveEncryptionKey(String newKey) async {
    try {
      await storage.write(
        key: SecureStorageKeys.hiveEncryptionKey,
        value: newKey,
      );
    } catch (e) {
      appLogger.e("Error generating Hive key: ${e.toString()}");
    }
  }

  Future<void> deleteHiveEncryptionKey() async {
    await storage.delete(key: SecureStorageKeys.hiveEncryptionKey);
  }

  Uint8List generateSalt(int length) {
    final random = Random.secure();
    return Uint8List.fromList(
        List<int>.generate(length, (_) => random.nextInt(256)));
  }

  /// Checks if the critical settings exist in the secure storage
  /// Returns true if the critical settings exist
  /// Returns false if the critical settings do not exist
  Future<bool> criticalSettingsExist() async {
    try {
      CriticalSettings csettings = await getCriticalSettings();
      if (csettings.storedPasswordHash == null ||
          csettings.storedPasswordHash!.trim().isEmpty) {
        return false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<CriticalSettings> getCriticalSettings() async {
    String? json = await storage.read(key: SecureStorageKeys.criticalSettings);
    if (json == null) {
      throw "Error while fetching critical settings";
    }
    try {
      return CriticalSettings.fromJSON(json);
    } catch (e) {
      throw "Error while parsing critical settings";
    }
  }

  Uint8List decodeBase64WithPadding(String input) {
    int mod = input.length % 4;
    if (mod > 0) {
      input += '=' * (4 - mod); // add necessary padding
    }
    return base64.decode(input);
  }

  Future<bool> verifyArgon2Hash({
    required String password,
    required String hashString,
  }) async {
    /// Parse PHC components for example: argon2id$v=19$m=1024,t=64,p=2$VW/30Zp2IWl7EQhxTgK7YHTQMwW0Fdv0g32xTX2q1ZU$T8tM27lPD1glAjCHnq1VhLu7/OC9U+T5E2f8XeL6sJk
    final parts = hashString.split(r'$');
    if (parts.length < 6) return false;
    final saltBase64 = parts[4];
    final hashBase64 = parts[5];
    final salt = decodeBase64WithPadding(saltBase64);
    final expectedHash = decodeBase64WithPadding(hashBase64);
    dev.log("Started verifying the hash");
    final newHash = await _argon2idAlgorithm.deriveKeyFromPassword(
        password: password, nonce: salt);
    dev.log("Hash generated");
    final newHashBytes = await newHash.extractBytes();
    dev.log("Extract bytes");
    return _constantTimeBytesEqual(newHashBytes, expectedHash);
  }

  bool _constantTimeBytesEqual(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    int diff = 0;
    for (int i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }

  /// Signs a user in the wallet. Updates the padding of the wallet settings
  /// if user signs in correctly
  /// Returns true if the password is correct
  Future<bool> signInWallet(String password) async {
    CriticalSettings settings = await getCriticalSettings();
    if (password.isEmpty ||
        password.trim().isEmpty ||
        settings.storedPasswordHash == null ||
        settings.storedPasswordHash!.trim().isEmpty) {
      return false;
    }
    dev.log('password: $password');
    dev.log('hash: ${settings.storedPasswordHash}');
    var result = await verifyArgon2Hash(
      password: password,
      hashString: settings.storedPasswordHash!,
    );
    dev.log('result: $result');
    if (result) {
      Settings s = await getWalletSettings();
      s.padding = settings.padding;
      await setWalletSettings(s);
    }
    return result;
  }

  //Makes sure that all the wallet keys are valid
  Future<bool> validateWalletContents() async {
    try {
      await getCriticalSettings();
    } catch (e) {
      return false;
    }
    String? settings = await storage.read(key: SecureStorageKeys.settings);
    if (settings == null) {
      return false;
    }
    return true;
  }

  Future<bool> savePassword(String password) async {
    if (password.isEmpty || password.trim().isEmpty) {
      return false;
    }
    try {
      var result = await hashPasswordWithArgon2id(password);
      CriticalSettings settings = await getCriticalSettings();
      settings.storedPasswordHash = result;
      await storage.write(
          key: SecureStorageKeys.criticalSettings, value: settings.toJSON());
    } catch (e) {
      appLogger.e(e.toString());
      return false;
    }
    return true;
  }

  /// Generates a secure random salt for password hashing
  Uint8List generateSecureSalt(int saltLength) {
    final random = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(saltLength, (_) => random.nextInt(256)),
    );
  }

  /// Encodes bytes to base64 without padding
  String encodeBase64WithoutPadding(Uint8List bytes) {
    String base64Str = base64.encode(bytes);
    return base64Str.replaceAll('=', '');
  }

  /// Creates an Argon2id hash in PHC string format from a password
  /// Returns a string in the format: $argon2id$v=19$m=1024,t=64,p=2$salt$hash
  ///
  /// This optimized version reduces async operations and reuses the algorithm instance
  Future<String> hashPasswordWithArgon2id(String password) async {
    final salt = generateSecureSalt(argon2SaltSizeBytes);
    dev.log('Generating key');
    final secretKey = await _argon2idAlgorithm.deriveKeyFromPassword(
      password: password,
      nonce: salt,
    );
    dev.log('Key generated');
    dev.log('Extracting bytes');
    final hashBytes = await secretKey.extractBytes();
    dev.log('Bytes extracted');
    // Convert salt and hash to base64 without padding for PHC format
    final saltBase64 = encodeBase64WithoutPadding(salt);
    final hashBase64 =
        encodeBase64WithoutPadding(Uint8List.fromList(hashBytes));
    // Construct the PHC string format
    return '\$argon2id\$v=19\$m=$argon2MemorySize,t=$argon2Iterations,p=$argon2Parallelism\$$saltBase64\$$hashBase64';
  }

  // Creates a new wallet
  // Returns true if the wallet was created successfully
  Future<bool> createWallet(String password) async {
    if (password.isEmpty || password.trim().isEmpty) {
      return false;
    }
    var result = await hashPasswordWithArgon2id(password);
    dev.log("The new hash after creating the wallet is: $result");
    CriticalSettings csettings = CriticalSettings(
        storedPasswordHash: result, publicIds: [], privateSeeds: [], names: []);

    await storage.write(
        key: SecureStorageKeys.criticalSettings, value: csettings.toJSON());
    await storage.write(
        key: SecureStorageKeys.settings,
        value: Settings(
                TOTPKey: null,
                biometricEnabled: false,
                padding: csettings.padding)
            .toJSON());
    return true;
  }

  Future<Settings> getWalletSettings() async {
    String? settings = await storage.read(key: SecureStorageKeys.settings);
    if (settings == null) {
      throw Exception("Settings not found");
    }

    Settings settingsObj;
    try {
      settingsObj = Settings.fromJson(settings);
    } catch (e) {
      throw Exception("Settings not found or malformed");
    }

    return settingsObj;
  }

  Future<void> updateWalletSettingsPadding(String padding) async {
    var settings = await getWalletSettings();
    settings.padding = padding;
    await storage.write(
        key: SecureStorageKeys.settings, value: settings.toJSON());
  }

  Future<Settings> setWalletSettings(Settings settings) async {
    var csettings = await getCriticalSettings();
    settings.padding = csettings.padding;

    await storage.write(
        key: SecureStorageKeys.settings, value: settings.toJSON());
    return settings;
  }

  Future<List<QubicListVm>> getWalletContents() async {
    CriticalSettings settings = await getCriticalSettings();
    List<QubicListVm> list = [];
    for (int i = 0; i < settings.publicIds.length; i++) {
      list.add(QubicListVm(settings.publicIds[i], settings.names[i], null, null,
          null, settings.isWatchOnly[i]));
    }
    return list;
  }

  Future<bool> deleteWallet() async {
    await storage.deleteAll();
    return true;
  }

  Future<void> addManyIds(List<QubicId> ids) async {
    CriticalSettings settings = await getCriticalSettings();
    for (QubicId id in ids) {
      settings.privateSeeds.add(id.getPrivateSeed());
      settings.publicIds.add(id.getPublicId());
      settings.names.add(id.getName());
    }
    await storage.write(
        key: SecureStorageKeys.criticalSettings, value: settings.toJSON());
    await updateWalletSettingsPadding(settings.padding!);
  }

  // Adds a new Qubic ID to the secure storage
  Future<void> addID(QubicId qubicId,
      {bool isDerivedFromMnemonic = false}) async {
    CriticalSettings settings = await getCriticalSettings();

    settings.privateSeeds.add(qubicId.getPrivateSeed());
    settings.publicIds.add(qubicId.getPublicId());
    settings.names.add(qubicId.getName());
    if (isDerivedFromMnemonic) {
      settings.idsGeneratedFromMnemonic.add(qubicId.getPublicId());
    }
    await storage.write(
        key: SecureStorageKeys.criticalSettings, value: settings.toJSON());
    await updateWalletSettingsPadding(settings.padding!);
  }

  Future<void> renameId(String publicId, String name) async {
    CriticalSettings settings = await getCriticalSettings();
    int i = settings.publicIds.indexOf(publicId);
    if (i == -1) return;
    settings.names[i] = name;

    await storage.write(
        key: SecureStorageKeys.criticalSettings, value: settings.toJSON());
    await updateWalletSettingsPadding(settings.padding!);
  }

  //Gets a Qubic ID from a public key
  Future<QubicId> getIdByPublicKey(String publicKey) async {
    CriticalSettings settings = await getCriticalSettings();
    int i = settings.publicIds.indexOf(publicKey);
    if (i == -1) {
      throw Exception("ID not found");
    }
    return QubicId(settings.privateSeeds[i], settings.publicIds[i],
        settings.names[i], null);
  }

  //Removes a Qubic ID from the secure Storage (Based on its public key)
  Future<bool> removeID(String publicKey) async {
    CriticalSettings settings = await getCriticalSettings();
    int i = settings.publicIds.indexOf(publicKey);
    if (i == -1) {
      return false;
    }

    settings.privateSeeds.removeAt(i);
    settings.publicIds.removeAt(i);
    settings.names.removeAt(i);
    settings.idsGeneratedFromMnemonic.remove(publicKey);
    await storage.write(
        key: SecureStorageKeys.criticalSettings, value: settings.toJSON());
    await updateWalletSettingsPadding(settings.padding!);
    return true;
  }
}
