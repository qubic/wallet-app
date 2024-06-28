import 'package:flutter/material.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/styles/textStyles.dart';

abstract class ButtonStyles {
  static ButtonStyle dangerButtonBig = ButtonStyle(
      overlayColor: MaterialStatePropertyAll<Color>(
          LightThemeColors.dangerColor.withOpacity(0.8)),
      shape: MaterialStatePropertyAll<RoundedRectangleBorder>(
          RoundedRectangleBorder(
              side: const BorderSide(
                  width: 1.5, color: LightThemeColors.dangerColor),
              borderRadius: BorderRadius.circular(12.0))));

  static ButtonStyle primaryButtonBig = ButtonStyle(
      overlayColor: MaterialStatePropertyAll<Color>(
          LightThemeColors.extraStrongBackground.withOpacity(0.1)),
      backgroundColor: const MaterialStatePropertyAll<Color>(
          LightThemeColors.buttonBackground),
      shape: MaterialStatePropertyAll<RoundedRectangleBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0))));

  static ButtonStyle textButtonBig = ButtonStyle(
      overlayColor: MaterialStatePropertyAll<Color>(
          LightThemeColors.buttonBackground.withOpacity(0.1)),
      shape: MaterialStatePropertyAll<RoundedRectangleBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0))));

  static ButtonStyle primaryButtonBigDisabled = ButtonStyle(
      overlayColor: MaterialStatePropertyAll<Color>(
          LightThemeColors.extraStrongBackground.withOpacity(0.1)),
      backgroundColor: const MaterialStatePropertyAll<Color>(
          LightThemeColors.buttonBackgroundDisabled),
      shape: MaterialStatePropertyAll<RoundedRectangleBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0))));
}
