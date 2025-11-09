import 'package:flutter/material.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/pages/main/tab_dapps/components/dapp_tile.dart';
import 'package:qubic_wallet/stores/wallet_content_store.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

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
    final walletStore = getIt<WalletContentStore>();

    return ThemedControls.card(
      child: Column(
        children: List.generate(walletStore.popularDapps.length, (index) {
          return SlideTransition(
            position: slideAnimation,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: DAppTile(
                dApp: walletStore.popularDapps[index],
              ),
            ),
          );
        }),
      ),
    );
  }
}
