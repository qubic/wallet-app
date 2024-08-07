import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/pages/auth/import_private_seed.dart';
import 'package:qubic_wallet/pages/auth/import_vault_file.dart';

import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/styles/edgeInsets.dart';
import 'package:qubic_wallet/styles/textStyles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

class ImportSelector extends StatefulWidget {
  const ImportSelector({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ImportSelectorState createState() => _ImportSelectorState();
}

class _ImportSelectorState extends State<ImportSelector> {
  bool isLoading = false; //Is the form loading

  final ApplicationStore appStore = getIt<ApplicationStore>();
  bool obscuringTextPass = true; //Hide password text
  bool obscuringTextPassRepeat = true; //Hide password repeat text

  int? selectedImportType =
      0; //0 = no option, 1 vault file, 2 seed, null = no option

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget getSelectionButton(Function? onPressed, String assetPath, String title,
      String subtitle, bool hasError) {
    return ThemedControls.darkButtonBigWithChild(
        error: hasError,
        onPressed: () async {
          if (onPressed != null) {
            await onPressed();
          }
        },
        child: Padding(
            padding: const EdgeInsets.all(ThemePaddings.normalPadding),
            child: Flex(
                direction: Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(assetPath),
                  ThemedControls.spacerHorizontalNormal(),
                  Expanded(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: TextStyles.textBold),
                          ThemedControls.spacerVerticalSmall(),
                          Container(
                              child: Text(subtitle,
                                  style: TextStyles.secondaryText))
                        ]),
                  )
                ])));
  }

  //Gets the container scroll view
  Widget getScrollView() {
    final l10n = l10nOf(context);

    return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Row(children: [
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ThemedControls.pageHeader(
                  headerText: l10n.importWalletTitle, subheaderText: ""),
              Text(l10n.importWalletSubHeader, style: TextStyles.secondaryText),
              ThemedControls.spacerVerticalNormal(),
              getSelectionButton(() {
                pushScreen(
                  context,
                  screen: const ImportVaultFile(),
                  withNavBar: false, // OPTIONAL VALUE. True by default.
                  pageTransitionAnimation: PageTransitionAnimation.cupertino,
                );
              },
                  "assets/images/import-vault-file.png",
                  l10n.importWalletLabelFromVaultFile,
                  l10n.importWalletLabelFromVaultFileDescription,
                  false),
              ThemedControls.spacerVerticalNormal(),
              getSelectionButton(() {
                pushScreen(
                  context,
                  screen: const ImportPrivateSeed(),
                  withNavBar: false, // OPTIONAL VALUE. True by default.
                  pageTransitionAnimation: PageTransitionAnimation.cupertino,
                );
              },
                  "assets/images/import-private-seed.png",
                  l10n.importWalletLabelFromPrivateSeed,
                  l10n.importWalletLabelFromPrivateSeedDescription,
                  false),
            ],
          ))
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: !isLoading,
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
            ),
            body: Padding(
              padding: ThemeEdgeInsets.pageInsets,
              child: Column(children: [
                Expanded(child: getScrollView()),
              ]),
            )));
  }
}
