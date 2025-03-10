import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/styles/input_decorations.dart';
import 'package:qubic_wallet/styles/text_styles.dart';

class WebviewAddressBar extends StatelessWidget {
  const WebviewAddressBar({
    super.key,
    required this.urlController,
    required this.webViewController,
  });

  final TextEditingController urlController;
  final InAppWebViewController? webViewController;

  void _handleUrlSubmission(String input) {
    final isValidUrl = RegExp(
            r'^(https?:\/\/)?(www\.)?([a-zA-Z0-9-_]+(\.[a-zA-Z]{2,})+)(\/.*)?$')
        .hasMatch(input);

    final url = isValidUrl
        ? (input.startsWith("http") ? input : "https://$input")
        : "https://www.google.com/search?q=${Uri.encodeComponent(input)}";

    webViewController?.loadUrl(
        urlRequest: URLRequest(url: WebUri.uri(Uri.parse(url))));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(ThemePaddings.normalPadding),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: urlController,
              onTap: () => urlController.selection = TextSelection(
                  baseOffset: 0, extentOffset: urlController.value.text.length),
              keyboardType: TextInputType.url,
              style: TextStyles.inputBoxSmallStyle
                  .copyWith(fontSize: ThemeFontSizes.small),
              decoration: ThemeInputDecorations.normalInputbox.copyWith(
                  suffixIcon: IconButton(
                      onPressed: () {
                        webViewController?.reload();
                      },
                      icon: const Icon(Icons.refresh,
                          size: 15, color: LightThemeColors.menuInactive)),
                  prefixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios,
                            size: 15, color: LightThemeColors.menuInactive),
                        padding: EdgeInsets.zero,
                        onPressed: () async {
                          if (await webViewController?.canGoBack() ?? false) {
                            webViewController?.goBack();
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios,
                            size: 15, color: LightThemeColors.menuInactive),
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
                      borderSide: const BorderSide(color: Colors.transparent))),
              onSubmitted: _handleUrlSubmission,
            ),
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
    );
  }
}
