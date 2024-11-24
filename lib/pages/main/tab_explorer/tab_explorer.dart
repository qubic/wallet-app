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

part 'components/explorer_ticks_pagination.dart';
part 'components/tick_panel.dart';
part 'components/empty_explorer.dart';
part 'components/latest_ticks_container.dart';
part 'components/overview_container.dart';
part 'components/explorer_app_bar.dart';

class TabExplorer extends StatefulWidget {
  const TabExplorer({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TabExplorerState createState() => _TabExplorerState();
}

class _TabExplorerState extends State<TabExplorer> {
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
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            _ExplorerAppBar(refreshOverview: refreshOverview),
            _OverviewContainer(refreshOverview: refreshOverview),
            _LatestTicksContainer(refreshOverview: refreshOverview),
          ],
        ),
      ),
    ));
  }
}
