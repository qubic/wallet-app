import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/dtos/dapp_dto.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/pages/main/tab_dapps/components/dapp_tile.dart';
import 'package:qubic_wallet/pages/main/tab_dapps/components/featured_app_widget.dart';
import 'package:qubic_wallet/pages/main/tab_dapps/components/popular_apps_widget.dart';
import 'package:qubic_wallet/stores/dapp_store.dart';
import 'package:qubic_wallet/styles/edge_insets.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

class TabDApps extends StatefulWidget {
  const TabDApps({super.key});

  @override
  State<TabDApps> createState() => _TabDAppsState();
}

class _TabDAppsState extends State<TabDApps> with TickerProviderStateMixin {
  bool _isFirst = true;
  final dappStore = getIt<DappStore>();

  late AnimationController _featuredController;
  late Animation<Offset> _featuredSlideAnimation;
  late Animation<double> _fadeAnimation;
  late AnimationController _popularController;
  late Animation<Offset> _popularSlideAnimation;
  late Animation<double> _popularFadeAnimation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isFirst) {
      _initializeFeaturedAnimations();
      _initializePopularAnimations();
      _startAnimations();
      _isFirst = false;
    }
  }

  void _initializeFeaturedAnimations() {
    _featuredController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _featuredSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _featuredController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _featuredController,
      curve: Curves.easeIn,
    ));
  }

  void _initializePopularAnimations() {
    _popularController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _popularSlideAnimation = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _popularController,
      curve: Curves.easeOutCubic,
    ));

    _popularFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _popularController,
      curve: Curves.easeIn,
    ));
  }

  Future<void> _startAnimations() async {
    if (mounted) {
      _featuredController.forward();
      _popularController.forward();
    }
  }

  @override
  void dispose() {
    _featuredController.dispose();
    _popularController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return Scaffold(body: Observer(builder: (context) {
      if (dappStore.error != null) {
        return SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                l10n.generalErrorUnexpectedError,
                style: TextStyles.secondaryText,
              ),
              const SizedBox(height: ThemePaddings.normalPadding),
              ThemedControls.primaryButtonBig(
                  onPressed: () {
                    getIt<DappStore>().loadDapps();
                  },
                  text: l10n.generalButtonTryAgain)
            ],
          ),
        );
      } else if (dappStore.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      return ListView(
        padding: EdgeInsets.zero,
        children: [
          FeaturedAppWidget(
            slideAnimation: _featuredSlideAnimation,
            fadeAnimation: _fadeAnimation,
            featuredApp: dappStore.featuredDapp,
          ),
          if (dappStore.featuredDapp != null) const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: ThemePaddings.normalPadding),
            child: TopDAppsWidget(
              topDApps: dappStore.topDapps,
              fadeAnimation: _fadeAnimation,
              slideAnimation: _featuredSlideAnimation,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: ThemePaddings.hugePadding),
            child: Text(l10n.dAppPopularApps,
                style: TextStyles.pageTitle
                    .copyWith(fontSize: ThemeFontSizes.sectionTitle)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: ThemePaddings.normalPadding),
            child: PopularDAppsWidget(
              slideAnimation: _popularSlideAnimation,
              fadeAnimation: _popularFadeAnimation,
            ),
          ),
          const SizedBox(height: 16),
        ],
      );
    }));
  }
}

class TopDAppsWidget extends StatelessWidget {
  final Animation<Offset> slideAnimation;
  final Animation<double> fadeAnimation;
  final List<DappDto> topDApps;

  const TopDAppsWidget({
    required this.slideAnimation,
    required this.fadeAnimation,
    required this.topDApps,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ThemedControls.card(
      child: Column(
        children: List.generate(topDApps.length, (index) {
          return SlideTransition(
            position: slideAnimation,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: DAppTile(
                dApp: topDApps[index],
              ),
            ),
          );
        }),
      ),
    );
  }
}
