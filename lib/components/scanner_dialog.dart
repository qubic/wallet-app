import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/app_logger.dart';

void showQRScanner({
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
            onDetect: (capture) {
              if (hasProcessedSuccess) {
                return; // Exit early if already processed
              }

              final List<Barcode> barcodes = capture.barcodes;

              for (final barcode in barcodes) {
                if (barcode.rawValue != null && !hasProcessedSuccess) {
                  try {
                    onFoundSuccess(barcode.rawValue!);
                    hasProcessedSuccess = true;
                    break;
                  } catch (e) {
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
  ).whenComplete(() {
    appLogger.d("QR Scanner dialog closed");
    controller.dispose();
  });
}
