import 'package:flutter/material.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';

class RefreshLoadingIndicator extends StatelessWidget {
  const RefreshLoadingIndicator({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
        width: 10,
        height: 10,
        child: CircularProgressIndicator(
            strokeWidth: 2, color: LightThemeColors.buttonBackground));
  }
}
