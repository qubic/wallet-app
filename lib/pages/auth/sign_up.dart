import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qubic_wallet/components/copyable_text.dart';
import 'package:qubic_wallet/components/gradient_foreground.dart';
import 'package:qubic_wallet/components/toggleable_qr_code.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/copy_to_clipboard.dart';
import 'package:qubic_wallet/helpers/global_snack_bar.dart';
import 'package:qubic_wallet/helpers/show_alert_dialog.dart';
import 'package:qubic_wallet/models/qubic_list_vm.dart';
import 'package:qubic_wallet/resources/qubic_li.dart';

import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/stores/settings_store.dart';
import 'package:qubic_wallet/styles/edgeInsets.dart';
import 'package:qubic_wallet/styles/inputDecorations.dart';
import 'package:qubic_wallet/styles/textStyles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:share_plus/share_plus.dart';

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
  final GlobalSnackBar _globalSnackbar = getIt<GlobalSnackBar>();

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
    if (canCheckBiometrics == null) return Container();
    if (canCheckBiometrics! == false) return Container();
    var theme = SettingsThemeData(
      settingsSectionBackground: LightThemeColors.cardBackground,
      //Theme.of(context).cardTheme.color,
      settingsListBackground: LightThemeColors.backkground,
      dividerColor: Colors.transparent,
      titleTextColor: Theme.of(context).colorScheme.onBackground,
    );
    return Flex(direction: Axis.horizontal, children: [
      Flexible(
          fit: FlexFit.tight,
          flex: 4,
          child: Text(
            "Enable biometric access to your wallet",
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
              onChanged: (value) {
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
    return [
      getSignUpError(),
      FormBuilderTextField(
        name: "password",
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(
              errorText: "Please fill in a password"),
          FormBuilderValidators.minLength(8,
              errorText: "Password must be at least 8 characters long")
        ]),
        onSubmitted: (value) => handleSubmit(),
        onChanged: (value) => currentPassword = value ?? "",
        decoration: ThemeInputDecorations.bigInputbox.copyWith(
          hintText: "Enter password",
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: ThemePaddings.smallPadding),
            child: IconButton(
              icon: Icon(
                  obscuringTextPass ? Icons.visibility : Icons.visibility_off),
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
              errorText: "Please fill in your password again"),
          (value) {
            if (value == currentPassword) return null;
            return "Passwords do not match";
          }
        ]),
        onSubmitted: (value) => handleSubmit(),
        decoration: ThemeInputDecorations.bigInputbox.copyWith(
          hintText: "Repeat password",
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: ThemePaddings.smallPadding),
            child: IconButton(
              icon: Icon(obscuringTextPassRepeat
                  ? Icons.visibility
                  : Icons.visibility_off),
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
      const SizedBox(height: ThemePaddings.normalPadding),
      biometricsControls()
    ];
  }

  //Gets the container scroll view
  Widget getScrollView() {
    return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Row(children: [
          Container(
              child: Expanded(
                  child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ThemedControls.pageHeader(
                  headerText: "Create new wallet", subheaderText: ""),
              Text(
                  "Fill in a a password that will be used to unlock your new wallet",
                  style: TextStyles.textNormal),
              FormBuilder(
                  key: _formKey, child: Column(children: getSignUpForm()))
            ],
          )))
        ]));
  }

  //Get the footer buttons
  List<Widget> getButtons() {
    return [
      Expanded(
          child: ThemedControls.primaryButtonBigWithChild(
              onPressed: handleSubmit,
              child: Padding(
                  padding: const EdgeInsets.all(ThemePaddings.normalPadding),
                  child: !isLoading
                      ? Text("Proceed",
                          textAlign: TextAlign.center,
                          style: TextStyles.primaryButtonText)
                      : SizedBox(
                          height: 23,
                          width: 23,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context)
                                  .colorScheme
                                  .inversePrimary)))))
    ];
  }

  //Handles form submission
  Future<void> handleSubmit() async {
    if (!context.mounted) return;

    if (isLoading) {
      return;
    }
    setState(() {
      signUpError = null;
    });
    _formKey.currentState?.validate();
    if (_formKey.currentState!.isValid) {
      setState(() {
        isLoading = true;
        signUpError = null;
      });
      if (await appStore
          .signUp(_formKey.currentState!.instantValue["password"])) {
        try {
          await appStore.checkWalletIsInitialized();
          await getIt<QubicLi>().authenticate();
        } catch (e) {
          showAlertDialog(
              context, "Error contacting Qubic Network", e.toString());
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
              context, "Error storing biometric info", e.toString());
        }
        context.goNamed("mainScreen");
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
        ),
        body: SafeArea(
            minimum: ThemeEdgeInsets.pageInsets,
            child: Column(children: [
              Expanded(child: getScrollView()),
              Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: getButtons())
            ])));
  }
}
