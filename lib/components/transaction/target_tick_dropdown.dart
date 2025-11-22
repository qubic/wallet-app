import 'package:flutter/material.dart';
import 'package:qubic_wallet/helpers/target_tick.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

/// Reusable dropdown widget for selecting target tick type in transaction screens
class TargetTickDropdown extends StatelessWidget {
  final TargetTickTypeEnum value;
  final ValueChanged<TargetTickTypeEnum?> onChanged;
  final bool isEnabled;

  const TargetTickDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.isEnabled = true,
  });

  List<DropdownMenuItem<TargetTickTypeEnum>> _getTickList(BuildContext context) {
    final l10n = l10nOf(context);

    return TargetTickTypeEnum.values.map((targetTickType) {
      return DropdownMenuItem<TargetTickTypeEnum>(
        value: targetTickType,
        child: Text(
          targetTickType == TargetTickTypeEnum.manual
              ? l10n.sendItemLabelTargetTickManual
              : l10n.sendItemLabelTargetTickAutomatic(targetTickType.value),
          style: TextStyles.inputBoxSmallStyle,
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ThemedControls.dropdown<TargetTickTypeEnum>(
      value: value,
      onChanged: onChanged,
      items: _getTickList(context),
    );
  }
}
