import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/resources/apis/static/qubic_static_api.dart';
import 'package:qubic_wallet/styles/text_styles.dart';

class TermsOfUseScreen extends StatefulWidget {
  const TermsOfUseScreen({super.key});

  @override
  State<TermsOfUseScreen> createState() => _TermsOfUseScreenState();
}

class _TermsOfUseScreenState extends State<TermsOfUseScreen> {
  final QubicStaticApi _staticApi = getIt<QubicStaticApi>();
  final ValueNotifier<double> progress = ValueNotifier<double>(0);
  InAppWebViewController? webViewController;
  bool _hasTriedFallback = false;

  String getTermsUrl(BuildContext context, {bool forceEnglish = false}) {
    final currentLocale = forceEnglish ? 'en' : l10nOf(context).localeName;
    return _staticApi.getTermsUrl(currentLocale);
  }

  void _handleLoadError() {
    if (!_hasTriedFallback) {
      _hasTriedFallback = true;
      // Fallback to English if the localized version doesn't exist
      final englishUrl = getTermsUrl(context, forceEnglish: true);
      webViewController?.loadUrl(
        urlRequest: URLRequest(url: WebUri.uri(Uri.parse(englishUrl))),
      );
    }
  }

  @override
  void dispose() {
    progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    final termsUrl = getTermsUrl(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.generalLabelTermsOfService,
          style: TextStyles.textExtraLargeBold,
        ),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress indicator
          ValueListenableBuilder<double>(
            valueListenable: progress,
            builder: (context, value, child) {
              return value < 1.0
                  ? LinearProgressIndicator(
                      value: value,
                      backgroundColor: LightThemeColors.inputBorderColor,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        LightThemeColors.primary,
                      ),
                    )
                  : const SizedBox.shrink();
            },
          ),
          // WebView
          Expanded(
            child: InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri.uri(Uri.parse(termsUrl)),
              ),
              initialSettings: InAppWebViewSettings(
                useShouldOverrideUrlLoading: false,
                safeBrowsingEnabled: true,
                javaScriptEnabled: true,
              ),
              onWebViewCreated: (controller) {
                webViewController = controller;
              },
              onProgressChanged: (controller, p) {
                progress.value = p / 100;
              },
              onLoadStop: (controller, url) {
                progress.value = 1.0;
              },
              onReceivedError: (controller, request, error) {
                _handleLoadError();
              },
              onReceivedHttpError: (controller, request, response) {
                if (response.statusCode == 404) {
                  _handleLoadError();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
