// Enum to define scanner types
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/app_logger.dart';
import 'package:qubic_wallet/helpers/global_snack_bar.dart';
import 'package:qubic_wallet/helpers/id_validators.dart';
import 'package:qubic_wallet/l10n/l10n.dart';

void showQRScanner({
  required BuildContext context,
  required Function(String) onFoundSuccess,
  required String instructionText,
}) {
  showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    builder: (BuildContext context) {
      return Stack(
        children: [
          MobileScanner(
            controller: MobileScannerController(
              detectionSpeed: DetectionSpeed.normal,
              facing: CameraFacing.back,
              torchEnabled: false,
            ),
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              bool foundSuccess = false;

              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  if (foundSuccess) break;

                  // Call the callback function to handle validation and success logic
                  try {
                    appLogger
                        .i("QR Code scanned with value: ${barcode.rawValue!}");
                    onFoundSuccess(barcode.rawValue!);
                    foundSuccess = true;
                  } catch (e) {
                    // Continue to next barcode if validation fails
                    continue;
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
  );
}
