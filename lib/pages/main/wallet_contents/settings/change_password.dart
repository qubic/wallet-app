import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/re_auth_dialog.dart';
import 'package:qubic_wallet/helpers/show_alert_dialog.dart';
import 'package:qubic_wallet/helpers/global_snack_bar.dart';
import 'package:qubic_wallet/resources/secure_storage.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/stores/settings_store.dart';
import 'package:qubic_wallet/styles/edge_insets.dart';
import 'package:qubic_wallet/styles/input_decorations.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:qubic_wallet/timed_controller.dart';
import 'package:qubic_wallet/l10n/l10n.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _formKey = GlobalKey<FormBuilderState>();

  final ApplicationStore appStore = getIt<ApplicationStore>();
  final SettingsStore settingsStore = getIt<SettingsStore>();
  final SecureStorage secureStorage = getIt<SecureStorage>();
  final GlobalSnackBar snackBar = getIt<GlobalSnackBar>();
  final TimedController timedController = getIt<TimedController>();

  bool showingPassword = false;
  bool showingRepeatPassword = false;

  String currentPassword = "";
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

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
                headerText: l10n.changePasswordHeader,
              ),
              Text(l10n.changePasswordLabelInstructions,
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: ThemePaddings.hugePadding),
              ThemedControls.spacerVerticalMini(),
              FormBuilder(
                  key: _formKey,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FormBuilderTextField(
                          name: "password",
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(
                                errorText:
                                    l10n.generalErrorSetWalletPasswordEmpty),
                            FormBuilderValidators.minLength(8,
                                errorText: l10n.generalErrorPasswordMinLength)
                          ]),
                          onChanged: (value) => currentPassword = value ?? "",
                          onSubmitted: (String? text) {
                            saveIdHandler();
                          },
                          enabled: !isLoading,
                          decoration:
                              ThemeInputDecorations.bigInputbox.copyWith(
                            hintText: l10n.changePasswordFieldHintNewPassword,
                            suffixIcon: Padding(
                                padding: const EdgeInsets.only(
                                    right: ThemePaddings.smallPadding),
                                child: IconButton(
                                  icon: showingPassword
                                      ? Image.asset(
                                          "assets/images/eye-closed.png")
                                      : Image.asset(
                                          "assets/images/eye-open.png"),
                                  onPressed: () {
                                    setState(() =>
                                        showingPassword = !showingPassword);
                                  },
                                )),
                          ),
                          obscureText: !showingPassword,
                          enableSuggestions: false,
                          autocorrect: false,
                          autofillHints: null,
                        ),
                        ThemedControls.spacerVerticalSmall(),
                        FormBuilderTextField(
                          name: "passwordRepeat",
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(
                                errorText: l10n
                                    .generalErrorSetWalletPasswordRepeatEmpty),
                            (value) {
                              if (value == currentPassword) return null;
                              return l10n.changePasswordErrorPasswordDontMatch;
                            }
                          ]),
                          onSubmitted: (String? text) {
                            saveIdHandler();
                          },
                          enabled: !isLoading,
                          decoration:
                              ThemeInputDecorations.bigInputbox.copyWith(
                            hintText:
                                l10n.changePasswordFieldHintRepeatPassword,
                            suffixIcon: Padding(
                                padding: const EdgeInsets.only(
                                    right: ThemePaddings.smallPadding),
                                child: IconButton(
                                  icon: showingRepeatPassword
                                      ? Image.asset(
                                          "assets/images/eye-closed.png")
                                      : Image.asset(
                                          "assets/images/eye-open.png"),
                                  onPressed: () {
                                    setState(() => showingRepeatPassword =
                                        !showingRepeatPassword);
                                  },
                                )),
                          ),
                          obscureText: !showingRepeatPassword,
                          enableSuggestions: false,
                          autocorrect: false,
                          autofillHints: null,
                        ),
                      ]))
            ],
          ))
        ]));
  }

  List<Widget> getButtons() {
    final l10n = l10nOf(context);
    return [
      Expanded(
          child: !isLoading
              ? ThemedControls.transparentButtonBigWithChild(
                  child: Padding(
                      padding: const EdgeInsets.all(ThemePaddings.smallPadding),
                      child: Text(l10n.generalButtonCancel,
                          style: TextStyles.transparentButtonText)),
                  onPressed: () {
                    Navigator.pop(context);
                  })
              : Container()),
      ThemedControls.spacerHorizontalNormal(),
      Expanded(
          child: ThemedControls.primaryButtonBigWithChild(
              onPressed: saveIdHandler,
              child: Padding(
                  padding: const EdgeInsets.all(ThemePaddings.smallPadding + 3),
                  child: !isLoading
                      ? Text(
                          MediaQuery.of(context).size.width < 400
                              ? l10n.generalButtonSave
                              : l10n.changePasswordButtonSave,
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

  void saveIdHandler() async {
    final l10n = l10nOf(context);

    if (isLoading) {
      return;
    }
    _formKey.currentState?.validate();

    if (!_formKey.currentState!.isValid) {
      return;
    }

    var result = await reAuthDialogPassOnly(context);
    if (!result) {
      return;
    }
    if (_formKey.currentState!.isValid) {
      setState(() {
        isLoading = true;
      });

      if (await secureStorage
          .savePassword(_formKey.currentState!.instantValue["password"])) {
        timedController.interruptFetchTimer();
        timedController.fetchData();
        setState(() {
          isLoading = false;
        });

        snackBar.show(l10n.changePasswordSnackbarPasswordChanged);
        //appStore.reportGlobalNotification("Password changed successfully");
      } else {
        if (!mounted) return;
        showAlertDialog(context, l10n.changePasswordDialogSaveErrorTitle,
            l10n.changePasswordDialogSaveErrorMessage);
        setState(() {
          isLoading = false;
        });
      }
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  TextEditingController privateSeed = TextEditingController();

  bool showAccountInfoTooltip = false;
  bool showSeedInfoTooltip = false;
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: !isLoading,
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
            ),
            body: SafeArea(
                minimum: ThemeEdgeInsets.pageInsets
                    .copyWith(bottom: ThemePaddings.normalPadding),
                child: Column(children: [
                  Expanded(child: getScrollView()),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: getButtons())
                ]))));
  }
}
