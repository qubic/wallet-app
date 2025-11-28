import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/global_snack_bar.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/pages/main/tab_dapps/components/add_to_favorites_dialog.dart';
import 'package:qubic_wallet/resources/hive_storage.dart';
import 'package:qubic_wallet/styles/input_decorations.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class WebviewAddressBar extends StatefulWidget {
  const WebviewAddressBar({
    super.key,
    required this.urlController,
    required this.webViewController,
    required this.canGoBack,
    required this.canGoForward,
    required this.urlChangeNotifier,
    this.hideFavorites = false,
  });

  final TextEditingController urlController;
  final InAppWebViewController? webViewController;
  final ValueNotifier<bool> canGoBack;
  final ValueNotifier<bool> canGoForward;
  final ValueNotifier<int> urlChangeNotifier;
  final bool hideFavorites;

  @override
  State<WebviewAddressBar> createState() => _WebviewAddressBarState();
}

class _WebviewAddressBarState extends State<WebviewAddressBar> {
  bool _isFavorite = false;
  String? _cachedTitle;
  String? _cachedFaviconUrl;

  @override
  void initState() {
    super.initState();
    widget.urlChangeNotifier.addListener(_onUrlChanged);
    _onUrlChanged();
  }

  @override
  void dispose() {
    widget.urlChangeNotifier.removeListener(_onUrlChanged);
    super.dispose();
  }

  void _onUrlChanged() async {
    if (widget.webViewController != null) {
      final webUrl = await widget.webViewController!.getUrl();
      if (webUrl != null && mounted) {
        final hiveStorage = getIt<HiveStorage>();

        // Update favorite status
        final isFavorite = hiveStorage.isFavorite(webUrl.toString());

        // Cache title and favicon for instant access when adding to favorites
        String? title;
        String? faviconUrl;

        try {
          title = await widget.webViewController!.getTitle();
          final favicons = await widget.webViewController!.getFavicons();
          if (favicons.isNotEmpty) {
            faviconUrl = favicons.first.url.toString();
          }
        } catch (_) {
          // Silently fail - we'll use fallback later if needed
        }

        // Fallback favicon URL
        if (faviconUrl == null || faviconUrl.isEmpty) {
          try {
            final uri = Uri.parse(webUrl.toString());
            faviconUrl = '${uri.scheme}://${uri.host}/favicon.ico';
          } catch (_) {
            // Ignore
          }
        }

        if (mounted) {
          setState(() {
            _isFavorite = isFavorite;
            _cachedTitle = title;
            _cachedFaviconUrl = faviconUrl;
          });
        }
      }
    }
  }

  void _handleUrlSubmission(String input) {
    final isValidUrl = RegExp(
            r'^(https?:\/\/)?(www\.)?([a-zA-Z0-9-_]+(\.[a-zA-Z]{2,})+)(\/.*)?$')
        .hasMatch(input);

    final url = isValidUrl
        ? (input.startsWith("http") ? input : "https://$input")
        : "https://www.google.com/search?q=${Uri.encodeComponent(input)}";

    widget.webViewController?.loadUrl(
        urlRequest: URLRequest(url: WebUri.uri(Uri.parse(url))));
  }

  Color _getButtonColor(bool isActive) {
    return isActive
        ? LightThemeColors.menuActive
        : LightThemeColors.menuInactive;
  }

  void _reloadPage(BuildContext context) async {
    if (widget.webViewController != null) {
      widget.webViewController?.reload();
    }
  }

  void _shareCurrentUrl(BuildContext context) async {
    if (widget.webViewController != null) {
      final url = await widget.webViewController!.getUrl();
      if (url != null) {
        await Share.share(url.toString());
      }
    }
  }

  void _openInBrowser(BuildContext context) async {
    if (widget.webViewController != null) {
      final url = await widget.webViewController!.getUrl();
      if (url != null) {
        final uri = Uri.parse(url.toString());
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      }
    }
  }

  void _handleFavoriteAction(BuildContext context) async {
    final l10n = l10nOf(context);
    if (widget.webViewController != null) {
      final url = await widget.webViewController!.getUrl();
      if (url != null && context.mounted) {
        final hiveStorage = getIt<HiveStorage>();

        if (_isFavorite) {
          // Remove from favorites
          hiveStorage.removeFavoriteDapp(url.toString());
          final globalSnackBar = getIt<GlobalSnackBar>();
          globalSnackBar.show(l10n.favoriteRemoved);
        } else {
          // Add to favorites - use cached values for instant display
          await showDialog(
            context: context,
            builder: (context) => AddToFavoritesDialog(
              url: url.toString(),
              initialName: _cachedTitle,
              iconUrl: _cachedFaviconUrl,
            ),
          );
        }
        _onUrlChanged();
      }
    }
  }


  PopupMenuItem<String> _getMenuItem({
    required String value,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return PopupMenuItem<String>(
      value: value,
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor ?? LightThemeColors.menuInactive),
          ThemedControls.spacerHorizontalSmall(),
          Text(label, style: TextStyles.inputBoxSmallStyle.copyWith(color: textColor)),
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
              controller: widget.urlController,
              onTap: () => widget.urlController.selection = TextSelection(
                  baseOffset: 0, extentOffset: widget.urlController.value.text.length),
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
                            onTap: () => _reloadPage(context),
                            icon: Icons.refresh,
                          ),
                          if (!widget.hideFavorites && !_isFavorite)
                            _getMenuItem(
                              value: 'favorite',
                              label: l10n.addToFavorites,
                              onTap: () => _handleFavoriteAction(context),
                              icon: Icons.star_border,
                            ),
                          _getMenuItem(
                            value: 'share',
                            label: l10n.webviewAddressBarLabelShareURL,
                            onTap: () => _shareCurrentUrl(context),
                            icon: Icons.share,
                          ),
                          _getMenuItem(
                            value: 'open_in_browser',
                            label: l10n.webviewAddressBarLabelOpenInBrowser,
                            onTap: () => _openInBrowser(context),
                            icon: Icons.open_in_browser,
                          ),
                          if (!widget.hideFavorites && _isFavorite)
                            _getMenuItem(
                              value: 'remove_favorite',
                              label: l10n.removeFavorite,
                              onTap: () => _handleFavoriteAction(context),
                              icon: Icons.star,
                              iconColor: LightThemeColors.error,
                              textColor: LightThemeColors.error,
                            ),
                        ],
                      ),
                    ],
                  ),
                  prefixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ValueListenableBuilder<bool>(
                          valueListenable: widget.canGoBack,
                          builder: (context, value, child) {
                            return IconButton(
                              icon: Icon(Icons.arrow_back_ios,
                                  size: 15, color: _getButtonColor(value)),
                              padding: EdgeInsets.zero,
                              onPressed: value
                                  ? () async {
                                      widget.webViewController?.goBack();
                                    }
                                  : null,
                            );
                          }),
                      ValueListenableBuilder<bool>(
                          valueListenable: widget.canGoForward,
                          builder: (context, value, child) {
                            return IconButton(
                              icon: Icon(
                                Icons.arrow_forward_ios,
                                size: 15,
                                color: _getButtonColor(value),
                              ),
                              onPressed: value
                                  ? () async {
                                      widget.webViewController?.goForward();
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
