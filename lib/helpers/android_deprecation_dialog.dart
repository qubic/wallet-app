import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/platform_helpers.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/resources/hive_storage.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

const int _minSupportedAndroidSdkNext = 24; // Android 7.0 (Nougat)

/// Tracks whether we've already shown (or are showing) the dialog this app
/// session, so a rapid second invocation doesn't stack two dialogs before
/// the first ack is persisted.
bool _shownThisSession = false;

/// Shows a one-time popup informing users on Android 5/6 that this is the
/// last supported version for their device. Only fires once per install.
Future<void> maybeShowAndroidDeprecationDialog(BuildContext context) async {
  if (!isAndroid) return;
  if (_shownThisSession) return;
  // Claim the slot synchronously so a second invocation during the awaits
  // below can't race past the guard.
  _shownThisSession = true;

  final int sdkInt;
  try {
    final info = await DeviceInfoPlugin().androidInfo;
    sdkInt = info.version.sdkInt;
  } catch (_) {
    _shownThisSession = false;
    return;
  }
  if (sdkInt >= _minSupportedAndroidSdkNext) return;

  final hive = getIt<HiveStorage>();
  if (hive.getAndroidDeprecationDialogAcknowledged()) return;

  if (!context.mounted) return;

  final l10n = l10nOf(context);

  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => PopScope(
      canPop: false,
      child: AlertDialog(
        surfaceTintColor: LightThemeColors.strongBackground,
        title: Text(
          l10n.androidDeprecationDialogTitle,
          style: TextStyles.alertHeader,
        ),
        content: _buildBody(
          l10n.androidDeprecationDialogMessageBefore,
          l10n.androidDeprecationDialogMessageHighlight,
          l10n.androidDeprecationDialogMessageAfter,
        ),
        actions: [
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 100),
            child: ThemedControls.primaryButtonBig(
              text: l10n.androidDeprecationDialogButton,
              onPressed: () async {
                await hive.setAndroidDeprecationDialogAcknowledged(true);
                if (!ctx.mounted) return;
                Navigator.of(ctx).pop();
              },
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildBody(String before, String highlight, String after) {
  final baseStyle = TextStyles.alertText.copyWith(fontSize: 16);
  return RichText(
    text: TextSpan(
      style: baseStyle,
      children: [
        TextSpan(text: before),
        TextSpan(
          text: highlight,
          style: baseStyle.copyWith(
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline,
          ),
        ),
        TextSpan(text: after),
      ],
    ),
  );
}
