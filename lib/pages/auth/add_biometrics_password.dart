import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/resources/qubic_cmd.dart';

import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/stores/settings_store.dart';
import 'package:qubic_wallet/styles/edge_insets.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:universal_platform/universal_platform.dart';

class AddBiometricsPassword extends StatefulWidget {
  const AddBiometricsPassword({super.key, required this.onAddedBiometrics});

  final Function(bool hasAddedBiometrics) onAddedBiometrics;

  @override
  // ignore: library_private_types_in_public_api
  _AddBiometricsPasswordState createState() => _AddBiometricsPasswordState();
}

class _AddBiometricsPasswordState extends State<AddBiometricsPassword> {
  bool isLoading = false; //Is the form loading

  final ApplicationStore appStore = getIt<ApplicationStore>();
  bool obscuringTextPass = true; //Hide password text
  bool obscuringTextPassRepeat = true; //Hide password repeat text
  final QubicCmd qubicCmd = getIt<QubicCmd>();
  String? generatedPublicId;

  String currentPassword = "";
  String? signUpError;

//Variable for local authentication
  final LocalAuthentication auth = LocalAuthentication();
  bool? canCheckBiometrics; //If true, the device has biometrics
  List<BiometricType>? availableBiometrics; //Is empty, no biometric is enrolled
  final SettingsStore settingsStore = getIt<SettingsStore>();
  bool? canUseBiometrics = false;
  bool enabledBiometrics = false;

  @override
  void initState() {
    super.initState();

    auth.canCheckBiometrics.then((value) {
      setState(() {
        canCheckBiometrics = value;
      });

      if (value == true) {
        auth.getAvailableBiometrics().then((value) {
          setState(() {
            availableBiometrics = value;
            canUseBiometrics = value.isNotEmpty;
          });
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  //Gets the loading indicator inside button
  Widget _getLoadingProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: SizedBox(
          width: 21,
          height: 21,
          child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Theme.of(context).colorScheme.inversePrimary)),
    );
  }

  Widget biometricsControls() {
    if (canUseBiometrics == null) return Container();
    if (canUseBiometrics! == false) return Container();
    if (canCheckBiometrics == null) return Container();
    if (canCheckBiometrics! == false) return Container();

    String enableText = "Biometric Unlock";
    if (UniversalPlatform.isDesktop) {
      enableText = "OS unlock";
    }

    return Flex(direction: Axis.horizontal, children: [
      Flexible(
          fit: FlexFit.tight,
          flex: 4,
          child: Text(
            enableText,
          )),
      Flexible(
          fit: FlexFit.tight,
          child: Switch(
              activeColor: LightThemeColors.primary,
              activeTrackColor: LightThemeColors.buttonPrimary,
              trackOutlineColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                return Colors.orange.withOpacity(0);
              }),
              value: enabledBiometrics,
              onChanged: (value) async {
                if (value == true) {
                  final bool didAuthenticate = await auth.authenticate(
                      localizedReason: ' ',
                      options: AuthenticationOptions(
                          biometricOnly:
                              UniversalPlatform.isDesktop ? false : true));
                  if (!didAuthenticate) {
                    return;
                  }
                }
                setState(() {
                  enabledBiometrics = value;
                });
              }))
    ]);
  }

  Future<void> _handleProceed() async {
    setState(() {
      isLoading = true;
    });
    widget.onAddedBiometrics(enabledBiometrics);
    setState(() {
      isLoading = false;
    });
  }

  List<Widget> getButtons() {
    final l10n = l10nOf(context);
    return [
      Expanded(
          child: ThemedControls.primaryButtonBigWithChild(
              onPressed: () async {
                await _handleProceed();
              },
              child: isLoading
                  ? _getLoadingProgressIndicator()
                  : Padding(
                      padding:
                          const EdgeInsets.all(ThemePaddings.smallPadding + 3),
                      child: Text(l10n.generalButtonProceed,
                          textAlign: TextAlign.center,
                          style: TextStyles.primaryButtonText),
                    )))
    ];
  }

  //Gets the container scroll view
  Widget getScrollView() {
    String title = "Biometric unlock";
    String subheader =
        "You can enable authentication via biometrics. If enabled, you can sign in to your wallet and issue transfers without using your password.";

    if (UniversalPlatform.isDesktop) {
      title = "OS unlock";
      subheader =
          "You can enable authentication via your OS. If you enable this, you can sign in to your wallet and issue transfers without using your password.";
    }

    return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Row(children: [
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ThemedControls.pageHeader(headerText: title, subheaderText: ""),
              Text(subheader, style: TextStyles.secondaryText),
              ThemedControls.spacerVerticalHuge(),
              biometricsControls()
            ],
          ))
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: !isLoading,
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
            ),
            body: SafeArea(
              child: Padding(
                padding: ThemeEdgeInsets.pageInsets,
                child: Column(children: [
                  Expanded(child: getScrollView()),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: getButtons())
                ]),
              ),
            )));
  }
}
