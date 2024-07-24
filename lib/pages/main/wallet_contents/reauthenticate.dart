// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:qubic_wallet/components/reauthenticate/authenticate_password.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/styles/edgeInsets.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

class Reauthenticate extends StatefulWidget {
  final bool passwordOnly; // If true, only password authentication is required
  final bool
      autoLocalAuth; // If true, automatically authenticate with local auth
  const Reauthenticate(
      {super.key, this.passwordOnly = false, this.autoLocalAuth = true});

  @override
  // ignore: library_private_types_in_public_api
  _ReauthenticateState createState() => _ReauthenticateState();
}

class _ReauthenticateState extends State<Reauthenticate> {
  final ApplicationStore appStore = getIt<ApplicationStore>();

  bool hasAccepted = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget getHeader() {
    final l10n = l10nOf(context);

    return Stack(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child:
              ThemedControls.pageHeader(headerText: l10n.reauthenticateTitle),
        ),
        Align(
          alignment: Alignment.center,
          child: Text(l10n.reauthenticateHeader,
              style: Theme.of(context)
                  .textTheme
                  .displayMedium!
                  .copyWith(fontFamily: ThemeFonts.primary)),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Text(l10n.reathenticateLabelReason),
        )
      ],
    );
  }

  Widget getContents() {
    final l10n = l10nOf(context);
    return Column(
      children: [
        Expanded(
            child: ThemedControls.pageHeader(
                headerText: l10n.reauthenticateTitle)),
        Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewPadding.bottom),
            child: AuthenticatePassword(
              onSuccess: () {
                Navigator.of(context).pop(true);
              },
              passOnly: widget.passwordOnly,
            )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
        ),
        body: Padding(
            padding: ThemeEdgeInsets.pageInsets,
            child: Center(child: getContents())));
  }
}
