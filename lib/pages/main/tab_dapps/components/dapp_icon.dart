import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';

/// Reusable dApp icon widget with network image loading and fallback
/// Displays dApp icon from URL or shows default image on error/missing URL
/// Uses CachedNetworkImage for persistent disk-based caching
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
            ? CachedNetworkImage(
                imageUrl: iconUrl!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: size,
                  height: size,
                  color: LightThemeColors.grey90,
                  child: Center(
                    child: SizedBox(
                      width: size * 0.3,
                      height: size * 0.3,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          LightThemeColors.grey60,
                        ),
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Image.asset(
                  Config.dAppDefaultImageName,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                ),
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
