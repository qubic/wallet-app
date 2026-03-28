import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/app_logger.dart';
import 'package:qubic_wallet/helpers/global_snack_bar.dart';
import 'package:qubic_wallet/helpers/id_validators.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/styles/text_styles.dart';

class QrScannerService {
  final GlobalSnackBar globalSnackBar;

  QrScannerService(this.globalSnackBar);

  void scanAndSet({
    required BuildContext context,
    required TextEditingController controller,
    required String Function(BuildContext) instructionTextBuilder,
    required String? Function(String) validator,
    String Function(String)? transformer,
  }) {
    final l10n = l10nOf(context);

    _showQRScanner(
      context: context,
      instructionText: instructionTextBuilder(context),
      onFoundSuccess: (String scannedValue) {
        final transformed = transformer?.call(scannedValue) ?? scannedValue;
        final validationResult = validator(transformed);
        if (validationResult == null) {
          controller.text = transformed;
          Navigator.pop(context);
          globalSnackBar.show(l10n.generalSnackBarMessageQRScannedWithSuccess);
        } else {
          Navigator.pop(context);
          appLogger.e("QR Code scanned with invalid value: $validationResult");
          globalSnackBar.showError(
              "QR Code scanned with invalid value: $validationResult");
        }
      },
    );
  }

  void scanAndSetPublicId({
    required BuildContext context,
    required TextEditingController controller,
  }) {
    scanAndSet(
      context: context,
      controller: controller,
      instructionTextBuilder: (ctx) =>
          l10nOf(ctx).sendItemLabelQRScannerInstructions,
      validator: CustomFormFieldValidators.isPublicID(context: context),
      transformer: (value) =>
          value.replaceAll("https://wallet.qubic.org/payment/", ""),
    );
  }

  void scanAndSetSeed({
    required BuildContext context,
    required TextEditingController controller,
  }) {
    scanAndSet(
      context: context,
      controller: controller,
      instructionTextBuilder: (ctx) =>
          l10nOf(ctx).addAccountHeaderScanQRCodeInstructions,
      validator: CustomFormFieldValidators.isSeed(context: context),
    );
  }

  void _showQRScanner({
    required BuildContext context,
    required Function(String) onFoundSuccess,
    required String instructionText,
  }) {
    late MobileScannerController controller;

    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      builder: (BuildContext context) {
        bool hasProcessedSuccess = false;

        controller = MobileScannerController(
          detectionSpeed: DetectionSpeed.normal,
          facing: CameraFacing.back,
          torchEnabled: false,
        );

        return Stack(
          children: [
            MobileScanner(
              controller: controller,
              errorBuilder: (context, error) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    child: Text(
                      error.toString(),
                      style: TextStyles.textNormal,
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
              onDetect: (capture) {
                if (hasProcessedSuccess) return;

                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null) {
                    try {
                      onFoundSuccess(barcode.rawValue!);
                      hasProcessedSuccess = true;
                      break;
                    } catch (_) {
                      // ignore and continue scanning
                    }
                  }
                }
              },
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.white60,
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(ThemePaddings.normalPadding),
                  child: Text(
                    instructionText,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ).whenComplete(() {
      appLogger.d("QR Scanner dialog closed");
      controller.dispose();
    });
  }
}
