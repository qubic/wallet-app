import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/dtos/dapp_dto.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/dapp_helpers.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/pages/main/tab_dapps/components/dapp_icon.dart';
import 'package:qubic_wallet/pages/main/tab_dapps/components/dapp_list_tile.dart';
import 'package:qubic_wallet/pages/main/tab_dapps/components/dapp_tile.dart';
import 'package:qubic_wallet/pages/main/tab_dapps/components/popular_apps_widget.dart';
import 'package:qubic_wallet/pages/main/tab_dapps/favorites_list_screen.dart';
import 'package:qubic_wallet/resources/hive_storage.dart';
import 'package:qubic_wallet/styles/input_decorations.dart';
import 'package:qubic_wallet/stores/wallet_content_store.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

class TabDApps extends StatefulWidget {
  const TabDApps({super.key});

  @override
  State<TabDApps> createState() => _TabDAppsState();
}

class _TabDAppsState extends State<TabDApps> with TickerProviderStateMixin {
  bool _isFirst = true;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final GlobalKey _searchFieldKey = GlobalKey();
  bool _isSearchActive = false;
  String _searchQuery = '';

  final walletStore = getIt<WalletContentStore>();

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

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchQueryChange);
    _searchFocusNode.addListener(_onSearchFocusChange);
  }

  void _onSearchQueryChange() {
    setState(() {
      _searchQuery = _searchController.text;
      // Update search active state based on focus or text
      _isSearchActive = _searchFocusNode.hasFocus || _searchQuery.isNotEmpty;
    });
  }

  void _onSearchFocusChange() {
    setState(() {
      // Show search overlay when focused or has text
      _isSearchActive = _searchFocusNode.hasFocus || _searchQuery.isNotEmpty;
    });
  }

  void _initializeFeaturedAnimations() {
    _featuredController = AnimationController(
      vsync: this,
      duration: Duration.zero, // No animation
    );

    _featuredSlideAnimation = Tween<Offset>(
      begin: Offset.zero, // Start at final position
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _featuredController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 1.0, // Start fully visible
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _featuredController,
      curve: Curves.easeIn,
    ));
  }

  void _initializePopularAnimations() {
    _popularController = AnimationController(
      vsync: this,
      duration: Duration.zero, // No animation
    );

    _popularSlideAnimation = Tween<Offset>(
      begin: Offset.zero, // Start at final position
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _popularController,
      curve: Curves.easeOutCubic,
    ));

    _popularFadeAnimation = Tween<double>(
      begin: 1.0, // Start fully visible
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
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Map<String, List<Map<String, dynamic>>> _getSearchResults() {
    if (_searchQuery.isEmpty) return {};

    final query = _searchQuery.toLowerCase();
    final results = <String, List<Map<String, dynamic>>>{};
    final hiveStorage = getIt<HiveStorage>();

    // Search in favorites
    final favoriteResults = <Map<String, dynamic>>[];
    final favorites = hiveStorage.getFavoriteDapps();
    for (final favorite in favorites) {
      // Search in both name and URL
      if (favorite.name.toLowerCase().contains(query) ||
          favorite.url.toLowerCase().contains(query)) {
        favoriteResults.add({
          'type': 'favorite',
          'name': favorite.name,
          'url': favorite.url,
          'icon': favorite.iconUrl,
          'description': extractDomain(favorite.url),
        });
      }
    }
    if (favoriteResults.isNotEmpty) {
      results['favorites'] = favoriteResults;
    }

    // Search in top dApps (Qubic Apps)
    final qubicAppResults = <Map<String, dynamic>>[];
    for (final dapp in walletStore.topDapps) {
      if (dapp.url != null &&
          dapp.name != null &&
          (dapp.name!.toLowerCase().contains(query) ||
              dapp.url!.toLowerCase().contains(query))) {
        qubicAppResults.add({
          'type': 'qubic_app',
          'name': dapp.name,
          'url': dapp.url,
          'icon': dapp.icon,
          'description': dapp.description,
        });
      }
    }
    if (qubicAppResults.isNotEmpty) {
      results['qubic_apps'] = qubicAppResults;
    }

    // Search in popular dApps
    final popularAppResults = <Map<String, dynamic>>[];
    for (final dapp in walletStore.popularDapps) {
      if (dapp.url != null &&
          dapp.name != null &&
          (dapp.name!.toLowerCase().contains(query) ||
              dapp.url!.toLowerCase().contains(query))) {
        popularAppResults.add({
          'type': 'popular_app',
          'name': dapp.name,
          'url': dapp.url,
          'icon': dapp.icon,
          'description': dapp.description,
        });
      }
    }
    if (popularAppResults.isNotEmpty) {
      results['popular_apps'] = popularAppResults;
    }

    // Always add Google search option at the end
    results['google'] = [
      {
        'type': 'google',
        'name': _searchQuery,
        'url':
            'https://www.google.com/search?q=${Uri.encodeComponent(_searchQuery)}',
      }
    ];

    return results;
  }

  void _navigateToFavorites() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FavoritesListScreen()),
    );
    // Refresh the favorites list when returning from the favorites screen
    if (mounted) {
      setState(() {});
    }
  }

  void _handleResultTap(Map<String, dynamic> result) async {
    final url = result['url'] as String;

    final opened = await openDappUrl(context, url);

    // Clear search only if webview was actually opened
    if (mounted && opened) {
      _searchFocusNode.unfocus();
      _searchController.clear();
      setState(() {});
    }
  }

  Widget _buildSearchResultsOverlay() {
    final l10n = l10nOf(context);
    final results = _getSearchResults();

    // Show helpful message if user hasn't typed anything yet
    if (_searchQuery.isEmpty) {
      return Container(
        color: LightThemeColors.background,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(ThemePaddings.hugePadding),
            child: Text(
              l10n.dAppSearchEmptyState,
              style: TextStyles.secondaryText,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Container(
      color: LightThemeColors.background,
      child: ListView(
        padding: const EdgeInsets.only(top: ThemePaddings.smallPadding),
        children: [
          // Favorites section
          if (results.containsKey('favorites')) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                ThemePaddings.normalPadding,
                ThemePaddings.normalPadding,
                ThemePaddings.normalPadding,
                ThemePaddings.smallPadding,
              ),
              child: Text(
                l10n.favoritesTitle,
                style: TextStyles.labelText,
              ),
            ),
            ...results['favorites']!.map((result) => _buildResultTile(result)),
          ],

          // Qubic Apps section
          if (results.containsKey('qubic_apps')) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                ThemePaddings.normalPadding,
                ThemePaddings.normalPadding,
                ThemePaddings.normalPadding,
                ThemePaddings.smallPadding,
              ),
              child: Text(
                l10n.dAppQubicApps,
                style: TextStyles.labelText,
              ),
            ),
            ...results['qubic_apps']!.map((result) => _buildResultTile(result)),
          ],

          // Popular Apps section
          if (results.containsKey('popular_apps')) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                ThemePaddings.normalPadding,
                ThemePaddings.normalPadding,
                ThemePaddings.normalPadding,
                ThemePaddings.smallPadding,
              ),
              child: Text(
                l10n.dAppPopularApps,
                style: TextStyles.labelText,
              ),
            ),
            ...results['popular_apps']!
                .map((result) => _buildResultTile(result)),
          ],

          // Google Search section
          if (results.containsKey('google')) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                ThemePaddings.normalPadding,
                ThemePaddings.normalPadding,
                ThemePaddings.normalPadding,
                ThemePaddings.smallPadding,
              ),
              child: Text(
                l10n.dAppSearchInGoogle,
                style: TextStyles.labelText,
              ),
            ),
            ...results['google']!
                .map((result) => _buildGoogleSearchTile(result)),
          ],
        ],
      ),
    );
  }

  Widget _buildGoogleSearchTile(Map<String, dynamic> result) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: ThemePaddings.normalPadding,
        vertical: ThemePaddings.smallPadding,
      ),
      leading: Container(
        width: 40,
        height: 40,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: SvgPicture.asset('assets/icons/google.svg'),
      ),
      title: Text(
        '"${result['name']}"',
        style: TextStyles.labelText.copyWith(height: 1.2),
      ),
      onTap: () => _handleResultTap(result),
    );
  }

  Widget _buildResultTile(Map<String, dynamic> result) {
    return DappListTile(
      name: result['name'],
      subtitle: result['description'] ?? '',
      iconUrl: result['icon'],
      onTap: () => _handleResultTap(result),
    );
  }

  Widget _buildSearchField(AppLocalizations l10n,
      {required bool showCloseButton}) {
    return Padding(
      key: _searchFieldKey,
      padding: const EdgeInsets.fromLTRB(
          ThemePaddings.normalPadding,
          ThemePaddings.smallPadding,
          ThemePaddings.normalPadding,
          ThemePaddings.smallPadding),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        style: TextStyles.textNormal,
        decoration: ThemeInputDecorations.normalInputbox.copyWith(
          hintText: l10n.dAppSearchPlaceholder,
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: showCloseButton
              ? IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    _searchFocusNode.unfocus();
                  },
                )
              : null,
        ),
        onSubmitted: (_) {
          // Just dismiss keyboard when Done/Return is pressed
          _searchFocusNode.unfocus();
        },
      ),
    );
  }

  Widget _buildFavoritesSection(AppLocalizations l10n) {
    final hiveStorage = getIt<HiveStorage>();
    final favorites = hiveStorage.getFavoriteDapps();

    if (favorites.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: ThemePaddings.smallPadding + ThemePaddings.normalPadding,
            right: ThemePaddings.smallPadding,
          ),
          child: Text(
            l10n.favoritesTitle,
            style: TextStyles.labelText,
          ),
        ),
        const SizedBox(height: ThemePaddings.normalPadding),
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: ThemePaddings.smallPadding),
          child: SizedBox(
            height: 95,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: favorites.length + 1,
              itemBuilder: (context, index) {
                if (index == favorites.length) {
                  // "View All" button
                  return GestureDetector(
                    onTap: _navigateToFavorites,
                    child: Container(
                      width: 60,
                      margin: const EdgeInsets.only(
                          right: ThemePaddings.smallPadding),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: LightThemeColors.primary
                                    .withValues(alpha: 0.08),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: ThemedControls.chevronIcon,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final favorite = favorites[index];
                return GestureDetector(
                  onTap: () async {
                    await openDappUrl(context, favorite.url);
                    // Refresh the favorites list when returning from webview
                    setState(() {});
                  },
                  child: Container(
                    width: 60,
                    margin: const EdgeInsets.only(
                        right: ThemePaddings.smallPadding),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: Center(
                            child: DappIcon(
                              iconUrl: favorite.iconUrl,
                              size: Config.dAppIconSize,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          favorite.name,
                          style: TextStyles.secondaryTextSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTabExplore, style: TextStyles.textExtraLargeBold),
        centerTitle: true,
        backgroundColor: LightThemeColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onOpened: () {
              // Exit search mode when menu is opened
              _searchController.clear();
              _searchFocusNode.unfocus();
            },
            onSelected: (value) {
              if (value == 'favorites') {
                _navigateToFavorites();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'favorites',
                child: Row(
                  children: [
                    const Icon(Icons.star_border, size: 20),
                    const SizedBox(width: 12),
                    Text(l10n.favoritesTitle),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        color: LightThemeColors.background,
        // Observer watches walletStore for changes and rebuilds when state updates
        child: Observer(builder: (context) {
          // State 1: Error state (network failure, API error, etc.)
          // Shows error message with retry button
          if (walletStore.error != null) {
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
                        walletStore.loadDapps();
                      },
                      text: l10n.generalButtonTryAgain)
                ],
              ),
            );
          }
          // State 2: Loading state (initial load or refresh)
          // Shows spinner while fetching dApp data from API
          else if (walletStore.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // State 3: Normal/Success state (data loaded, no errors)
          // This is the primary UI state where users spend most of their time
          // Toggles between search mode and browse mode based on _isSearchActive
          return _isSearchActive
              // Search mode: User has focused the search field or entered text
              // Shows search results overlay with close button
              ? Column(
                  children: [
                    _buildSearchField(l10n, showCloseButton: true),
                    Expanded(child: _buildSearchResultsOverlay()),
                  ],
                )
              // Browse mode: Default state showing all dApp categories
              // Displays favorites, Qubic apps, and popular apps
              : ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildSearchField(l10n, showCloseButton: false),
                    const SizedBox(height: 16),
                    // Favorites Section
                    _buildFavoritesSection(l10n),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: ThemePaddings.smallPadding +
                            ThemePaddings.normalPadding,
                        right: ThemePaddings.smallPadding,
                      ),
                      child: Text(
                        l10n.dAppQubicApps,
                        style: TextStyles.labelText,
                      ),
                    ),
                    const SizedBox(height: ThemePaddings.normalPadding),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: ThemePaddings.smallPadding),
                      child: TopDAppsWidget(
                        topDApps: walletStore.topDapps,
                        fadeAnimation: _fadeAnimation,
                        slideAnimation: _featuredSlideAnimation,
                        onDappReturn: () {
                          setState(() {});
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: ThemePaddings.smallPadding +
                            ThemePaddings.normalPadding,
                        right: ThemePaddings.smallPadding,
                      ),
                      child: Text(l10n.dAppPopularApps,
                          style: TextStyles.labelText),
                    ),
                    const SizedBox(height: ThemePaddings.normalPadding),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: ThemePaddings.smallPadding),
                      child: PopularDAppsWidget(
                        slideAnimation: _popularSlideAnimation,
                        fadeAnimation: _popularFadeAnimation,
                        onDappReturn: () {
                          setState(() {});
                        },
                      ),
                    ),
                    const SizedBox(height: ThemePaddings.hugePadding),
                  ],
                );
        }),
      ),
    );
  }
}

class TopDAppsWidget extends StatelessWidget {
  final Animation<Offset> slideAnimation;
  final Animation<double> fadeAnimation;
  final List<DappDto> topDApps;
  final VoidCallback? onDappReturn;

  const TopDAppsWidget({
    required this.slideAnimation,
    required this.fadeAnimation,
    required this.topDApps,
    this.onDappReturn,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ThemedControls.card(
      child: Column(
        children: List.generate(topDApps.length * 2 - 1, (index) {
          if (index.isOdd) {
            // Add spacing between items to match card padding
            return const SizedBox(height: ThemePaddings.smallPadding);
          }
          final itemIndex = index ~/ 2;
          return SlideTransition(
            position: slideAnimation,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: DAppTile(
                dApp: topDApps[itemIndex],
                onReturn: onDappReturn,
              ),
            ),
          );
        }),
      ),
    );
  }
}
