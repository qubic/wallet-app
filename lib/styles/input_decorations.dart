import 'package:flutter/material.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';

abstract class ThemeInputDecorations {
  static InputDecoration dropdownBox = InputDecoration(
    contentPadding:
        const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 20),
    hoverColor: LightThemeColors.primary.withValues(alpha: 0.01),
    errorStyle: const TextStyle(
        color: LightThemeColors.error,
        fontSize: ThemeFontSizes.small,
        fontWeight: FontWeight.normal),
    enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: LightThemeColors.inputBorderColor)),
    focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: LightThemeColors.inputBorderColor)),
    border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: LightThemeColors.inputBorderColor)),
    errorBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        borderSide:
            BorderSide(color: LightThemeColors.error.withValues(alpha: 0.5))),
    focusedErrorBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        borderSide:
            BorderSide(color: LightThemeColors.error.withValues(alpha: 0.5))),
    disabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: LightThemeColors.inputBorderColor)),
    filled: true,
    hintStyle: TextStyle(
        color: LightThemeColors.primary.withValues(alpha: 0.4),
        fontSize: ThemeFontSizes.label),
    fillColor: Colors.transparent,
  );

  static InputDecoration bigInputbox = InputDecoration(
    contentPadding:
        const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 20),
    hoverColor: LightThemeColors.primary.withValues(alpha: 0.01),
    errorStyle: const TextStyle(
        color: LightThemeColors.error,
        fontSize: ThemeFontSizes.small,
        fontWeight: FontWeight.normal),
    enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: LightThemeColors.inputBorderColor)),
    focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: LightThemeColors.inputBorderColor)),
    border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: LightThemeColors.inputBorderColor)),
    errorBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        borderSide:
            BorderSide(color: LightThemeColors.error.withValues(alpha: 0.5))),
    focusedErrorBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        borderSide:
            BorderSide(color: LightThemeColors.error.withValues(alpha: 0.5))),
    disabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: LightThemeColors.inputBorderColor)),
    filled: true,
    hintStyle: const TextStyle(
        color: LightThemeColors.inputFieldHint, fontSize: ThemeFontSizes.label),
    fillColor: LightThemeColors.inputFieldBg,
  );

  static InputDecoration normalInputbox = InputDecoration(
    contentPadding:
        const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 10),
    hoverColor: LightThemeColors.primary.withValues(alpha: 0.01),
    errorStyle: const TextStyle(
        color: LightThemeColors.error,
        fontSize: ThemeFontSizes.small,
        fontWeight: FontWeight.normal),
    enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: LightThemeColors.inputBorderColor)),
    focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: LightThemeColors.inputBorderColor)),
    border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: LightThemeColors.inputBorderColor)),
    errorBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        borderSide:
            BorderSide(color: LightThemeColors.error.withValues(alpha: 0.5))),
    focusedErrorBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        borderSide:
            BorderSide(color: LightThemeColors.error.withValues(alpha: 0.5))),
    disabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: LightThemeColors.inputBorderColor)),
    filled: true,
    hintStyle: const TextStyle(
        color: LightThemeColors.inputFieldHint, fontSize: ThemeFontSizes.label),
    fillColor: LightThemeColors.inputFieldBg,
  );

  static InputDecoration normalMultiLineInputbox = InputDecoration(
    contentPadding:
        const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
    hoverColor: LightThemeColors.primary.withValues(alpha: 0.01),
    errorStyle: const TextStyle(
        color: LightThemeColors.error,
        fontSize: ThemeFontSizes.small,
        fontWeight: FontWeight.normal),
    enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: LightThemeColors.inputBorderColor)),
    focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: LightThemeColors.inputBorderColor)),
    border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: LightThemeColors.inputBorderColor)),
    errorBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        borderSide:
            BorderSide(color: LightThemeColors.error.withValues(alpha: 0.5))),
    focusedErrorBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        borderSide:
            BorderSide(color: LightThemeColors.error.withValues(alpha: 0.5))),
    disabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(2)),
        borderSide: BorderSide(color: LightThemeColors.inputBorderColor)),
    filled: true,
    hintStyle: const TextStyle(
        color: LightThemeColors.inputFieldHint, fontSize: ThemeFontSizes.label),
    fillColor: LightThemeColors.inputFieldBg,
  );
}
