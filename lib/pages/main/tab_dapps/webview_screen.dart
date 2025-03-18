import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/models/app_link/app_link_controller.dart';
import 'package:qubic_wallet/pages/main/tab_dapps/components/webview_address_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class WebviewScreen extends StatefulWidget {
  final String initialUrl;

  const WebviewScreen({super.key, required this.initialUrl});

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
    }
  }

  Future<NavigationActionPolicy> _handleDeepLinkNavigation(
      InAppWebViewController controller,
      NavigationAction navigationAction) async {
    final url = await controller.getUrl();
    final deepLink = navigationAction.request.url;

    if (deepLink != null &&
        url != navigationAction.request.url &&
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: statusBarHeight),
          WebviewAddressBar(
            urlController: urlController,
            webViewController: webViewController,
            canGoBack: canGoBack,
            canGoForward: canGoForward,
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
                  initialUrlRequest:
                      URLRequest(url: WebUri.uri(Uri.parse(widget.initialUrl))),
                  gestureRecognizers: {
                    Factory(() => OnTapGestureRecognizer(onTapCallback: () {
                          FocusScope.of(context).unfocus();
                        })),
                  },
                  onWebViewCreated: (controller) {
                    webViewController = controller;
                  },
                  onLoadStart: (controller, url) => _updateUrl(url.toString()),
                  onLoadStop: (controller, url) => _updateUrl(url.toString()),
                  onProgressChanged: (controller, p) {
                    progress.value = p / 100;
                    if (p == 100) {
                      _checkNavigationState();
                    }
                  },
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
