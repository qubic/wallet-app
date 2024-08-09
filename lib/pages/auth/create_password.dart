import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/pages/auth/create_password_sheet.dart';
import 'package:qubic_wallet/resources/qubic_cmd.dart';

import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/styles/edge_insets.dart';
import 'package:qubic_wallet/styles/input_decorations.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

class CreatePassword extends StatefulWidget {
  const CreatePassword({super.key, required this.onPasswordCreated});

  final Function(String password) onPasswordCreated;

  @override
  // ignore: library_private_types_in_public_api
  _CreatePasswordState createState() => _CreatePasswordState();
}

class _CreatePasswordState extends State<CreatePassword> {
  bool isLoading = false; //Is the form loading

  final ApplicationStore appStore = getIt<ApplicationStore>();
  bool obscuringTextPass = true; //Hide password text
  bool obscuringTextPassRepeat = true; //Hide password repeat text
  final _formKey = GlobalKey<FormBuilderState>();
  final QubicCmd qubicCmd = getIt<QubicCmd>();
  String? generatedPublicId;

  String currentPassword = "";
  String? signUpError;

  int stepNumber = 1;
  int totalSteps = 1;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
            if (value == currentPassword) return null;
            return l10n.generalErrorSetPasswordNotMatching;
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

  Future<void> handleProceed() async {
    if (!_formKey.currentState!.validate()) {
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
              child: CreatePasswordSheet(onAccept: () async {
            setState(() {
              isLoading = true;
            });

            // Navigator.pop(context);
            widget.onPasswordCreated(currentPassword);
            setState(() {
              isLoading = false;
            });
          }, onReject: () async {
            setState(() {
              isLoading = false;
            });
            Navigator.pop(context);
          }));
        });
  }

  Widget getGeneratedPublicId() {
    final l10n = l10nOf(context);

    if (generatedPublicId == null) {
      return Container();
    }
    return Column(
      children: [
        ThemedControls.spacerVerticalNormal(),
        Text(l10n.generalLabeQubicAddress, style: TextStyles.secondaryText),
        ThemedControls.spacerVerticalSmall(),
        Text(generatedPublicId!, style: TextStyles.inputBoxSmallStyle),
      ],
    );
  }

  //Gets the loading indicator inside button
  Widget _getLoadingProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: SizedBox(
          width: 21,
          height: 21,
          child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Theme.of(context).colorScheme.inversePrimary)),
    );
  }

  List<Widget> getButtons() {
    final l10n = l10nOf(context);
    return [
      Expanded(
          child: ThemedControls.primaryButtonBigWithChild(
              onPressed: () async {
                await handleProceed();
              },
              child: isLoading
                  ? _getLoadingProgressIndicator()
                  : Padding(
                      padding:
                          const EdgeInsets.all(ThemePaddings.smallPadding + 3),
                      child: Text(l10n.generalButtonProceed,
                          textAlign: TextAlign.center,
                          style: TextStyles.primaryButtonText),
                    )))
    ];
  }

  //Gets the container scroll view
  Widget getScrollView() {
    final l10n = l10nOf(context);

    return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Row(children: [
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ThemedControls.pageHeader(
                  headerText: l10n.signUpStepOneHeader, subheaderText: ""),
              Text(l10n.signUpStepOneSubHeader,
                  style: TextStyles.secondaryText),
              ThemedControls.spacerVerticalHuge(),
              FormBuilder(
                  key: _formKey, child: Column(children: getSignUpForm())),
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
