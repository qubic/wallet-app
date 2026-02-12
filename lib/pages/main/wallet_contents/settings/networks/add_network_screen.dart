import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/id_validators.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/models/network_model.dart';
import 'package:qubic_wallet/stores/network_store.dart';
import 'package:qubic_wallet/styles/edge_insets.dart';
import 'package:qubic_wallet/styles/input_decorations.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

class AddNetworkScreen extends StatefulWidget {
  final NetworkModel? network;

  const AddNetworkScreen({super.key, this.network});

  @override
  State<AddNetworkScreen> createState() => _AddNetworkScreenState();
}

class _AddNetworkScreenState extends State<AddNetworkScreen> {
  final formKey = GlobalKey<FormBuilderState>();
  final TextEditingController networkNameController = TextEditingController();
  final TextEditingController rpcUrlController = TextEditingController();
  final TextEditingController explorerController = TextEditingController();
  final networkStore = getIt<NetworkStore>();
  static const httpsScheme = "https://";
  final prefixHttpsWidget = const Padding(
    padding: EdgeInsets.only(left: 12, right: 2),
    child: Text(
      httpsScheme,
      style: TextStyle(
          color: LightThemeColors.inputFieldHint,
          fontSize: ThemeFontSizes.label),
    ),
  );

  bool get isEditing => widget.network != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      networkNameController.text = widget.network!.name;
      rpcUrlController.text = removeHttpsScheme(widget.network!.rpcUrl);
      explorerController.text = removeHttpsScheme(widget.network!.explorerUrl);
    }
  }

  @override
  void dispose() {
    networkNameController.dispose();
    rpcUrlController.dispose();
    explorerController.dispose();
    super.dispose();
  }

  onSubmitted() {
    if (formKey.currentState!.validate()) {
      final network = NetworkModel(
        name: networkNameController.text,
        rpcUrl: '$httpsScheme${rpcUrlController.text}',
        explorerUrl: '$httpsScheme${explorerController.text}',
      );
      if (isEditing) {
        networkStore.updateNetwork(widget.network!, network);
      } else {
        networkStore.addNetwork(network);
      }
      Navigator.pop(context);
    }
  }

  String removeHttpsScheme(String url) {
    if (url.startsWith(httpsScheme)) {
      return url.replaceFirst(httpsScheme, "");
    }
    return url;
  }

  List<String> getNetworkNamesForValidation() {
    if (isEditing) {
      return networkStore.networks
          .where((n) => n.name != widget.network!.name)
          .map((e) => e.name)
          .toList();
    }
    return networkStore.networks.map((e) => e.name).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
            isEditing ? l10n.editNetworkTitle : l10n.addNetworkTitle,
            style: TextStyles.textExtraLargeBold),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: FormBuilder(
          key: formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: ThemeEdgeInsets.pageInsets,
                  children: [
                    Text(
                      l10n.addNetworkLabelNetworkName,
                      style: TextStyles.labelTextNormal,
                    ),
                    ThemedControls.spacerVerticalSmall(),
                    TextFormField(
                        controller: networkNameController,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          CustomFormFieldValidators.isNameAvailable(
                              namesList: getNetworkNamesForValidation(),
                              context: context)
                        ]),
                        decoration:
                            ThemeInputDecorations.normalInputbox.copyWith(
                          hintText: l10n.addNetworkTextFieldHintNetworkName,
                        )),
                    ThemedControls.spacerVerticalNormal(),
                    Row(
                      children: [
                        Text(
                          l10n.addNetworkLabelRPCURL,
                          style: TextStyles.labelTextNormal,
                        ),
                        const Spacer(),
                        ThemedControls.transparentButtonSmall(
                            onPressed: () async {
                              if (rpcUrlController.text.isNotEmpty == true) {
                                rpcUrlController.clear();
                              } else {
                                final clipboardData = await Clipboard.getData(
                                    Clipboard.kTextPlain);
                                if (clipboardData != null) {
                                  rpcUrlController.text = clipboardData.text!;
                                }
                              }
                              setState(() {});
                            },
                            text: rpcUrlController.text.isNotEmpty == true
                                ? l10n.generalButtonClear
                                : l10n.generalButtonPaste),
                      ],
                    ),
                    TextFormField(
                      controller: rpcUrlController,
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.url(),
                      ]),
                      decoration: ThemeInputDecorations.normalInputbox.copyWith(
                        hintText:
                            removeHttpsScheme(Config.qubicMainnetRpcDomain),
                        prefixIcon: prefixHttpsWidget,
                        prefixIconConstraints:
                            const BoxConstraints(minWidth: 0, minHeight: 0),
                      ),
                    ),
                    ThemedControls.spacerVerticalNormal(),
                    Row(
                      children: [
                        Text(
                          l10n.addNetworkLabelQubicExplorerURL,
                          style: TextStyles.labelTextNormal,
                        ),
                        const Spacer(),
                        ThemedControls.transparentButtonSmall(
                            onPressed: () async {
                              if (explorerController.text.isNotEmpty == true) {
                                explorerController.clear();
                              } else {
                                final clipboardData = await Clipboard.getData(
                                    Clipboard.kTextPlain);
                                if (clipboardData != null) {
                                  explorerController.text = clipboardData.text!;
                                }
                              }
                              setState(() {});
                            },
                            text: explorerController.text.isNotEmpty == true
                                ? l10n.generalButtonClear
                                : l10n.generalButtonPaste),
                      ],
                    ),
                    TextFormField(
                        controller: explorerController,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.url(),
                        ]),
                        decoration:
                            ThemeInputDecorations.normalInputbox.copyWith(
                          hintText: removeHttpsScheme(Config.URL_WebExplorer),
                          prefixIcon: prefixHttpsWidget,
                          prefixIconConstraints:
                              const BoxConstraints(minWidth: 0, minHeight: 0),
                        )),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                      child: ThemedControls.transparentButtonBigWithChild(
                          child: Padding(
                              padding: const EdgeInsets.all(
                                  ThemePaddings.smallPadding),
                              child: Text(l10n.generalButtonCancel,
                                  style: TextStyles.transparentButtonText)),
                          onPressed: () {
                            Navigator.pop(context);
                          })),
                  ThemedControls.spacerHorizontalNormal(),
                  Expanded(
                      child: ThemedControls.primaryButtonBigWithChild(
                          onPressed: onSubmitted,
                          child: Padding(
                              padding: const EdgeInsets.all(
                                  ThemePaddings.smallPadding),
                              child: Text(l10n.generalButtonSave,
                                  textAlign: TextAlign.center,
                                  style: TextStyles.primaryButtonText))))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
