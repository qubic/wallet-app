import 'package:flutter/material.dart';
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
  final bool passOnly; // If true, only password authentication is required
  final bool
      autoLocalAuth; // If true, automatically authenticate with local auth

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
  final LocalAuthentication auth = LocalAuthentication();

  String? signInError;
  double formOpacity = 1;

  @override
  void initState() {
    super.initState;
    if (settingsStore.settings.biometricEnabled && !widget.passOnly) {
      setState(() {
        formOpacity = 0;
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
      Flexible(child: authenticateButton(), flex: 3, fit: FlexFit.tight)
    ];
    if (settingsStore.settings.biometricEnabled && !widget.passOnly) {
      children.add(const SizedBox(width: ThemePaddings.normalPadding));
      children.add(
        Flexible(fit: FlexFit.tight, child: biometricsButton()),
      );
    }
    return Flex(
      direction: Axis.horizontal,
      children: children,
    );
  }

  Future<void> handleBiometricsAuth() async {
    if (isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
      signInError = null;
    });

    final bool didAuthenticate = await auth.authenticate(
        localizedReason: ' ',
        options: AuthenticationOptions(
            biometricOnly: UniversalPlatform.isDesktop ? false : true));

    if (didAuthenticate) {
      widget.onSuccess();
    } else {
      setState(() {
        isLoading = false;
        signInError = "Authentication cancelled. Please try again";
        setState(() {
          formOpacity = 1;
        });
      });
    }
  }

  Widget biometricsButton() {
    return AnimatedOpacity(
        opacity: isLoading ? 0.1 : 1,
        duration: const Duration(milliseconds: 200),
        child: ThemedControls.transparentButtonBigWithChild(
            onPressed: () async {
              await handleBiometricsAuth();
            },
            child: Padding(
                padding: EdgeInsets.fromLTRB(
                    MediaQuery.of(context).size.width < 400
                        ? ThemePaddings.smallPadding
                        : ThemePaddings.normalPadding,
                    ThemePaddings.miniPadding - 1,
                    MediaQuery.of(context).size.width < 400
                        ? ThemePaddings.smallPadding
                        : ThemePaddings.normalPadding,
                    ThemePaddings.miniPadding - 1),
                child: SizedBox(
                    height: 42,
                    width: MediaQuery.of(context).size.width < 400 ? 32 : 42,
                    child: Icon(
                        UniversalPlatform.isDesktop
                            ? Icons.security
                            : Icons.fingerprint,
                        size: MediaQuery.of(context).size.width < 400 ? 32 : 42,
                        color: LightThemeColors.primary)))));
  }

  void authenticateHandler() async {
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
    return ThemedControls.primaryButtonBigWithChild(
        onPressed: authenticateHandler,
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
                        color: Theme.of(context).colorScheme.inversePrimary)));
          } else {
            return const Padding(
                padding: EdgeInsets.all(
                  ThemePaddings.normalPadding,
                ),
                child: SizedBox(height: 21, child: Text("Authenticate")));
          }
        }));
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
//                  return Container(child: const SizedBox(height: 33));
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
                          icon: Icon(obscuringTextPass
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              obscuringTextPass = !obscuringTextPass;
                            });
                          },
                        ),
                      ),
                    ),
                    onSubmitted: (value) => authenticateHandler(),
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
