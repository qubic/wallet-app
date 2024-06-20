import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mobx/mobx.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:qubic_wallet/globals.dart';
import 'package:qubic_wallet/helpers/global_snack_bar.dart';
import 'package:qubic_wallet/pages/auth/erase_wallet_sheet.dart';
import 'package:qubic_wallet/pages/auth/sign_up.dart';
import 'package:qubic_wallet/resources/qubic_cmd_utils.dart';
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

class SignIn extends StatefulWidget {
  const SignIn({super.key});

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

  late final AnimationController _rotationController;

  late final Animation _animation;

  late AnimatedSnackBar errorBar;
  late AnimatedSnackBar notificationBar;
  bool obscuringText = true;

  //FJS

  double rotation = 3.19911;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final ApplicationStore applicationStore = getIt<ApplicationStore>();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 600),
    );

    //_animation = Tween(begin: 3.19911, end: 5.0).animate(CurvedAnimation(
    _animation = Tween(begin: 3.39911, end: 3.29911).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.fastOutSlowIn,
    ));

    _rotationController.repeat();
    qubicHubService.loadVersionInfo().then((value) {
      if (qubicHubStore.updateNeeded) {
        showAlertDialog(context, "Update required",
            "USE THIS VERSION AT YOUR OWN RISK\n\nYour current version is outdated and will possibly not work. Please update your wallet version to ${qubicHubStore.minVersion}.\n\nYou can still access your funds and back up your seeds, but other functionality may be broken.  ");
      }
    }, onError: (e) {
      _globalSnackbar.showError(e.toString().replaceAll("Exception: ", ""));
    });

    _disposeSnackbarAuto = autorun((_) {
      if (applicationStore.globalError != "") {
        var errorPos = applicationStore.globalError.indexOf("~");
        var error = (errorPos == -1)
            ? applicationStore.globalError
            : applicationStore.globalError.substring(0, errorPos);

        // AnimatedSnackBar.material(error,
        //         type: AnimatedSnackBarType.error,
        //         snackBarStrategy: StackSnackBarStrategy())
        //     .show(context);
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
  }

  @override
  void dispose() {
    _rotationController.dispose();

    _disposeSnackbarAuto();
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

  Widget biometricsButton() {
    if (isLoading) {
      return Container();
    }
    return TextButton(onPressed: () async {
      if (isLoading) {
        return;
      }
      setState(() {
        isLoading = true;
      });
      final bool didAuthenticate = await auth.authenticate(
          localizedReason: ' ',
          options: const AuthenticationOptions(biometricOnly: true));

      if (didAuthenticate) {
        await appStore.biometricSignIn();
        await authSuccess();
      }
      setState(() {
        isLoading = false;
      });
    }, child: Builder(builder: (context) {
      return Padding(
          padding: const EdgeInsets.fromLTRB(
              ThemePaddings.normalPadding, 0, ThemePaddings.normalPadding, 0),
          child: SizedBox(
              height: 40,
              width: 42,
              child: Icon(Icons.fingerprint,
                  size: 42, color: Theme.of(context).colorScheme.primary)));
    }));
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
                        height: 22,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color:
                                Theme.of(context).colorScheme.inversePrimary)));
              } else {
                return Padding(
                    padding: EdgeInsets.all(ThemePaddings.normalPadding),
                    child: Text("Unlock wallet",
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

  Widget getVersionInfo() {
    return Observer(builder: (BuildContext context) {
      if (qubicHubStore.versionInfo == null) {
        return Container();
      }
      return Text("v${qubicHubStore.versionInfo}",
          textAlign: TextAlign.center,
          style: TextStyles.labelTextSmall
              .copyWith(color: LightThemeColors.color3));
    });
  }

  Widget getLogo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(

            //    MediaQuery.of(context).size.height *                                              0.15,
            child: Image(image: AssetImage('assets/images/blue-logo.png'))),
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

  List<Widget> getLoginForm() {
    return [
      getSignInError(),
      const SizedBox(height: ThemePaddings.smallPadding),
      FormBuilderTextField(
        name: "password",
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(
              errorText: "Please fill in a password"),
        ]),
        decoration: ThemeInputDecorations.bigInputbox.copyWith(
          hintText: "Wallet password",
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: ThemePaddings.smallPadding),
            child: IconButton(
              icon:
                  Icon(obscuringText ? Icons.visibility : Icons.visibility_off),
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
      ),
      const SizedBox(height: ThemePaddings.normalPadding),
      Observer(builder: (context) {
        return Center(
            child: Column(children: [
          Flex(
              mainAxisAlignment: MainAxisAlignment.center,
              direction: Axis.horizontal,
              children: getCTA()),
          SizedBox(height: ThemePaddings.normalPadding),
          // SizedBox(
          //     width: double.infinity,
          //     height: 56,
          //     child: ThemedControls.transparentButtonBigWithChild(
          //         child: Padding(
          //             padding: EdgeInsets.all(ThemePaddings.smallPadding),
          //             child: Text("Create new wallet",
          //                 style: TextStyles.transparentButtonText)),
          //         onPressed: () {
          //           pushNewScreen(
          //             context,
          //             screen: SignUp(),
          //             withNavBar: false, // OPTIONAL VALUE. True by default.
          //             pageTransitionAnimation:
          //                 PageTransitionAnimation.cupertino,
          //           );
          //           //context.goNamed("createWallet");
          //         })),
          SizedBox(
              width: double.infinity,
              height: 56,
              child: _isKeyboardVisible
                  ? Container()
                  : ThemedControls.transparentButtonBigWithChild(
                      child: Padding(
                          padding: EdgeInsets.all(ThemePaddings.smallPadding),
                          child: Text("Erase wallet data",
                              style: TextStyles.transparentButtonText)),
                      onPressed: () {
                        showModalBottomSheet<void>(
                            context: context,
                            isScrollControlled: true,
                            useRootNavigator: true,
                            backgroundColor: LightThemeColors.backkground,
                            builder: (BuildContext context) {
                              return EraseWalletSheet(onAccept: () async {
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
                              });
                            });
                      }

                      //context.goNamed("createWallet");
                      ))
        ]));
      })
    ];
  }

  Widget buildSignUp(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          ThemePaddings.bigPadding,
          ThemePaddings.bigPadding,
          ThemePaddings.bigPadding,
          ThemePaddings.bigPadding),
      child: Container(
          width: double.infinity,
          child: Flex(
              direction: Axis.vertical,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: getLogo()),
                SizedBox(
                    width: double.infinity,
                    child:
                        ThemedControls.primaryButtonBigWithChild(onPressed: () {
                      pushNewScreen(
                        context,
                        screen: SignUp(),
                        withNavBar: false, // OPTIONAL VALUE. True by default.
                        pageTransitionAnimation:
                            PageTransitionAnimation.cupertino,
                      );
                    }, child: Builder(builder: (context) {
                      return Padding(
                          padding: EdgeInsets.all(ThemePaddings.normalPadding),
                          child: Text("Create a new wallet",
                              style: TextStyles.primaryButtonText));
                    })))
              ])),
    );
    // return Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    //   Center(child: getLogo()),
    //   Expanded(child: Container()),
    //   Text("aaa")
    // ]);
  }

  Widget buildLogin(BuildContext context) {
    return Stack(children: [
      Container(
        constraints: const BoxConstraints.expand(),
//           decoration: BoxDecoration(
//               gradient: LinearGradient(
//             begin: Alignment(-1.0, 0.0),
//             end: Alignment(1.0, 0.0),
//             transform:
//                 GradientRotation(_animation.value), //GradientRotation(3.19911),
//             stops: [
//               0.001,
//               1,
//             ],
//             colors: [
//               LightThemeColors.gradient1,
//               LightThemeColors.gradient2,
// //              Color(0xFFBF0FFF),
//               //            Color(0xFF0F27FF),
//             ],
//           ))
      ),
      Container(
        constraints: const BoxConstraints.expand(),
        // decoration: BoxDecoration(
        //     gradient: LinearGradient(
        //   begin: Alignment.topCenter,
        //   end: Alignment.bottomCenter,
        //   stops: const [
        //     0.4,
        //     0.68,
        //     0.8,
        //   ],
        //   colors: [
        //     const Color(0x00FFFFFF),
        //     LightThemeColors.strongBackground.withOpacity(0.5),
        //     LightThemeColors.strongBackground
        //   ],
        // ))
      ),
      SafeArea(
          child: Container(
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      0, ThemePaddings.bigPadding, 0, 0),
                  child: FormBuilder(
                      key: _formKey,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Center(child: getLogo()),
                            ),
                            Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    ThemePaddings.bigPadding,
                                    ThemePaddings.bigPadding,
                                    ThemePaddings.bigPadding,
                                    ThemePaddings.bigPadding),
                                child: Column(children: getLoginForm()))
                          ]))))),
    ]);
  }

  bool isLoading = false;
  bool _isKeyboardVisible = false;

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
                  return buildLogin(context);
                } else {
                  return buildSignUp(context);
                }
              },
            ),
            Positioned(
                bottom: ThemePaddings.normalPadding,
                right: ThemePaddings.bigPadding,
                child: _isKeyboardVisible ? Container() : getVersionInfo())
          ],
        ));
  }
}
