part of '../tab_explorer.dart';

class _ExplorerAppBar extends StatelessWidget {
  final ApplicationStore appStore = getIt<ApplicationStore>();
  final VoidCallback refreshOverview;
  _ExplorerAppBar({required this.refreshOverview});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
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
                        highlightColor: LightThemeColors.extraStrongBackground,
                        onPressed: refreshOverview,
                        icon: const Icon(Icons.refresh,
                            color: LightThemeColors.primary, size: 20),
                      )));
            } else {
              return Container();
            }
          }),
        SliverButton(
          icon: const ImageIcon(AssetImage('assets/images/explorer_search.png'),
              color: LightThemeColors.primary),
          onPressed: () {
            pushScreen(
              context,
              screen: const ExplorerSearch(),
              withNavBar: false,
              pageTransitionAnimation: PageTransitionAnimation.cupertino,
            );
          },
        ),
        ThemedControls.spacerHorizontalSmall(),
      ],
      floating: false,
      pinned: false,
      collapsedHeight: 60,
      expandedHeight: 0,
    );
  }
}
