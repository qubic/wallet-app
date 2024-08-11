import 'package:flutter/material.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';

abstract class ButtonStyles {
  static ButtonStyle dangerButtonBig = ButtonStyle(
      overlayColor: WidgetStatePropertyAll<Color>(
          LightThemeColors.dangerColor.withOpacity(0.8)),
      shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
          RoundedRectangleBorder(
              side: const BorderSide(
                  width: 1.5, color: LightThemeColors.dangerColor),
              borderRadius: BorderRadius.circular(12.0))));

  static ButtonStyle primaryButtonBig = ButtonStyle(
      overlayColor: WidgetStatePropertyAll<Color>(
          LightThemeColors.extraStrongBackground.withOpacity(0.1)),
      backgroundColor: const WidgetStatePropertyAll<Color>(
          LightThemeColors.buttonBackground),
      shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0))));

  static ButtonStyle textButtonBig = ButtonStyle(
      overlayColor: WidgetStatePropertyAll<Color>(
          LightThemeColors.buttonBackground.withOpacity(0.1)),
      shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0))));

  static ButtonStyle primaryButtonBigDisabled = ButtonStyle(
      overlayColor: WidgetStatePropertyAll<Color>(
          LightThemeColors.extraStrongBackground.withOpacity(0.1)),
      backgroundColor: const WidgetStatePropertyAll<Color>(
          LightThemeColors.buttonBackgroundDisabled),
      shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0))));

  static ButtonStyle darkButtonBig = ButtonStyle(
      overlayColor: WidgetStatePropertyAll<Color>(
          LightThemeColors.primary.withOpacity(0.03)),
      backgroundColor: WidgetStatePropertyAll<Color>(
          LightThemeColors.primary.withOpacity(0.02)),
      shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
          RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: const BorderSide(
                  color: LightThemeColors.darkButtonBorderColor, width: 1))));

  static ButtonStyle darkButtonBigError = ButtonStyle(
      overlayColor: WidgetStatePropertyAll<Color>(
          LightThemeColors.primary.withOpacity(0.03)),
      backgroundColor: WidgetStatePropertyAll<Color>(
          LightThemeColors.primary.withOpacity(0.02)),
      shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
          RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side:
                  const BorderSide(color: LightThemeColors.error, width: 1))));
}
