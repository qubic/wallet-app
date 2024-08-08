import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:qubic_wallet/globals/localization_manager.dart';

export 'package:flutter_gen/gen_l10n/app_localizations.dart';

AppLocalizations l10nOf(BuildContext context) {
  LocalizationManager.instance.setLocalization(context);
  return AppLocalizations.of(context)!;
}

class L10nWrapper {
  AppLocalizations? l10n;
  L10nWrapper();
}

final l10nWrapper = L10nWrapper();
