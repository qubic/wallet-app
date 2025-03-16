import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/models/network_model.dart';
import 'package:qubic_wallet/stores/network_store.dart';
import 'package:qubic_wallet/styles/edge_insets.dart';
import 'package:qubic_wallet/styles/input_decorations.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

class AddNetworkScreen extends StatefulWidget {
  const AddNetworkScreen({super.key});

  @override
  State<AddNetworkScreen> createState() => _AddNetworkScreenState();
}

class _AddNetworkScreenState extends State<AddNetworkScreen> {
  final addNetworkFormKey = GlobalKey<FormBuilderState>();
  final TextEditingController networkNameController = TextEditingController();
  final TextEditingController rpcUrlController = TextEditingController();
  final TextEditingController liUrlController = TextEditingController();
  final networkStore = getIt<NetworkStore>();

  @override
  void dispose() {
    networkNameController.dispose();
    rpcUrlController.dispose();
    liUrlController.dispose();
    super.dispose();
  }

  onSubmitted() {
    if (addNetworkFormKey.currentState!.validate()) {
      final network = NetworkModel(networkNameController.text,
          rpcUrlController.text, liUrlController.text);
      networkStore.addNetwork(network);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Custom Network", style: TextStyles.textExtraLargeBold),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: FormBuilder(
          key: addNetworkFormKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: ThemeEdgeInsets.pageInsets,
                  children: [
                    Text(
                      "Network Name",
                      style: TextStyles.labelTextNormal,
                    ),
                    ThemedControls.spacerVerticalSmall(),
                    FormBuilderTextField(
                        name: "networkName",
                        controller: networkNameController,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                        ]),
                        decoration:
                            ThemeInputDecorations.normalInputbox.copyWith(
                          hintText: "Eg: Qubic Mainnet",
                        )),
                    ThemedControls.spacerVerticalNormal(),
                    Row(
                      children: [
                        Text(
                          "RPC URL",
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
                    FormBuilderTextField(
                        name: "rpcUrl",
                        controller: rpcUrlController,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.url(),
                        ]),
                        decoration:
                            ThemeInputDecorations.normalInputbox.copyWith(
                          hintText: "Eg: https://rpc.qubic.org",
                        )),
                    ThemedControls.spacerVerticalNormal(),
                    Row(
                      children: [
                        Text(
                          "Qubic Li URL",
                          style: TextStyles.labelTextNormal,
                        ),
                        const Spacer(),
                        ThemedControls.transparentButtonSmall(
                            onPressed: () async {
                              if (liUrlController.text.isNotEmpty == true) {
                                liUrlController.clear();
                              } else {
                                final clipboardData = await Clipboard.getData(
                                    Clipboard.kTextPlain);
                                if (clipboardData != null) {
                                  liUrlController.text = clipboardData.text!;
                                }
                              }
                              setState(() {});
                            },
                            text: liUrlController.text.isNotEmpty == true
                                ? l10n.generalButtonClear
                                : l10n.generalButtonPaste),
                      ],
                    ),
                    FormBuilderTextField(
                        name: "liUrl",
                        controller: liUrlController,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.url(),
                        ]),
                        decoration:
                            ThemeInputDecorations.normalInputbox.copyWith(
                          hintText: "Eg: https://api.qubic.li",
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
