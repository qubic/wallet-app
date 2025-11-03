import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:local_auth/local_auth.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/stores/settings_store.dart';
import 'package:qubic_wallet/styles/input_decorations.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/services/biometric_service.dart';

class AuthenticatePassword extends StatefulWidget {
  final Function onSuccess;
  final bool passOnly; // If true, only password _authentication is required
  final bool
      autoLocalAuth; // If true, automatically _authenticate with local _auth
  const AuthenticatePassword({
    super.key,
    required this.onSuccess,
    this.passOnly = false,
    this.autoLocalAuth = true,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AuthenticatePasswordState createState() => _AuthenticatePasswordState();
}

class _AuthenticatePasswordState extends State<AuthenticatePassword> {
  bool obscuringTextPass = true;
  final _formKey = GlobalKey<FormBuilderState>();
  final ApplicationStore appStore = getIt<ApplicationStore>();
  final SettingsStore settingsStore = getIt<SettingsStore>();
  final LocalAuthentication _auth = LocalAuthentication();
  final BiometricService _biometricService = getIt<BiometricService>();

  String? signInError; //Error of signing in
  double formOpacity = 1; //Hide the form when biometric is shown
  BiometricType? biometricType; //The type of biometric available

  @override
  void initState() {
    super.initState;
    if (settingsStore.settings.biometricEnabled && !widget.passOnly) {
      setState(() {
        formOpacity = 0;
      });

      _auth.canCheckBiometrics.then((value) {
        _auth.getAvailableBiometrics().then((value) {
          if ((value.contains(BiometricType.face)) && (biometricType == null)) {
            setState(() {
              biometricType = BiometricType.face;
            });
          }
          if ((value.contains(BiometricType.fingerprint)) &&
              (biometricType == null)) {
            setState(() {
              biometricType = BiometricType.fingerprint;
            });
          }
          if ((value.contains(BiometricType.iris)) && (biometricType == null)) {
            setState(() {
              biometricType = BiometricType.iris;
            });
          }
          if ((value.contains(BiometricType.strong)) &&
              (biometricType == null)) {
            setState(() {
              biometricType = BiometricType.strong;
            });
          }
        });
      });
      WidgetsBinding.instance
          .addPostFrameCallback((_) => handleBiometricsAuth());
    }
  }

  bool firstRun = true;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (firstRun) {
      if (settingsStore.settings.biometricEnabled && !widget.passOnly) {
        handleBiometricsAuth();
      }
      firstRun = false;
    }
  }

  Widget getCTA() {
    List<Widget> children = [
      SizedBox(width: double.infinity, child: authenticateButton())
    ];
    if (settingsStore.settings.biometricEnabled && !widget.passOnly) {
      children.add(ThemedControls.spacerVerticalNormal());
      children.add(SizedBox(width: double.infinity, child: biometricsButton()));
    }
    return Column(
      children: children,
    );
  }

  void _setAuthError(String? error) {
    setState(() {
      isLoading = false;
      formOpacity = 1;
      signInError = error;
    });
  }

  Future<void> handleBiometricsAuth() async {
    if (mounted) {
      if (isLoading) {
        return;
      }
      setState(() {
        isLoading = true;
      });

      final error = await _biometricService.handleBiometricsAuth(context);

      if (error == null) {
        widget.onSuccess();
      } else {
        _setAuthError(error);
      }

      setState(() {
        isLoading = false;
        formOpacity = 1;
      });
    }
  }

  Widget biometricsButton() {
    final l10n = l10nOf(context);

    String label = l10n.authenticateButtonWithBiometrics;

    if (biometricType == BiometricType.face) {
      label = l10n.authenticateButtonWithWithFaceID;
    } else if (biometricType == BiometricType.fingerprint) {
      label = l10n.authenticateButtonWithTouchID;
    } else if (biometricType == BiometricType.iris) {
      label = l10n.authenticateButtonWithIris;
    } else if (biometricType == BiometricType.strong) {
      if (UniversalPlatform.isAndroid) {
        label = l10n.authenticateButtonWithBiometrics;
      } else {
        label = l10n.authenticateButtonWithOS;
      }
    } else if (biometricType == BiometricType.weak) {
      label = l10n.authenticateButtonAlternative;
    }
    return AnimatedOpacity(
        opacity: isLoading ? 0.1 : 1,
        duration: const Duration(milliseconds: 200),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          child: ThemedControls.transparentButtonBigWithChild(
              onPressed: () async {
                await handleBiometricsAuth();
              },
              child: Text(label, style: TextStyles.transparentButtonPrimary)),
        ));
  }

  void _authenticateHandler() async {
    final l10n = l10nOf(context);
    if (isLoading) {
      return;
    }
    setState(() {
      signInError = null;
    });
    _formKey.currentState?.validate();
    if (_formKey.currentState!.isValid) {
      setState(() {
        isLoading = true;
        signInError = null;
      });
      if (await appStore
          .signIn(_formKey.currentState!.instantValue["password"])) {
        setState(() {
          isLoading = false;
        });

        widget.onSuccess();
      } else {
        setState(() {
          isLoading = false;
          signInError = l10n.authenticateErrorInvalidPassword;
        });
      }
    }
  }

  Widget authenticateButton() {
    final l10n = l10nOf(context);

    return SizedBox(
      height: 48,
      child: ThemedControls.primaryButtonBigWithChild(
          onPressed: _authenticateHandler,
          child: Builder(builder: (context) {
            if (isLoading) {
              return SizedBox(
                  height: 21,
                  width: 21,
                  child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).colorScheme.inversePrimary));
            } else {
              return Text(l10n.authenticateButtonAuthenticate,
                  style: TextStyles.primaryButtonText);
            }
          })),
    );
  }

  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);

    return AnimatedOpacity(
        opacity: formOpacity,
        duration: const Duration(milliseconds: 200),
        child: FormBuilder(
            key: _formKey,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Builder(builder: (context) {
                    if (signInError == null) {
                      return Container();
                    } else {
                      return Center(
                        child: Padding(
                            padding: const EdgeInsets.only(
                                bottom: ThemePaddings.normalPadding),
                            child: Text(signInError!,
                                style: Theme.of(context)
                                    .primaryTextTheme
                                    .bodyMedium
                                    ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .error))),
                      );
                    }
                  }),
                  FormBuilderTextField(
                    name: "password",
                    autofocus: !settingsStore.settings.biometricEnabled ||
                        widget.passOnly,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(
                          errorText: l10n.generalErrorRequiredField),
                    ]),
                    decoration: ThemeInputDecorations.bigInputbox.copyWith(
                      hintText: l10n.generalTextFieldHintPassword,
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(
                            right: ThemePaddings.smallPadding),
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
                    onSubmitted: (value) => _authenticateHandler(),
                    style: TextStyles.inputBoxNormalStyle,
                    enabled: !isLoading,
                    obscureText: obscuringTextPass,
                    enableSuggestions: false,
                    autocorrect: false,
                    autofillHints: null,
                  ),
                  ThemedControls.spacerVerticalNormal(),
                  Center(child: getCTA()),
                ])));
  }
}
