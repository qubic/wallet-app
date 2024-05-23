import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/globals.dart';
import 'package:qubic_wallet/stores/application_store.dart';

/// A global snackbar that can be shown from anywhere in the app
class GlobalSnackBar {
  final ApplicationStore appStore = getIt<ApplicationStore>();

  void show(String message) {
    if (Config.useNativeSnackbar) {
      scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
        elevation: 999,
        showCloseIcon: true,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        content: Text(message),
      ));
    } else {
      appStore.reportGlobalNotification(message);
    }
  }

  void showError(String error) {
    if (Config.useNativeSnackbar) {
      scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
        elevation: 999,
        showCloseIcon: true,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        content: Text(error),
      ));
    } else {
      appStore.reportGlobalError(error);
    }
  }
}
