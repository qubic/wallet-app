import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/services/qr_scanner_service.dart';
import 'package:qubic_wallet/styles/app_icons.dart';

/// A compact QR scan icon button designed for use inside text field suffixes.
/// Scans a QR code and sets the result as a public ID in the provided controller.
class QrScanIconButton extends StatelessWidget {
  final TextEditingController controller;

  const QrScanIconButton({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return IconButton(
      tooltip: l10n.tooltipScanQRCode,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      onPressed: () {
        getIt<QrScannerService>().scanAndSetPublicId(
          context: context,
          controller: controller,
        );
      },
      icon: SvgPicture.asset(
        AppIcons.scan,
        height: 20,
        colorFilter: const ColorFilter.mode(
          LightThemeColors.primary,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}
