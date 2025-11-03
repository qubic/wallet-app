import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:mobx/mobx.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/global_snack_bar.dart';
import 'package:qubic_wallet/helpers/id_validators.dart';
import 'package:qubic_wallet/helpers/platform_helpers.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/models/qubic_list_vm.dart';
import 'package:qubic_wallet/stores/address_book_store.dart';
import 'package:qubic_wallet/styles/edge_insets.dart';
import 'package:qubic_wallet/styles/input_decorations.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

class AddToAddressBookScreen extends StatefulWidget {
  const AddToAddressBookScreen({super.key});

  @override
  State<AddToAddressBookScreen> createState() => _AddToAddressBookScreenState();
}

class _AddToAddressBookScreenState extends State<AddToAddressBookScreen> {
  TextEditingController accountNameController = TextEditingController();
  TextEditingController publicIdController = TextEditingController();
  bool isPublicIdEmpty = true;
  bool isLoading = false;
  final formKey = GlobalKey<FormState>();
  final _globalSnackBar = getIt<GlobalSnackBar>();
  final AddressBookStore addressBookStore = getIt<AddressBookStore>();

  @override
  void initState() {
    super.initState();
    publicIdController.addListener(() {
      if (publicIdController.text.isEmpty != isPublicIdEmpty) {
        if (publicIdController.text.isEmpty) {
          setState(() {
            isPublicIdEmpty = true;
          });
        } else {
          setState(() {
            isPublicIdEmpty = false;
          });
        }
      }
    });
  }

  void submit() {
    if (formKey.currentState!.validate()) {
      addressBookStore.addAddressBook(QubicListVm(publicIdController.text,
          accountNameController.text, null, null, null, false));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: Padding(
        padding: ThemeEdgeInsets.pageInsets.copyWith(
            bottom: MediaQuery.of(context).padding.bottom +
                ThemePaddings.normalPadding),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Row(children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ThemedControls.pageHeader(
                            headerText: l10n.addressBookAddTitle),
                        ThemedControls.spacerVerticalSmall(),
                        Form(
                          key: formKey,
                          child: Column(
                            children: [
                              Text(l10n.addressBookAddDescription),
                              ThemedControls.spacerVerticalHuge(),
                              Row(children: [
                                Text(l10n.addressBookAddLabelName,
                                    style: TextStyles.labelTextNormal),
                              ]),
                              ThemedControls.spacerVerticalSmall(),
                              TextFormField(
                                controller: accountNameController,
                                validator: FormBuilderValidators.compose([
                                  FormBuilderValidators.required(
                                      errorText:
                                          l10n.generalErrorRequiredField),
                                  CustomFormFieldValidators.isNameAvailable(
                                      namesList: addressBookStore.addressBook
                                          .map((e) => e.name)
                                          .toList(),
                                      context: context)
                                ]),
                                readOnly: isLoading,
                                style: TextStyles.inputBoxSmallStyle,
                                decoration: ThemeInputDecorations.normalInputbox
                                    .copyWith(
                                        hintText: l10n
                                            .addressBookAddLabelDescription),
                                autocorrect: false,
                                autofillHints: null,
                              ),
                              ThemedControls.spacerVerticalHuge(),
                              Row(children: [
                                Text(l10n.generalLabeQubicAddressAndPublicID,
                                    style: TextStyles.labelTextNormal),
                                ThemedControls.spacerHorizontalSmall(),
                                Tooltip(
                                    triggerMode: TooltipTriggerMode.tap,
                                    showDuration: const Duration(seconds: 5),
                                    message: l10n
                                        .addAccountWatchOnlyQubicAddressTooltip,
                                    child: ThemedControls.invertedColors(
                                        child: Image.asset(
                                            "assets/images/question-active-16.png"))),
                                const Spacer(),
                                ThemedControls.transparentButtonSmall(
                                    onPressed: () async {
                                      if (!isPublicIdEmpty) {
                                        publicIdController.clear();
                                        return;
                                      }
                                      final clipboardData =
                                          await Clipboard.getData(
                                              Clipboard.kTextPlain);
                                      if (clipboardData != null) {
                                        publicIdController.text =
                                            clipboardData.text!;
                                      }
                                    },
                                    text: isPublicIdEmpty
                                        ? l10n.generalButtonPaste
                                        : l10n.generalButtonClear),
                              ]),
                              ThemedControls.spacerVerticalSmall(),
                              TextFormField(
                                controller: publicIdController,
                                maxLength: 60,
                                maxLines: 2,
                                validator: FormBuilderValidators.compose([
                                  FormBuilderValidators.required(
                                      errorText:
                                          l10n.generalErrorRequiredField),
                                  CustomFormFieldValidators.isPublicID(
                                      context: context),
                                  CustomFormFieldValidators.isPublicIdAvailable(
                                      currentQubicIDs:
                                          addressBookStore.addressBook,
                                      context: context)
                                ]),
                                readOnly: isLoading,
                                style: TextStyles.inputBoxSmallStyle,
                                decoration: ThemeInputDecorations.normalInputbox
                                    .copyWith(
                                        hintText: l10n
                                            .addAccountWatchOnlyHintQubicAddress),
                                autocorrect: false,
                                autofillHints: null,
                              ),
                              ThemedControls.spacerVerticalNormal(),
                              if (isMobile)
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: ThemedControls.primaryButtonNormal(
                                      onPressed: () {
                                        showQRScanner(context, _globalSnackBar);
                                      },
                                      text: l10n.generalButtonUseQRCode,
                                      icon: Image.asset(
                                          "assets/images/Group 2294.png")),
                                ),
                              const SizedBox(
                                  height: ThemePaddings.normalPadding),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
            Row(
              children: [
                Expanded(
                    child: !isLoading
                        ? ThemedControls.transparentButtonBigWithChild(
                            child: Padding(
                                padding: const EdgeInsets.all(
                                    ThemePaddings.smallPadding),
                                child: Text(l10n.generalButtonCancel,
                                    style: TextStyles.transparentButtonText)),
                            onPressed: () {
                              Navigator.pop(context);
                            })
                        : Container()),
                ThemedControls.spacerHorizontalNormal(),
                Expanded(
                    child: ThemedControls.primaryButtonBigWithChild(
                        onPressed: submit,
                        child: Padding(
                            padding: const EdgeInsets.all(
                                ThemePaddings.smallPadding + 3),
                            child: Text(l10n.generalButtonSave,
                                textAlign: TextAlign.center,
                                style: TextStyles.primaryButtonText))))
              ],
            ),
          ],
        ),
      ),
    );
  }

  void showQRScanner(BuildContext context, GlobalSnackBar globalSnackBar) {
    showModalBottomSheet<void>(
        context: context,
        useSafeArea: true,
        builder: (BuildContext context) {
          final l10n = l10nOf(context);

          return Stack(children: [
            MobileScanner(
              // fit: BoxFit.contain,
              controller: MobileScannerController(
                detectionSpeed: DetectionSpeed.normal,
                facing: CameraFacing.back,
                torchEnabled: false,
              ),

              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                bool foundSuccess = false;
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null) {
                    var value = publicIdController.text;
                    value = barcode.rawValue!
                        .replaceAll("https://wallet.qubic.org/payment/", "");
                    var validator =
                        CustomFormFieldValidators.isPublicID(context: context);
                    if (validator(value) == null) {
                      if (foundSuccess == true) {
                        break;
                      }
                      publicIdController.text = value;
                      foundSuccess = true;
                    }
                  }
                }
                if (foundSuccess) {
                  Navigator.pop(context);
                  globalSnackBar
                      .show(l10n.generalSnackBarMessageQRScannedWithSuccess);
                }
              },
            ),
            Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                    color: Colors.white60,
                    width: double.infinity,
                    child: Padding(
                        padding:
                            const EdgeInsets.all(ThemePaddings.normalPadding),
                        child: Text(l10n.sendItemLabelQRScannerInstructions,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center))))
          ]);
        });
  }
}
