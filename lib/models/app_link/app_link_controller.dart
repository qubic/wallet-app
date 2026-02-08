import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/helpers/wallet_connect_methods.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/models/app_link/app_link_verbs.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/add_wallet_connect/add_wallet_connect.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/stores/root_jailbreak_flag_store.dart';

class AppLinkController {
  final ApplicationStore _applicationStore = getIt<ApplicationStore>();

  ///Validates the URI or throws an exception
  void validateUriOrThrow(Uri uri, BuildContext context) {
    final l10n = l10nOf(context);

    if (uri.hasEmptyPath) {
      throw Exception(l10n.uriIsEmpty);
    }

    if (!uri.isScheme(Config.CustomURLScheme)) {
      throw Exception(l10n.uriSchemeUnknown);
    }

    if (uri.pathSegments.isEmpty) {
      throw Exception(l10n.uriInvalidFormat);
    }
  }

// Handles a URL action to pair a WalletConnect connection
  void _handleWCPair(Uri uri, BuildContext context) async {
    final l10n = l10nOf(context);

    String connectionUrl;
    // Check if the URL contains an encoded 'uri' query parameter, and decode it
    if (uri.queryParameters.containsKey('uri')) {
      connectionUrl = Uri.decodeComponent(uri.queryParameters['uri']!);
    } else {
      // Remove the qubic scheme and host part of the URL to extract the connection details
      String remove = "${uri.scheme}://${uri.host}/";
      connectionUrl = uri.toString().substring(remove.length);
    }
    if (validateWalletConnectURL(connectionUrl, context) != null) {
      throw Exception(l10n.uriInvalidWCPairUrl);
    }
    if (getIt<RootJailbreakFlagStore>().restrictFeatureIfDeviceCompromised()) {
      return;
    }
    if (_applicationStore.nonWatchOnlyAccounts.isEmpty) {
      throw Exception(l10n.errorNoAccountsForWalletConnect);
    }
    await pushScreen(
      context,
      screen:
          AddWalletConnect(connectionUrl: connectionUrl, isFromDeepLink: true),
      withNavBar: false,
      pageTransitionAnimation: PageTransitionAnimation.cupertino,
    );
  }

  /// Parses the URI string and acts accordingly
  void parseUriString(Uri uri, BuildContext context) {
    final l10n = l10nOf(context);

    try {
      if (uri.host == AppLinkVerbs.pairWalletConnect) {
        validateUriOrThrow(uri, context);
        _handleWCPair(uri, context);
      } else if (uri.host == AppLinkVerbs.openApp) {
        // Just open the app
      } else {
        throw Exception(l10n.uriUnknownAction);
      }
    } catch (e) {
      _applicationStore.reportGlobalError(e.toString());
    }
  }
}
