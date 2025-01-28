part of '../add_wallet_connect.dart';

class _AddWalletConnectMobileView extends StatefulWidget {
  final Function(BarcodeCapture capture) onDetect;
  final String? connectionUrl;

  final VoidCallback pasteAndProceed;
  final Function(String?) proceedHandler;
  final bool isLoading;
  const _AddWalletConnectMobileView(
      {required this.onDetect,
      required this.pasteAndProceed,
      required this.isLoading,
      required this.proceedHandler,
      this.connectionUrl});

  @override
  State<_AddWalletConnectMobileView> createState() =>
      _AddWalletConnectMobileViewState();
}

class _AddWalletConnectMobileViewState
    extends State<_AddWalletConnectMobileView> {
  // To not show the custom scan window until the camera is initialized
  bool isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.connectionUrl != null) {
      widget.proceedHandler(widget.connectionUrl);
    }

    Future.delayed(const Duration(milliseconds: 600), () {
      setState(() {
        isCameraInitialized = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        const overlayWidth = 280.0;
        const overlayHeight = 280.0;
        final shiftingFromCenterToTop =
            constraints.maxHeight > ResponsiveConstants.largeScreenHeight
                ? constraints.maxHeight * 0.1
                : constraints.maxHeight * .08;

        // Calculate center vertically (with shifting to the top) and horizontally
        final centerY = constraints.maxHeight / 2 - shiftingFromCenterToTop;
        final scanWindow = Rect.fromCenter(
          center: Offset(constraints.maxWidth / 2, centerY),
          width: overlayWidth,
          height: overlayHeight,
        );

        return Stack(
          children: [
            // QR Scanner
            if (!widget.isLoading)
              MobileScanner(
                fit: BoxFit.cover,
                controller: MobileScannerController(
                  facing: CameraFacing.back,
                  torchEnabled: false,
                ),
                scanWindow: scanWindow,
                onDetect: widget.onDetect,
              ),
            // Blurred Background excluding the scan window area
            if (isCameraInitialized)
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
            if (isCameraInitialized)
              Positioned(
                top: centerY - overlayHeight / 2,
                left: (constraints.maxWidth - overlayWidth) / 2,
                child: Container(
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
            // Text below the scan window
            if (isCameraInitialized)
              Positioned(
                top: centerY +
                    overlayHeight / 2 +
                    24, // 24px spacing below scan window
                left: (constraints.maxWidth - overlayWidth) / 2,
                child: Material(
                  color: Colors.transparent,
                  child: SizedBox(
                    width: overlayWidth,
                    child: Text(
                      l10n.wcAddConnectionScan,
                      style: TextStyles.textNormal,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            // Show loading indicator until the camera is initialized
            if (!isCameraInitialized)
              Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            // AppBar on top of everything
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AppBar(
                backgroundColor: Colors.transparent,
                title: Badge(
                  offset: const Offset(-20, -10),
                  backgroundColor: LightThemeColors.warning10,
                  label: const Text("BETA", style: TextStyle(fontSize: 10)),
                  alignment: Alignment.topLeft,
                  child: Text(l10n.wcAddConnection,
                      style: TextStyles.textExtraLargeBold),
                ),
                centerTitle: true,
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
                    onPressed: widget.isLoading ? null : widget.pasteAndProceed,
                    child: Padding(
                        padding: const EdgeInsets.all(
                            ThemePaddings.smallPadding + 3),
                        child: widget.isLoading
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
