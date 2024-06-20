import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';

class GradientContainer extends StatelessWidget {
  final Widget? child;
  GradientContainer({
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        child: this.child != null ? this.child : Container(),
        constraints: const BoxConstraints.expand(),
        decoration: BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment(-1.0, 0.0),
          end: Alignment(1.0, 0.0),
          transform: GradientRotation(2.19911),
          stops: [
            0.03,
            1,
          ],
          colors: [
            Color.fromARGB(255, 12, 19, 27),
            Color.fromARGB(255, 12, 19, 27)
            //LightThemeColors.color1,
            //LightThemeColors.color1,
            //LightThemeColors.gradient1,
            //LightThemeColors.gradient2.darken()
          ],
        )));
  }
}
