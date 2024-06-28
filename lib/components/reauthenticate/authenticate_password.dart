import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:local_auth/local_auth.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/stores/settings_store.dart';
import 'package:qubic_wallet/styles/inputDecorations.dart';
import 'package:qubic_wallet/styles/textStyles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:universal_platform/universal_platform.dart';

class AuthenticatePassword extends StatefulWidget {
  final Function onSuccess;
  final bool passOnly; // If true, only password _authentication is required
  final bool
      autoLocalAuth; // If true, automatically _authenticate with local _auth

  const AuthenticatePassword(
      {super.key,
      required this.onSuccess,
      this.passOnly = false,
      this.autoLocalAuth = true});

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

      handleBiometricsAuth();
    }
  }

  @override
  void dispose() {
    super.dispose();
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

  Future<void> handleBiometricsAuth() async {
    if (isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    try {
      final bool didAuthenticate = await _auth.authenticate(
          localizedReason: ' ',
          options: AuthenticationOptions(
              biometricOnly: UniversalPlatform.isDesktop ? false : true));

      if (didAuthenticate) {
        widget.onSuccess();
      }
      setState(() {
        isLoading = false;
        formOpacity = 1;
      });
    } on PlatformException catch (err) {
      if ((err.message != null) &&
          (err.message!
              .contains("API is locked out due to too many attempts"))) {
        setState(() {
          isLoading = false;
          formOpacity = 1;
          signInError = err.message ??
              "Too many failed attempts to _authenticate you. Please lock and unlock your phone via PIN / pattern and try again";
        });
      } else if (err.message != null) {
        setState(() {
          isLoading = false;
          formOpacity = 1;
          signInError = err.message ??
              "An error has occurred while trying to authenticate you";
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        formOpacity = 1;
        signInError =
            "An error has occurred while trying to authenticate you. Please try again";
      });
    }
  }

  Widget biometricsButton() {
    String label = "Unlock with Biometrics";
    if (biometricType == BiometricType.face) {
      label = "Unlock with Face ID";
    } else if (biometricType == BiometricType.fingerprint) {
      label = "Unlock with Touch ID";
    } else if (biometricType == BiometricType.iris) {
      label = "Unlock with Iris";
    } else if (biometricType == BiometricType.strong) {
      if (UniversalPlatform.isAndroid) {
        label = "Unlock with Biometric";
      } else {
        label = "Unlock with OS";
      }
    } else if (biometricType == BiometricType.weak) {
      label = "Alternative Unlock";
    }
    return AnimatedOpacity(
        opacity: isLoading ? 0.1 : 1,
        duration: const Duration(milliseconds: 200),
        child: SizedBox(
          height: 48,
          child: ThemedControls.transparentButtonBigWithChild(
              onPressed: () async {
                await handleBiometricsAuth();
              },
              child: Padding(
                  padding: const EdgeInsets.all(ThemePaddings.smallPadding + 2),
                  child:
                      Text(label, style: TextStyles.transparentButtonPrimary))),
        ));
  }

  void _authenticateHandler() async {
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
          signInError = "You provided an invalid password";
        });
      }
    }
  }

  Widget authenticateButton() {
    return SizedBox(
      height: 48,
      child: ThemedControls.primaryButtonBigWithChild(
          onPressed: _authenticateHandler,
          child: Builder(builder: (context) {
            if (isLoading) {
              return Padding(
                  padding: const EdgeInsets.all(
                    ThemePaddings.normalPadding,
                  ),
                  child: SizedBox(
                      height: 21,
                      width: 21,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color:
                              Theme.of(context).colorScheme.inversePrimary)));
            } else {
              return Text("Authenticate", style: TextStyles.primaryButtonText);
            }
          })),
    );
  }

  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
        opacity: formOpacity,
        duration: const Duration(milliseconds: 200),
        child: FormBuilder(
            key: _formKey,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(child: Builder(builder: (context) {
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
                  })),
                  FormBuilderTextField(
                    name: "password",
                    autofocus: !settingsStore.settings.biometricEnabled ||
                        widget.passOnly,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                    decoration: ThemeInputDecorations.bigInputbox.copyWith(
                      hintText: "Wallet password",
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
                    autocorrect: false,
                    autofillHints: null,
                  ),
                  const SizedBox(height: ThemePaddings.normalPadding),
                  Center(child: getCTA()),
                ])));
  }
}
