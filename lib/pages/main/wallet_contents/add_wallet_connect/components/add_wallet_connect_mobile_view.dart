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
        final isTablet =
            constraints.maxWidth > ResponsiveConstants.tabletBreakpoint;
        final screenSize = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;
        final overlayWidth = screenSize * (isTablet ? 0.55 : 0.75);
        final overlayHeight = overlayWidth;
        final shiftingFromCenterToTop = isTablet
            ? constraints.maxHeight * 0.05 // Less shift for tablets
            : constraints.maxHeight > ResponsiveConstants.largeScreenHeight
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
              Positioned(
                child: MobileScanner(
                  fit: BoxFit.cover,
                  controller: MobileScannerController(
                    facing: CameraFacing.back,
                    torchEnabled: false,
                  ),
                  onDetect: widget.onDetect,
                  errorBuilder: (context, error, child) {
                    return Material(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 50),
                          child: Text(
                            error.toString(),
                            style: TextStyles.textNormal,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            // Blurred Background excluding the scan window area
            if (isCameraInitialized)
              Positioned.fill(
                child: ClipPath(
                  clipper: ScannerOverlayClipper(scanWindow),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.5),
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

            Positioned(
              top: MediaQuery.of(context).padding.top,
              left: ThemePaddings.normalPadding,
              right: ThemePaddings.normalPadding,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  color: Colors.transparent,
                  child: Row(
                    children: [
                      // Back arrow icon
                      IconButton(
                        icon: isIOS
                            ? const Icon(Icons.arrow_back_ios)
                            : const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text(
                          l10n.wcAddConnection,
                          maxLines: 2,
                          style: TextStyles.textExtraLargeBold,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const IconButton(
                        icon: SizedBox.shrink(),
                        onPressed: null,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              bottom:
                  constraints.maxHeight > ResponsiveConstants.largeScreenHeight
                      ? MediaQuery.of(context).padding.bottom +
                          ThemePaddings.smallPadding
                      : MediaQuery.of(context).padding.bottom +
                          ThemePaddings.bigPadding,
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
