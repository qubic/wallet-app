import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/pages/main/tab_settings/components/settings_list_tile.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/styles/app_icons.dart';
import 'package:url_launcher/url_launcher_string.dart';

class CommunityListTile extends StatelessWidget {
  final String title;
  final String prefixIconPath;
  final bool hasSuffixIcon;
  final String url;
  const CommunityListTile(
      {super.key,
      required this.title,
      required this.prefixIconPath,
      this.hasSuffixIcon = true,
      required this.url});

  Future<void> launchQubicURL(String url) async {
    try {
      await launchUrlString(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      getIt<ApplicationStore>().reportGlobalNotification(e.toString());
    }
  }

  final defaultIconHeight = 20.0;

  @override
  Widget build(BuildContext context) {
    return SettingsListTile(
      title: title,
      prefix: Center(
        child: SvgPicture.asset(
          prefixIconPath,
          height: defaultIconHeight,
        ),
      ),
      suffix: hasSuffixIcon
          ? SvgPicture.asset(
              AppIcons.externalLink,
              height: defaultIconHeight,
            )
          : const SizedBox.shrink(),
      onPressed: () => launchQubicURL(url),
    );
  }
}
