import 'package:flutter/material.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
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

class _TabDAppsState extends State<TabDApps> {
  bool _isImagesLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _preloadImages();
  }

  Future<void> _preloadImages() async {
    for (var dApp in dAppsList) {
      await precacheImage(NetworkImage(dApp.icon), context);
    }
    if (mounted) {
      await precacheImage(AssetImage(featureApp.icon), context);
    }
    setState(() {
      _isImagesLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: _isImagesLoaded
          ? ListView(
              padding: ThemeEdgeInsets.pageInsets,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                WebviewScreen(initialUrl: featureApp.url)));
                  },
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
                              Colors.transparent, // Opacity 0 at the bottom
                            ],
                            stops: const [
                              0.0,
                              1.0
                            ], // Gradual transition from top to bottom
                          ).createShader(bounds);
                        },
                        blendMode: BlendMode.dstIn,
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(featureApp.icon)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: ThemePaddings.normalPadding),
                        child: Column(
                          children: [
                            Text(
                              "Featured App",
                              style: TextStyles.labelText,
                            ),
                            ThemedControls.spacerVerticalMini(),
                            Text(
                              featureApp.description,
                              style: TextStyles.secondaryTextSmall,
                              textAlign: TextAlign.center,
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Text(
                  "Popular dApps",
                  style: TextStyles.pageTitle,
                ),
                ThemedControls.card(
                  child: Column(
                    children: List.generate(dAppsList.length, (index) {
                      return DAppTile(dApp: dAppsList[index]);
                    }),
                  ),
                ),
              ],
            )
          : const Center(
              child:
                  CircularProgressIndicator()), // Show loading until images are cached
    );
  }
}
