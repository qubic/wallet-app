import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:qubic_wallet/pages/auth/sign_up.dart';
import 'package:qubic_wallet/resources/qubic_li.dart';
import 'package:qubic_wallet/resources/secure_storage.dart';
import 'package:qubic_wallet/services/qubic_hub_service.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/stores/qubic_hub_store.dart';
import 'package:qubic_wallet/stores/settings_store.dart';
import 'package:qubic_wallet/styles/buttonStyles.dart';
import 'package:qubic_wallet/styles/inputDecorations.dart';
import 'package:qubic_wallet/styles/textStyles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:qubic_wallet/timed_controller.dart';
import 'package:universal_platform/universal_platform.dart';

class SignIn extends StatefulWidget {
  String? disableLocalAuth;
  SignIn({super.key, this.disableLocalAuth});

  @override
  // ignore: library_private_types_in_public_api
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final _formKey = GlobalKey<FormBuilderState>();
  final LocalAuthentication auth = LocalAuthentication();

  final ApplicationStore appStore = getIt<ApplicationStore>();
  final SettingsStore settingsStore = getIt<SettingsStore>();
  final QubicHubStore qubicHubStore = getIt<QubicHubStore>();
  final QubicHubService qubicHubService = getIt<QubicHubService>();

  final TimedController timedController = getIt<TimedController>();
  final SecureStorage secureStorage = getIt<SecureStorage>();

  final GlobalSnackBar _globalSnackbar = getIt<GlobalSnackBar>();
  String? signInError;
  late final ReactionDisposer _disposeSnackbarAuto;
  late final ReactionDisposer _disposeLocalAuth;

  late AnimatedSnackBar errorBar;
  late AnimatedSnackBar notificationBar;
  bool obscuringText = true;

  bool isLoading = false;
  double formOpacity = 1;
  bool _isKeyboardVisible = false;
  double viewInsets = 0.0;

  double rotation = 3.19911;

  int timesPressed = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final ApplicationStore applicationStore = getIt<ApplicationStore>();

    //Get version info
    // qubicHubService.loadVersionInfo().then((value) {
    //   if (qubicHubStore.updateNeeded) {
    //     showAlertDialog(context, "Update required",
    //         "USE THIS VERSION AT YOUR OWN RISK\n\nYour current version is outdated and will possibly not work. Please update your wallet version to ${qubicHubStore.minVersion}.\n\nYou can still access your funds and back up your seeds, but other functionality may be broken.  ");
    //   }
    // }, onError: (e) {
    //   _globalSnackbar.showError(e.toString().replaceAll("Exception: ", ""));
    // });

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

    _disposeLocalAuth = autorun((_) {
      //Automatic local authentication on login

      if (((widget.disableLocalAuth == null)) &&
          (settingsStore.settings.biometricEnabled)) {
        setState(() {
          formOpacity = 0;
        });
        handleBiometricsAuth();
      }
    });
  }

  @override
  void dispose() {
    _disposeSnackbarAuto();
    _disposeLocalAuth();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  showAlertDialog(BuildContext context, String title, String message) {
    // set up the button
    Widget okButton = TextButton(
      child: const Text("OK"),
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
    if (isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    try {
      final bool didAuthenticate = await auth.authenticate(
          localizedReason: ' ',
          options: AuthenticationOptions(
              biometricOnly: UniversalPlatform.isDesktop ? false : true));

      if (didAuthenticate) {
        await appStore.biometricSignIn();
        await authSuccess();
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
              "Too many failed attempts to authenticate you. Please lock and unlock your phone via PIN / pattern and try again";
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
    return AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isLoading ? 0.1 : 1,
        child: TextButton(
            style: ButtonStyles.textButtonBig.copyWith(
              shadowColor: MaterialStateProperty.all<Color>(
                  LightThemeColors.buttonBackground),
              elevation: MaterialStateProperty.all<double>(0.0),
            ),
            onPressed: () async {
              await handleBiometricsAuth();
            },
            child: Builder(builder: (context) {
              return Padding(
                  padding: const EdgeInsets.fromLTRB(
                      ThemePaddings.normalPadding,
                      2,
                      ThemePaddings.normalPadding,
                      2),
                  child: SizedBox(
                      height: 42,
                      width: 42,
                      child: Icon(
                          UniversalPlatform.isDesktop
                              ? Icons.security
                              : Icons.fingerprint,
                          size: 34,
                          color: LightThemeColors.primary)));
            })));
  }

  Future<void> authSuccess() async {
    try {
      await getIt<QubicLi>().authenticate();
      setState(() {
        isLoading = false;
      });
      context.goNamed("mainScreen");
    } catch (e) {
      showAlertDialog(context, "Error contacting Qubic Network", e.toString());
      setState(() {
        isLoading = false;
      });
    }
  }

  void signInHandler() async {
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
        authSuccess();
      } else {
        setState(() {
          isLoading = false;
        });
        setState(() {
          signInError = "You have provided an invalid password";
        });
      }
    }
  }

  Widget signInButton() {
    return Expanded(
        child: ThemedControls.primaryButtonBigWithChild(
            onPressed: signInHandler,
            child: Builder(builder: (context) {
              if (isLoading) {
                return Padding(
                    padding: const EdgeInsets.all(ThemePaddings.normalPadding),
                    child: SizedBox(
                        height: 23,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color:
                                Theme.of(context).colorScheme.inversePrimary)));
              } else {
                return Padding(
                    padding: EdgeInsets.all(ThemePaddings.normalPadding),
                    child: Text("Unlock Wallet",
                        style: TextStyles.primaryButtonText));
              }
            })));
  }

  List<Widget> getCTA() {
    List<Widget> results = [signInButton()];
    if (settingsStore.settings.biometricEnabled) {
      results.add(const VerticalDivider());
      results.add(biometricsButton());
    }
    return results;
  }

  //Gets the version info
  Widget getVersionInfo() {
    if (timesPressed < 5) {
      return Container();
    }
    return Observer(builder: (BuildContext context) {
      if (qubicHubStore.versionInfo == null) {
        return Container();
      }
      return Text(
          "v${qubicHubStore.versionInfo} (build ${qubicHubStore.buildNumber})",
          textAlign: TextAlign.center,
          style: TextStyles.labelTextSmall
              .copyWith(color: LightThemeColors.color3));
    });
  }

  //Gets the logo in sign i form
  Widget getLogo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(

            //    MediaQuery.of(context).size.height *                                              0.15,
            child: GestureDetector(
                onTap: () {
                  setState(() {
                    timesPressed++;
                  });
                },
                child:
                    Image(image: AssetImage('assets/images/blue-logo.png')))),
        ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: 12.0,
              minWidth: 10.0,
              maxHeight: 40.0,
              maxWidth: 10.0,
            ),
            child: Container()),
        Text("Welcome to the",
            textAlign: TextAlign.center,
            style: TextStyles.pageTitle
                .copyWith(fontSize: ThemeFontSizes.loginTitle.toDouble())),
        Text("Qubic Wallet",
            textAlign: TextAlign.center,
            style: TextStyles.pageTitle.copyWith(
                fontSize: ThemeFontSizes.loginTitle.toDouble(),
                color: LightThemeColors.titleColor)),
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
                padding:
                    const EdgeInsets.only(bottom: ThemePaddings.smallPadding),
                child: ThemedControls.errorLabel(signInError!));
          }
        }));
  }

  // Gets the password field for signing in
  Widget getPasswordField() {
    return FormBuilderTextField(
      name: "password",
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(errorText: "Please fill in a password"),
      ]),
      decoration: ThemeInputDecorations.bigInputbox.copyWith(
        hintText: "Wallet password",
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
          Flex(
              mainAxisAlignment: MainAxisAlignment.center,
              direction: Axis.horizontal,
              children: getCTA()),
          SizedBox(height: ThemePaddings.normalPadding),
          _isKeyboardVisible
              ? Container()
              : SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ThemedControls.transparentButtonBigWithChild(
                      child: Padding(
                          padding:
                              const EdgeInsets.all(ThemePaddings.smallPadding),
                          child: Text("Erase Wallet Data",
                              style: TextStyles.destructiveButtonText)),
                      onPressed: () {
                        showModalBottomSheet<void>(
                            context: context,
                            isScrollControlled: true,
                            useSafeArea: true,
                            useRootNavigator: true,
                            backgroundColor: LightThemeColors.background,
                            builder: (BuildContext context) {
                              return SafeArea(
                                child: EraseWalletSheet(onAccept: () async {
                                  await secureStorage.deleteWallet();
                                  await settingsStore.loadSettings();
                                  appStore.checkWalletIsInitialized();
                                  appStore.signOut();
                                  timedController.stopFetchTimer();
                                  Navigator.pop(context);
                                  _globalSnackbar
                                      .show("Wallet data erased from device");
                                }, onReject: () async {
                                  Navigator.pop(context);
                                }),
                              );
                            });
                      }

                      //context.goNamed("createWallet");
                      ))
        ]));
      })
    ];
  }

  //Builds the signup screen
  Widget buildSignUp(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(
        ThemePaddings.bigPadding,
      ),
      child: Container(
          width: double.infinity,
          child: Flex(
              direction: Axis.vertical,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: getLogo()),
                SizedBox(
                    width: double.infinity,
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
                        child: Padding(
                            padding: const EdgeInsets.all(
                                ThemePaddings.normalPadding),
                            child: Text("Create a new wallet",
                                style: TextStyles.primaryButtonText)))),
              ])),
    );
  }

  // Builds the signin screen
  Widget buildSignIn(BuildContext context) {
    return Stack(children: [
      SafeArea(
          child: Padding(
              padding:
                  const EdgeInsets.fromLTRB(0, ThemePaddings.bigPadding, 0, 0),
              child: FormBuilder(
                  key: _formKey,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Center(child: getLogo()),
                        ),
                        Padding(
                            padding: const EdgeInsets.all(
                              ThemePaddings.bigPadding,
                            ),
                            child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 200),
                                opacity: formOpacity,
                                child: Column(children: getSignInForm())))
                      ])))),
    ]);
  }

  @override
  void didChangeMetrics() {
    final value = WidgetsBinding.instance.window.viewInsets.bottom;
    setState(() {
      _isKeyboardVisible = value > 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 15, 23, 31),
        body: Stack(
          children: [
            Observer(
              builder: (BuildContext context) {
                if (appStore.hasStoredWalletSettings) {
                  return buildSignIn(context);
                } else {
                  return buildSignUp(context);
                }
              },
            ),
            Positioned(
                bottom: 2,
                right: ThemePaddings.bigPadding,
                child: _isKeyboardVisible ? Container() : getVersionInfo())
          ],
        ));
  }
}
