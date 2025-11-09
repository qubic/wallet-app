import 'package:flutter/material.dart';
import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/dapp_helpers.dart';
import 'package:qubic_wallet/helpers/global_snack_bar.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/models/favorite_dapp.dart';
import 'package:qubic_wallet/pages/main/tab_dapps/components/add_to_favorites_dialog.dart';
import 'package:qubic_wallet/resources/hive_storage.dart';
import 'package:qubic_wallet/styles/edge_insets.dart';
import 'package:qubic_wallet/styles/text_styles.dart';

class FavoritesListScreen extends StatefulWidget {
  const FavoritesListScreen({super.key});

  @override
  State<FavoritesListScreen> createState() => _FavoritesListScreenState();
}

class _FavoritesListScreenState extends State<FavoritesListScreen> {
  final HiveStorage _hiveStorage = getIt<HiveStorage>();
  final GlobalSnackBar _globalSnackBar = getIt<GlobalSnackBar>();
  late List<FavoriteDapp> _favorites;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() {
    setState(() {
      _favorites = _hiveStorage.getFavoriteDapps();
    });
  }

  void _removeFavorite(FavoriteDapp favorite) {
    _hiveStorage.removeFavoriteDapp(favorite.url);
    _loadFavorites();
    _globalSnackBar.show(l10nOf(context).favoriteRemoved);
  }

  void _openFavorite(FavoriteDapp favorite) async {
    await openDappUrl(context, favorite.url);
    // Refresh the favorites list when returning from webview
    if (mounted) {
      setState(() {});
    }
  }

  void _showAddFavoriteDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const AddToFavoritesDialog(
        url: '',
        initialName: '',
      ),
    );
    if (result == true) {
      _loadFavorites();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.favoritesTitle, style: TextStyles.textExtraLargeBold),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: LightThemeColors.primary),
            onPressed: _showAddFavoriteDialog,
          ),
        ],
      ),
      body: _favorites.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.favoritesEmpty,
                    style: TextStyles.textLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.favoritesEmptyDescription,
                    style: TextStyles.secondaryText,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: ThemeEdgeInsets.pageInsets,
              itemCount: _favorites.length,
              itemBuilder: (context, index) {
                final favorite = _favorites[index];
                return Dismissible(
                  key: Key(favorite.url),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    _removeFavorite(favorite);
                  },
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: Colors.red,
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: ThemePaddings.normalPadding,
                      vertical: ThemePaddings.smallPadding,
                    ),
                    leading: SizedBox(
                      width: Config.dAppIconSize,
                      height: Config.dAppIconSize,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: favorite.iconUrl != null && favorite.iconUrl!.isNotEmpty
                            ? Image.network(
                                favorite.iconUrl!,
                                width: Config.dAppIconSize,
                                height: Config.dAppIconSize,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    Config.dAppDefaultImageName,
                                    width: Config.dAppIconSize,
                                    height: Config.dAppIconSize,
                                    fit: BoxFit.cover,
                                  );
                                },
                              )
                            : Image.asset(
                                Config.dAppDefaultImageName,
                                width: Config.dAppIconSize,
                                height: Config.dAppIconSize,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          favorite.name,
                          style: TextStyles.labelText.copyWith(height: 1.2),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          favorite.url,
                          style: TextStyles.smallInfoText.copyWith(height: 1.2),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _openFavorite(favorite),
                  ),
                );
              },
            ),
    );
  }
}
