import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mobx/mobx.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:qubic_wallet/helpers/global_snack_bar.dart';
import 'package:qubic_wallet/pages/auth/erase_wallet_sheet.dart';
import 'package:qubic_wallet/pages/auth/import_selector.dart';
import 'package:qubic_wallet/pages/auth/sign_up.dart';
import 'package:qubic_wallet/pages/main/download_cmd_utils.dart';
import 'package:qubic_wallet/resources/hive_storage.dart';
import 'package:qubic_wallet/resources/secure_storage.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/stores/settings_store.dart';
import 'package:qubic_wallet/styles/input_decorations.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:qubic_wallet/timed_controller.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:qubic_wallet/l10n/l10n.dart';

class SignIn extends StatefulWidget {
  final String?
      disableLocalAuth; //if not null then local auth is disabled. TODO: Change this to a boolean
  const SignIn({super.key, this.disableLocalAuth});

  @override
  // ignore: library_private_types_in_public_api
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  //DI objects
  final LocalAuthentication _auth = LocalAuthentication();
  final ApplicationStore _appStore = getIt<ApplicationStore>();
  final SettingsStore _settingsStore = getIt<SettingsStore>();
  final HiveStorage _hiveStorage = getIt<HiveStorage>();
  final TimedController _timedController = getIt<TimedController>();
  final SecureStorage _secureStorage = getIt<SecureStorage>();
  final GlobalSnackBar _globalSnackbar = getIt<GlobalSnackBar>();

  //Unlock wallet form
  final _formKey = GlobalKey<FormBuilderState>();
  String? signInError;

  //Disposers
  late final ReactionDisposer _disposeSnackbarAuto;
  late final ReactionDisposer _disposeLocalAuth;

  //Snackbar
  late AnimatedSnackBar errorBar;
  late AnimatedSnackBar notificationBar;

  //Local state
  bool isLoading = false;
  double formOpacity = 1;
  bool isKeyboardVisible = false;
  bool obscuringText = true; //Hide password or not
  int timesPressed = 0; //Number of times logo has been clicked
  BiometricType? biometricType; //The type of biometric available

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final ApplicationStore applicationStore = getIt<ApplicationStore>();

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
        if ((value.contains(BiometricType.strong)) && (biometricType == null)) {
          setState(() {
            biometricType = BiometricType.strong;
          });
        }
      });
    });

    //Setup snackbars
    _disposeSnackbarAuto = autorun((_) {
      if (applicationStore.globalError != "") {
        var errorPos = applicationStore.globalError.indexOf("~");
        var error = (errorPos == -1)
            ? applicationStore.globalError
            : applicationStore.globalError.substring(0, errorPos);

        if (error != "") {
          errorBar = AnimatedSnackBar(
              builder: ((context) {
                return Ink(
                    child: InkWell(
                        onTap: (() {
                          AnimatedSnackBar.removeAll();
                        }),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: LightThemeColors.cardBackground.withRed(100),
                          ),
                          padding:
                              const EdgeInsets.all(ThemePaddings.normalPadding),
                          child: Text(
                            error,
                            style: TextStyles.labelTextSmall,
                          ),
                        )));
              }),
              snackBarStrategy: RemoveSnackBarStrategy());
          errorBar.show(context);
          applicationStore.clearGlobalError();
        }
      }

      if (applicationStore.globalNotification != "") {
        var notificationPos = applicationStore.globalNotification.indexOf("~");
        var notification = (notificationPos == -1)
            ? applicationStore.globalNotification
            : applicationStore.globalNotification.substring(0, notificationPos);

        if (notification != "") {
          notificationBar = AnimatedSnackBar(
              builder: ((context) {
                return Ink(
                    child: InkWell(
                        onTap: (() {
                          AnimatedSnackBar.removeAll();
                        }),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: LightThemeColors.cardBackground),
                          padding:
                              const EdgeInsets.all(ThemePaddings.normalPadding),
                          child: Text(
                            notification,
                            style: TextStyles.labelTextSmall,
                          ),
                        )));
              }),
              snackBarStrategy: RemoveSnackBarStrategy());
          notificationBar.show(context);
        }
      }
    });
  }

  bool firstRun = true;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (firstRun) {
      //Automatic local authentication on launch of widget
      _disposeLocalAuth = autorun((_) {
        if (((widget.disableLocalAuth == null)) &&
            (_settingsStore.settings.biometricEnabled)) {
          setState(() {
            formOpacity = 0;
          });
          handleBiometricsAuth();
        }
      });
      firstRun = false;
    }
  }

  @override
  void dispose() {
    _disposeSnackbarAuto();
    _disposeLocalAuth();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  showAlertDialog(BuildContext context, String title, String message) {
    final l10n = l10nOf(context);
    // set up the button
    Widget okButton = TextButton(
      child: Text(l10n.generalButtonOK),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<void> handleBiometricsAuth() async {
    final l10n = l10nOf(context);

    if (isLoading || !mounted) {
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
        await _appStore.biometricSignIn();
        if (!mounted) return;
        context.goNamed("mainScreen");
      }
      setState(() {
        isLoading = false;
        formOpacity = 1;
      });
    } on PlatformException catch (err) {
      if ((err.message != null) &&
          (err.message!
              // TODO: can we check the error with the error code? why if the app is in another langauge?
              .contains("API is locked out due to too many attempts"))) {
        setState(() {
          isLoading = false;
          formOpacity = 1;
          signInError = err.message ?? l10n.authenticateErrorTooManyAttempts;
        });
      } else if (err.message != null) {
        setState(() {
          isLoading = false;
          formOpacity = 1;
          signInError = err.message ?? l10n.authenticateErrorGeneral;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        formOpacity = 1;
        signInError = l10n.authenticateErrorGeneral;
      });
    }
  }

  void signInHandler() async {
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
      if (await _appStore
          .signIn(_formKey.currentState!.instantValue["password"])) {
        setState(() {
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        setState(() {
          signInError = l10n.authenticateErrorInvalidPassword;
        });
      }
    }
  }

  Widget eraseWalletButton() {
    final l10n = l10nOf(context);
    return SizedBox(
        width: double.infinity,
        height: 48,
        child: ThemedControls.dangerButtonBigWithClild(
            child: Text(l10n.generalButtonEraseWalletData,
                style: TextStyles.destructiveButtonText),
            onPressed: () {
              showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  useRootNavigator: true,
                  backgroundColor: LightThemeColors.background,
                  builder: (BuildContext context) {
                    final l10n = l10nOf(context);

                    return SafeArea(
                      child: EraseWalletSheet(onAccept: () async {
                        await _secureStorage.deleteWallet();
                        await _settingsStore.loadSettings();
                        await _hiveStorage.clear();
                        _appStore.checkWalletIsInitialized();
                        _appStore.signOut();
                        _timedController.stopFetchTimers();
                        if (!context.mounted) return;
                        Navigator.pop(context);
                        _globalSnackbar
                            .show(l10n.generalSnackBarMessageWalletDataErased);
                      }, onReject: () async {
                        Navigator.pop(context);
                      }),
                    );
                  });
            }));
  }

  Widget biometricsButton() {
    final l10n = l10nOf(context);
    String label = l10n.generalButtonUnlockWithBiometric;
    if (biometricType == BiometricType.face) {
      label = l10n.generalButtonUnlockWithFaceID;
    } else if (biometricType == BiometricType.fingerprint) {
      label = l10n.generalButtonUnlockWithTouchID;
    } else if (biometricType == BiometricType.iris) {
      label = l10n.generalButtonUnlockWithIris;
    } else if (biometricType == BiometricType.strong) {
      if (UniversalPlatform.isAndroid) {
        label = l10n.generalButtonUnlockWithBiometric;
      } else {
        label = l10n.generalButtonUnlockWithOS;
      }
    } else if (biometricType == BiometricType.weak) {
      label = l10n.generalButtonAlternativeUnlock;
    }

    return SizedBox(
        width: double.infinity,
        height: 48,
        child: ThemedControls.transparentButtonBigWithChild(
            onPressed: handleBiometricsAuth,
            child: Text(label, style: TextStyles.transparentButtonPrimary)));
  }

  Widget signInButton(BuildContext context) {
    final l10n = l10nOf(context);

    return SizedBox(
        width: double.infinity,
        height: 48,
        child: ThemedControls.primaryButtonBigWithChild(
            onPressed: signInHandler,
            child: Builder(builder: (context) {
              if (isLoading) {
                return SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).colorScheme.inversePrimary));
              } else {
                return Text(l10n.welcomeButtonUnlockWallet,
                    style: TextStyles.primaryButtonText);
              }
            })));
  }

  //Gets the version info
  Widget getVersionInfo() {
    if (timesPressed < 5) {
      return Container();
    }
    return Observer(builder: (BuildContext context) {
      if (_settingsStore.versionInfo == null) {
        return Container();
      }
      return Text(
          "${_settingsStore.versionInfo} (${_settingsStore.buildNumber})",
          textAlign: TextAlign.center,
          style: TextStyles.labelTextSmall
              .copyWith(color: LightThemeColors.color3));
    });
  }

//TRANSLATE
  //Gets the main text under the logo
  Widget getMainTextLabels() {
    final l10n = l10nOf(context);

    return Observer(builder: (builder) {
      if (_appStore.hasStoredWalletSettings) {
        return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Text(l10n.welcomeTitle,
              textAlign: TextAlign.center,
              style: TextStyles.pageTitle
                  .copyWith(fontSize: ThemeFontSizes.loginTitle.toDouble())),
        ]);
      }
      return Column(children: [
        Text(l10n.signInTitleOne,
            textAlign: TextAlign.center,
            style: TextStyles.pageTitle
                .copyWith(fontSize: ThemeFontSizes.loginTitle.toDouble())),
        Text(l10n.siginInTitleTwo,
            textAlign: TextAlign.center,
            style: TextStyles.pageTitle.copyWith(
                fontSize: ThemeFontSizes.loginTitle.toDouble(),
                color: LightThemeColors.titleColor)),
      ]);
    });
  }

  //Gets the logo (tappable to show version info)
  Widget getLogo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
            child: GestureDetector(
                onDoubleTap: () {
                  setState(() {
                    timesPressed++;
                  });
                },
                onTap: () {
                  setState(() {
                    timesPressed++;
                  });
                },
                child: const Image(
                    image: AssetImage('assets/images/blue-logo.png')))),
        ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: 12.0,
              minWidth: 10.0,
              maxHeight: 40.0,
              maxWidth: 10.0,
            ),
            child: Container()),
        getMainTextLabels()
      ],
    );
  }

  //Shows a sign in error
  Widget getSignInError() {
    return Container(
        alignment: Alignment.center,
        child: Builder(builder: (context) {
          if (signInError == null) {
            return const SizedBox(height: 25);
          } else {
            return Padding(
                padding: const EdgeInsets.only(
                    top: ThemePaddings.normalPadding,
                    bottom: ThemePaddings.smallPadding),
                child: ThemedControls.errorLabel(signInError!));
          }
        }));
  }

  // Gets the password field for signing in
  Widget getPasswordField() {
    final l10n = l10nOf(context);
    return FormBuilderTextField(
      name: "password",
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(
            errorText: l10n.generalErrorEmptyWalletPassword),
      ]),
      decoration: ThemeInputDecorations.bigInputbox.copyWith(
        hintText: l10n.generalTextFieldHintPassword,
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: ThemePaddings.smallPadding),
          child: IconButton(
            icon: obscuringText
                ? Image.asset("assets/images/eye-open.png")
                : Image.asset("assets/images/eye-closed.png"),
            onPressed: () {
              setState(() {
                obscuringText = !obscuringText;
              });
            },
          ),
        ),
      ),
      onSubmitted: (value) => signInHandler(),
      enabled: !isLoading,
      obscureText: obscuringText,
      autocorrect: false,
      autofillHints: null,
    );
  }

  //Gets the sign in  form
  List<Widget> getSignInForm() {
    return [
      getSignInError(),
      ThemedControls.spacerVerticalNormal(),
      getPasswordField(),
      ThemedControls.spacerVerticalNormal(),
      Observer(builder: (context) {
        return Center(
            child: Column(children: [
          signInButton(context),
          if (_settingsStore.settings.biometricEnabled)
            ThemedControls.spacerVerticalNormal(),
          if (_settingsStore.settings.biometricEnabled) biometricsButton(),
          const SizedBox(height: ThemePaddings.normalPadding),
        ]));
      })
    ];
  }

  //Builds the signup screen
  Widget buildSignUp(BuildContext context) {
    final l10n = l10nOf(context);

    return Padding(
      padding: const EdgeInsets.all(
        ThemePaddings.bigPadding,
      ),
      child: SizedBox(
          width: double.infinity,
          child: Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewPadding.bottom),
              child: Flex(
                  direction: Axis.vertical,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: getLogo()),
                    SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ThemedControls.primaryButtonBigWithChild(
                            onPressed: () {
                              pushScreen(
                                context,
                                screen: const SignUp(),
                                withNavBar:
                                    false, // OPTIONAL VALUE. True by default.
                                pageTransitionAnimation:
                                    PageTransitionAnimation.cupertino,
                              );
                            },
                            child: Text(l10n.welcomeButtonCreateWallet,
                                style: TextStyles.primaryButtonText))),
                    ThemedControls.spacerVerticalNormal(),
                    SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ThemedControls.transparentButtonBigWithChild(
                            onPressed: () {
                              pushScreen(
                                context,
                                screen: const ImportSelector(),
                                withNavBar:
                                    false, // OPTIONAL VALUE. True by default.
                                pageTransitionAnimation:
                                    PageTransitionAnimation.cupertino,
                              );
                            },
                            child: Text(l10n.welcomeButtonImportExistingWallet,
                                style: TextStyles.transparentButtonPrimary))),
                  ]))),
    );
  }

  // Builds the signin screen
  Widget buildSignIn(BuildContext context) {
    return SafeArea(
        child: Stack(children: [
      SafeArea(
        child: Padding(
            padding:
                const EdgeInsets.fromLTRB(0, ThemePaddings.bigPadding, 0, 0),
            child: FormBuilder(
                key: _formKey,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(child: getLogo()),
                      Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: ThemePaddings.bigPadding,
                          ),
                          child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 200),
                              opacity: formOpacity,
                              child: Column(children: getSignInForm())))
                    ]))),
      ),
      Positioned(
          bottom: UniversalPlatform.isDesktop
              ? ThemePaddings.bigPadding
              : ThemePaddings.normalPadding,
          left: 0,
          right: 0,
          child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: ThemePaddings.bigPadding),
              child: eraseWalletButton()
                  .animate(
                      target: (isKeyboardVisible || formOpacity == 0) ? 1 : 0)
                  .moveY(
                      begin: 0,
                      end: 100,
                      duration: const Duration(milliseconds: 50)))),
    ]));
  }

  @override
  void didChangeMetrics() {
    final value = View.of(context).viewInsets.bottom;
    setState(() {
      isKeyboardVisible = value > 50.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      if (UniversalPlatform.isDesktop && !_settingsStore.cmdUtilsAvailable) {
        return const Scaffold(body: DownloadCmdUtils());
      }
      return Scaffold(
          backgroundColor: const Color.fromARGB(255, 15, 23, 31),
          body: Stack(
            children: [
              Observer(
                builder: (BuildContext context) {
                  if (_appStore.hasStoredWalletSettings) {
                    return buildSignIn(context);
                  } else {
                    return buildSignUp(context);
                  }
                },
              ),
              Positioned(
                  bottom: 2,
                  right: ThemePaddings.bigPadding,
                  child: isKeyboardVisible ? Container() : getVersionInfo())
            ],
          ));
    });
  }
}
