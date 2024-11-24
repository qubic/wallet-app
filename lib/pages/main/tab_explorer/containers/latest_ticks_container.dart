part of '../tab_explorer.dart';

class _LatestTicksContainer extends StatelessWidget {
  final ExplorerStore explorerStore = getIt<ExplorerStore>();
  final VoidCallback refreshOverview;
  _LatestTicksContainer({required this.refreshOverview});

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return Observer(builder: (context) {
      if (explorerStore.networkOverview == null) {
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      } else if (explorerStore.isLoading == true) {
        return const SliverPadding(
          padding: EdgeInsets.only(top: 10),
          sliver: SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          ),
        );
      } else if (explorerStore.isLoading == false &&
          explorerStore.networkTicks == null) {
        return SliverToBoxAdapter(
            child: FilledButton.icon(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        LightThemeColors.buttonBackground)),
                onPressed: refreshOverview,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.explorerButtonRefreshData)));
      }
      return SliverList.builder(
        itemCount: (explorerStore.networkTicks!.ticks.length / 3).ceil(),
        itemBuilder: (context, index) {
          final startIndex = index * 3;
          final endIndex = startIndex + 3;
          final rowTicks = explorerStore.networkTicks!.ticks.sublist(
              startIndex,
              endIndex > explorerStore.networkTicks!.ticks.length
                  ? explorerStore.networkTicks!.ticks.length
                  : endIndex);

          return Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween, // Space between buttons
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
                      style: TextStyles.textExplorerTick.copyWith(
                        color: tick.arbitrated
                            ? Theme.of(context).colorScheme.error
                            : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      );
    });
  }
}
