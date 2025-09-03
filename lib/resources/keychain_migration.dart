import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qubic_wallet/helpers/app_logger.dart';
import 'package:universal_platform/universal_platform.dart';

class KeychainMigration {
  static const String _migrationKey = 'keychain_migration_completed_v1';

  static Future<bool> needsMigration() async {
    if (!UniversalPlatform.isIOS) return false;
    final prefs = await SharedPreferences.getInstance();
    final migrated = prefs.getBool(_migrationKey);
    return migrated == null || !migrated;
  }

  static Future<void> markMigrationComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_migrationKey, true);
  }

  static Future<void> migrateKeychain() async {
    if (!await needsMigration()) {
      appLogger.i('Keychain migration not needed');
      return;
    }

    appLogger.i('Starting iOS keychain migration...');

    try {
      // Create storage instances with old and new configs
      const oldStorage = FlutterSecureStorage(
        iOptions: IOSOptions(
          synchronizable: false,
          accessibility: KeychainAccessibility.unlocked,
        ),
      );

      const newStorage = FlutterSecureStorage(
        iOptions: IOSOptions(
          synchronizable: false,
          accessibility: KeychainAccessibility.unlocked_this_device,
        ),
      );

      // Read all items from old storage
      final allItems = await oldStorage.readAll();
      if (allItems.isEmpty) {
        appLogger.i('No items to migrate in keychain');
        await markMigrationComplete();
        return;
      }

      appLogger.i('Found ${allItems.length} items to migrate');

      // Migrate each item to new storage
      for (final entry in allItems.entries) {
        try {
          // First check if item already exists in new storage
          final existingValue = await newStorage.read(key: entry.key);
          if (existingValue != null) {
            appLogger.d(
                'Key ${entry.key} already exists in new storage, skipping migration');
            // Still delete from old storage since we have it in new storage
            await oldStorage.delete(key: entry.key);
            continue;
          }

          // Item doesn't exist in new storage, so migrate it

          await oldStorage.delete(key: entry.key);
          await newStorage.write(
            key: entry.key,
            value: entry.value,
          );
          appLogger.d('Migrated key: ${entry.key}');
        } catch (e) {
          appLogger.e('Error migrating key ${entry.key}: $e');
          // Continue with other items even if one fails
        }
      }

      appLogger.i('Keychain migration completed successfully');
      await markMigrationComplete();
    } catch (e) {
      appLogger.e('Failed to migrate keychain: $e');
      rethrow;
    }
  }
}
