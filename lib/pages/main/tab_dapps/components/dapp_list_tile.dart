import 'package:flutter/material.dart';
import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/pages/main/tab_dapps/components/dapp_icon.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

/// Reusable list tile for displaying dApps and favorites
/// Used in search results and favorites list
class DappListTile extends StatelessWidget {
  final String name;
  final String subtitle;
  final String? iconUrl;
  final VoidCallback onTap;

  const DappListTile({
    super.key,
    required this.name,
    required this.subtitle,
    this.iconUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: ThemePaddings.normalPadding,
          vertical: ThemePaddings.smallPadding,
        ),
        child: Row(
          children: [
            DappIcon(
              iconUrl: iconUrl,
              size: Config.dAppIconSize,
            ),
            ThemedControls.spacerHorizontalNormal(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyles.labelTextTight,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyles.smallInfoTextTight,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
