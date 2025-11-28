import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/models/app_link/app_link_controller.dart';
import 'package:qubic_wallet/pages/main/tab_dapps/components/webview_address_bar.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:url_launcher/url_launcher.dart';

class WebviewScreen extends StatefulWidget {
  final String initialUrl;
  final bool hideFavorites;
  final String? customTitle;

  const WebviewScreen({
    super.key,
    required this.initialUrl,
    this.hideFavorites = false,
    this.customTitle,
  });

  @override
  State<WebviewScreen> createState() => _WebviewScreenState();
}

class _WebviewScreenState extends State<WebviewScreen> {
  InAppWebViewController? webViewController;
  final ValueNotifier<double> progress = ValueNotifier(0);

  final TextEditingController urlController = TextEditingController();
  final AppLinkController appLinkController = AppLinkController();
  final ValueNotifier<bool> canGoBack = ValueNotifier(false);
  final ValueNotifier<bool> canGoForward = ValueNotifier(false);
  final ValueNotifier<int> urlChangeNotifier = ValueNotifier(0);
  String? loadError;

  @override
  void initState() {
    super.initState();
    urlController.text = _cleanUrl(widget.initialUrl);
  }

  Future<void> _checkNavigationState() async {
    if (webViewController != null) {
      canGoBack.value = await webViewController!.canGoBack();
      canGoForward.value = await webViewController!.canGoForward();
    }
  }

  String _cleanUrl(String url) {
    Uri? parsedUri = Uri.tryParse(url);
    if (parsedUri != null) {
      String host = parsedUri.host.replaceFirst(RegExp(r'^www\.'), '');
      String path = parsedUri.path.replaceAll(RegExp(r'\/$'), '');
      return host + path;
    }
    return url;
  }

  void _updateUrl(String? url) {
    if (url != null) {
      urlController.text = _cleanUrl(url);
      // Notify that URL has changed
      urlChangeNotifier.value++;
    }
  }

  Future<NavigationActionPolicy> _handleDeepLinkNavigation(
      InAppWebViewController controller,
      NavigationAction navigationAction) async {
    final deepLink = navigationAction.request.url;
    if (deepLink != null &&
        (deepLink.scheme != 'https' && deepLink.scheme != 'http')) {
      if (deepLink.toString().startsWith(Config.CustomURLScheme)) {
        appLinkController.parseUriString(deepLink, context);
      } else {
        launchUrl(deepLink, mode: LaunchMode.externalNonBrowserApplication);
      }
      return NavigationActionPolicy.CANCEL;
    }

    return NavigationActionPolicy.ALLOW;
  }

  @override
  void dispose() {
    urlController.dispose();
    webViewController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final l10n = l10nOf(context);

    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: statusBarHeight),
          // Show title bar if customTitle is provided, otherwise show address bar
          if (widget.customTitle != null)
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: ThemePaddings.normalPadding),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: LightThemeColors.navBorder,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.customTitle!,
                      style: TextStyles.textExtraLargeBold,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            )
          else
            WebviewAddressBar(
              urlController: urlController,
              webViewController: webViewController,
              canGoBack: canGoBack,
              canGoForward: canGoForward,
              urlChangeNotifier: urlChangeNotifier,
              hideFavorites: widget.hideFavorites,
            ),
          ValueListenableBuilder(
              valueListenable: progress,
              builder: (context, value, child) {
                return (progress.value < 1.0)
                    ? LinearProgressIndicator(
                        value: value,
                        borderRadius: BorderRadius.circular(12),
                        backgroundColor: LightThemeColors.navBg,
                        color: LightThemeColors.primary50,
                      )
                    : const SizedBox.shrink();
              }),
          Expanded(
            child: Stack(
              children: [
                InAppWebView(
                  shouldOverrideUrlLoading: _handleDeepLinkNavigation,
                  initialSettings: InAppWebViewSettings(
                    useShouldOverrideUrlLoading: true,
                    safeBrowsingEnabled: true,
                  ),
                  initialUrlRequest: URLRequest(
                      url: WebUri.uri(Uri.parse(widget.initialUrl))),
                  gestureRecognizers: {
                    Factory(() => OnTapGestureRecognizer(onTapCallback: () {
                          FocusScope.of(context).unfocus();
                        })),
                  },
                  onWebViewCreated: (controller) {
                    webViewController = controller;
                    setState(() {});
                  },
                  onLoadStart: (controller, url) {
                    setState(() {
                      loadError = null;
                    });
                    _updateUrl(url.toString());
                  },
                  onLoadStop: (controller, url) {
                    _updateUrl(url.toString());
                  },
                  onUpdateVisitedHistory: (controller, url, isReload) {
                    _checkNavigationState();
                  },
                  onProgressChanged: (controller, p) {
                    progress.value = p / 100;
                  },
                  onReceivedError: (controller, request, error) {
                    setState(() {
                      // Check if it's an ATS error (insecure HTTP connection)
                      if (error.description.contains('App Transport Security') ||
                          error.description.contains('NSURLErrorDomain') ||
                          request.url.scheme == 'http') {
                        loadError = l10n.webviewErrorInsecureConnection;
                      } else {
                        loadError = l10n.webviewErrorGeneric(error.description);
                      }
                      progress.value = 1.0; // Complete the progress bar on error
                    });
                  },
                  onReceivedHttpError: (controller, request, response) {
                    // Only show error overlay for main page requests, not for resources like favicons
                    if (response.statusCode != null &&
                        response.statusCode! >= 400 &&
                        request.isForMainFrame == true) {
                      setState(() {
                        loadError = l10n.webviewErrorHttp(response.statusCode.toString());
                        progress.value = 1.0; // Complete the progress bar on error
                      });
                    }
                  },
                ),
                // Error overlay
                if (loadError != null)
                  Container(
                    color: LightThemeColors.background,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(ThemePaddings.hugePadding),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: LightThemeColors.error,
                            ),
                            const SizedBox(height: ThemePaddings.bigPadding),
                            Text(
                              l10n.webviewErrorCannotLoad,
                              style: TextStyles.textBold.copyWith(
                                color: LightThemeColors.primary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: ThemePaddings.normalPadding),
                            Text(
                              loadError!,
                              style: TextStyles.secondaryTextSmall,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnTapGestureRecognizer extends TapGestureRecognizer {
  final VoidCallback onTapCallback;

  OnTapGestureRecognizer({required this.onTapCallback});

  @override
  void rejectGesture(int pointer) {
    acceptGesture(pointer);
  }

  @override
  void handleTapUp(
      {required PointerDownEvent down, required PointerUpEvent up}) {
    onTapCallback();
  }
}
