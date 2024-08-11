// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/helpers/global_snack_bar.dart';
import 'package:qubic_wallet/l10n/l10n.dart';

/// Copies a string to clipboard and shows a snackbar
copyToClipboard(String copiedText, BuildContext context) async {
  final l10n = l10nOf(context);

  final _globalSnackBar = getIt<GlobalSnackBar>();
  await Clipboard.setData(ClipboardData(text: copiedText));
  _globalSnackBar.show(l10n.generalSnackBarMessageCopiedToClipboard);
}
