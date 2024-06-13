import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qubic_wallet/components/copyable_text.dart';
import 'package:qubic_wallet/components/toggleable_qr_code.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/copy_to_clipboard.dart';
import 'package:qubic_wallet/helpers/global_snack_bar.dart';
import 'package:qubic_wallet/helpers/show_alert_dialog.dart';
import 'package:qubic_wallet/models/qubic_list_vm.dart';
import 'package:qubic_wallet/resources/qubic_li.dart';

import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/styles/edgeInsets.dart';
import 'package:qubic_wallet/styles/inputDecorations.dart';
import 'package:qubic_wallet/styles/textStyles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:share_plus/share_plus.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ReceiveState createState() => _ReceiveState();
}

class _ReceiveState extends State<SignUp> {
  final ApplicationStore appStore = getIt<ApplicationStore>();
  bool obscuringTextPass = true;
  bool obscuringTextPassRepeat = true;
  final _formKey = GlobalKey<FormBuilderState>();
  final GlobalSnackBar _globalSnackbar = getIt<GlobalSnackBar>();

  String currentPassword = "";

  String? signUpError;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

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
    ];
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
          setState(() {
            isLoading = false;
          });
          context.goNamed("mainScreen");
        } catch (e) {
          showAlertDialog(
              context, "Error contacting Qubic Network", e.toString());
          setState(() {
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
      // setState(() {
      //   signUpError = "You have provided an invalid password";
      // });
    }
  }

  bool isLoading = false;
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
    // minimum: ThemeEdgeInsets.pageInsets,
    // child: Column(children: [
    //   Expanded(child: getScrollView()),
    // ])));
  }
}
