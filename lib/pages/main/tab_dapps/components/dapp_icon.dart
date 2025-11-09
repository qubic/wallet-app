import 'package:flutter/material.dart';
import 'package:qubic_wallet/config.dart';

/// Reusable dApp icon widget with network image loading and fallback
/// Displays dApp icon from URL or shows default image on error/missing URL
class DappIcon extends StatelessWidget {
  final String? iconUrl;
  final double size;

  const DappIcon({
    super.key,
    this.iconUrl,
    this.size = Config.dAppIconSize,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: iconUrl != null && iconUrl!.isNotEmpty
            ? Image.network(
                iconUrl!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    Config.dAppDefaultImageName,
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                  );
                },
              )
            : Image.asset(
                Config.dAppDefaultImageName,
                width: size,
                height: size,
                fit: BoxFit.cover,
              ),
      ),
    );
  }
}
