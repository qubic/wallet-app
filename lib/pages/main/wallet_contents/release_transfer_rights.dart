import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:qubic_wallet/components/transaction/advanced_tick_options.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/dtos/grouped_asset_dto.dart';
import 'package:qubic_wallet/extensions/as_thousands.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/app_logger.dart';
import 'package:qubic_wallet/helpers/global_snack_bar.dart';
import 'package:qubic_wallet/helpers/id_validators.dart';
import 'package:qubic_wallet/helpers/re_auth_dialog.dart';
import 'package:qubic_wallet/helpers/send_transaction.dart';
import 'package:qubic_wallet/helpers/target_tick.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/models/qubic_list_vm.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/transfers/transactions_for_id.dart';
import 'package:qubic_wallet/resources/apis/live/qubic_live_api.dart';
import 'package:qubic_wallet/smart_contracts/release_transfer_rights_info.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/stores/qubic_ecosystem_store.dart';
import 'package:qubic_wallet/styles/edge_insets.dart';
import 'package:qubic_wallet/styles/input_decorations.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:qubic_wallet/timed_controller.dart';

class ReleaseTransferRights extends StatefulWidget {
  final QubicListVm item;
  final GroupedAssetDto groupedAsset;

  const ReleaseTransferRights({
    super.key,
    required this.item,
    required this.groupedAsset,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ReleaseTransferRightsState createState() => _ReleaseTransferRightsState();
}

class _ReleaseTransferRightsState extends State<ReleaseTransferRights> {
  final _formKey = GlobalKey<FormBuilderState>();
  final ApplicationStore appStore = getIt<ApplicationStore>();
  final QubicEcosystemStore ecosystemStore = getIt<QubicEcosystemStore>();
  final _liveApi = getIt<QubicLiveApi>();
  final TimedController _timedController = getIt<TimedController>();
  final GlobalSnackBar _globalSnackBar = getIt<GlobalSnackBar>();

  final NumberFormat formatter = NumberFormat.decimalPatternDigits(
    locale: 'en_us',
    decimalDigits: 0,
  );

  List<bool> expanded = [false];
  TargetTickTypeEnum targetTickType = defaultTargetTickType;

  // Selected contract indices
  int? selectedSourceContractIndex;
  int? selectedDestinationContractIndex;
  String? sourceContractError;
  String? destinationContractError;

  // Available units for selected source
  int availableUnits = 0;

  // Fee (default to 0, will be loaded from API or use defaults)
  int currentFee = 0;

  // Controllers
  final numberOfSharesCtrl = TextEditingController();
  final tickController = TextEditingController();
  final feeController = TextEditingController();

  bool isLoading = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeFormData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Complete initialization after context is available
    if (!_isInitialized) {
      _isInitialized = true;
      _updateFee(); // This will also update the fee controller
    }
  }

  void _initializeFormData() {
    // Auto-select source contract if only one available
    final contractsWithBalance = widget.groupedAsset.contractContributions
        .where((c) => c.numberOfUnits > 0)
        .toList();

    if (contractsWithBalance.length == 1) {
      selectedSourceContractIndex =
          contractsWithBalance.first.managingContractIndex;
      availableUnits = contractsWithBalance.first.numberOfUnits;
      _updateDestinationDefault();
      // Don't call _updateFee() here - it needs context, will be called in didChangeDependencies
    }
  }

  void _updateDestinationDefault() {
    // If source is not Qx, default destination to Qx (contract index 1)
    // Find Qx contract dynamically
    final qxContract = ecosystemStore.getQxContract();

    if (selectedSourceContractIndex != null &&
        qxContract != null &&
        selectedSourceContractIndex != qxContract.contractIndex) {
      selectedDestinationContractIndex = qxContract.contractIndex;
    }
  }

  void _updateFee() {
    if (selectedSourceContractIndex == null) {
      currentFee = ReleaseTransferRightsInfo.defaultReleaseFee;
      _updateFeeController();
      return;
    }

    // Get procedure number for source contract dynamically
    final procedureNumber =
        ecosystemStore.getTransferShareManagementRightsProcedureId(
            selectedSourceContractIndex!);

    if (procedureNumber == null) {
      currentFee = ReleaseTransferRightsInfo.defaultReleaseFee;
      _updateFeeController();
      return;
    }

    // Try to get fee from ecosystem store (will be available when smart_contracts.json includes fee data)
    final fee = ecosystemStore.getFeeForProcedure(
        selectedSourceContractIndex!, procedureNumber);

    // Use default fee (0 QUBIC based on contract code analysis)
    currentFee = fee ?? ReleaseTransferRightsInfo.defaultReleaseFee;
    _updateFeeController();
  }

  void _updateFeeController() {
    final l10n = l10nOf(context);
    feeController.text =
        "${currentFee.asThousands()} ${l10n.generalLabelCurrencyQubic}";
  }

  @override
  void dispose() {
    numberOfSharesCtrl.dispose();
    tickController.dispose();
    feeController.dispose();
    super.dispose();
  }

  int getAssetAmount() {
    final text = numberOfSharesCtrl.text;
    if (text.isEmpty) return 0;

    final spaceIndex = text.indexOf(" ");
    final cleanText = spaceIndex > 0 ? text.substring(0, spaceIndex) : text;

    try {
      final amount =
          int.parse(cleanText.replaceAll(" ", "").replaceAll(",", ""));
      if (amount <= 0) {
        return 0;
      }
      return amount;
    } catch (e) {
      appLogger.e('Failed to parse asset amount: $e');
      return 0;
    }
  }

  List<DropdownMenuItem<int>> getSourceContractList() {
    final l10n = l10nOf(context);
    return widget.groupedAsset.contractContributions
        .where((c) => c.numberOfUnits > 0)
        .map((contribution) {
      final contractName = ecosystemStore
              .getContractNameByIndex(contribution.managingContractIndex) ??
          "Contract ${contribution.managingContractIndex}";

      return DropdownMenuItem<int>(
        value: contribution.managingContractIndex,
        child: Text(
          l10n.releaseTransferRightsSourceContractOption(
            contractName,
            formatter.format(contribution.numberOfUnits),
            widget.groupedAsset.issuedAsset.name,
          ),
          style: TextStyles.inputBoxSmallStyle,
        ),
      );
    }).toList();
  }

  List<DropdownMenuItem<int>> getDestinationContractList() {
    // Get all contracts that allow transfer shares as destination
    final supportedContracts = ecosystemStore.smartContracts
        .where((contract) =>
            contract.allowTransferShares &&
            contract.contractIndex != selectedSourceContractIndex)
        .toList();

    // Sort alphabetically by name (case-insensitive)
    supportedContracts
        .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return supportedContracts.map((contract) {
      return DropdownMenuItem<int>(
        value: contract.contractIndex,
        child: Text(
          contract.name,
          style: TextStyles.inputBoxSmallStyle,
        ),
      );
    }).toList();
  }

  CurrencyInputFormatter getInputFormatter(BuildContext context) {
    return CurrencyInputFormatter(
      trailingSymbol: widget.groupedAsset.issuedAsset.name,
      useSymbolPadding: true,
      thousandSeparator: ThousandSeparator.Comma,
      mantissaLength: 0,
    );
  }

  Widget getSourceContractField() {
    final l10n = l10nOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.releaseTransferRightsLabelSourceContract,
          style: TextStyles.labelTextNormal,
        ),
        ThemedControls.spacerVerticalMini(),
        ThemedControls.dropdown<int>(
          value: selectedSourceContractIndex,
          onChanged: (int? value) {
            setState(() {
              selectedSourceContractIndex = value;
              sourceContractError = null; // Clear error when user selects

              // Update available units
              if (value != null) {
                final contribution = widget.groupedAsset.contractContributions
                    .firstWhere((c) => c.managingContractIndex == value);
                availableUnits = contribution.numberOfUnits;

                // Clear destination if same as source
                if (selectedDestinationContractIndex == value) {
                  selectedDestinationContractIndex = null;
                }

                // Update default destination
                _updateDestinationDefault();

                // Update fee
                _updateFee();
              } else {
                availableUnits = 0;
              }
            });
          },
          items: getSourceContractList(),
        ),
        if (sourceContractError != null) ...[
          ThemedControls.spacerVerticalMini(),
          Text(
            sourceContractError!,
            style: TextStyles.labelTextNormalError,
          ),
        ],
      ],
    );
  }

  Widget getAvailableAmountInfo() {
    final l10n = l10nOf(context);
    if (selectedSourceContractIndex == null) {
      return Container();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ThemedControls.spacerVerticalMini(),
        Text(
          l10n.releaseTransferRightsLabelAvailableAmount(
              formatter.format(availableUnits)),
          style: TextStyles.secondaryText,
        ),
      ],
    );
  }

  Widget getAmountField() {
    final l10n = l10nOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                l10n.releaseTransferRightsLabelAmount,
                style: TextStyles.labelTextNormal,
              ),
            ),
            ThemedControls.transparentButtonSmall(
              text: l10n.accountSendButtonMax,
              onPressed: () {
                if (availableUnits > 0) {
                  numberOfSharesCtrl.value = getInputFormatter(context)
                      .formatEditUpdate(const TextEditingValue(text: ''),
                          TextEditingValue(text: availableUnits.toString()));
                }
              },
            ),
          ],
        ),
        ThemedControls.spacerVerticalMini(),
        FormBuilderTextField(
          name: "amount",
          controller: numberOfSharesCtrl,
          enabled: !isLoading && selectedSourceContractIndex != null,
          textAlign: TextAlign.end,
          keyboardType: const TextInputType.numberWithOptions(decimal: false),
          decoration: ThemeInputDecorations.normalInputbox,
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(
                errorText: l10n.generalErrorRequiredField),
            CustomFormFieldValidators.isLessThanParsedAsset(
              context: context,
              lessThan: availableUnits,
            ),
          ]),
          inputFormatters: [getInputFormatter(context)],
          maxLines: 1,
          autocorrect: false,
          autofillHints: null,
        ),
      ],
    );
  }

  Widget getDestinationContractField() {
    final l10n = l10nOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.releaseTransferRightsLabelDestinationContract,
          style: TextStyles.labelTextNormal,
        ),
        ThemedControls.spacerVerticalMini(),
        ThemedControls.dropdown<int>(
          value: selectedDestinationContractIndex,
          onChanged: (int? value) {
            setState(() {
              selectedDestinationContractIndex = value;
              destinationContractError = null; // Clear error when user selects

              // Validate if same as source
              if (value != null && value == selectedSourceContractIndex) {
                destinationContractError =
                    l10n.releaseTransferRightsErrorSameContract;
              }
            });
          },
          items: getDestinationContractList(),
        ),
        if (destinationContractError != null) ...[
          ThemedControls.spacerVerticalMini(),
          Text(
            destinationContractError!,
            style: TextStyles.labelTextNormalError,
          ),
        ],
      ],
    );
  }

  Widget getFeeInfo() {
    final l10n = l10nOf(context);
    final balance = widget.item.amount ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.generalLabelFee,
          style: TextStyles.labelTextNormal,
        ),
        ThemedControls.spacerVerticalMini(),
        FormBuilderTextField(
          name: "fee",
          readOnly: true,
          textAlign: TextAlign.center,
          controller: feeController,
          validator: FormBuilderValidators.compose([
            CustomFormFieldValidators.isLessThanParsed(
                lessThan: balance, context: context),
          ]),
          decoration: ThemeInputDecorations.normalInputbox,
        ),
        ThemedControls.spacerVerticalMini(),
        Text(
          l10n.assetsLabelCurrentBalance(formatter.format(widget.item.amount)),
          style: TextStyles.secondaryText,
        ),
      ],
    );
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.releaseTransferRightsTitle,
                    style: TextStyles.pageTitle,
                  ),
                  ThemedControls.spacerVerticalMini(),
                  Text(
                    "${widget.groupedAsset.issuedAsset.name} - ${widget.item.name}",
                    style: TextStyles.pageSubtitle,
                  )
                ],
              ),
              ThemedControls.spacerVerticalHuge(),
              FormBuilder(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      getSourceContractField(),
                      ThemedControls.spacerVerticalNormal(),
                      getDestinationContractField(),
                      ThemedControls.spacerVerticalNormal(),
                      getAmountField(),
                      ThemedControls.spacerVerticalNormal(),
                      getFeeInfo(),
                      ThemedControls.spacerVerticalBig(),
                      ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Material(
                              elevation: 0,
                              borderOnForeground: false,
                              shadowColor: Colors.transparent,
                              child: ExpansionPanelList(
                                  elevation: 0,
                                  expansionCallback:
                                      (int index, bool isExpanded) {
                                    setState(() {
                                      expanded[index] = !expanded[index];
                                    });
                                  },
                                  children: [
                                    ExpansionPanel(
                                      canTapOnHeader: true,
                                      backgroundColor:
                                          LightThemeColors.cardBackground,
                                      headerBuilder: (BuildContext context,
                                          bool isExpanded) {
                                        return ListTile(
                                          title: Text(l10n
                                              .accountSendSectionAdvanceOptionsTitle),
                                        );
                                      },
                                      body: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                            ThemePaddings.normalPadding,
                                            0,
                                            ThemePaddings.normalPadding,
                                            ThemePaddings.normalPadding,
                                          ),
                                          child: AdvancedTickOptions(
                                            targetTickType: targetTickType,
                                            onTargetTickTypeChanged:
                                                (TargetTickTypeEnum? value) {
                                              setState(() {
                                                targetTickType = value!;
                                              });
                                            },
                                            tickController: tickController,
                                            currentTick: appStore.currentTick,
                                            isLoading: isLoading,
                                          )),
                                      isExpanded: expanded[0],
                                    )
                                  ]))),
                    ],
                  )),
              const SizedBox(height: ThemePaddings.normalPadding),
            ],
          ))
        ]));
  }

  List<Widget> getButtons() {
    final l10n = l10nOf(context);

    return [
      !isLoading
          ? Expanded(
              child: ThemedControls.transparentButtonBigWithChild(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(ThemePaddings.smallPadding),
                    child: Text(l10n.generalButtonCancel,
                        style: TextStyles.transparentButtonText),
                  )),
            )
          : Container(),
      ThemedControls.spacerHorizontalNormal(),
      Expanded(
          child: ThemedControls.primaryButtonBigWithChild(
              onPressed: releaseTransferRightsHandler,
              child: Padding(
                  padding: const EdgeInsets.all(ThemePaddings.smallPadding + 3),
                  child: !isLoading
                      ? SizedBox(
                          width: double.infinity,
                          child: Text(l10n.releaseTransferRightsButtonSubmit,
                              textAlign: TextAlign.center,
                              style: TextStyles.primaryButtonText))
                      : Padding(
                          padding: const EdgeInsets.fromLTRB(57, 0, 57, 0),
                          child: SizedBox(
                              height: 23,
                              width: 23,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inversePrimary))))))
    ];
  }

  void releaseTransferRightsHandler() async {
    final l10n = l10nOf(context);

    // Validate dropdowns first and set error messages
    bool hasError = false;

    if (selectedSourceContractIndex == null) {
      setState(() {
        sourceContractError = l10n.releaseTransferRightsErrorNoSourceContract;
      });
      hasError = true;
    } else {
      setState(() {
        sourceContractError = null;
      });
    }

    if (selectedDestinationContractIndex == null) {
      setState(() {
        destinationContractError =
            l10n.releaseTransferRightsErrorNoDestinationContract;
      });
      hasError = true;
    } else if (selectedSourceContractIndex ==
        selectedDestinationContractIndex) {
      setState(() {
        destinationContractError = l10n.releaseTransferRightsErrorSameContract;
      });
      hasError = true;
    } else {
      setState(() {
        destinationContractError = null;
      });
    }

    // Validate form fields
    _formKey.currentState?.validate();
    if (!_formKey.currentState!.isValid) {
      hasError = true;
    }

    if (hasError) {
      return;
    }

    if (!mounted) return;
    bool authenticated = await reAuthDialog(context);
    if (!authenticated) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      int? targetTick;

      if (targetTickType == TargetTickTypeEnum.manual) {
        targetTick = int.tryParse(tickController.text);
      } else {
        // fetch latest tick
        int latestTick = (await _liveApi.getCurrentTick()).tick;
        targetTick = latestTick + targetTickType.value;
      }

      // Get contract address and procedure number dynamically from ecosystem store
      final sourceContract =
          ecosystemStore.getContractByIndex(selectedSourceContractIndex!);
      final procedureNumber =
          ecosystemStore.getTransferShareManagementRightsProcedureId(
              selectedSourceContractIndex!);

      if (sourceContract == null || procedureNumber == null) {
        _globalSnackBar.show(l10n.releaseTransferRightsErrorInvalidContract);
        return;
      }

      final contractAddress = sourceContract.address;

      if (!mounted) return;
      var result = await sendReleaseTransferRightsTransactionDialog(
        context,
        sourceId: widget.item.publicId,
        issuerIdentity: widget.groupedAsset.issuedAsset.issuerIdentity,
        assetName: widget.groupedAsset.issuedAsset.name,
        numberOfShares: getAssetAmount(),
        destinationContractIndex: selectedDestinationContractIndex!,
        contractAddress: contractAddress,
        procedureNumber: procedureNumber,
        fee: currentFee,
        destinationTick: targetTick!,
      );

      if (result == null) {
        return;
      }
      await _timedController.interruptFetchTimer();

      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return TransactionsForId(
          publicQubicId: widget.item.publicId,
          item: widget.item,
        );
      }));
      _globalSnackBar.show(l10n.generalSnackBarMessageTransactionSubmitted(
          targetTick.asThousands()));
    } catch (e) {
      _globalSnackBar.showError(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
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
