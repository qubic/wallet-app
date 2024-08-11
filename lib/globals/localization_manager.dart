import 'package:flutter/material.dart';
import 'package:qubic_wallet/l10n/l10n.dart';

/// Localization manager
///
/// Holds an instance of the current localization as a global object to be used in services
/// It is initialized via setLocalization method, which is called every time the localization is fetched via context
class LocalizationManager {
  static final LocalizationManager instance = LocalizationManager._();
  LocalizationManager._();

  AppLocalizations? _localization;

  /// Get the current localization. Throws error if not initialized
  AppLocalizations get appLocalization => _localization!;

  /// Check if the localization is initialized
  bool get isInitialized => _localization != null;

  /// Set the current localization (memoized)
  ///
  /// This is done to avoid context in services
  void setLocalizations(AppLocalizations localizations) {
    if (_localization != null) {
      return;
    }
    _localization = localizations;
  }

  /// Replace the current localization
  /// (no memoization takes place)
  void replaceLocalizations(AppLocalizations localizations) {
    _localization = localizations;
  }

  /// Clear the current localization
  void clearLocalizations() {
    _localization = null;
  }
}
