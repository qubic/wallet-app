import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:qubic_wallet/globals/localization_manager.dart';

export 'package:flutter_gen/gen_l10n/app_localizations.dart';

AppLocalizations l10nOf(BuildContext context) {
  if (!LocalizationManager.instance.isInitialized) {
    final localizations = AppLocalizations.of(context);
    if (localizations != null) {
      LocalizationManager.instance.setLocalizations(localizations);
    }
  }
  return AppLocalizations.of(context)!;
}

class L10nWrapper {
  AppLocalizations? l10n;
  void setL10n(AppLocalizations l10) {
    l10n = l10;
  }
}

final l10nWrapper = L10nWrapper();
