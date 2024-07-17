// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:qubic_wallet/components/reauthenticate/authenticate_password.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/styles/edgeInsets.dart';
import 'package:qubic_wallet/styles/textStyles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

// A clone of the Reauthenticate widget, but supporting password only and returning the password on success
class ReauthenticateGetPassword extends StatefulWidget {
  const ReauthenticateGetPassword({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ReauthenticateGetPasswordState createState() =>
      _ReauthenticateGetPasswordState();
}

class _ReauthenticateGetPasswordState extends State<ReauthenticateGetPassword> {
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
    return Stack(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child:
              ThemedControls.pageHeader(headerText: "Authentication Required"),
        ),
        Align(
          alignment: Alignment.center,
          child: Text("Please reauthenticate",
              style: Theme.of(context)
                  .textTheme
                  .displayMedium!
                  .copyWith(fontFamily: ThemeFonts.primary)),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Text(
              "Please authenticate again in order to proceed. The password you provide will be the one used to encrypt your vault wallet."),
        )
      ],
    );
  }

  Widget getContents() {
    return Column(
      children: [
        Expanded(
            child: ThemedControls.pageHeader(
                headerText: "Authentication Required")),
        Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewPadding.bottom),
            child: AuthenticatePassword(
              onSuccess: (password) {
                Navigator.of(context).pop(password);
              },
              passOnly: true,
              returnPassword: true,
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
