import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:qubic_wallet/components/refresh_loading_indicator.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/stores/explorer_store.dart';

class ExplorerLoadingIndicator extends StatelessWidget {
  final ExplorerStore expStore = getIt<ExplorerStore>();

  ExplorerLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Observer(
          builder: (context) {
            if (expStore.isLoading) {
              return const RefreshLoadingIndicator();
            }
            return const SizedBox.shrink();
          },
        )
      ],
    );
  }
}
