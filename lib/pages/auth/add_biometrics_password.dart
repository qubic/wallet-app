import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qubic_wallet/components/copyable_text.dart';
import 'package:qubic_wallet/components/gradient_foreground.dart';
import 'package:qubic_wallet/components/toggleable_qr_code.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/copy_to_clipboard.dart';
import 'package:qubic_wallet/helpers/global_snack_bar.dart';
import 'package:qubic_wallet/helpers/id_validators.dart';
import 'package:qubic_wallet/helpers/platform_helpers.dart';
import 'package:qubic_wallet/helpers/show_alert_dialog.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/models/qubic_list_vm.dart';
import 'package:qubic_wallet/pages/auth/create_password_sheet.dart';
import 'package:qubic_wallet/resources/qubic_cmd.dart';
import 'package:qubic_wallet/resources/qubic_li.dart';

import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/stores/settings_store.dart';
import 'package:qubic_wallet/styles/edgeInsets.dart';
import 'package:qubic_wallet/styles/inputDecorations.dart';
import 'package:qubic_wallet/styles/textStyles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_platform/universal_platform.dart';

class AddBiometricsPassword extends StatefulWidget {
  AddBiometricsPassword({super.key, required this.onAddedBiometrics});

  Function(bool hasAddedBiometrics) onAddedBiometrics;

  @override
  // ignore: library_private_types_in_public_api
  _AddBiometricsPasswordState createState() => _AddBiometricsPasswordState();
}

class _AddBiometricsPasswordState extends State<AddBiometricsPassword> {
  bool isLoading = false; //Is the form loading

  final ApplicationStore appStore = getIt<ApplicationStore>();
  bool obscuringTextPass = true; //Hide password text
  bool obscuringTextPassRepeat = true; //Hide password repeat text
  final _formKey = GlobalKey<FormBuilderState>();
  final GlobalSnackBar _globalSnackbar = getIt<GlobalSnackBar>();
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

  Widget biometricsControls() {
    if (canUseBiometrics == null) return Container();
    if (canUseBiometrics! == false) return Container();
    if (canCheckBiometrics == null) return Container();
    if (canCheckBiometrics! == false) return Container();
    var theme = SettingsThemeData(
      settingsSectionBackground: LightThemeColors.cardBackground,
      //Theme.of(context).cardTheme.color,
      settingsListBackground: LightThemeColors.background,
      dividerColor: Colors.transparent,
      titleTextColor: Theme.of(context).colorScheme.onBackground,
    );

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
                return null; // Use the default color.
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

//Gets the sign up form

  Future<void> handleProceed() async {
    widget.onAddedBiometrics(enabledBiometrics);
  }

  List<Widget> getButtons() {
    final l10n = l10nOf(context);
    return [
      Expanded(
          child: ThemedControls.primaryButtonBigWithChild(
              onPressed: () async {
                await handleProceed();
              },
              child: Padding(
                padding: const EdgeInsets.all(ThemePaddings.smallPadding + 3),
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
