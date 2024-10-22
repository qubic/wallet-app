part of '../add_wallet_connect.dart';

class _AddWalletConnectDesktopView extends StatefulWidget {
  final bool isLoading;
  final VoidCallback pasteAndProceed;
  final Function(String?) proceedHandler;
  const _AddWalletConnectDesktopView({
    super.key,
    required this.isLoading,
    required this.pasteAndProceed,
    required this.proceedHandler,
  });

  @override
  State<_AddWalletConnectDesktopView> createState() =>
      _AddWalletConnectDesktopViewState();
}

class _AddWalletConnectDesktopViewState
    extends State<_AddWalletConnectDesktopView> {
  final _globalSnackBar = getIt<GlobalSnackBar>();
  final urlController = TextEditingController();
  bool canConnect = false;

  pasteToForm() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    String? clipboardText = clipboardData?.text;
    urlController.text = clipboardText ?? "";
  }

  @override
  void dispose() {
    urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return PopScope(
      canPop: !widget.isLoading,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
        ),
        body: SafeArea(
          minimum: ThemeEdgeInsets.pageInsets
              .copyWith(bottom: ThemePaddings.normalPadding),
          child: Column(
            children: [
              Expanded(
                  child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: Row(children: [
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            if (isMobile) ...[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color:
                                            LightThemeColors.inputBorderColor,
                                        width: 1),
                                  ),
                                  width: double.infinity,
                                  height: 280,
                                  child: CustomPaint(
                                    foregroundPainter: ScannerCornerBorders(),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: MobileScanner(
                                        fit: BoxFit.cover,
                                        controller: MobileScannerController(
                                          detectionSpeed:
                                              DetectionSpeed.noDuplicates,
                                          facing: CameraFacing.back,
                                          torchEnabled: false,
                                        ),
                                        onDetect: (capture) {
                                          final List<Barcode> barcodes =
                                              capture.barcodes;
                                          for (final barcode in barcodes) {
                                            if (barcode.rawValue != null &&
                                                !widget.isLoading) {
                                              _globalSnackBar.show(l10n
                                                  .generalSnackBarMessageQRScannedWithSuccess);
                                              widget.proceedHandler(
                                                  barcode.rawValue);
                                            }
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              ThemedControls.spacerVerticalBig(),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: ThemePaddings.normalPadding),
                                child: Text(
                                  l10n.wcPointCameraToQR,
                                  textAlign: TextAlign.center,
                                  style: TextStyles.labelTextNormal
                                      .copyWith(fontWeight: FontWeight.w400),
                                ),
                              )
                            ],
                            ThemedControls.pageHeader(
                              headerText: l10n.wcAddWcTitle,
                            ),
                            ThemedControls.spacerVerticalSmall(),
                            Text(
                              l10n.wcAddURL,
                              style: TextStyles.secondaryTextLarge,
                            ),
                            ThemedControls.spacerVerticalBig(),
                            FormBuilderTextField(
                                name: "urlController",
                                controller: urlController,
                                onChanged: (val) {
                                  canConnect = (val?.length ==
                                          Config.wallectConnectUrlLength)
                                      ? true
                                      : false;
                                  setState(() {});
                                },
                                style: TextStyles.inputBoxSmallStyle,
                                decoration: ThemeInputDecorations.normalInputbox
                                    .copyWith(
                                        hintText: l10n.pasteURLHere,
                                        suffixIconConstraints:
                                            const BoxConstraints(
                                                minHeight: 24, minWidth: 32),
                                        suffixIcon: Padding(
                                          padding: const EdgeInsets.only(
                                              right:
                                                  ThemePaddings.normalPadding),
                                          child: SizedBox(
                                            height: 24,
                                            child: ThemedControls
                                                .secondaryButtonWithChild(
                                                    onPressed: pasteToForm,
                                                    child: Text(
                                                        l10n.generalButtonPaste,
                                                        style: TextStyles
                                                            .primaryButtonText
                                                            .copyWith(
                                                                color: LightThemeColors
                                                                    .primary40))),
                                          ),
                                        ))),
                          ],
                        ))
                      ]))),
              SizedBox(
                width: double.infinity,
                height: ButtonStyles.buttonHeight,
                child: ThemedControls.primaryButtonBigWithChild(
                    onPressed: canConnect ? widget.pasteAndProceed : null,
                    enabled: canConnect,
                    child: Padding(
                        padding: const EdgeInsets.all(
                            ThemePaddings.smallPadding + 3),
                        child: widget.isLoading
                            ? const SizedBox(
                                height: 23,
                                width: 23,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: LightThemeColors.extraStrongBackground,
                                ),
                              )
                            : Text(
                                l10n.generalButtonConnect,
                                style: TextStyles.primaryButtonText,
                              ))),
              )
            ],
          ),
        ),
      ),
    );
  }
}
