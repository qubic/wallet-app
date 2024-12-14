import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/helpers/wallet_connect_methods.dart';
import 'package:qubic_wallet/models/app_link/app_link_verbs.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/add_wallet_connect/add_wallet_connect.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/l10n/l10n.dart';

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

  //Handles a URL action to pair a wallet connect connection
  void _handleWCPair(Uri uri, BuildContext context) {
    final l10n = l10nOf(context);

    String remove = "${uri.scheme}://${uri.host}/";
    //Trim out qubic-wallet scheme and host
    String connectionUrl = uri.toString().substring(remove.length);

    if (validateWalletConnectURL(connectionUrl, context) != null) {
      throw Exception(l10n.uriInvalidWCPairUrl);
    }

    pushScreen(
      context,
      screen: AddWalletConnect(connectionUrl: connectionUrl),
      withNavBar: false,
      pageTransitionAnimation: PageTransitionAnimation.cupertino,
    );
  }

  ///Parses the URI string and acts accordingly
  void parseUriString(Uri uri, BuildContext context) {
    final l10n = l10nOf(context);

    try {
      validateUriOrThrow(uri, context);
      if (uri.host == AppLinkVerbs.PairWalletConnect) {
        _handleWCPair(uri, context);
      } else {
        throw Exception(l10n.uriUnknownAction);
      }
    } catch (e) {
      _applicationStore.reportGlobalError(e.toString());
    }
  }
}
