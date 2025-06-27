import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:qubic_wallet/config.dart';
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
    bool isSafeDevice = await SafeDevice.isSafeDevice;
    isRootedOrJailbroken = isSafeDevice;
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

  Future<void> showSecurityWarningIfNeeded(BuildContext context) async {
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
