import 'package:flutter/material.dart';
import 'package:qubic_wallet/l10n/l10n.dart';

class LocalizationManager {
  static final LocalizationManager instance = LocalizationManager._();
  LocalizationManager._();

  AppLocalizations? _localization;

  AppLocalizations get appLocalization => _localization!;

  void setLocalization(BuildContext context) {
    if (_localization != null) {
      return;
    }
    if (AppLocalizations.of(context) != null) {
      _localization = AppLocalizations.of(context)!;
    }
  }
}
