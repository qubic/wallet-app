// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/helpers/app_logger.dart';
import 'package:qubic_wallet/helpers/global_snack_bar.dart';

import 'dart:async';
import 'package:qubic_wallet/l10n/l10n.dart';

class ClipboardHelper {
  static final ClipboardHelper _instance = ClipboardHelper._internal();
  factory ClipboardHelper() => _instance;
  ClipboardHelper._internal();

  Timer? _clipboardTimer;
  DateTime? _clipboardSetTime;

  static Future<void> copyToClipboard(
    String copiedText,
    BuildContext context, {
    String? message,
    bool isSensitive = false,
  }) async {
    final l10n = l10nOf(context);
    final globalSnackBar = getIt<GlobalSnackBar>();

    await Clipboard.setData(ClipboardData(text: copiedText));
    globalSnackBar
        .show(message ?? l10n.generalSnackBarMessageCopiedToClipboard);
    if (isSensitive) {
      _instance._startSensitiveClipboardTimer();
    }
  }

  void _startSensitiveClipboardTimer() {
    _clipboardSetTime = DateTime.now();
    _clipboardTimer?.cancel();
    _clipboardTimer = Timer(const Duration(minutes: 1), () async {
      await Clipboard.setData(const ClipboardData(text: ''));
      _clipboardTimer = null;
      _clipboardSetTime = null;
      appLogger.i('[Clipboard] cleared after 1 minute');
    });
  }

  /// Call this on app resume to clear clipboard if expired (only for sensitive copies)
  static void checkAndClearExpiredClipboard() {
    if (_instance._clipboardSetTime != null &&
        DateTime.now().difference(_instance._clipboardSetTime!).inSeconds >=
            60) {
      _instance._clearSensitiveClipboard();
      appLogger
          .i('[Clipboard] cleared expired sensitive content on app resume');
    }
  }

  /// Immediately clears sensitive clipboard content and cancels timer
  void _clearSensitiveClipboard() {
    Clipboard.setData(const ClipboardData(text: ''));
    _clipboardTimer?.cancel();
    _clipboardTimer = null;
    _clipboardSetTime = null;
  }
}
