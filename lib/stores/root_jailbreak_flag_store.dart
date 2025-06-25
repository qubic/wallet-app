import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/helpers/show_alert_dialog.dart';
import 'package:safe_device/safe_device.dart';

part 'root_jailbreak_flag_store.g.dart';

class RootJailbreakFlagStore = _RootJailbreakFlagStore
    with _$RootJailbreakFlagStore;

abstract class _RootJailbreakFlagStore with Store {
  @observable
  bool isRootedOrJailbroken = false;

  _RootJailbreakFlagStore() {
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
        "Your device appears to be rooted or jailbroken. For security reasons, we have disabled this feature.",
        primaryButtonLabel: "Ok",
      );
    }
  }

  Future<void> showAppropriateDialog(BuildContext context) async {
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
}

enum DetectionModes {
  none,
  warn,
  restrict,
}
