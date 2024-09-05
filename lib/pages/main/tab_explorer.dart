import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:pagination_flutter/pagination.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:qubic_wallet/components/explorer_results/explorer_loading_indicator.dart';
import 'package:qubic_wallet/components/gradient_foreground.dart';
import 'package:qubic_wallet/components/sliver_button.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/extensions/asThousands.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/epoch_helpers.dart';
import 'package:qubic_wallet/helpers/platform_helpers.dart';
import 'package:qubic_wallet/helpers/global_snack_bar.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/explorer/explorer_search.dart';
import 'package:qubic_wallet/resources/qubic_li.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/stores/explorer_store.dart';
import 'package:qubic_wallet/styles/edge_insets.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:qubic_wallet/timed_controller.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:qubic_wallet/l10n/l10n.dart';

import 'wallet_contents/explorer/explorer_result_page.dart';

class TabExplorer extends StatefulWidget {
  const TabExplorer({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TabExplorerState createState() => _TabExplorerState();
}

class _TabExplorerState extends State<TabExplorer> {
  final ApplicationStore appStore = getIt<ApplicationStore>();
  final ExplorerStore explorerStore = getIt<ExplorerStore>();
  final QubicLi li = getIt<QubicLi>();
  final TimedController _timedController = getIt<TimedController>();
  final GlobalSnackBar _globalSnackBar = getIt<GlobalSnackBar>();

  final _scrollController = ScrollController();
  //Pagination Related
  int numberOfPages = 0;
  int currentPage = 1;
  int itemsPerPage = 1000;

  late final disposeReaction =
      reaction((_) => explorerStore.networkOverview, (value) {
    if (explorerStore.networkOverview != null) {
      //Calculate number of pages
      setState(() {
        numberOfPages =
            (explorerStore.networkOverview!.ticks.length / itemsPerPage).ceil();
        currentPage = 1;
      });
    } else {
      _timedController.interruptFetchTimer();
    }
  });

  void refreshOverview() {
    explorerStore.incrementPendingRequests();
    try {
      li.getNetworkOverview().then((value) {
        explorerStore.setNetworkOverview(value);
        explorerStore.decreasePendingRequests();
        setState(() {
          numberOfPages =
              (explorerStore.networkOverview!.ticks.length / itemsPerPage)
                  .ceil();
          currentPage = 1;
        });
      }, onError: (e) {
        _globalSnackBar.showError(e.toString().replaceAll("Exception: ", ""));

        explorerStore.decreasePendingRequests();
      });
    } on Exception catch (e) {
      _globalSnackBar.showError(e.toString().replaceAll("Exception: ", ""));
    }
  }

  @override
  void initState() {
    super.initState();
    if (explorerStore.networkOverview == null) {
      refreshOverview();
    }
  }

  @override
  void dispose() {
    super.dispose();
    disposeReaction();
    // disposer();
  }

  Widget getEmptyExplorer() {
    final l10n = l10nOf(context);
    return Center(
        child: Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: ThemePaddings.bigPadding,
          vertical: ThemePaddings.hugePadding * 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GradientForeground(
              child: const Icon(
            Icons.account_tree,
            size: 100,
          )),
          Text(l10n.explorerLabelLoadingData, style: TextStyles.secondaryText),
          ThemedControls.spacerVerticalBig(),
          Observer(builder: (context) {
            if (explorerStore.pendingRequests > 0) {
              return const CircularProgressIndicator();
            } else {
              return FilledButton.icon(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          LightThemeColors.buttonBackground)),
                  onPressed: () async {
                    refreshOverview();
                  },
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.explorerButtonRefreshData));
            }
          }),
        ],
      ),
    ));
  }

  Widget getPagination() {
    double width = MediaQuery.of(context).size.width;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Pagination(
            numOfPages: numberOfPages,
            selectedPage: currentPage,
            pagesVisible: width < 400
                ? 3
                : width < 440
                    ? 1
                    : width < 490
                        ? 2
                        : 3,
            onPageChanged: (page) {
              setState(() {
                currentPage = page;
              });
            },
            nextIcon: Icon(
              Icons.arrow_forward_ios,
              color: Theme.of(context).colorScheme.secondary,
              size: 14,
            ),
            previousIcon: Icon(
              Icons.arrow_back_ios,
              color: Theme.of(context).colorScheme.secondary,
              size: 14,
            ),
            activeTextStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            activeBtnStyle: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all(LightThemeColors.primary),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
            ),
            inactiveBtnStyle: ButtonStyle(
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              )),
            ),
            inactiveTextStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.secondary),
          ),
        ],
      ),
    );
  }

  Widget tickPanel(String title, String contents) {
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: LightThemeColors.cardBackground,
        ),
        child: Padding(
            padding: const EdgeInsets.all(ThemePaddings.smallPadding),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(title, style: TextStyles.secondaryTextSmall)),
                  FittedBox(
                      fit: BoxFit.scaleDown,
                      child:
                          Text(contents, style: TextStyles.textExtraLargeBold))
                ])));
  }

  List<Widget> getExplorerContents() {
    double width = MediaQuery.of(context).size.width;
    List<Widget> cards = [];

    cards.add(Observer(builder: (context) {
      final l10n = l10nOf(context);

      if (explorerStore.networkOverview == null) {
        return getEmptyExplorer();
      }

      return Padding(
          padding: ThemeEdgeInsets.pageInsets,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ThemedControls.pageHeader(
                headerText: l10n.explorerTitle,
                subheaderText: l10n.explorerLabelEpoch(getCurrentEpoch()),
                subheaderPill: false),

            ThemedControls.spacerVerticalNormal(),
            Text(l10n.explorerHeaderOverview,
                style: TextStyles.labelTextNormal),
            ThemedControls.spacerVerticalSmall(),
            Flex(direction: Axis.horizontal, children: [
              Expanded(
                  flex: 1,
                  child: tickPanel(l10n.explorerLabelPrice,
                      "\$${explorerStore.networkOverview!.price.toString()}")),
              ThemedControls.spacerHorizontalMini(),
              Expanded(
                  flex: 1,
                  child: tickPanel(l10n.explorerLabelMarketCap,
                      "\$${explorerStore.networkOverview!.marketCap.asThousands()}"))
            ]),
            ThemedControls.spacerVerticalMini(),
            Flex(direction: Axis.horizontal, children: [
              Expanded(
                  flex: 1,
                  child: tickPanel(
                      l10n.explorerLabelTotalTicks,
                      explorerStore.networkOverview!.numberOfTicks
                          .asThousands())),
              ThemedControls.spacerHorizontalMini(),
              Expanded(
                  flex: 1,
                  child: tickPanel(
                      l10n.explorerLabelEmptyTicks,
                      explorerStore.networkOverview!.numberOfEmptyTicks
                          .asThousands())),
              ThemedControls.spacerHorizontalMini(),
              Expanded(
                  flex: 1,
                  child: tickPanel(l10n.explorerLabelTickQuality,
                      "${explorerStore.networkOverview!.tickQualityPercentage}%"))
            ]),
            ThemedControls.spacerVerticalMini(),
            Flex(direction: Axis.horizontal, children: [
              Expanded(
                  flex: 1,
                  child: tickPanel(l10n.explorerLabelTotalSupply,
                      explorerStore.networkOverview!.supply.asThousands())),
              ThemedControls.spacerHorizontalMini(),
              Expanded(
                  flex: 1,
                  child: tickPanel(
                      l10n.explorerLabelTotalAddresses,
                      explorerStore.networkOverview!.numberOfEntities
                          .asThousands()))
            ]),
            //Starts here
            ThemedControls.spacerVerticalBig(),

            StickyHeader(
                header: Container(
                    color: Theme.of(context).colorScheme.background,
                    child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                            0,
                            ThemePaddings.smallPadding,
                            0,
                            ThemePaddings.smallPadding),
                        child: width > 400
                            ? Row(children: [
                                ThemedControls.pageHeader(
                                    headerText: l10n.explorerHeaderTicks,
                                    subheaderText: l10n.explorerSubHeaderTicks),
                                Expanded(child: Container()),
                                getPagination()
                                // Container(
                                //     height: 50.0,
                                //     color: Theme.of(context).colorScheme.background,
                                //     padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                //     alignment: Alignment.centerLeft,
                                //     child: getPagination())
                              ])
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    ThemedControls.pageHeader(
                                        headerText: l10n.explorerHeaderTicks,
                                        subheaderText:
                                            l10n.explorerSubHeaderTicks),

                                    getPagination()
                                    // Container(
                                    //     height: 50.0,
                                    //     color: Theme.of(context).colorScheme.background,
                                    //     padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                    //     alignment: Alignment.centerLeft,
                                    //     child: getPagination())
                                  ]))),
                content: Observer(builder: (context) {
                  List<Widget> items = [];
                  int min = (currentPage - 1) * itemsPerPage;
                  int max = currentPage * itemsPerPage;
                  if (min < 0) {
                    min = 0;
                  }
                  if (max > explorerStore.networkOverview!.ticks.length) {
                    max = explorerStore.networkOverview!.ticks.length;
                  }

                  List<Widget> lineWidget = [];
                  int lineCount = 0;
                  int maxPerLine = width < 400 ? 1 : 2;
                  for (var i = min; i < max; i++) {
                    lineWidget.add(TextButton(
                        onPressed: () {
                          pushScreen(
                            context,
                            screen: ExplorerResultPage(
                                resultType: ExplorerResultType.tick,
                                tick: explorerStore
                                    .networkOverview!.ticks[i].tick),
                            //TransactionsForId(publicQubicId: item.publicId),
                            withNavBar:
                                false, // OPTIONAL VALUE. True by default.
                            pageTransitionAnimation:
                                PageTransitionAnimation.cupertino,
                          );
                        },
                        child: FittedBox(
                            child: Text(
                                explorerStore.networkOverview!.ticks[i].tick
                                    .asThousands()
                                    .toString(),
                                style: TextStyles.textExplorerTick.copyWith(
                                    color: explorerStore.networkOverview!
                                            .ticks[i].arbitrated
                                        ? Theme.of(context).colorScheme.error
                                        : Theme.of(context)
                                            .colorScheme
                                            .primary)))));
                    if (lineCount == maxPerLine) {
                      items.add(Row(
                          mainAxisAlignment: width > 400
                              ? MainAxisAlignment.spaceEvenly
                              : MainAxisAlignment.spaceAround,
                          children: lineWidget));
                      lineWidget = [];
                      lineCount = 0;
                    } else {
                      lineCount++;
                    }
                  }

                  return Column(
                    children: items,
                  );
                })),
            //Ends here
          ]));
    }));
    return cards;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: RefreshIndicator(
            onRefresh: () async {
              refreshOverview();
            },
            backgroundColor: LightThemeColors.refreshIndicatorBackground,
            child: Scrollbar(
                controller: _scrollController,
                child:
                    CustomScrollView(controller: _scrollController, slivers: [
                  SliverAppBar(
                    backgroundColor: LightThemeColors.background,
                    actions: <Widget>[
                      ExplorerLoadingIndicator(),
                      ThemedControls.spacerHorizontalSmall(),
                      if (isDesktop)
                        Observer(builder: (context) {
                          if (appStore.pendingRequests == 0) {
                            return Ink(
                                decoration: const ShapeDecoration(
                                  color: LightThemeColors.background,
                                  shape: CircleBorder(),
                                ),
                                child: SizedBox(
                                    width: 32,
                                    height: 32,
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      color: LightThemeColors.cardBackground,
                                      highlightColor: LightThemeColors
                                          .extraStrongBackground,
                                      onPressed: () {
                                        refreshOverview();
                                      },
                                      icon: const Icon(Icons.refresh,
                                          color: LightThemeColors.primary,
                                          size: 20),
                                    )));
                          } else {
                            return Container();
                          }
                        }),
                      SliverButton(
                        icon: const Icon(Icons.filter_list,
                            color: LightThemeColors.primary),
                        onPressed: () {
                          pushScreen(
                            context,
                            screen: const ExplorerSearch(),
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
                    pinned: false,
                    collapsedHeight: 60,
                    expandedHeight: 0,
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return getExplorerContents()[index];
                    }, childCount: getExplorerContents().length),
                  ),
                ]))));
  }
}
