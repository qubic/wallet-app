import 'package:flutter/material.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';

class GradientContainer extends StatelessWidget {
  final Widget? child;
  const GradientContainer({
    super.key,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment(-1.0, 0.0),
          end: Alignment(1.0, 0.0),
          transform: GradientRotation(2.19911),
          stops: [
            0.03,
            1,
          ],
          colors: [
            LightThemeColors.background,
            LightThemeColors.background
            //LightThemeColors.color1,
            //LightThemeColors.color1,
            //LightThemeColors.gradient1,
            //LightThemeColors.gradient2.darken()
          ],
        )),
        child: child ?? Container());
  }
}
