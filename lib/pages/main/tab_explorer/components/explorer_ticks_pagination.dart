part of '../tab_explorer.dart';

class _ExplorerTicksPagination extends StatelessWidget {
  const _ExplorerTicksPagination({
    required this.explorerStore,
    required this.width,
  });

  final ExplorerStore explorerStore;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Observer(
            builder: (context) {
              return Pagination(
                numOfPages:
                    explorerStore.networkTicks?.pagination.totalPages ?? 0,
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
              );
            },
          ),
        ],
      ),
    );
  }
}
