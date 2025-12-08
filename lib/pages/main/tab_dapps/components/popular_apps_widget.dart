import 'package:flutter/material.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/pages/main/tab_dapps/components/dapp_tile.dart';
import 'package:qubic_wallet/stores/wallet_content_store.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

class PopularDAppsWidget extends StatelessWidget {
  final Animation<Offset> slideAnimation;
  final Animation<double> fadeAnimation;
  final VoidCallback? onDappReturn;

  const PopularDAppsWidget({
    required this.slideAnimation,
    required this.fadeAnimation,
    this.onDappReturn,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final walletStore = getIt<WalletContentStore>();

    return ThemedControls.card(
      child: Column(
        children:
            List.generate(walletStore.popularDapps.length * 2 - 1, (index) {
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
                dApp: walletStore.popularDapps[itemIndex],
                onReturn: onDappReturn,
              ),
            ),
          );
        }),
      ),
    );
  }
}
