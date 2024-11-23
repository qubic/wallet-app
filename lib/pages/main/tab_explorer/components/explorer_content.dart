part of '../tab_explorer.dart';

class _ExplorerContent extends StatelessWidget {
  _ExplorerContent();

  final explorerStore = getIt<ExplorerStore>();

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    double width = MediaQuery.of(context).size.width;

    return Padding(
        padding: ThemeEdgeInsets.pageInsets,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ThemedControls.pageHeader(
              headerText: l10n.explorerTitle,
              subheaderText: l10n.explorerLabelEpoch(getCurrentEpoch()),
              subheaderPill: false),
          ThemedControls.spacerVerticalNormal(),
          Text(l10n.explorerHeaderOverview, style: TextStyles.labelTextNormal),
          ThemedControls.spacerVerticalSmall(),
          Flex(direction: Axis.horizontal, children: [
            Expanded(
                flex: 1,
                child: _TickPanel(l10n.explorerLabelPrice,
                    "\$${explorerStore.networkOverview!.price.toString()}")),
            ThemedControls.spacerHorizontalMini(),
            Expanded(
                flex: 1,
                child: _TickPanel(l10n.explorerLabelMarketCap,
                    "\$${explorerStore.networkOverview!.marketCap!.asThousands()}"))
          ]),
          ThemedControls.spacerVerticalMini(),
          Flex(direction: Axis.horizontal, children: [
            Expanded(
                flex: 1,
                child: _TickPanel(
                    l10n.explorerLabelTotalTicks,
                    explorerStore.networkOverview!.ticksInCurrentEpoch!
                        .asThousands())),
            ThemedControls.spacerHorizontalMini(),
            Expanded(
                flex: 1,
                child: _TickPanel(
                    l10n.explorerLabelEmptyTicks,
                    explorerStore.networkOverview!.emptyTicksInCurrentEpoch!
                        .asThousands())),
            ThemedControls.spacerHorizontalMini(),
            Expanded(
                flex: 1,
                child: _TickPanel(l10n.explorerLabelTickQuality,
                    "${explorerStore.networkOverview!.epochTickQuality}%"))
          ]),
          ThemedControls.spacerVerticalMini(),
          Flex(direction: Axis.horizontal, children: [
            Expanded(
                flex: 1,
                child: _TickPanel(
                    l10n.explorerLabelTotalSupply,
                    explorerStore.networkOverview!.circulatingSupply!
                        .asThousands())),
            ThemedControls.spacerHorizontalMini(),
            Expanded(
                flex: 1,
                child: _TickPanel(
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
                              _ExplorerTicksPagination(
                                  explorerStore: explorerStore, width: width)
                            ])
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                  ThemedControls.pageHeader(
                                      headerText: l10n.explorerHeaderTicks,
                                      subheaderText:
                                          l10n.explorerSubHeaderTicks),
                                  _ExplorerTicksPagination(
                                      explorerStore: explorerStore,
                                      width: width),
                                ]))),
              content: Observer(builder: (context) {
                return explorerStore.networkTicks?.ticks == null
                    ? const Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount:
                            (explorerStore.networkTicks!.ticks.length / 3)
                                .ceil(),
                        itemBuilder: (context, index) {
                          final startIndex = index * 3;
                          final endIndex = startIndex + 3;
                          final rowTicks = explorerStore.networkTicks!.ticks
                              .sublist(
                                  startIndex,
                                  endIndex >
                                          explorerStore
                                              .networkTicks!.ticks.length
                                      ? explorerStore.networkTicks!.ticks.length
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
                                      style:
                                          TextStyles.textExplorerTick.copyWith(
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
              })),
        ]));
  }
}
