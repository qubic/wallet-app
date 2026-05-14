import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qubic_wallet/components/confirmation_dialog.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/models/network_model.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/settings/networks/add_network_screen.dart';
import 'package:qubic_wallet/stores/network_store.dart';
import 'package:qubic_wallet/styles/app_icons.dart';
import 'package:qubic_wallet/styles/button_styles.dart';
import 'package:qubic_wallet/styles/edge_insets.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:qubic_wallet/timed_controller.dart';

class NetworksScreen extends StatelessWidget {
  NetworksScreen({super.key});
  final networkStore = getIt<NetworkStore>();
  final timerController = getIt<TimedController>();

  onSetDefault(NetworkModel network) {
    networkStore.setCurrentNetwork(network);
    timerController.interruptFetchTimer();
  }

  onDelete(NetworkModel network) {
    networkStore.removeNetwork(network);
  }

  navigateToEdit(BuildContext context, NetworkModel network) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return AddNetworkScreen(network: network);
    }));
  }

  showRemoveDialog(BuildContext context, NetworkModel network) {
    final l10n = l10nOf(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          title:
              l10n.networksConfirmationDialogTitleDeleteNetwork(network.name),
          content:
              l10n.networksConfirmationDialogContentDeleteNetwork(network.name),
          continueText: l10n.generalButtonDelete,
          continueFunction: () {
            onDelete(network);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.networksTitle, style: TextStyles.textExtraLargeBold),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: LightThemeColors.primary),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const AddNetworkScreen();
              }));
            },
          ),
        ],
      ),
      body: Observer(builder: (context) {
        return ListView.builder(
            padding: ThemeEdgeInsets.pageInsets,
            itemCount: networkStore.networks.length,
            itemBuilder: (context, index) {
              final network = networkStore.networks[index];
              bool isSelected = networkStore.currentNetwork == network;
              bool isDefault = networkStore.defaultNetworks.contains(network);
              return ThemedControls.card(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: Text(network.name,
                              style: TextStyles.sliverCardPreLabel)),
                      if (isSelected)
                        Text(
                          l10n.networksLabelDefault,
                          style: TextStyles.secondaryText
                              .copyWith(color: LightThemeColors.primary40),
                        )
                    ],
                  ),
                  ThemedControls.spacerVerticalSmall(),
                  Text(network.rpcUrl, style: TextStyles.secondaryText),
                  Text(network.explorerUrl, style: TextStyles.secondaryText),
                  ThemedControls.spacerVerticalSmall(),
                  if (!isSelected)
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: ButtonStyles.buttonHeight,
                            child: ThemedControls.secondaryButtonWithChild(
                              onPressed: () => onSetDefault(network),
                              child: Text(
                                l10n.networksButtonSetAsDefault,
                                style: TextStyles.primaryButtonText
                                    .copyWith(color: LightThemeColors.primary40),
                              ),
                            ),
                          ),
                        ),
                        if (!isDefault) ...[
                          ThemedControls.spacerHorizontalSmall(),
                          _EditNetworkButton(
                              onPressed: () => navigateToEdit(context, network)),
                          ThemedControls.spacerHorizontalSmall(),
                          _DeleteNetworkButton(
                              onPressed: () =>
                                  showRemoveDialog(context, network)),
                        ]
                      ],
                    ),
                  if (isSelected && !isDefault)
                    Row(
                      children: [
                        const Spacer(),
                        _EditNetworkButton(
                            onPressed: () =>
                                navigateToEdit(context, network)),
                      ],
                    ),
                ],
              ));
            });
      }),
    );
  }
}

class _DeleteNetworkButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _DeleteNetworkButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ButtonStyles.buttonHeight,
      height: ButtonStyles.buttonHeight,
      child: TextButton(
          style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              backgroundColor: LightThemeColors.dangerBackgroundButton),
          onPressed: onPressed,
          child: SvgPicture.asset(AppIcons.close)),
    );
  }
}

class _EditNetworkButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _EditNetworkButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ThemedControls.iconButtonSquare(
      onPressed: onPressed,
      icon: const Icon(Icons.edit, color: LightThemeColors.primary40, size: 20),
    );
  }
}
