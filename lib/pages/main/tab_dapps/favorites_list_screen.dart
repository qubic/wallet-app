import 'package:flutter/material.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/dapp_helpers.dart';
import 'package:qubic_wallet/helpers/global_snack_bar.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/models/favorite_dapp.dart';
import 'package:qubic_wallet/pages/main/tab_dapps/components/add_to_favorites_dialog.dart';
import 'package:qubic_wallet/pages/main/tab_dapps/components/dapp_list_tile.dart';
import 'package:qubic_wallet/resources/hive_storage.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

class FavoritesListScreen extends StatefulWidget {
  const FavoritesListScreen({super.key});

  @override
  State<FavoritesListScreen> createState() => _FavoritesListScreenState();
}

class _FavoritesListScreenState extends State<FavoritesListScreen> {
  final HiveStorage _hiveStorage = getIt<HiveStorage>();
  final GlobalSnackBar _globalSnackBar = getIt<GlobalSnackBar>();
  late List<FavoriteDappModel> _favorites;

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

  void _removeFavorite(FavoriteDappModel favorite) {
    _hiveStorage.removeFavoriteDapp(favorite.url);
    _loadFavorites();
    _globalSnackBar.show(l10nOf(context).favoriteRemoved);
  }

  void _openFavorite(FavoriteDappModel favorite) async {
    await openDappUrl(context, favorite.url);
    // Refresh the favorites list when returning from webview
    if (mounted) {
      _loadFavorites();
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
                  ThemedControls.spacerVerticalSmall(),
                  Text(
                    l10n.favoritesEmptyDescription,
                    style: TextStyles.secondaryText,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: ThemePaddings.smallPadding),
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
                  child: DappListTile(
                    name: favorite.name,
                    subtitle: favorite.url,
                    iconUrl: favorite.iconUrl,
                    onTap: () => _openFavorite(favorite),
                  ),
                );
              },
            ),
    );
  }
}
