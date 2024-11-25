part of '../tab_explorer.dart';

class _OverviewContainer extends StatelessWidget {
  final VoidCallback refreshOverview;
  _OverviewContainer({required this.refreshOverview});

  final ExplorerStore explorerStore = getIt<ExplorerStore>();
  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    final width = MediaQuery.of(context).size.width;
    return SliverPadding(
      padding: ThemeEdgeInsets.pageInsets.copyWith(bottom: 0),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          Observer(builder: (context) {
            if (explorerStore.networkOverview == null) {
              return _EmptyExplorer(onRefresh: refreshOverview);
            } else {
              return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ThemedControls.pageHeader(
                        headerText: l10n.explorerTitle,
                        subheaderText:
                            l10n.explorerLabelEpoch(getCurrentEpoch()),
                        subheaderPill: false),
                    ThemedControls.spacerVerticalNormal(),
                    Text(l10n.explorerHeaderOverview,
                        style: TextStyles.labelTextNormal),
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
                              explorerStore
                                  .networkOverview!.ticksInCurrentEpoch!
                                  .asThousands())),
                      ThemedControls.spacerHorizontalMini(),
                      Expanded(
                          flex: 1,
                          child: _TickPanel(
                              l10n.explorerLabelEmptyTicks,
                              explorerStore
                                  .networkOverview!.emptyTicksInCurrentEpoch!
                                  .asThousands())),
                      ThemedControls.spacerHorizontalMini(),
                      Expanded(
                          flex: 1,
                          child: _TickPanel(l10n.explorerLabelTickQuality,
                              "${explorerStore.networkOverview!.epochTickQuality?.toStringAsFixed(2)}%"))
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
                    Container(
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
                                ],
                              ),
                      ),
                    ),
                  ]);
            }
          }),
        ]),
      ),
    );
  }
}
