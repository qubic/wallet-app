import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/resources/qubic_cmd_utils.dart';
import 'package:qubic_wallet/stores/settings_store.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:window_manager/window_manager.dart';

class PlatformSpecificInitilization {
  Future<void> _android() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final path = dir.parent.path;
      final file =
          File('$path/databases/com.google.android.datatransport.events');
      if (await file.exists()) {
        await file.writeAsString('Fake');
      }

      if (!kReleaseMode) {
        await InAppWebViewController.setWebContentsDebuggingEnabled(true);
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<void> _iOS() async {}

  Future<void> _mobile() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  Future<void> _windows() async {}
  Future<void> _linux() async {}
  Future<void> _macOS() async {}
  Future<void> _desktop() async {
    // Window management
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
        size: Size(540, 800),
        center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.normal,
        title: 'Qubic Wallet',
        maximumSize: Size(540, 3000),
        minimumSize: Size(320, 600));
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });

    getIt.get<SettingsStore>().cmdUtilsAvailable =
        await QubicCmdUtils().canUseUtilities();
  }

  Future<void> run() async {
    // Initialize platform-specific plugins
    if (UniversalPlatform.isAndroid) {
      await _android();
      await _mobile();
      return;
    }
    if (UniversalPlatform.isIOS) {
      await _iOS();
      await _mobile();
      return;
    }

    if (UniversalPlatform.isWindows) {
      await _windows();
      await _desktop();
      return;
    }

    if (UniversalPlatform.isLinux) {
      await _linux();
      await _desktop();
      return;
    }

    if (UniversalPlatform.isMacOS) {
      await _macOS();
      await _desktop();
      return;
    }
  }
}
