import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/global_snack_bar.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/pages/auth/erase_wallet_sheet.dart';
import 'package:qubic_wallet/resources/hive_storage.dart';
import 'package:qubic_wallet/resources/secure_storage.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/stores/settings_store.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:qubic_wallet/timed_controller.dart';

class EraseWalletDataButton extends StatelessWidget {
  final ApplicationStore appStore = getIt<ApplicationStore>();
  final SettingsStore settingsStore = getIt<SettingsStore>();
  final HiveStorage _hiveStorage = getIt<HiveStorage>();
  final SecureStorage secureStorage = getIt<SecureStorage>();
  final _globalSnackBar = getIt<GlobalSnackBar>();
  final TimedController timedController = getIt<TimedController>();
  EraseWalletDataButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ThemedControls.dangerButtonBigWithClild(
        child: Text(l10n.generalButtonEraseWalletData,
            style: TextStyles.destructiveButtonText),
        onPressed: () {
          showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              useRootNavigator: true,
              useSafeArea: true,
              backgroundColor: LightThemeColors.background,
              builder: (BuildContext context) {
                return SafeArea(
                    child: EraseWalletSheet(onAccept: () async {
                  await secureStorage.deleteWallet();
                  await settingsStore.loadSettings();
                  await _hiveStorage.clear();
                  appStore.checkWalletIsInitialized();
                  appStore.signOut();
                  timedController.stopFetchTimers();
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  context.go("/signInNoAuth");
                  _globalSnackBar
                      .show(l10n.generalSnackBarMessageWalletDataErased);
                }, onReject: () async {
                  Navigator.pop(context);
                }));
              });
        },
      ),
    );
  }
}
