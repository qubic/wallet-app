import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/helpers/show_alert_dialog.dart';
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
    bool isSafeDevice = await SafeDevice.isSafeDevice;
    isRootedOrJailbroken = isSafeDevice;
  }

  Future<void> showWarningDialog(BuildContext context) async {
    if (isRootedOrJailbroken) {
      showAlertDialog(
        context,
        "Device Compromised",
        "Your device appears to be rooted or jailbroken. Some features may be exposed to security risks. We strongly recommend using this wallet only on secure, unmodified devices. You can still use the app under your own risk.",
        primaryButtonLabel: "I understand",
      );
    }
  }

  Future<void> showRestrictDialog(BuildContext context) async {
    if (isRootedOrJailbroken) {
      showAlertDialog(
        context,
        "Access Restricted",
        "Your device appears to be rooted or jailbroken. For security reasons, some features are disabled.",
        primaryButtonLabel: "Ok",
      );
    }
  }

  Future<void> showSecurityNoticeIfNeeded(BuildContext context) async {
    if (!isRootedOrJailbroken) return;
    switch (Config.detectionMode) {
      case DetectionModes.warn:
        await showWarningDialog(context);
        break;
      case DetectionModes.restrict:
        await showRestrictDialog(context);
        break;
      case DetectionModes.none:
        break;
    }
  }

  bool get isDeviceRestricted =>
      Config.detectionMode == DetectionModes.restrict && isRootedOrJailbroken;

  bool checkAndHandleRestriction() {
    if (isDeviceRestricted && rootNavigatorKey.currentState?.context != null) {
      showRestrictDialog(rootNavigatorKey.currentState!.context);
    }

    return isDeviceRestricted;
  }
}

enum DetectionModes {
  none,
  warn,
  restrict,
}
