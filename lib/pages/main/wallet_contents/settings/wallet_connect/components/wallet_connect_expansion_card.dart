import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/styles/app_icons.dart';
import 'package:qubic_wallet/styles/button_styles.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

class WallectConnectExpansionCard extends StatefulWidget {
  final List<Widget> title;
  final Widget content;
  final VoidCallback onRemove;
  final VoidCallback onOpen;

  const WallectConnectExpansionCard({
    super.key,
    required this.title,
    required this.content,
    required this.onRemove,
    required this.onOpen,
  });

  @override
  _WallectConnectExpansionCardState createState() =>
      _WallectConnectExpansionCardState();
}

class _WallectConnectExpansionCardState
    extends State<WallectConnectExpansionCard> {
  bool _isExpanded = false;

  void toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ThemedControls.card(
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      ...widget.title,
      if (_isExpanded) ThemedControls.spacerVerticalNormal(),
      AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: _isExpanded ? widget.content : const SizedBox.shrink(),
      ),
      ThemedControls.spacerVerticalNormal(),
      SizedBox(
        height: ButtonStyles.buttonHeight,
        child: Row(
          children: [
            Expanded(
                child: ThemedControls.secondaryButtonWithChild(
              onPressed: widget.onOpen,
              child: Text(
                "Open App",
                style: TextStyles.primaryButtonText
                    .copyWith(color: LightThemeColors.primary40),
              ),
            )),
            ThemedControls.spacerHorizontalSmall(),
            SizedBox(
              width: ButtonStyles.buttonHeight,
              child: TextButton(
                  style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      backgroundColor: LightThemeColors.dangerBackgroundButton),
                  onPressed: widget.onRemove,
                  child: SvgPicture.asset(AppIcons.close)),
            ),
            ThemedControls.spacerHorizontalSmall(),
            SizedBox(
              width: ButtonStyles.buttonHeight,
              child: ThemedControls.transparentButtonWithChild(
                  onPressed: toggleExpansion,
                  child: AnimatedRotation(
                      duration: const Duration(milliseconds: 300),
                      turns: _isExpanded ? 0.5 : 0,
                      child: SvgPicture.asset(AppIcons.arrowDown))),
            )
          ],
        ),
      )
    ]));
  }
}
