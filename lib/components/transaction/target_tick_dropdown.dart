import 'package:flutter/material.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/helpers/target_tick.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/stores/wallet_content_store.dart';
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
    final walletContentStore = getIt<WalletContentStore>();

    return TargetTickTypeEnum.values.map((targetTickType) {
      final String label;
      switch (targetTickType) {
        case TargetTickTypeEnum.manual:
          label = l10n.sendItemLabelTargetTickManual;
        case TargetTickTypeEnum.automatic:
          // Show the offset actually being applied, e.g. "Automatic (+10)".
          label = l10n.sendItemLabelTargetTickAutomaticDefault(
              walletContentStore.defaultTickOffset);
        default:
          label = l10n.sendItemLabelTargetTickAutomatic(targetTickType.value);
      }

      return DropdownMenuItem<TargetTickTypeEnum>(
        value: targetTickType,
        child: Text(label, style: TextStyles.inputBoxSmallStyle),
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
