import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:qubic_wallet/components/id_list_item_select.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/transaction_UI_helpers.dart';
import 'package:qubic_wallet/models/qubic_list_vm.dart';
import 'package:qubic_wallet/models/transaction_filter.dart';
import 'package:qubic_wallet/models/transaction_vm.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/styles/edge_insets.dart';
import 'package:qubic_wallet/styles/input_decorations.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:qubic_wallet/l10n/l10n.dart';

class FilterTransactions extends StatefulWidget {
  final TransactionFilter? initialFilter;
  const FilterTransactions({super.key, this.initialFilter});

  @override
  // ignore: library_private_types_in_public_api
  _FilterTransactionsState createState() => _FilterTransactionsState();
}

class _FilterTransactionsState extends State<FilterTransactions> {
  final _formKey = GlobalKey<FormBuilderState>();
  final ApplicationStore appStore = getIt<ApplicationStore>();

  String? selectedQubicId;
  ComputedTransactionStatus? selectedStatus;
  TransactionDirection? selectedDirection;

  bool isFilterForId() => widget.initialFilter?.qubicId != null;

  @override
  void initState() {
    super.initState();

    if (isFilterForId()) {
      selectedQubicId = widget.initialFilter?.qubicId;
      selectedStatus = widget.initialFilter?.status;
      selectedDirection = widget.initialFilter?.direction;
      return;
    }

    if (appStore.transactionFilter!.qubicId != null) {
      selectedQubicId = appStore.transactionFilter!.qubicId!;
    }

    if (appStore.transactionFilter!.status != null) {
      selectedStatus = appStore.transactionFilter!.status!;
    }

    if (appStore.transactionFilter!.direction != null) {
      selectedDirection = appStore.transactionFilter!.direction!;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<Widget> getStatusLabel(ComputedTransactionStatus? e) {
    final l10n = l10nOf(context);
    List<Widget> out = [];
    if (e == null) {
      out.add(
        Text(l10n.filterTransfersLabelAnyStatus, style: TextStyles.textNormal),
      );
    } else {
      out.add(Icon(getTransactionStatusIcon(e),
          color: getTransactionStatusColor(e)));
      out.add(const Text(" "));
      out.add(Text(getTransactionStatusText(e, context),
          style: TextStyles.textNormal));
    }
    return out;
  }

  List<Widget> getDirectionLabel(TransactionDirection? e) {
    final l10n = l10nOf(context);
    List<Widget> out = [];
    if (e == null) {
      out.add(Text(
        l10n.generalLabelAnyDirection,
        style: TextStyles.secondaryTextNormal,
      ));
    } else {
      out.add(Icon(e == TransactionDirection.incoming
          ? Icons.input_outlined
          : Icons.output_outlined));
      out.add(const Text(" "));
      out.add(Text(
          e == TransactionDirection.incoming
              ? l10n.transactionLabelDirectionIncoming
              : l10n.transactionLabelDirectionOutgoing,
          style: TextStyles.textNormal));
    }
    return out;
  }

  Widget getDirectionDropdown() {
    final l10n = l10nOf(context);
    List<TransactionDirection?> directionOptions = [
      null,
      TransactionDirection.incoming,
      TransactionDirection.outgoing
    ];

    List<DropdownMenuItem> items = directionOptions
        .map((e) => DropdownMenuItem<TransactionDirection?>(
            value: e,
            child: Column(children: [
              Row(children: getDirectionLabel(e)),
            ])))
        .toList();

    return FormBuilderDropdown(
        name: "direction",
        icon: SizedBox(height: 2, child: Container()),
        onChanged: (value) {
          setState(() {
            selectedDirection = value;
          });
        },
        initialValue: selectedDirection,
        decoration: ThemeInputDecorations.dropdownBox.copyWith(
          suffix: selectedDirection == null
              ? const SizedBox(height: 10)
              : SizedBox(
                  height: 25,
                  width: 25,
                  child: IconButton(
                    padding: const EdgeInsets.all(0),
                    icon: const Icon(Icons.close, size: 15.0),
                    onPressed: () {
                      _formKey.currentState!.fields['direction']
                          ?.didChange(null);
                      setState(() {
                        selectedDirection = null;
                      });
                      // _formKey.currentState!.fields['status']?.setState(() {
                      //   _formKey.currentState!.fields['status']?.didChange(null);
                      // });
                    },
                  )),
          hintText: l10n.filterTransfersLabelByDirection,
        ),
        selectedItemBuilder: (BuildContext context) {
          return items.map<Widget>((item) {
            // This is the widget that will be shown when you select an item.
            // Here custom text style, alignment and layout size can be applied
            // to selected item string.

            return Container(
              alignment: Alignment.centerLeft,
              child: Row(
                  children: item.value != null
                      ? getDirectionLabel(item.value)
                      : [
                          Text(
                            l10n.generalLabelAnyDirection,
                            style: TextStyles.secondaryTextNormal,
                          )
                        ]),
            );
          }).toList();
        },
        items: items);
  }

  Widget getStatusDropdown() {
    final l10n = l10nOf(context);

    List<ComputedTransactionStatus?> statusOptions = [
      null,
      ComputedTransactionStatus.pending,
      ComputedTransactionStatus.success,
      ComputedTransactionStatus.failure,
      ComputedTransactionStatus.invalid,
    ];

    List<DropdownMenuItem> items = statusOptions
        .map((e) => DropdownMenuItem<ComputedTransactionStatus?>(
            value: e,
            child: Column(children: [Row(children: getStatusLabel(e))])))
        .toList();

    return FormBuilderDropdown(
        name: "status",
        icon: SizedBox(height: 2, child: Container()),
        onChanged: (value) {
          setState(() {
            selectedStatus = value;
          });
        },
        initialValue: selectedStatus,
        decoration: ThemeInputDecorations.dropdownBox.copyWith(
            suffix: selectedStatus == null
                ? const SizedBox(height: 10)
                : SizedBox(
                    height: 25,
                    width: 25,
                    child: IconButton(
                      padding: const EdgeInsets.all(0),
                      icon: const Icon(Icons.close, size: 15.0),
                      onPressed: () {
                        _formKey.currentState!.fields['status']
                            ?.didChange(null);
                        setState(() {
                          selectedStatus = null;
                        });
                        // _formKey.currentState!.fields['status']?.setState(() {
                        //   _formKey.currentState!.fields['status']?.didChange(null);
                        // });
                      },
                    )),
            hintText: l10n.filterTransfersLabelByStatus),
        selectedItemBuilder: (BuildContext context) {
          return items.map<Widget>((item) {
            // This is the widget that will be shown when you select an item.
            // Here custom text style, alignment and layout size can be applied
            // to selected item string.

            return Container(
              alignment: Alignment.centerLeft,
              child: Row(
                  children: item.value != null
                      ? getStatusLabel(item.value)
                      : [
                          Text(
                            l10n.filterTransfersLabelAnyStatus,
                            style: TextStyles.secondaryTextNormal,
                          )
                        ]),
            );
          }).toList();
        },
        items: items);
  }

  Widget getAccountsDropdown() {
    final l10n = l10nOf(context);
    List<QubicListVm?> accounts = [];
    accounts.add(null);
    for (var e in appStore.currentQubicIDs) {
      accounts.add(null);
      accounts.add(e); // Add actual item
    }

    List<DropdownMenuItem<String?>> selectableItems = [];
    selectableItems.add(DropdownMenuItem<String?>(
        value: null,
        child: Column(children: [
          Row(children: [
            Text(
              l10n.filterTransfersLabelAnyQubicID,
              style: TextStyles.accountName,
            ),
          ]),
        ])));
    // Add each QubicID with dividers
    int dividerIndex = 0; // To give unique values to dividers
    selectableItems.addAll(
      appStore.currentQubicIDs
          .expand((e) => [
                DropdownMenuItem<String?>(
                  // Unique value for the divider
                  value: 'divider_$dividerIndex',
                  // Disable this item so divider couldn't be chosen
                  enabled: false,
                  child: const Divider(
                    color: LightThemeColors.primary,
                    height: ThemePaddings.hugePadding,
                  ),
                ),
                DropdownMenuItem<String?>(
                  value: e.publicId,
                  child: IdListItemSelect(item: e, showAmount: false),
                ),
              ])
          .toList(),
    );
    return ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        clipBehavior: Clip.hardEdge,
        child: Container(
            child: FormBuilderDropdown(
                isDense: true,
                name: "qubicId",
                icon: SizedBox(height: 2, child: Container()),
                enabled: !isFilterForId(),
                onChanged: (value) {
                  setState(() {
                    selectedQubicId = value;
                  });
                },
                initialValue: selectedQubicId,
                decoration: ThemeInputDecorations.dropdownBox.copyWith(
                    suffix: selectedQubicId == null || isFilterForId()
                        ? const SizedBox(height: 12)
                        : SizedBox(
                            height: 25,
                            width: 25,
                            child: IconButton(
                              padding: const EdgeInsets.all(0),
                              icon: const Icon(Icons.close, size: 15.0),
                              onPressed: () {
                                _formKey.currentState!.fields['qubicId']
                                    ?.didChange(null);
                                setState(() {
                                  selectedQubicId = null;
                                });
                              },
                            )),
                    hintText: l10n.filterTransfersLabelByQubicID),
                selectedItemBuilder: (BuildContext context) {
                  return accounts.map<Widget>((QubicListVm? item) {
                    // This is the widget that will be shown when you select an item.
                    // Here custom text style, alignment and layout size can be applied
                    // to selected item string.

                    if (item == null) {
                      return Text(l10n.filterTransfersLabelAnyQubicID,
                          style: TextStyles.secondaryTextNormal);
                    }
                    return Container(
                        alignment: Alignment.centerLeft,
                        child: Flex(
                          direction: Axis.horizontal,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Flexible(
                                child: Text("${item.name} - ",
                                    style: TextStyles.textNormal)),
                            Expanded(
                                child: Text(item.publicId,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyles.secondaryTextSmall)),
                          ],
                        ));
                  }).toList();
                },
                items: selectableItems)));
  }

  Widget getScrollView() {
    final l10n = l10nOf(context);
    return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Row(children: [
          Container(
              child: Expanded(
                  child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ThemedControls.pageHeader(headerText: l10n.filterTransfersTitle),
              appStore.transactionFilter!.totalActiveFilters > 0
                  ? TextButton(
                      onPressed: () {
                        appStore.clearTransactionFilters();
                        Navigator.pop(context);
                      },
                      child: Text(l10n.generalButtonClearAll,
                          style: Theme.of(context)
                              .primaryTextTheme
                              .titleSmall
                              ?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.secondary)))
                  : Container(),
              Padding(
                  padding:
                      const EdgeInsets.only(top: ThemePaddings.normalPadding),
                  child: FormBuilder(
                      key: _formKey,
                      child: Column(
                        children: [
                          getAccountsDropdown(),
                          const SizedBox(height: ThemePaddings.normalPadding),
                          getDirectionDropdown(),
                          const SizedBox(height: ThemePaddings.normalPadding),
                          getStatusDropdown(),
                        ],
                      )))
            ],
          )))
        ]));
  }

  List<Widget> getButtons() {
    final l10n = l10nOf(context);

    return [
      Expanded(
          child: !isLoading
              ? ThemedControls.transparentButtonBigWithChild(
                  child: Padding(
                      padding:
                          const EdgeInsets.all(ThemePaddings.smallPadding + 3),
                      child: Text(l10n.generalButtonCancel,
                          style: TextStyles.transparentButtonText)),
                  onPressed: () {
                    Navigator.pop(context);
                  })
              : Container()),
      ThemedControls.spacerHorizontalNormal(),
      Expanded(
          child: ThemedControls.primaryButtonBigWithChild(
              child: Padding(
                  padding: const EdgeInsets.all(ThemePaddings.smallPadding + 3),
                  child: Text(l10n.generalButtonApply,
                      style: TextStyles.primaryButtonText)),
              onPressed: saveIdHandler))
    ];
  }

  void saveIdHandler() async {
    _formKey.currentState?.validate();
    if (!_formKey.currentState!.isValid) {
      return;
    }
    if (isFilterForId()) {
      Navigator.pop(
          context,
          TransactionFilter(
              qubicId: selectedQubicId,
              status: selectedStatus,
              direction: selectedDirection));
      return;
    }
    //Prevent duplicates
    appStore.setTransactionFilters(
        selectedQubicId, selectedStatus, selectedDirection);

    Navigator.pop(context);
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
