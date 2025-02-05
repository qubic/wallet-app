import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:qubic_wallet/components/gradient_foreground.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/re_auth_dialog.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/stores/settings_store.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:qubic_wallet/styles/edge_insets.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:qubic_wallet/l10n/l10n.dart';

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

  String _title = "";
  String _description = "";
  Widget _icon = const Icon(Icons.fingerprint);
  String _switchLabel = "";

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
        final l10n = l10nOf(context);
        setState(() {
          availableBiometrics = value;
          canUseBiometrics = value.isNotEmpty;
          enabled = settingsStore.settings.biometricEnabled;
          if ((value.contains(BiometricType.face)) && (biometricType == null)) {
            setState(() {
              biometricType = BiometricType.face;
              _description =
                  "${l10n.manageBiometricsLabelInstructionsForFaceID} ${l10n.manageBiometricsLabelAdditionalInstructions}";
              _title =
                  l10n.manageBiometricsTitle(l10n.generalBiometricTypeFaceID);
              _switchLabel = l10n
                  .manageBiometricsSwitchLabel(l10n.generalBiometricTypeFaceID);
              _icon = Image.asset("assets/images/faceid-big.png");
            });
          }
          if ((value.contains(BiometricType.fingerprint)) &&
              (biometricType == null)) {
            setState(() {
              biometricType = BiometricType.fingerprint;
              _description =
                  "${l10n.manageBiometricsLabelInstructionsForTouchID} ${l10n.manageBiometricsLabelAdditionalInstructions}";
              _title =
                  l10n.manageBiometricsTitle(l10n.generalBiometricTypeTouchID);
              _switchLabel = l10n.manageBiometricsSwitchLabel(
                  l10n.generalBiometricTypeTouchID);
              _icon = const Icon(Icons.fingerprint,
                  size: 100, color: LightThemeColors.buttonBackground);
            });
          }
          if ((value.contains(BiometricType.iris)) && (biometricType == null)) {
            setState(() {
              biometricType = BiometricType.iris;
              _description =
                  "${l10n.manageBiometricsLabelInstructionsForIris} ${l10n.manageBiometricsLabelAdditionalInstructions}";
              _title =
                  l10n.manageBiometricsTitle(l10n.generalBiometricTypeIris);
              _switchLabel = l10n
                  .manageBiometricsSwitchLabel(l10n.generalBiometricTypeIris);
              _icon = const Icon(Icons.remove_red_eye_outlined,
                  size: 100, color: LightThemeColors.buttonBackground);
            });
          }
          if ((value.contains(BiometricType.strong)) &&
              (biometricType == null)) {
            setState(() {
              biometricType = BiometricType.strong;

              if (UniversalPlatform.isDesktop) {
                _description =
                    "${l10n.manageBiometricsLabelInstructionsForOS} ${l10n.manageBiometricsLabelAdditionalInstructions}";
                _title =
                    l10n.manageBiometricsTitle(l10n.generalBiometricTypeOS);
                _switchLabel = l10n
                    .manageBiometricsSwitchLabel(l10n.generalBiometricTypeOS);
                _icon = const Icon(Icons.shield,
                    size: 100, color: LightThemeColors.buttonBackground);
              } else {
                _description =
                    "${l10n.manageBiometricsLabelInstructionsForGeneric} ${l10n.manageBiometricsLabelAdditionalInstructions}";
                _title = l10n
                    .manageBiometricsTitle(l10n.generalBiometricTypeGeneric);
                _switchLabel = l10n.manageBiometricsSwitchLabel(
                    l10n.generalBiometricTypeGeneric);
                _icon = const Icon(Icons.fingerprint,
                    size: 100, color: LightThemeColors.buttonBackground);
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
    final l10n = l10nOf(context);

    return Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
          const SizedBox(height: ThemePaddings.hugePadding),
          const CircularProgressIndicator(),
          const SizedBox(height: ThemePaddings.normalPadding),
          Text(l10n.generalLabelLoading,
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
      settingsListBackground: LightThemeColors.cardBackground,
      dividerColor: Colors.transparent,
      titleTextColor: Theme.of(context).colorScheme.onBackground,
    );
    return Column(children: [
      const SizedBox(height: ThemePaddings.hugePadding),
      Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        _icon,
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
                  title: Text(_switchLabel, style: TextStyles.labelText),
                ),
              ],
            ),
          ])
    ]);
  }

  Widget showPossibleErrors() {
    final l10n = l10nOf(context);
    String? errorText;
    String? errorDescription;
    if ((canCheckBiometrics == false) || (availableBiometrics == null)) {
      errorText = UniversalPlatform.isDesktop
          ? l10n.manageBiometricsErrorOSAuthNotAvailableTitle
          : l10n.manageBiometricsErrorNotAvailableTitle;
      errorDescription = UniversalPlatform.isDesktop
          ? l10n.manageBiometricsErrorOSAuthNotAvailableMessage
          : l10n.manageBiometricsErrorNotAvailableMessage;
    }

    if (availableBiometrics != null && availableBiometrics!.isEmpty) {
      errorText = UniversalPlatform.isDesktop
          ? l10n.manageBiometricsErrorNoOSAuthTitle
          : l10n.manageBiometricsErrorNoBiometricDataTitle;
      errorDescription = UniversalPlatform.isDesktop
          ? l10n.manageBiometricsErrorNoOSAuthMessage
          : l10n.manageBiometricsErrorNoBiometricDataMessage;
    }
    if (errorText == null) {
      return Container();
    }
    return Padding(
        padding: const EdgeInsets.only(top: ThemePaddings.bigPadding),
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
    return PopScope(
        canPop: !isLoading,
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
