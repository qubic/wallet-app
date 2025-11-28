import 'package:flutter/material.dart';
import 'package:qubic_wallet/components/transaction/manual_tick_input.dart';
import 'package:qubic_wallet/components/transaction/target_tick_dropdown.dart';
import 'package:qubic_wallet/helpers/target_tick.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

/// Complete advanced options section for transaction screens
/// Combines target tick type dropdown with conditional manual tick input
class AdvancedTickOptions extends StatelessWidget {
  final TargetTickTypeEnum targetTickType;
  final Function(TargetTickTypeEnum? value) onTargetTickTypeChanged;
  final TextEditingController tickController;
  final int currentTick;
  final bool isLoading;

  const AdvancedTickOptions({
    super.key,
    required this.targetTickType,
    required this.onTargetTickTypeChanged,
    required this.tickController,
    required this.currentTick,
    required this.isLoading,
  });

  void _handleSetCurrentTick() {
    if (currentTick > 0) {
      tickController.text = currentTick.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);

    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          l10n.sendItemLabelDetermineTargetTick,
          style: TextStyles.labelTextNormal,
        ),
        ThemedControls.spacerVerticalMini(),
        TargetTickDropdown(
          value: targetTickType,
          onChanged: onTargetTickTypeChanged,
          isEnabled: !isLoading,
        ),
        if (targetTickType == TargetTickTypeEnum.manual)
          ManualTickInput(
            controller: tickController,
            currentTick: currentTick,
            isLoading: isLoading,
            onSetCurrentTick: _handleSetCurrentTick,
          ),
      ],
    );
  }
}
