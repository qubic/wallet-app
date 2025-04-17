import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/helpers/global_snack_bar.dart';
import 'package:qubic_wallet/pages/main/tab_settings/components/settings_list_tile.dart';
import 'package:qubic_wallet/styles/app_icons.dart';
import 'package:url_launcher/url_launcher_string.dart';

class LinkListTile extends StatelessWidget {
  final String title;
  final String prefixIconPath;
  final String url;
  const LinkListTile(
      {super.key,
      required this.title,
      required this.prefixIconPath,
      required this.url});

  Future<void> launchQubicURL(String url) async {
    try {
      await launchUrlString(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      getIt.get<GlobalSnackBar>().showError(e.toString());
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
      suffix: SvgPicture.asset(
        AppIcons.externalLink,
        height: defaultIconHeight,
      ),
      onPressed: () => launchQubicURL(url),
    );
  }
}
