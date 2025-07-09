import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/styles/app_icons.dart';
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
    String iconPath = AppIcons.fingerPrint;

    // Check if biometrics are available on the device
    bool canCheckBiometrics = await auth.canCheckBiometrics;
    if (!canCheckBiometrics) {
      return {'label': label, 'icon': iconPath};
    }

    // Get available biometric types
    List<BiometricType> availableBiometrics =
        await auth.getAvailableBiometrics();

    // Determine the type of biometric and update label and icon accordingly
    if (availableBiometrics.contains(BiometricType.face)) {
      label =
          l10n.settingsLabelManageBiometrics(l10n.generalBiometricTypeFaceID);
      iconPath = AppIcons.faceId;
    } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
      label =
          l10n.settingsLabelManageBiometrics(l10n.generalBiometricTypeTouchID);
      iconPath = AppIcons.fingerPrint;
    } else if (availableBiometrics.contains(BiometricType.iris)) {
      label = l10n.settingsLabelManageBiometrics(l10n.generalBiometricTypeIris);
      iconPath = AppIcons.iris;
    } else if (availableBiometrics.contains(BiometricType.strong)) {
      if (UniversalPlatform.isWindows) {
        label = l10n.settingsLabelManageBiometrics(l10n.generalBiometricTypeOS);
        iconPath = AppIcons.security;
      } else {
        label = l10n
            .settingsLabelManageBiometrics(l10n.generalBiometricTypeGeneric);
        iconPath = AppIcons.fingerPrint;
      }
    }

    return {'label': label, 'icon': iconPath};
  }

  /// Handles biometric authentication and returns error message if failed, null if successful
  Future<String?> handleBiometricsAuth(BuildContext context) async {
    final l10n = l10nOf(context);

    try {
      final bool didAuthenticate = await auth.authenticate(
          localizedReason: ' ',
          options: AuthenticationOptions(
              biometricOnly: UniversalPlatform.isDesktop ? false : true));
      return didAuthenticate ? null : l10n.authenticateErrorGeneral;
    } on PlatformException catch (err) {
      if (err.code == lockedOut) {
        return l10n.biometricErrorLockedOut;
      } else if (err.code == permanentlyLockedOut) {
        return l10n.biometricErrorPermanentlyLockedOut;
      } else if (err.code == notAvailable || err.code == otherOperatingSystem) {
        return l10n.biometricErrorNotAvailable;
      } else if (err.code == notEnrolled) {
        return l10n.biometricErrorNotEnrolled;
      } else if (err.code == passcodeNotSet) {
        return l10n.biometricErrorPasscodeNotSet;
      } else if (err.code == biometricOnlyNotSupported) {
        return l10n.biometricErrorBiometricOnlyNotSupported;
      } else {
        return err.message ?? l10n.authenticateErrorGeneral;
      }
    } catch (e) {
      return l10n.authenticateErrorGeneral;
    }
  }
}
