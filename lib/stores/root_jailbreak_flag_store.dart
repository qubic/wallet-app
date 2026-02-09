import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/helpers/platform_helpers.dart';
import 'package:qubic_wallet/helpers/show_alert_dialog.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/routes.dart';
import 'package:safe_device/safe_device.dart';

part 'root_jailbreak_flag_store.g.dart';

class RootJailbreakFlagStore = RootJailbreakFlagStoreBase
    with _$RootJailbreakFlagStore;

abstract class RootJailbreakFlagStoreBase with Store {
  @observable
  bool isRootedOrJailbroken = false;

  RootJailbreakFlagStoreBase() {
    checkDeviceState();
  }

  @action
  Future<void> checkDeviceState() async {
    // Only check on mobile devices (safe_device only supports iOS/Android)
    // Also skip iOS apps running on Mac (false positives)
    if (!isMobile || isIosAppOnMac) {
      isRootedOrJailbroken = false;
      return;
    }

    bool isSafeDevice = await SafeDevice.isSafeDevice;
    isRootedOrJailbroken = !isSafeDevice;
  }

  Future<void> showWarningDialog(BuildContext context) async {
    final l10n = l10nWrapper.l10n;
    if (isRootedOrJailbroken && l10n != null) {
      showAlertDialog(
        context,
        l10n.rootJailbreakDialogTitleWarning,
        l10n.rootJailbreakDialogMessageWarning,
        primaryButtonLabel: l10n.rootJailbreakDialogButtonWarning,
      );
    }
  }

  Future<void> showRestrictDialog(BuildContext context) async {
    final l10n = l10nWrapper.l10n;
    if (isRootedOrJailbroken && l10n != null) {
      showAlertDialog(
        context,
        l10n.rootJailbreakDialogTitleRestrict,
        l10n.rootJailbreakDialogMessageRestrict,
        primaryButtonLabel: l10n.rootJailbreakDialogButtonRestrict,
      );
    }
  }

  Future<void> showSecurityWarningIfNeeded() async {
    final context = rootNavigatorKey.currentState?.context;
    if (!isRootedOrJailbroken || context == null) return;
    switch (Config.deviceIntegrityResponse) {
      case DeviceIntegrityResponse.warn:
        await showWarningDialog(context);
        break;
      case DeviceIntegrityResponse.restrict:
        await showRestrictDialog(context);
        break;
      case DeviceIntegrityResponse.none:
        break;
    }
  }

  bool get isDeviceRestricted =>
      Config.deviceIntegrityResponse == DeviceIntegrityResponse.restrict &&
      isRootedOrJailbroken;

  Future<void> showRestrictFeatureDialog(BuildContext context) async {
    final l10n = l10nWrapper.l10n;
    if (isRootedOrJailbroken && l10n != null) {
      showAlertDialog(
        context,
        l10n.rootJailbreakDialogTitleRestrictFeature,
        l10n.rootJailbreakDialogMessageRestrictFeature,
        primaryButtonLabel: l10n.rootJailbreakDialogButtonRestrictFeature,
      );
    }
  }

  bool restrictFeatureIfDeviceCompromised() {
    if (isDeviceRestricted && rootNavigatorKey.currentState?.context != null) {
      showRestrictFeatureDialog(rootNavigatorKey.currentState!.context);
    }

    return isDeviceRestricted;
  }
}

/// Defines how the app responds to rooted (Android) or jailbroken (iOS) devices.
enum DeviceIntegrityResponse {
  none,
  warn,
  restrict,
}
