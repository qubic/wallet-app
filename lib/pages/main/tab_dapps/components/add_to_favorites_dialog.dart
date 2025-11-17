import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/dapp_helpers.dart';
import 'package:qubic_wallet/helpers/global_snack_bar.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/models/favorite_dapp.dart';
import 'package:qubic_wallet/resources/hive_storage.dart';
import 'package:qubic_wallet/styles/input_decorations.dart';
import 'package:qubic_wallet/styles/text_styles.dart';

class AddToFavoritesDialog extends StatefulWidget {
  final String url;
  final String? initialName;
  final String? iconUrl;

  const AddToFavoritesDialog({
    super.key,
    required this.url,
    this.initialName,
    this.iconUrl,
  });

  @override
  State<AddToFavoritesDialog> createState() => _AddToFavoritesDialogState();
}

class _AddToFavoritesDialogState extends State<AddToFavoritesDialog> {
  final _formKey = GlobalKey<FormBuilderState>();
  final HiveStorage _hiveStorage = getIt<HiveStorage>();
  final GlobalSnackBar _globalSnackBar = getIt<GlobalSnackBar>();
  late TextEditingController _nameController;
  late TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _urlController = TextEditingController(text: widget.url);

    // Prevent deletion of https:// prefix
    _urlController.addListener(() {
      final text = _urlController.text;
      if (!text.startsWith('https://')) {
        _urlController.value = const TextEditingValue(
          text: 'https://',
          selection: TextSelection.collapsed(offset: 8),
        );
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _saveFavorite() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final values = _formKey.currentState!.value;
      final name = values['name'] as String;
      final url = values['url'] as String;

      // Find the best icon based on priority:
      // 1. Same host as existing app in wallet store
      // 2. Page icon if available
      // 3. Default icon (null)
      final iconUrl = findFavoriteIcon(url.trim(), widget.iconUrl);

      final favorite = FavoriteDapp(
        name: name.trim(),
        url: url.trim(),
        createdAt: DateTime.now(),
        iconUrl: iconUrl,
      );

      _hiveStorage.addFavoriteDapp(favorite);
      Navigator.of(context).pop(true);
      _globalSnackBar.show(l10nOf(context).favoriteAddedSuccessfully);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);

    return AlertDialog(
      title: Text(
        l10n.addToFavorites,
        style: TextStyles.alertHeader,
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        child: FormBuilder(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.favoriteNameLabel,
                style: TextStyles.labelText,
              ),
              const SizedBox(height: ThemePaddings.miniPadding),
              FormBuilderTextField(
                name: 'name',
                controller: _nameController,
                decoration: ThemeInputDecorations.normalInputbox.copyWith(
                  hintText: l10n.favoriteNameHint,
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(
                    errorText: l10n.favoriteNameRequired,
                  ),
                  FormBuilderValidators.maxLength(
                    50,
                    errorText: l10n.favoriteNameTooLong,
                  ),
                  (value) {
                    if (value == null || value.isEmpty) return null;
                    final favorites = _hiveStorage.getFavoriteDapps();
                    final isDuplicate = favorites.any(
                      (fav) => fav.name.toLowerCase() == value.trim().toLowerCase(),
                    );
                    if (isDuplicate) {
                      return l10n.favoriteNameAlreadyInUse;
                    }
                    return null;
                  },
                ]),
              ),
              const SizedBox(height: ThemePaddings.normalPadding),
              Text(
                l10n.favoriteUrlLabel,
                style: TextStyles.labelText,
              ),
              const SizedBox(height: ThemePaddings.miniPadding),
              FormBuilderTextField(
                name: 'url',
                controller: _urlController,
                decoration: ThemeInputDecorations.normalInputbox.copyWith(
                  hintText: 'https://example.com',
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(
                    errorText: l10n.favoriteUrlRequired,
                  ),
                  (value) {
                    if (value == null || value.isEmpty) return null;
                    final urlPattern = RegExp(
                      r'^https:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
                    );
                    if (!urlPattern.hasMatch(value.trim())) {
                      return l10n.favoriteUrlInvalid;
                    }
                    return null;
                  },
                ]),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            l10n.generalButtonCancel,
            style: TextStyles.secondaryText,
          ),
        ),
        FilledButton(
          onPressed: _saveFavorite,
          child: Text(l10n.generalButtonSave),
        ),
      ],
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
    );
  }
}
