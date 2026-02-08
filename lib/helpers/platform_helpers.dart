import 'package:flutter_is_ios_app_on_mac/flutter_is_ios_app_on_mac.dart';
import 'package:universal_platform/universal_platform.dart';

bool isIOS = UniversalPlatform.isIOS;
bool isAndroid = UniversalPlatform.isAndroid;
bool isMacOS = UniversalPlatform.isMacOS;
bool isWindows = UniversalPlatform.isWindows;
bool isLinux = UniversalPlatform.isLinux;
bool isFuchsia = UniversalPlatform.isFuchsia;
bool isWeb = UniversalPlatform.isWeb;
bool isDesktop = isWindows || isLinux || isFuchsia || isMacOS;

/// Whether this is an iOS app running on Mac via compatibility mode.
/// Must be initialized by calling [initializePlatformHelpers] at app startup.
bool isIosAppOnMac = false;

bool isMobile = isAndroid || isIOS;

/// Initialize platform helpers that require async checks.
/// Call this early in app startup (e.g., in main()).
Future<void> initializePlatformHelpers() async {
  isIosAppOnMac = await FlutterIsIosAppOnMac.isIosAppOnMac();
}
