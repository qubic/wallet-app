import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:universal_platform/universal_platform.dart';

class BiometricService {
  final LocalAuthentication auth = LocalAuthentication();

  /// This function checks the available biometrics and returns a tuple containing
  /// the biometric type string and the corresponding icon widget.
  Future<Map<String, dynamic>> getAvailableBiometric(
      BuildContext context) async {
    final l10n = l10nOf(context);
    String label =
        l10n.settingsLabelManageBiometrics(l10n.generalBiometricTypeGeneric);
    Widget icon = const Icon(Icons.fingerprint);

    // Check if biometrics are available on the device
    bool canCheckBiometrics = await auth.canCheckBiometrics;
    if (!canCheckBiometrics) {
      return {'label': label, 'icon': icon};
    }

    // Get available biometric types
    List<BiometricType> availableBiometrics =
        await auth.getAvailableBiometrics();

    // Determine the type of biometric and update label and icon accordingly
    if (availableBiometrics.contains(BiometricType.face)) {
      label =
          l10n.settingsLabelManageBiometrics(l10n.generalBiometricTypeFaceID);
      icon = Image.asset("assets/images/faceid.png");
    } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
      label =
          l10n.settingsLabelManageBiometrics(l10n.generalBiometricTypeTouchID);
      icon = const Icon(Icons.fingerprint);
    } else if (availableBiometrics.contains(BiometricType.iris)) {
      label = l10n.settingsLabelManageBiometrics(l10n.generalBiometricTypeIris);
      icon = const Icon(Icons.remove_red_eye_outlined);
    } else if (availableBiometrics.contains(BiometricType.strong)) {
      if (UniversalPlatform.isWindows) {
        label = l10n.settingsLabelManageBiometrics(l10n.generalBiometricTypeOS);
        icon = const Icon(Icons.security);
      } else {
        label = l10n
            .settingsLabelManageBiometrics(l10n.generalBiometricTypeGeneric);
        icon = const Icon(Icons.fingerprint);
      }
    }

    return {'label': label, 'icon': icon};
  }
}
