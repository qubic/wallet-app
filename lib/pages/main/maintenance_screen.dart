import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/dtos/app_message_dto.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/stores/app_message_store.dart';
import 'package:qubic_wallet/styles/app_icons.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

class MaintenanceScreen extends StatelessWidget {
  final AppMessageDto? appMessage;
  const MaintenanceScreen({super.key, this.appMessage});

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Center(
            child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: ThemePaddings.normalPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                AppIcons.maintenance,
                height: 100,
                colorFilter: const ColorFilter.mode(
                    LightThemeColors.primary40, BlendMode.srcIn),
              ),
              ThemedControls.spacerVerticalNormal(),
              Text(appMessage?.title ?? "",
                  style: TextStyles.alertHeader, textAlign: TextAlign.center),
              ThemedControls.spacerVerticalSmall(),
              Text(appMessage?.message ?? "",
                  style: TextStyles.alertText, textAlign: TextAlign.center),
              ThemedControls.spacerVerticalNormal(),
              Observer(builder: (context) {
                bool isLoading = getIt<AppMessageStore>().isLoading;
                return ThemedControls.primaryButtonSmall(
                    onPressed: () async {
                      final navigator = Navigator.of(context);
                      final message =
                          await getIt<AppMessageStore>().getAppMessage();
                      if (message == null) {
                        navigator.pop();
                      }
                    },
                    text: isLoading ? "" : l10n.maintenanceRefreshButton,
                    icon: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: LightThemeColors.background),
                          )
                        : null);
              }),
            ],
          ),
        )),
      ),
    );
  }
}
