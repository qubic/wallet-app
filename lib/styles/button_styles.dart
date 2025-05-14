import 'package:flutter/material.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';

abstract class ButtonStyles {
  static const double buttonHeight = 48;
  static ButtonStyle dangerButtonBig = ButtonStyle(
      overlayColor: WidgetStatePropertyAll<Color>(
          LightThemeColors.dangerColor.withValues(alpha: 0.2)),
      shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
          RoundedRectangleBorder(
              side: BorderSide.none,
              borderRadius: BorderRadius.circular(12.0))));

  static ButtonStyle primaryButtonBig = ButtonStyle(
      overlayColor: WidgetStatePropertyAll<Color>(
          LightThemeColors.extraStrongBackground.withValues(alpha: 0.1)),
      backgroundColor: const WidgetStatePropertyAll<Color>(
          LightThemeColors.buttonBackground),
      shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0))));

  static ButtonStyle textButtonBig = ButtonStyle(
      overlayColor: WidgetStatePropertyAll<Color>(
          LightThemeColors.buttonBackground.withValues(alpha: 0.1)),
      shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0))));

  static ButtonStyle primaryButtonBigDisabled = ButtonStyle(
      overlayColor: WidgetStatePropertyAll<Color>(
          LightThemeColors.extraStrongBackground.withValues(alpha: 0.1)),
      backgroundColor: const WidgetStatePropertyAll<Color>(
          LightThemeColors.buttonBackgroundDisabled),
      shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0))));

  static ButtonStyle secondaryButton = ButtonStyle(
      padding: WidgetStateProperty.all(EdgeInsets.zero),
      overlayColor: WidgetStatePropertyAll<Color>(
          LightThemeColors.buttonPrimary.withValues(alpha: 0.1)),
      backgroundColor: const WidgetStatePropertyAll<Color>(Color(0xff152932)),
      shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0))));

  static ButtonStyle darkButtonBig = ButtonStyle(
      overlayColor: WidgetStatePropertyAll<Color>(
          LightThemeColors.primary.withValues(alpha: 0.03)),
      backgroundColor: WidgetStatePropertyAll<Color>(
          LightThemeColors.primary.withValues(alpha: 0.2)),
      shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
          RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: const BorderSide(
                  color: LightThemeColors.darkButtonBorderColor, width: 1))));

  static ButtonStyle darkButtonBigError = ButtonStyle(
      overlayColor: WidgetStatePropertyAll<Color>(
          LightThemeColors.primary.withValues(alpha: 0.03)),
      backgroundColor: WidgetStatePropertyAll<Color>(
          LightThemeColors.primary.withValues(alpha: 0.2)),
      shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
          RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side:
                  const BorderSide(color: LightThemeColors.error, width: 1))));
}
