import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:qubic_wallet/components/adaptive_refresh_indicator.dart';
import 'package:qubic_wallet/components/sliver_button.dart';
import 'package:qubic_wallet/components/tick_indication_styled.dart';
import 'package:qubic_wallet/components/tick_refresh.dart';
import 'package:qubic_wallet/components/transaction_item.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/transaction_UI_helpers.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/models/transaction_filter.dart';
import 'package:qubic_wallet/models/transaction_vm.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/transfers/filter_transactions.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:qubic_wallet/timed_controller.dart';

class TabTransfers extends StatefulWidget {
  const TabTransfers({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TabTransfersState createState() => _TabTransfersState();
}

class _TabTransfersState extends State<TabTransfers> {
  final ApplicationStore appStore = getIt<ApplicationStore>();
  final TimedController _timedController = getIt<TimedController>();

  final double sliverCollapsed = 80;
  final double sliverExpanded = 80;

  String? filterQubicId;
  ComputedTransactionStatus? filterStatus;
  TransactionFilter? filter;

  final _scrollController = ScrollController();

  Widget clearFiltersButton(BuildContext context) {
    final l10n = l10nOf(context);

    return TextButton(
        onPressed: () {
          appStore.clearTransactionFilters();
        },
        child: Text(
            l10n.filterTransfersClearFilters(
                appStore.transactionFilter!.totalActiveFilters),
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: Theme.of(context).colorScheme.secondary,
                fontFamily: ThemeFonts.secondary)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return AdaptiveRefreshIndicator(
        edgeOffset: kToolbarHeight,
        onRefresh: () async {
          await _timedController.interruptFetchTimer();
        },
        backgroundColor: LightThemeColors.refreshIndicatorBackground,
        child: Container(
            color: LightThemeColors.background,
            child: Scrollbar(
                controller: _scrollController,
                child: CustomScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverAppBar(
                          backgroundColor: LightThemeColors.background,
                          actions: <Widget>[
                            TickRefresh(),
                            ThemedControls.spacerHorizontalSmall(),
                            SliverButton(
                              icon: const ImageIcon(
                                  AssetImage('assets/images/filter_trx.png'),
                                  color: LightThemeColors
                                      .primary // Optional: color to apply to the image
                                  ),
                              onPressed: () {
                                pushScreen(
                                  context,
                                  screen: const FilterTransactions(),
                                  withNavBar:
                                      false, // OPTIONAL VALUE. True by default.
                                  pageTransitionAnimation:
                                      PageTransitionAnimation.cupertino,
                                );
                              },
                            ),
                            ThemedControls.spacerHorizontalSmall(),
                          ],
                          floating: false,
                          pinned: true,
                          toolbarHeight: 58,
                          flexibleSpace: Stack(children: [
                            Positioned.fill(
                                child: Column(children: [
                              Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      0,
                                      ThemePaddings.normalPadding,
                                      0,
                                      ThemePaddings.normalPadding),
                                  child: Center(
                                      child: TickIndicatorStyled(
                                          textStyle: TextStyles.blackTickText)))
                            ])),
                          ])),
                      SliverList(
                          delegate: SliverChildListDelegate([
                        Container(
                          child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  ThemePaddings.normalPadding,
                                  ThemePaddings.normalPadding,
                                  ThemePaddings.normalPadding,
                                  ThemePaddings.miniPadding),
                              child: ThemedControls.pageHeader(
                                  headerText: l10n.appTabTransfers)),
                        )
                      ])),
                      Observer(builder: (context) {
                        if (appStore.currentTransactions.isEmpty) {
                          return SliverList(
                              delegate: SliverChildListDelegate([
                            Container(
                                child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        ThemePaddings.smallPadding,
                                        ThemePaddings.normalPadding,
                                        ThemePaddings.smallPadding,
                                        ThemePaddings.miniPadding),
                                    child: getEmptyTransactions(
                                        context: context,
                                        hasFiltered: false,
                                        numberOfFilters: null,
                                        onTap: () {})))
                          ]));
                        }
                        List<TransactionVm> filteredResults = [];

                        appStore.currentTransactions.reversed.forEach((tran) {
                          if ((appStore.transactionFilter == null) ||
                              (appStore.transactionFilter!.matchesVM(tran))) {
                            filteredResults.add(tran);
                          }
                        });
                        if (filteredResults.isEmpty) {
                          return SliverList(
                              delegate: SliverChildListDelegate([
                            Container(
                                child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        ThemePaddings.smallPadding,
                                        ThemePaddings.normalPadding,
                                        ThemePaddings.smallPadding,
                                        ThemePaddings.miniPadding),
                                    child: getEmptyTransactions(
                                        context: context,
                                        hasFiltered: true,
                                        numberOfFilters: appStore
                                            .transactionFilter
                                            ?.totalActiveFilters,
                                        onTap: () {
                                          appStore.clearTransactionFilters();
                                        })))
                          ]));
                        }
                        return SliverList(
                          delegate:
                              SliverChildBuilderDelegate((context, index) {
                            if (index == 0) {
                              return Container(
                                  color: LightThemeColors.background,
                                  child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: ThemePaddings.smallPadding,
                                      ),
                                      child: Flex(
                                          direction: MediaQuery.of(context)
                                                      .size
                                                      .width <
                                                  400
                                              ? Axis.vertical
                                              : Axis.horizontal,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                                l10n.transfersLabelShowingTransactionsFound(
                                                    filteredResults.length),
                                                style:
                                                    TextStyles.secondaryText),
                                            appStore.transactionFilter ==
                                                        null ||
                                                    appStore.transactionFilter!
                                                            .totalActiveFilters ==
                                                        0
                                                ? Container()
                                                : clearFiltersButton(context)
                                          ])));
                            }
                            return Container(
                                color: LightThemeColors.background,
                                child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: ThemePaddings.smallPadding,
                                        vertical:
                                            ThemePaddings.normalPadding / 2),
                                    child: TransactionItem(
                                      item: filteredResults[index - 1],
                                    )));
                          }, childCount: filteredResults.length + 1),
                        );
                      }),
                    ]))));
  }
}
