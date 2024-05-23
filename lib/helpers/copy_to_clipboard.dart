// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/services.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/helpers/global_snack_bar.dart';

/// Copies a string to clipboard ans shows a snackbar
copyToClipboard(String copiedText) async {
  final _globalSnackBar = getIt<GlobalSnackBar>();
  await Clipboard.setData(ClipboardData(text: copiedText));
  _globalSnackBar.show('Copied to clipboard');
}
