import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/models/dapp_model.dart';
import 'package:qubic_wallet/pages/main/tab_dapps/components/dapp_tile.dart';
import 'package:qubic_wallet/pages/main/tab_dapps/webview_screen.dart';
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
    await precacheImage(AssetImage(featuredApp.icon), context);

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
                ),
                const SizedBox(height: 16),
                ExplorerAppWidget(
                  slideAnimation: _featuredSlideAnimation,
                  fadeAnimation: _fadeAnimation,
                ),
                const SizedBox(height: 16),
                Text(l10n.dAppPopularApps, style: TextStyles.pageTitle),
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

class FeaturedAppWidget extends StatelessWidget {
  final Animation<Offset> slideAnimation;
  final Animation<double> fadeAnimation;

  const FeaturedAppWidget({
    required this.slideAnimation,
    required this.fadeAnimation,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WebviewScreen(initialUrl: featuredApp.url),
          ),
        );
      },
      child: SlideTransition(
        position: slideAnimation,
        child: FadeTransition(
          opacity: fadeAnimation,
          child: Stack(
            alignment: Alignment.center,
            children: [
              ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 1.0],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(featuredApp.icon),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: ThemePaddings.normalPadding),
                child: Column(
                  children: [
                    Text(l10n.dAppFeaturedApp, style: TextStyles.labelText),
                    ThemedControls.spacerVerticalMini(),
                    Text(
                      featuredApp.description,
                      style: TextStyles.secondaryTextSmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ExplorerAppWidget extends StatelessWidget {
  final Animation<Offset> slideAnimation;
  final Animation<double> fadeAnimation;

  const ExplorerAppWidget({
    required this.slideAnimation,
    required this.fadeAnimation,
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
                  return DAppTile(dApp: explorerApp.value);
                }))));
  }
}

class PopularDAppsWidget extends StatelessWidget {
  final Animation<Offset> slideAnimation;
  final Animation<double> fadeAnimation;

  const PopularDAppsWidget({
    required this.slideAnimation,
    required this.fadeAnimation,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ThemedControls.card(
      child: Column(
        children: List.generate(dAppsList.length, (index) {
          return SlideTransition(
            position: slideAnimation,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: DAppTile(dApp: dAppsList[index]),
            ),
          );
        }),
      ),
    );
  }
}
