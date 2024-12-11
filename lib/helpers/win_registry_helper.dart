import 'dart:io';

import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/helpers/platform_helpers.dart';
import 'package:win32_registry/win32_registry.dart';

Future<void> registerToRegistry(String scheme) async {
  String appPath = Platform.resolvedExecutable;

  String protocolRegKey = 'Software\\Classes\\$scheme';
  RegistryValue protocolRegValue = const RegistryValue(
    'URL Protocol',
    RegistryValueType.string,
    '',
  );
  String protocolCmdRegKey = 'shell\\open\\command';
  RegistryValue protocolCmdRegValue = RegistryValue(
    '',
    RegistryValueType.string,
    '"$appPath" "%1"',
  );

  final regKey = Registry.currentUser.createKey(protocolRegKey);
  regKey.createValue(protocolRegValue);
  regKey.createKey(protocolCmdRegKey).createValue(protocolCmdRegValue);
}

//Registers the app scheme to the registry in windows if needed
Future<void> registerAppSchemeIfNeeded() async {
  if (isWindows) {
    await registerToRegistry(Config.CustomURLScheme);
  }
}
