import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/show_alert_dialog.dart';
import 'package:qubic_wallet/pages/auth/create_password_sheet.dart';

import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/stores/settings_store.dart';
import 'package:qubic_wallet/styles/edge_insets.dart';
import 'package:qubic_wallet/styles/input_decorations.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:qubic_wallet/l10n/l10n.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ReceiveState createState() => _ReceiveState();
}

class _ReceiveState extends State<SignUp> {
  bool isLoading = false; //Is the form loading

  final ApplicationStore appStore = getIt<ApplicationStore>();
  bool obscuringTextPass = true; //Hide password text
  bool obscuringTextPassRepeat = true; //Hide password repeat text
  final _formKey = GlobalKey<FormBuilderState>();

  String currentPassword = "";
  String? signUpError;

  //Variable for local authentication
  final LocalAuthentication auth = LocalAuthentication();
  bool? canCheckBiometrics; //If true, the device has biometrics
  List<BiometricType>? availableBiometrics; //Is empty, no biometric is enrolled
  final SettingsStore settingsStore = getIt<SettingsStore>();
  bool? canUseBiometrics = false;
  bool enabledBiometrics = false;

  int stepNumber = 1;
  int totalSteps = 1;

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
          enabledBiometrics = settingsStore.settings.biometricEnabled;
          if (canUseBiometrics!) totalSteps = 2; //Total signin steps
        });
      });
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

    final l10n = l10nOf(context);

    String enableText = l10n.signUpSwitchLabelBiometricUnlock;
    if (UniversalPlatform.isDesktop) {
      enableText = l10n.signUpSwitchLabelOSUnlock;
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
                return Colors.orange.withValues(alpha: 0);
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

  // Show generic error message (not bound to field)
  Widget getSignUpError() {
    return Container(
        alignment: Alignment.center,
        child: Builder(builder: (context) {
          if (signUpError == null) {
            return const SizedBox(height: ThemePaddings.normalPadding);
          } else {
            return Padding(
                padding:
                    const EdgeInsets.only(bottom: ThemePaddings.smallPadding),
                child: ThemedControls.errorLabel(signUpError!));
          }
        }));
  }

  //Gets the sign up form
  List<Widget> getSignUpForm() {
    final l10n = l10nOf(context);

    return [
      getSignUpError(),
      FormBuilderTextField(
        name: "password",
        autofocus: true,
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(
              errorText: l10n.generalErrorSetWalletPasswordEmpty),
          FormBuilderValidators.minLength(8,
              errorText: l10n.generalErrorPasswordMinLength)
        ]),
        onSubmitted: (value) => handleProceed(),
        onChanged: (value) => currentPassword = value ?? "",
        decoration: ThemeInputDecorations.bigInputbox.copyWith(
          hintText: l10n.signUpTextFieldHintPassword,
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: ThemePaddings.smallPadding),
            child: IconButton(
              icon: obscuringTextPass
                  ? Image.asset("assets/images/eye-open.png")
                  : Image.asset("assets/images/eye-closed.png"),
              onPressed: () {
                setState(() {
                  obscuringTextPass = !obscuringTextPass;
                });
              },
            ),
          ),
        ),
        enabled: !isLoading,
        obscureText: obscuringTextPass,
        autocorrect: false,
        autofillHints: null,
      ),
      ThemedControls.spacerVerticalSmall(),
      FormBuilderTextField(
        name: "passwordRepeat",
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(
              errorText: l10n.generalErrorSetWalletPasswordRepeatEmpty),
          (value) {
            if (value != currentPassword) {
              return l10n.generalErrorSetPasswordNotMatching;
            }
            return null;
          }
        ]),
        onSubmitted: (value) => handleProceed(),
        decoration: ThemeInputDecorations.bigInputbox.copyWith(
          hintText: l10n.signUpTextFieldHintRepeatPassword,
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: ThemePaddings.smallPadding),
            child: IconButton(
              icon: obscuringTextPassRepeat
                  ? Image.asset("assets/images/eye-open.png")
                  : Image.asset("assets/images/eye-closed.png"),
              onPressed: () {
                setState(() {
                  obscuringTextPassRepeat = !obscuringTextPassRepeat;
                });
              },
            ),
          ),
        ),
        enabled: !isLoading,
        obscureText: obscuringTextPassRepeat,
        autocorrect: false,
        autofillHints: null,
      ),
    ];
  }

  Widget getStep2() {
    final l10n = l10nOf(context);

    String title = l10n.signUpStepTwoHeader;
    String subheader = l10n.signUpStepTwoSubHeader;

    if (UniversalPlatform.isDesktop) {
      title = l10n.signUpStepTwoHeaderForDesktop;
      subheader = l10n.signUpStepTwoSubHeaderForDesktop;
    }

    return Container(
        child: Expanded(
            child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ThemedControls.pageHeader(headerText: title, subheaderText: ""),
        Text(subheader, style: TextStyles.secondaryText),
        ThemedControls.spacerVerticalNormal(),
        biometricsControls()
      ],
    )));
  }

  Widget getStep1() {
    final l10n = l10nOf(context);
    return Container(
        child: Expanded(
            child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ThemedControls.pageHeader(
            headerText: l10n.signUpStepOneHeader, subheaderText: ""),
        Text(l10n.signUpStepOneSubHeader, style: TextStyles.secondaryText),
        FormBuilder(key: _formKey, child: Column(children: getSignUpForm()))
      ],
    )));
  }

  //Gets the container scroll view
  Widget getScrollView() {
    return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Row(children: [stepNumber == 1 ? getStep1() : getStep2()]));
  }

  //Get the footer buttons
  List<Widget> getButtons() {
    final l10n = l10nOf(context);

    return [
      Expanded(
          child: SizedBox(
        height: 48,
        child: ThemedControls.primaryButtonBigWithChild(
            onPressed: handleProceed,
            child: !isLoading
                ? Text(l10n.generalButtonProceed,
                    textAlign: TextAlign.center,
                    style: TextStyles.primaryButtonText)
                : SizedBox(
                    height: 23,
                    width: 23,
                    child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).colorScheme.inversePrimary))),
      ))
    ];
  }

  //Handles form submission and navigation from create password to biometrics setup
  Future<void> step1ToStep2Submit() async {
    final formState = _formKey.currentState;
    formState?.save(); // Save the form state
    if (formState == null || !formState.validate()) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      useSafeArea: true,
      backgroundColor: LightThemeColors.background,
      builder: (BuildContext context) {
        return SafeArea(
          child: CreatePasswordSheet(
            onAccept: () async {
              if (totalSteps == 2) {
                setState(() {
                  stepNumber = 2;
                  isLoading = false;
                });
              } else {
                setState(() {
                  isLoading = true;
                  signUpError = null;
                });
                await submitFinalize();
              }
            },
            onReject: () async {
              setState(() {
                isLoading = false;
                signUpError = null;
              });
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }

  //Handles last step of sign up
  Future<void> submitFinalize() async {
    final l10n = l10nOf(context);
    if (!context.mounted) return;

    setState(() {
      isLoading = true;
      signUpError = null;
    });
    if (await appStore.signUp(currentPassword)) {
      try {
        await appStore.checkWalletIsInitialized();
      } catch (e) {
        showAlertDialog(
            context, l10n.generalErrorContactingQubicNetwork, e.toString());
        setState(() {
          isLoading = false;
        });
      }
      try {
        await settingsStore.loadSettings();
        await settingsStore.setBiometrics(enabledBiometrics);

        setState(() {
          isLoading = false;
        });
      } catch (e) {
        showAlertDialog(
            context, l10n.signUpErrorStoringBiometricInfo, e.toString());
      }
      context.goNamed("mainScreen");
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  //Handles clicking of proceed button
  Future<void> handleProceed() async {
    if (isLoading) return;

    // Explicitly validate the form
    final formState = _formKey.currentState;
    if (formState != null && !formState.validate()) {
      // If the form is not valid, stop the loading and prevent proceeding
      setState(() {
        isLoading = false;
      });
      return;
    }

    if (stepNumber == 1) {
      if (totalSteps == 2) {
        await step1ToStep2Submit();
      } else {
        await submitFinalize();
      }
    }
    if (stepNumber == 2) {
      await submitFinalize();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: !isLoading,
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
            ),
            body: Padding(
              padding: ThemeEdgeInsets.pageInsets,
              child: Column(children: [
                Expanded(child: getScrollView()),
                Padding(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewPadding.bottom),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: getButtons()))
              ]),
            )));
  }
}
