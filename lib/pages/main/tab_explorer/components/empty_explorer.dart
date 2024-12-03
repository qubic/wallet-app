part of '../tab_explorer.dart';

class _EmptyExplorer extends StatelessWidget {
  final VoidCallback onRefresh;
  _EmptyExplorer({required this.onRefresh});

  final explorerStore = getIt<ExplorerStore>();

  @override
  Widget build(BuildContext context) {
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
            if (explorerStore.isLoading) {
              return const CircularProgressIndicator();
            } else {
              return FilledButton.icon(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          LightThemeColors.buttonBackground)),
                  onPressed: () async {
                    onRefresh();
                  },
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.explorerButtonRefreshData));
            }
          }),
        ],
      ),
    ));
    ;
  }
}
