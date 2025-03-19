import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/styles/input_decorations.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:share_plus/share_plus.dart';

class WebviewAddressBar extends StatelessWidget {
  const WebviewAddressBar({
    super.key,
    required this.urlController,
    required this.webViewController,
    required this.canGoBack,
    required this.canGoForward,
  });

  final TextEditingController urlController;
  final InAppWebViewController? webViewController;
  final ValueNotifier<bool> canGoBack;
  final ValueNotifier<bool> canGoForward;

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

  Color _getButtonColor(bool isActive) {
    return isActive
        ? LightThemeColors.menuActive
        : LightThemeColors.menuInactive;
  }

  void _shareCurrentUrl(BuildContext context) async {
    if (webViewController != null) {
      final url = await webViewController!.getUrl();
      if (url != null) {
        await Share.share(url.toString());
      }
    }
  }

  void _copyUrlToClipboard(BuildContext context) async {
    if (webViewController != null) {
      final url = await webViewController!.getUrl();
      if (url != null) {
        await Clipboard.setData(ClipboardData(text: url.toString()));
      }
    }
  }

  PopupMenuItem<String> _getMenuItem({
    required String value,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return PopupMenuItem<String>(
      value: value,
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 18, color: LightThemeColors.menuInactive),
          const SizedBox(width: 8),
          Text(label, style: TextStyles.inputBoxSmallStyle),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          ThemePaddings.normalPadding,
          ThemePaddings.smallPadding,
          ThemePaddings.minimumPadding,
          ThemePaddings.mediumPadding),
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
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_vert,
                          size: 15,
                          color: LightThemeColors.menuInactive,
                        ),
                        offset: const Offset(0, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        itemBuilder: (context) => [
                          _getMenuItem(
                            value: 'refresh',
                            label: l10n.webviewAddressBarLabelRefresh,
                            onTap: () => webViewController?.reload(),
                            icon: Icons.refresh,
                          ),
                          _getMenuItem(
                            value: 'share',
                            label: l10n.webviewAddressBarLabelShareURL,
                            onTap: () => _shareCurrentUrl(context),
                            icon: Icons.share,
                          ),
                          _getMenuItem(
                            value: 'copy',
                            label: l10n.webviewAddressBarLabelCopyURL,
                            onTap: () => _copyUrlToClipboard(context),
                            icon: Icons.content_copy,
                          ),
                        ],
                      ),
                    ],
                  ),
                  prefixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ValueListenableBuilder<bool>(
                          valueListenable: canGoBack,
                          builder: (context, value, child) {
                            return IconButton(
                              icon: Icon(Icons.arrow_back_ios,
                                  size: 15, color: _getButtonColor(value)),
                              padding: EdgeInsets.zero,
                              onPressed: value
                                  ? () async {
                                      webViewController?.goBack();
                                    }
                                  : null,
                            );
                          }),
                      ValueListenableBuilder<bool>(
                          valueListenable: canGoForward,
                          builder: (context, value, child) {
                            return IconButton(
                              icon: Icon(
                                Icons.arrow_forward_ios,
                                size: 15,
                                color: _getButtonColor(value),
                              ),
                              onPressed: value
                                  ? () async {
                                      webViewController?.goForward();
                                    }
                                  : null,
                            );
                          }),
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
