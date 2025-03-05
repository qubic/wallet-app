// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:qubic_wallet/components/adaptive_refresh_indicator.dart';
import 'package:qubic_wallet/components/transaction_item.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/transaction_UI_helpers.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/models/qubic_list_vm.dart';
import 'package:qubic_wallet/models/transaction_filter.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/transfers/filter_transactions.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/styles/edge_insets.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:qubic_wallet/timed_controller.dart';

class TransactionsForId extends StatefulWidget {
  final String publicQubicId;
  final QubicListVm? item;
  const TransactionsForId({super.key, required this.publicQubicId, this.item});

  @override
  // ignore: library_private_types_in_public_api
  _TransactionsForIdState createState() => _TransactionsForIdState();
}

class _TransactionsForIdState extends State<TransactionsForId> {
  final ApplicationStore appStore = getIt<ApplicationStore>();
  final TimedController _timedController = getIt<TimedController>();

  QubicListVm? walletItem;
  bool showFilterForm = false;
  TransactionDirection? selectedDirection;
  final _formKey = GlobalKey<FormBuilderState>();

  List<Widget> getDirectionLabel(TransactionDirection? e) {
    final l10n = l10nOf(context);

    List<Widget> out = [];
    if (e == null) {
      out.add(const Icon(Icons.clear));
      out.add(Text(
        l10n.transfersLabelAllTransactions,
        style: Theme.of(context)
            .textTheme
            .bodyLarge!
            .copyWith(fontStyle: FontStyle.italic),
      ));
    } else {
      out.add(Icon(e == TransactionDirection.incoming
          ? Icons.input_outlined
          : Icons.output_outlined));
      out.add(const Text(" "));
      out.add(Text(e == TransactionDirection.incoming
          ? l10n.transactionLabelDirectionIncoming
          : l10n.transactionLabelDirectionOutgoing));
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
              const Divider()
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
        decoration: InputDecoration(
          labelText: l10n.filterTransfersLabelByDirection,
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
          hintText: l10n.filterTransfersFieldHintByDirection,
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
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(fontStyle: FontStyle.italic),
                          )
                        ]),
            );
          }).toList();
        },
        items: items);
  }

  @override
  void initState() {
    super.initState();
    walletItem = appStore.findAccountById(widget.publicQubicId);
    transactionFilter = TransactionFilter(qubicId: widget.publicQubicId);
  }

  TransactionFilter? transactionFilter;

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(
              icon: const ImageIcon(AssetImage('assets/images/filter_trx.png'),
                  color: LightThemeColors.primary),
              onPressed: () async {
                final selectedFilter = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          FilterTransactions(initialFilter: transactionFilter),
                    ));
                if (selectedFilter != null) {
                  setState(() {
                    transactionFilter = selectedFilter;
                  });
                }
              },
            ),
            ThemedControls.spacerHorizontalSmall(),
          ],
        ),
        body: SafeArea(
            minimum: ThemeEdgeInsets.pageInsets
                .copyWith(bottom: ThemePaddings.normalPadding),
            child: AdaptiveRefreshIndicator(
              onRefresh: () async {
                await _timedController.interruptFetchTimer();
              },
              backgroundColor: LightThemeColors.refreshIndicatorBackground,
              child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ThemedControls.pageHeader(
                            headerText: (widget.item == null
                                ? l10n.transfersLabelFor
                                : l10n.transfersLabelForAccount(
                                    widget.item!.name)),
                            subheaderText: null),
                        Builder(builder: (context) {
                          List<Widget> results = [];
                          for (var tran
                              in appStore.currentTransactions.reversed) {
                            bool matchesItem = true;
                            if (transactionFilter != null) {
                              matchesItem = transactionFilter!.matchesVM(tran);
                            }
                            if (matchesItem) {
                              results.add(TransactionItem(item: tran));
                              results.add(const SizedBox(
                                  height: ThemePaddings.normalPadding));
                            }
                          }
                          if (results.isEmpty) {
                            results.add(TransactionUIHelpers
                                .getEmptyTransactionsForSingleID(
                                    context: context,
                                    hasFiltered: transactionFilter?.status !=
                                            null ||
                                        transactionFilter?.direction != null,
                                    numberOfFilters:
                                        transactionFilter!.totalActiveFilters -
                                            1,
                                    onTap: () {
                                      setState(() {
                                        transactionFilter = TransactionFilter(
                                            qubicId: widget.publicQubicId);
                                      });
                                    }));
                          } else {
                            results.insert(
                                0,
                                TransactionUIHelpers.getTransactionFiltersInfo(
                                    context,
                                    numberOfFilters:
                                        transactionFilter!.totalActiveFilters -
                                            1,
                                    numberOfResults: results.length ~/ 2,
                                    onTap: () {
                                  setState(() {
                                    transactionFilter = TransactionFilter(
                                        qubicId: widget.publicQubicId);
                                  });
                                }));
                          }
                          return Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: results);
                        })
                      ])),
            )));
  }
}
