import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:qubic_wallet/components/adaptive_refresh_indicator.dart';
import 'package:qubic_wallet/components/transaction_item.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/transaction_UI_helpers.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/models/qubic_list_vm.dart';
import 'package:qubic_wallet/models/transaction_filter.dart';

import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/styles/edge_insets.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:qubic_wallet/timed_controller.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';

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
    walletItem = appStore.currentQubicIDs.firstWhereOrNull(
        (element) => element.publicId == widget.publicQubicId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
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
                  child: Observer(builder: (context) {
                    return Column(
                        // runAlignment: WrapAlignment.center,
                        // alignment: WrapAlignment.center,
                        // crossAxisAlignment: WrapCrossAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ThemedControls.pageHeader(
                              headerText: (widget.item == null
                                  ? l10n.transfersLabelFor
                                  : l10n.transfersLabelForAccount(
                                      widget.item!.name)),
                              subheaderText: widget.publicQubicId),
                          Observer(builder: (context) {
                            List<Widget> results = [];
                            int added = 0;
                            appStore.currentTransactions.reversed
                                .forEach((tran) {
                              bool matchesItem =
                                  true; //If this widget has a specific item, only show transactions that involve that item
                              if (widget.item != null) {
                                matchesItem =
                                    widget.item!.publicId == tran.destId ||
                                        widget.item!.publicId == tran.sourceId;
                              }
                              if (matchesItem) {
                                added++;

                                results.add(TransactionItem(item: tran));
                                results.add(const SizedBox(
                                    height: ThemePaddings.normalPadding));
                              }
                            });
                            if (added == 0) {
                              results.add(getEmptyTransactionsForSingleID(
                                  context: context,
                                  hasFiltered: false,
                                  numberOfFilters: null,
                                  onTap: () {}));
                            }
                            return Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: results);
                          })
                        ]);
                  })),
            )));
  }
}
