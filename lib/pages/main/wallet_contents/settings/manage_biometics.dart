import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:local_auth/local_auth.dart';
import 'package:qubic_wallet/components/gradient_foreground.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/re_auth_dialog.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/stores/settings_store.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:qubic_wallet/styles/edgeInsets.dart';
import 'package:qubic_wallet/styles/inputDecorations.dart';
import 'package:qubic_wallet/styles/textStyles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:qubic_wallet/timed_controller.dart';
import 'package:universal_platform/universal_platform.dart';

class ManageBiometrics extends StatefulWidget {
  const ManageBiometrics({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ManageBiometricsState createState() => _ManageBiometricsState();
}

class _ManageBiometricsState extends State<ManageBiometrics> {
  final ApplicationStore appStore = getIt<ApplicationStore>();
  final LocalAuthentication auth = LocalAuthentication();
  final SettingsStore settingsStore = getIt<SettingsStore>();

  bool? canCheckBiometrics; //If true, the device has biometrics
  List<BiometricType>? availableBiometrics; //Is empty, no biometric is enrolled
  bool? canUseBiometrics = false;

  String _scope = "biometric";
  String _title = "Manage Biometric Unlock";
  String _description =
      "You can enable authentication via biometrics. If enabled, you can sign in to your wallet and issue transfers without using your password";
  IconData _icon = Icons.fingerprint;
  String _settingsLabel = "Biometric Unlock";

  BiometricType? biometricType; //The type of biometric available

  bool enabled = false;
  @override
  void initState() {
    super.initState();
    auth.canCheckBiometrics.then((value) {
      setState(() {
        canCheckBiometrics = value;
      });
      if (!value) {
        setState(() {
          canUseBiometrics = false;
        });
        return;
      }
      auth.getAvailableBiometrics().then((value) {
        setState(() {
          availableBiometrics = value;
          canUseBiometrics = value.isNotEmpty;
          enabled = settingsStore.settings.biometricEnabled;
          if ((value.contains(BiometricType.face)) && (biometricType == null)) {
            setState(() {
              biometricType = BiometricType.face;
              _description =
                  "You can enable authentication via Face ID. If you enable this, you can sign in to your wallet and issue transfers without using your password";
              _title = "Manage unlock with Face ID";
              _settingsLabel = "Unlock with Face ID";
              _icon = Icons.face_outlined;
            });
          }
          if ((value.contains(BiometricType.fingerprint)) &&
              (biometricType == null)) {
            setState(() {
              biometricType = BiometricType.fingerprint;
              _description =
                  "You can enable authentication via Touch ID. If you enable this, you can unlock your wallet and issue transfers without using your password";
              _title = "Manage unlock with Touch ID";
              _settingsLabel = "Unlock with Touch ID";
              _icon = Icons.fingerprint;
            });
          }
          if ((value.contains(BiometricType.iris)) && (biometricType == null)) {
            setState(() {
              biometricType = BiometricType.iris;
              _description =
                  "You can enable authentication with your iris. If you enable this, you can unlock your wallet and issue transfers without using your password";
              _title = "Manage unlock with Iris";
              _settingsLabel = "Unlock with Iris";
              _icon = Icons.remove_red_eye_outlined;
            });
          }
          if ((value.contains(BiometricType.strong)) &&
              (biometricType == null)) {
            setState(() {
              biometricType = BiometricType.strong;

              if (UniversalPlatform.isDesktop) {
                _description =
                    "You can enable authentication through your OS. If you enable this, you can unlock  your wallet and issue transfers using your OS authentication";
                _title = "Manage unlock with OS";
                _settingsLabel = "Unlock with OS";
                _icon = Icons.shield;
              } else {
                _description =
                    "You can enable authentication with biometrics. If you enable this, you can unlock your wallet and issue transfers without using your password";
                _title = "Manage unlock with Biometric";
                _settingsLabel = "Unlock with Biometric";
                _icon = Icons.fingerprint;
              }
            });
          }
        });
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget loadingIndicator() {
    return Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
          const SizedBox(height: ThemePaddings.hugePadding),
          const CircularProgressIndicator(),
          const SizedBox(height: ThemePaddings.normalPadding),
          Text("Loading...",
              style: Theme.of(context)
                  .textTheme
                  .displayMedium!
                  .copyWith(fontFamily: ThemeFonts.primary))
        ]));
  }

  Widget biometricsControls() {
    var theme = SettingsThemeData(
      settingsSectionBackground: LightThemeColors.cardBackground,
      //Theme.of(context).cardTheme.color,
      settingsListBackground: LightThemeColors.background,
      dividerColor: Colors.transparent,
      titleTextColor: Theme.of(context).colorScheme.onBackground,
    );
    return Column(children: [
      const SizedBox(height: ThemePaddings.hugePadding),
      Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        GradientForeground(
            child: Icon(_icon,
                size: 100, color: Theme.of(context).colorScheme.primary)),
      ]),
      const SizedBox(height: ThemePaddings.hugePadding),
      SettingsList(
          shrinkWrap: true,
          applicationType: ApplicationType.material,
          contentPadding: const EdgeInsets.all(0),
          darkTheme: theme,
          lightTheme: theme,
          sections: [
            SettingsSection(
              tiles: <SettingsTile>[
                SettingsTile.switchTile(
                  onToggle: (value) async {
                    //When enabling, then reauthenticate and then localise Authenticate
                    if (value == true) {
                      final bool reAuthValue = await reAuthDialog(context);
                      if (!reAuthValue) {
                        return false;
                      }
                      final bool didAuthenticate = await auth.authenticate(
                          localizedReason: ' ',
                          options: AuthenticationOptions(
                              biometricOnly:
                                  UniversalPlatform.isDesktop ? false : true));
                      if (!didAuthenticate) {
                        return false;
                      }
                    } else {
                      final bool reAuthValue = await reAuthDialog(context);
                      if (!reAuthValue) {
                        return false;
                      }
                    }
                    setState(() {
                      enabled = value;
                    });
                    await settingsStore.setBiometrics(value);
                  },
                  initialValue: enabled,
                  title: Text(_settingsLabel, style: TextStyles.labelText),
                ),
              ],
            ),
          ])
    ]);
  }

  Widget showPossibleErrors() {
    String? errorText;
    String? errorDescription;
    if ((canCheckBiometrics == false) || (availableBiometrics == null)) {
      errorText = UniversalPlatform.isDesktop
          ? "OS authentication not available"
          : "Biometric authentication not available";
      errorDescription = UniversalPlatform.isDesktop
          ? "Your OS does not support OS authentication"
          : "Your device does not support biometric authentication";
    }

    if (availableBiometrics != null && availableBiometrics!.isEmpty) {
      errorText = UniversalPlatform.isDesktop
          ? "No authentication info is registred in your OS"
          : "No biometric data has been registered in the device.";
      errorDescription = UniversalPlatform.isDesktop
          ? "You have not setup authentication in your OS. Please navigate to your OS control panel and setup authentication"
          : "Your device supports biometric authentication but you have not registered your biometric data yet. Please navigate to your device control panel, register your biometric data and try again";
    }
    if (errorText == null) {
      return Container();
    }
    return Padding(
        padding: EdgeInsets.only(top: ThemePaddings.bigPadding),
        child: ThemedControls.card(
            child: Column(children: [
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GradientForeground(
                      child: Image.asset("assets/images/Group 2358.png")),
                  ThemedControls.spacerHorizontalNormal(),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(errorText, style: TextStyles.secondaryText),
                        ThemedControls.spacerVerticalNormal(),
                        Text(errorDescription ?? "",
                            style: TextStyles.secondaryText)
                      ]))
                ]),
          ]),
        ])));
  }

  Widget getScrollView() {
    return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Row(children: [
          Container(
              child: Expanded(
                  child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ThemedControls.pageHeader(headerText: _title),
              Text(_description, style: TextStyles.secondaryText),
              canUseBiometrics == null
                  ? loadingIndicator()
                  : canUseBiometrics! == true
                      ? biometricsControls()
                      : showPossibleErrors(),
            ],
          )))
        ]));
  }

  Widget getButtons() {
    return Container();
    // return !isLoading
    //     ? Expanded(
    //         child: ThemedControls.primaryButtonBigWithChild(
    //             child: Padding(
    //                 padding: const EdgeInsets.all(ThemePaddings.normalPadding),
    //                 child:
    //                     Text("Go back", style: TextStyles.primaryButtonText)),
    //             onPressed: () {
    //               Navigator.pop(context);
    //             }))
    //     : Container();
  }

  void saveIdHandler() async {
    Navigator.pop(context);
  }

  TextEditingController privateSeed = TextEditingController();

  bool showAccountInfoTooltip = false;
  bool showSeedInfoTooltip = false;
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          return Future.value(!isLoading);
        },
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
            ),
            body: SafeArea(
                minimum: ThemeEdgeInsets.pageInsets
                    .copyWith(bottom: ThemePaddings.normalPadding),
                child: Column(children: [
                  Expanded(child: getScrollView()),
                  Row(children: [getButtons()]),
                ]))));
  }
}
