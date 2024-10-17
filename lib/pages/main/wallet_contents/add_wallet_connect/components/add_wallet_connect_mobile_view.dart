part of '../add_wallet_connect.dart';

class _AddWalletConnectMobileView extends StatelessWidget {
  final Function(BarcodeCapture capture) onDetect;
  final VoidCallback pasteAndProceed;
  final bool isLoading;
  const _AddWalletConnectMobileView(
      {required this.onDetect,
      required this.pasteAndProceed,
      required this.isLoading});

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final overlayWidth =
            constraints.maxWidth - ThemePaddings.hugePadding * 2;
        const overlayHeight = 280.0;

        // Calculate center vertically and horizontally
        final centerY = constraints.maxHeight / 2;
        final scanWindow = Rect.fromCenter(
          center: Offset(constraints.maxWidth / 2, centerY),
          width: overlayWidth,
          height: overlayHeight,
        );

        return Stack(
          children: [
            // QR Scanner
            MobileScanner(
              fit: BoxFit.cover,
              controller: MobileScannerController(
                detectionSpeed: DetectionSpeed.noDuplicates,
                facing: CameraFacing.back,
                torchEnabled: false,
              ),
              scanWindow: scanWindow,
              onDetect: onDetect,
            ),
            // Blurred Background excluding the scan window area
            Positioned.fill(
              child: ClipPath(
                clipper: ScannerOverlayClipper(scanWindow),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
              ),
            ),
            // Transparent overlay for the scan window (centered vertically)
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(
                    horizontal: ThemePaddings.hugePadding),
                width: overlayWidth,
                height: overlayHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: LightThemeColors.inputBorderColor, width: 1),
                ),
                child: CustomPaint(
                  foregroundPainter: ScannerCornerBorders(),
                ),
              ),
            ),
            // AppBar on top of everything
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AppBar(
                backgroundColor: Colors.transparent,
                title: Text("Scan QR Code"),
              ),
            ),
            Positioned(
              bottom: ThemePaddings.bottomPaddingMobile,
              left: ThemePaddings.normalPadding,
              right: ThemePaddings.normalPadding,
              child: SizedBox(
                width: double.infinity,
                height: ButtonStyles.buttonHeight,
                child: ThemedControls.secondaryButtonWithChild(
                    onPressed: pasteAndProceed,
                    child: Padding(
                        padding: const EdgeInsets.all(
                            ThemePaddings.smallPadding + 3),
                        child: isLoading
                            ? const SizedBox(
                                height: 23,
                                width: 23,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: LightThemeColors.buttonPrimary),
                              )
                            : Text(
                                l10n.pasteURLHere,
                                style: TextStyles.primaryButtonText.copyWith(
                                    color: LightThemeColors.primary40),
                              ))),
              ),
            ),
          ],
        );
      },
    );
  }
}
