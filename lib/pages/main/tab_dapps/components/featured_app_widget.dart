import 'package:flutter/material.dart';
import 'package:qubic_wallet/dtos/dapp_dto.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/pages/main/tab_dapps/webview_screen.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

class FeaturedAppWidget extends StatelessWidget {
  final Animation<Offset> slideAnimation;
  final Animation<double> fadeAnimation;
  final DappDto? featuredApp;

  const FeaturedAppWidget({
    required this.slideAnimation,
    required this.fadeAnimation,
    required this.featuredApp,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return GestureDetector(
      onTap: () {
        if (featuredApp?.url != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  WebviewScreen(initialUrl: featuredApp!.url!),
            ),
          );
        }
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
                  child: Image.asset("assets/images/featured.jpg"),
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
                      featuredApp?.description ?? "-",
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
