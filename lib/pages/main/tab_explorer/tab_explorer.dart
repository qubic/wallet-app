import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
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
import 'package:qubic_wallet/helpers/global_snack_bar.dart';
import 'package:qubic_wallet/helpers/platform_helpers.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/explorer/explorer_result_page.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/explorer/explorer_search.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/stores/explorer_store.dart';
import 'package:qubic_wallet/styles/edge_insets.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:sticky_headers/sticky_headers.dart';

part 'components/explorer_ticks_pagination.dart';
part 'components/tick_panel.dart';
part 'components/explorer_content.dart';
part 'components/empty_explorer.dart';

class TabExplorer extends StatefulWidget {
  const TabExplorer({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TabExplorerState createState() => _TabExplorerState();
}

class _TabExplorerState extends State<TabExplorer> {
  final ApplicationStore appStore = getIt<ApplicationStore>();
  final ExplorerStore explorerStore = getIt<ExplorerStore>();
  final GlobalSnackBar _globalSnackBar = getIt<GlobalSnackBar>();

  final _scrollController = ScrollController();

  void refreshOverview() async {
    try {
      explorerStore.setLoading(true);
      await explorerStore.getTicks();
      await explorerStore.getOverview();
    } catch (e) {
      _globalSnackBar.showError(e.toString());
    } finally {
      explorerStore.setLoading(false);
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
                            color: LightThemeColors.primary),
                        onPressed: () {
                          pushScreen(
                            context,
                            screen: const ExplorerSearch(),
                            withNavBar: false,
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
                    delegate: SliverChildListDelegate([
                      Observer(builder: (context) {
                        if (explorerStore.networkOverview == null) {
                          return _EmptyExplorer(onRefresh: refreshOverview);
                        } else {
                          return _ExplorerContent();
                        }
                      })
                    ]),
                  ),
                ]))));
  }
}
