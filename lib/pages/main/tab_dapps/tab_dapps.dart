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
  bool _isImagesLoaded = false;
  bool _isFirst = true;
  final featuredApp = getIt<DappStore>().featuredDapp;
  final topApps = getIt<DappStore>().topDapps;
  final dapps = getIt<DappStore>().allDapps;
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
      _preloadImages();
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

  Future<void> _preloadImages() async {
    if (mounted) {
      setState(() {
        _isImagesLoaded = true;
      });

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
    return Scaffold(
      body: _isImagesLoaded
          ? ListView(
              padding: ThemeEdgeInsets.pageInsets,
              children: [
                FeaturedAppWidget(
                  slideAnimation: _featuredSlideAnimation,
                  fadeAnimation: _fadeAnimation,
                  featuredApp: featuredApp,
                ),
                const SizedBox(height: 16),
                Column(
                  children: topApps
                      .map((e) => ToppAppWidget(
                            explorerApp: e,
                            fadeAnimation: _fadeAnimation,
                            slideAnimation: _featuredSlideAnimation,
                          ))
                      .toList(),
                ),
                // ExplorerAppWidget(
                //   slideAnimation: _featuredSlideAnimation,
                //   fadeAnimation: _fadeAnimation,
                //   explorerApp: explorer,
                // ),
                const SizedBox(height: 16),
                Text(l10n.dAppPopularApps,
                    style: TextStyles.pageTitle
                        .copyWith(fontSize: ThemeFontSizes.sectionTitle)),
                PopularDAppsWidget(
                  slideAnimation: _popularSlideAnimation,
                  fadeAnimation: _popularFadeAnimation,
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

class ToppAppWidget extends StatelessWidget {
  final Animation<Offset> slideAnimation;
  final Animation<double> fadeAnimation;
  final DappDto? explorerApp;

  const ToppAppWidget({
    required this.slideAnimation,
    required this.fadeAnimation,
    required this.explorerApp,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ThemedControls.card(
        child: SlideTransition(
            position: slideAnimation,
            child: FadeTransition(
                opacity: fadeAnimation,
                child: Observer(builder: (context) {
                  return DAppTile(dApp: explorerApp!);
                }))));
  }
}
