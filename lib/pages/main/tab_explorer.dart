import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:pagination_flutter/pagination.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:qubic_wallet/components/adaptive_refresh_indicator.dart';
import 'package:qubic_wallet/components/explorer_results/explorer_loading_indicator.dart';
import 'package:qubic_wallet/components/gradient_foreground.dart';
import 'package:qubic_wallet/components/sliver_button.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/extensions/asThousands.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/epoch_helpers.dart';
import 'package:qubic_wallet/helpers/platform_helpers.dart';
import 'package:qubic_wallet/helpers/global_snack_bar.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/explorer/explorer_result_page.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/explorer/explorer_search.dart';
import 'package:qubic_wallet/resources/apis/stats/qubic_stats_api.dart';
import 'package:qubic_wallet/resources/qubic_li.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/stores/explorer_store.dart';
import 'package:qubic_wallet/styles/edge_insets.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:qubic_wallet/timed_controller.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:qubic_wallet/l10n/l10n.dart';

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
  final QubicStatsApi statsApi = getIt<QubicStatsApi>();
  final TimedController _timedController = getIt<TimedController>();
  final GlobalSnackBar _globalSnackBar = getIt<GlobalSnackBar>();

  final _scrollController = ScrollController();
  //Pagination Related

  // late final disposeReaction =
  //     reaction((_) => explorerStore.networkOverview, (value) {
  //   if (explorerStore.networkOverview != null) {
  //     //Calculate number of pages
  //     setState(() {
  //       numberOfPages =
  //           (explorerStore.networkOverview!.ticksInCurrentEpoch! / itemsPerPage)
  //               .ceil();
  //       currentPage = 1;
  //     });
  //   } else {
  //     _timedController.interruptFetchTimer();
  //   }
  // });

  void refreshOverview() {
    try {
      explorerStore.getTicks();
      // statsApi.getMarketInfo().then((value) {
      //   explorerStore.setNetworkOverview(value);
      //   explorerStore.getTicks();
      //   // setState(() {
      //   //   numberOfPages = (explorerStore.networkOverview!.ticksInCurrentEpoch! /
      //   //           itemsPerPage)
      //   //       .ceil();
      //   //   currentPage = 1;
      //   // });
      // }, onError: (e) {
      //   _globalSnackBar.showError(e.toString().replaceAll("Exception: ", ""));
      // });
    } catch (e) {
      _globalSnackBar.showError(e.toString().replaceAll("Exception: ", ""));
    }
  }

  @override
  void initState() {
    if (explorerStore.networkTicks == null) {
      refreshOverview();
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    // disposeReaction();
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
            if (explorerStore.isTicksLoading) {
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
            numOfPages: explorerStore.networkTicks?.pagination.totalPages ?? 0,
            selectedPage: explorerStore.pageNumber,
            pagesVisible: width < 400
                ? 3
                : width < 440
                    ? 1
                    : width < 490
                        ? 2
                        : 3,
            onPageChanged: (page) {
              explorerStore.setPageNumber(page);
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
                      "\$${explorerStore.networkOverview!.marketCap!.asThousands()}"))
            ]),
            ThemedControls.spacerVerticalMini(),
            Flex(direction: Axis.horizontal, children: [
              Expanded(
                  flex: 1,
                  child: tickPanel(
                      l10n.explorerLabelTotalTicks,
                      explorerStore.networkOverview!.ticksInCurrentEpoch!
                          .asThousands())),
              ThemedControls.spacerHorizontalMini(),
              Expanded(
                  flex: 1,
                  child: tickPanel(
                      l10n.explorerLabelEmptyTicks,
                      explorerStore.networkOverview!.emptyTicksInCurrentEpoch!
                          .asThousands())),
              ThemedControls.spacerHorizontalMini(),
              Expanded(
                  flex: 1,
                  child: tickPanel(l10n.explorerLabelTickQuality,
                      "${explorerStore.networkOverview!.epochTickQuality}%"))
            ]),
            ThemedControls.spacerVerticalMini(),
            Flex(direction: Axis.horizontal, children: [
              Expanded(
                  flex: 1,
                  child: tickPanel(
                      l10n.explorerLabelTotalSupply,
                      explorerStore.networkOverview!.circulatingSupply!
                          .asThousands())),
              ThemedControls.spacerHorizontalMini(),
              Expanded(
                  flex: 1,
                  child: tickPanel(
                      l10n.explorerLabelTotalAddresses,
                      explorerStore.networkOverview!.activeAddresses!
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
                  final currentPage = explorerStore.pageNumber;
                  return explorerStore.networkTicks?.ticks == null
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount:
                              (explorerStore.networkTicks!.ticks.length / 3)
                                  .ceil(), // Divide by 3
                          itemBuilder: (context, index) {
                            // Calculate the start and end indices for this row
                            final startIndex = index * 3;
                            final endIndex = startIndex + 3;

                            // Get the ticks for this row
                            final rowTicks = explorerStore.networkTicks!.ticks
                                .sublist(
                                    startIndex,
                                    endIndex >
                                            explorerStore
                                                .networkTicks!.ticks.length
                                        ? explorerStore
                                            .networkTicks!.ticks.length
                                        : endIndex);

                            return Row(
                              mainAxisAlignment: MainAxisAlignment
                                  .spaceBetween, // Space between buttons
                              children: rowTicks.map((tick) {
                                return Expanded(
                                  // Make buttons flexible in size
                                  child: TextButton(
                                    onPressed: () {
                                      pushScreen(
                                        context,
                                        screen: ExplorerResultPage(
                                          resultType: ExplorerResultType.tick,
                                          tick: tick.tick,
                                        ),
                                        withNavBar: false,
                                        pageTransitionAnimation:
                                            PageTransitionAnimation.cupertino,
                                      );
                                    },
                                    child: FittedBox(
                                      child: Text(
                                        tick.tick.asThousands().toString(),
                                        style: TextStyles.textExplorerTick
                                            .copyWith(
                                          color: tick.arbitrated
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .error
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        );

                  // List<Widget> items = [];
                  // int min = (currentPage - 1) * 100;
                  // int max = currentPage * 100;
                  // if (min < 0) {
                  //   min = 0;
                  // }
                  // if (max >
                  //     explorerStore.networkOverview!.ticksInCurrentEpoch!) {
                  //   max = explorerStore.networkOverview!.ticksInCurrentEpoch!;
                  // }

                  // List<Widget> lineWidget = [];
                  // int lineCount = 0;
                  // int maxPerLine = width < 400 ? 1 : 2;
                  // for (var i = min; i < max; i++) {
                  //   lineWidget.add(
                  //     TextButton(
                  //       onPressed: () {
                  //         pushScreen(
                  //           context,
                  //           screen: ExplorerResultPage(
                  //               resultType: ExplorerResultType.tick,
                  //               tick:
                  //                   explorerStore.networkTicks!.ticks[i].tick),
                  //           //TransactionsForId(publicQubicId: item.publicId),
                  //           withNavBar:
                  //               false, // OPTIONAL VALUE. True by default.
                  //           pageTransitionAnimation:
                  //               PageTransitionAnimation.cupertino,
                  //         );
                  //       },
                  //       child: FittedBox(
                  //         child: Text(
                  //           explorerStore.networkTicks!.ticks[i].tick
                  //               .asThousands()
                  //               .toString(),
                  //           style: TextStyles.textExplorerTick.copyWith(
                  //               color: explorerStore
                  //                       .networkTicks!.ticks[i].arbitrated
                  //                   ? Theme.of(context).colorScheme.error
                  //                   : Theme.of(context).colorScheme.primary),
                  //         ),
                  //       ),
                  //     ),
                  //   );
                  //   if (lineCount == maxPerLine) {
                  //     items.add(Row(
                  //         mainAxisAlignment: width > 400
                  //             ? MainAxisAlignment.spaceEvenly
                  //             : MainAxisAlignment.spaceAround,
                  //         children: lineWidget));
                  //     lineWidget = [];
                  //     lineCount = 0;
                  //   } else {
                  //     lineCount++;
                  //   }
                  // }

                  // return explorerStore.networkTicks?.ticks == null
                  //     ? const Center(
                  //         child: CircularProgressIndicator(),
                  //       )
                  //     : Column(
                  //         children: items,
                  //       );
                })),
            //Ends here
          ]));
    }));
    return cards;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: AdaptiveRefreshIndicator(
            edgeOffset: kToolbarHeight,
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
                        icon: const ImageIcon(
                            AssetImage('assets/images/explorer_search.png'),
                            color: LightThemeColors
                                .primary // Optional: color to apply to the image
                            ),
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
