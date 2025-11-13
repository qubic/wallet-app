import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/models/terms_acceptance.dart';
import 'package:qubic_wallet/pages/main/tab_dapps/components/dapp_disclaimer_sheet.dart';
import 'package:qubic_wallet/pages/main/tab_dapps/webview_screen.dart';
import 'package:qubic_wallet/resources/hive_storage.dart';
import 'package:qubic_wallet/stores/settings_store.dart';
import 'package:qubic_wallet/stores/wallet_content_store.dart';

/// Extracts the domain/host from a URL
/// Returns the host if successful, or the full URL if parsing fails
String extractDomain(String url) {
  try {
    final uri = Uri.parse(url);
    return uri.host;
  } catch (e) {
    return url;
  }
}

/// Normalizes a host by removing 'www.' prefix for comparison
String _normalizeHost(String host) {
  final normalized = host.toLowerCase();
  if (normalized.startsWith('www.')) {
    return normalized.substring(4);
  }
  return normalized;
}

/// Finds an icon for a favorite dApp based on priority:
/// 1. If URL host matches an existing app in wallet store, use its icon
/// 2. If pageIconUrl is provided, use it
/// 3. Otherwise, return null (will use default icon)
String? findFavoriteIcon(String url, String? pageIconUrl) {
  final walletStore = getIt<WalletContentStore>();

  try {
    final uri = Uri.parse(url);
    final normalizedHost = _normalizeHost(uri.host);

    // Check topDapps for matching host
    for (final dapp in walletStore.topDapps) {
      if (dapp.url != null) {
        try {
          final dappUri = Uri.parse(dapp.url!);
          if (_normalizeHost(dappUri.host) == normalizedHost && dapp.icon != null) {
            return dapp.icon;
          }
        } catch (e) {
          // Skip if URL parsing fails
        }
      }
    }

    // Check popularDapps for matching host
    for (final dapp in walletStore.popularDapps) {
      if (dapp.url != null) {
        try {
          final dappUri = Uri.parse(dapp.url!);
          if (_normalizeHost(dappUri.host) == normalizedHost && dapp.icon != null) {
            return dapp.icon;
          }
        } catch (e) {
          // Skip if URL parsing fails
        }
      }
    }
  } catch (e) {
    // If URL parsing fails, fall through to pageIconUrl
  }

  // Return pageIconUrl if available, otherwise null
  return pageIconUrl;
}

bool _isQubicDomain(String url) {
  try {
    final uri = Uri.parse(url);
    return uri.host.toLowerCase().contains('qubic.org');
  } catch (e) {
    return false;
  }
}

bool _shouldShowDisclaimer(String url) {
  final hiveStorage = getIt<HiveStorage>();
  final walletStore = getIt<WalletContentStore>();

  // Never show disclaimer for qubic.org domains
  if (_isQubicDomain(url)) {
    return false;
  }

  final termsMetadata = walletStore.termsMetadata;
  final acceptance = hiveStorage.getTermsAcceptance();

  // If metadata not loaded or no terms metadata, use fallback logic
  if (termsMetadata == null) {
    // Fallback: show disclaimer if never accepted
    return acceptance == null;
  }

  // Never accepted any version - show disclaimer
  if (acceptance == null) {
    return true;
  }

  // User already accepted this exact version - skip disclaimer
  if (acceptance.version == termsMetadata.version) {
    return false;
  }

  // User accepted a different version
  // Show disclaimer only if this version requires acceptance
  return termsMetadata.requiresAcceptance;
}

Future<bool> openDappUrl(
  BuildContext context,
  String url, {
  bool hideFavorites = false,
  PageTransitionAnimation animation = PageTransitionAnimation.slideUp,
  bool withNavBar = true,
}) async {
  final hiveStorage = getIt<HiveStorage>();
  final walletStore = getIt<WalletContentStore>();

  // Check if we should show disclaimer
  if (!_shouldShowDisclaimer(url)) {
    // Open directly without disclaimer
    await pushScreen(
      context,
      screen: WebviewScreen(
        initialUrl: url,
        hideFavorites: hideFavorites,
      ),
      pageTransitionAnimation: animation,
      withNavBar: withNavBar,
    );
    return true;
  }

  // Get terms metadata for version and contentUrl
  final termsMetadata = walletStore.termsMetadata;

  // If metadata is not available, we cannot proceed with acceptance
  // This should not happen as metadata is fetched on app startup
  if (termsMetadata == null) {
    // Metadata not loaded - should have been loaded on startup
    // Block dApp access until metadata is available
    return false;
  }

  // Show disclaimer first
  final rootContext = Navigator.of(context, rootNavigator: true).context;
  final result = await showModalBottomSheet<bool>(
    context: rootContext,
    isDismissible: false,
    enableDrag: false,
    isScrollControlled: true,
    useRootNavigator: true,
    builder: (modalContext) => DappDisclaimerSheet(
      termsMetadata: termsMetadata,
      onAccept: () {
        final settingsStore = getIt<SettingsStore>();

        // Store terms acceptance with version from metadata
        hiveStorage.setTermsAcceptance(
          TermsAcceptance(
            version: termsMetadata.version,
            acceptedAt: DateTime.now(),
            appVersion: settingsStore.versionInfo ?? 'unknown',
          ),
        );
        Navigator.pop(modalContext, true);

        // Open the webview after disclaimer is accepted
        pushScreen(
          context,
          screen: WebviewScreen(
            initialUrl: url,
            hideFavorites: hideFavorites,
          ),
          pageTransitionAnimation: animation,
          withNavBar: withNavBar,
        );
      },
      onReject: () {
        Navigator.pop(modalContext, false);
      },
    ),
  );

  return result ?? false;
}
