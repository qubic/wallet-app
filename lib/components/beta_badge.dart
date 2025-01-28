import 'package:flutter/material.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';

class BetaBadge extends StatelessWidget {
  const BetaBadge({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Badge(
      backgroundColor: LightThemeColors.warning10,
      label: Text("BETA", style: TextStyle(fontSize: 10)),
    );
  }
}
