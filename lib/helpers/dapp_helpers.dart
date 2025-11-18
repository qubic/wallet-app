import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/pages/main/tab_dapps/components/external_url_warning_dialog.dart';
import 'package:qubic_wallet/pages/main/tab_dapps/webview_screen.dart';
import 'package:qubic_wallet/resources/hive_storage.dart';
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
          if (_normalizeHost(dappUri.host) == normalizedHost &&
              dapp.icon != null) {
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
          if (_normalizeHost(dappUri.host) == normalizedHost &&
              dapp.icon != null) {
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

bool _shouldShowWarning(String url) {
  final hiveStorage = getIt<HiveStorage>();

  // Never show warning for qubic.org domains
  if (_isQubicDomain(url)) {
    return false;
  }

  // Check if user has dismissed the warning
  return !hiveStorage.getExternalUrlWarningDismissed();
}

Future<bool> openDappUrl(
  BuildContext context,
  String url, {
  bool hideFavorites = false,
  PageTransitionAnimation animation = PageTransitionAnimation.slideUp,
  bool withNavBar = true,
}) async {
  final hiveStorage = getIt<HiveStorage>();

  // Check if we should show security warning
  if (!_shouldShowWarning(url)) {
    // Open directly without warning
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

  // Show security warning dialog
  final shouldContinue = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => ExternalUrlWarningDialog(
      onContinue: (doNotRemindAgain) {
        // Store preference if user checked "do not remind"
        if (doNotRemindAgain) {
          hiveStorage.setExternalUrlWarningDismissed(true);
        }
        Navigator.pop(dialogContext, true);
      },
      onCancel: () {
        Navigator.pop(dialogContext, false);
      },
    ),
  );

  // If user confirmed, open the webview
  if (shouldContinue == true && context.mounted) {
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

  return false;
}
