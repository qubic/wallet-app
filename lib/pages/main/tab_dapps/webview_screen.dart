import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/app_logger.dart';
import 'package:qubic_wallet/models/app_link/app_link_controller.dart';
import 'package:qubic_wallet/styles/input_decorations.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:url_launcher/url_launcher.dart';

class WebviewScreen extends StatefulWidget {
  final String initialUrl;

  const WebviewScreen({super.key, required this.initialUrl});

  @override
  State<WebviewScreen> createState() => _WebviewScreenState();
}

class _WebviewScreenState extends State<WebviewScreen> {
  InAppWebViewController? webViewController;
  String currentUrl = "";
  double progress = 0;

  final TextEditingController urlController = TextEditingController();
  final AppLinkController appLinkController = AppLinkController();
  @override
  void initState() {
    super.initState();
    currentUrl = widget.initialUrl;
    urlController.text = _cleanUrl(currentUrl);
  }

  String _cleanUrl(String url) {
    url = url.replaceFirst(
        RegExp(r'^https?://'), ''); // Remove https:// or http://
    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1); // Remove trailing slash
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: statusBarHeight),
          Padding(
            padding: const EdgeInsets.all(ThemePaddings.normalPadding),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                      controller: urlController,
                      onTap: () => urlController.selection = TextSelection(
                          baseOffset: 0,
                          extentOffset: urlController.value.text.length),
                      keyboardType: TextInputType.url,
                      style: TextStyles.inputBoxSmallStyle
                          .copyWith(fontSize: ThemeFontSizes.small),
                      decoration: ThemeInputDecorations.normalInputbox.copyWith(
                          suffixIcon: IconButton(
                              onPressed: () {
                                webViewController?.reload();
                              },
                              icon: const Icon(Icons.refresh,
                                  size: 15,
                                  color: LightThemeColors.menuInactive)),
                          prefixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back_ios,
                                    size: 15,
                                    color: LightThemeColors.menuInactive),
                                padding: EdgeInsets.zero,
                                onPressed: () async {
                                  if (await webViewController?.canGoBack() ??
                                      false) {
                                    webViewController?.goBack();
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.arrow_forward_ios,
                                    size: 15,
                                    color: LightThemeColors.menuInactive),
                                onPressed: () async {
                                  if (await webViewController?.canGoForward() ??
                                      false) {
                                    webViewController?.goForward();
                                  }
                                },
                              ),
                            ],
                          ),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: Colors.transparent))),
                      onChanged: (value) => appLogger.e("value $value"),
                      onSubmitted: (input) {
                        appLogger.e("input $input");
                        final urlRegex = RegExp(
                            r'^(https?:\/\/)?(www\.)?([a-zA-Z0-9-_]+(\.[a-zA-Z]{2,})+)(\/.*)?$');

                        if (urlRegex.hasMatch(input)) {
                          // If it's a valid URL, format it correctly and load it
                          final formattedUrl = input.startsWith("http")
                              ? input
                              : "https://$input";
                          webViewController?.loadUrl(
                              urlRequest: URLRequest(
                                  url: WebUri.uri(Uri.parse(formattedUrl))));
                        } else {
                          // If it's not a URL, perform a Google search
                          final searchQuery = Uri.encodeComponent(input);
                          webViewController?.loadUrl(
                              urlRequest: URLRequest(
                                  url: WebUri.uri(Uri.parse(
                                      "https://www.google.com/search?q=$searchQuery"))));
                        }
                      }),
                ),
                IconButton(
                  icon: const Icon(Icons.close,
                      size: 20, color: LightThemeColors.menuInactive),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          if (progress < 1.0)
            LinearProgressIndicator(
              value: progress,
              borderRadius: BorderRadius.circular(12),
              backgroundColor: LightThemeColors.navBg,
              color: LightThemeColors.primary50,
            ),
          Expanded(
            child: Stack(
              children: [
                InAppWebView(
                  shouldOverrideUrlLoading:
                      (controller, navigationAction) async {
                    try {
                      final deeplink = navigationAction.request.url;
                      if (deeplink == null) return NavigationActionPolicy.ALLOW;

                      final currentUrl = await controller.getUrl();
                      if (currentUrl == deeplink) {
                        return NavigationActionPolicy.ALLOW;
                      }
                      final deeplinkStr = deeplink.toString();
                      // Handle Qubic URLs
                      if (deeplinkStr.startsWith(Config.CustomURLScheme)) {
                        appLinkController.parseUriString(deeplink, context);
                        return NavigationActionPolicy.CANCEL;
                      }
                      await launchUrl(deeplink);
                      return NavigationActionPolicy.CANCEL;
                    } catch (e) {
                      appLogger.e("Error in URL handling: $e");
                      return NavigationActionPolicy.ALLOW;
                    }
                  },
                  initialSettings: InAppWebViewSettings(
                    useShouldOverrideUrlLoading: true,
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
                  onLoadStart: (controller, url) {
                    setState(() {
                      currentUrl = url.toString();
                      urlController.text = _cleanUrl(currentUrl);
                    });
                  },
                  onLoadStop: (controller, url) {
                    setState(() {
                      currentUrl = url.toString();
                      urlController.text = _cleanUrl(currentUrl);
                    });
                  },
                  onProgressChanged: (controller, p) {
                    setState(() {
                      progress = p / 100;
                    });
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
