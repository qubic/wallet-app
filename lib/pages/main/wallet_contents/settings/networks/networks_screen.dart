import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/settings/networks/add_network_screen.dart';
import 'package:qubic_wallet/styles/app_icons.dart';
import 'package:qubic_wallet/styles/button_styles.dart';
import 'package:qubic_wallet/styles/edge_insets.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

class NetworksScreen extends StatelessWidget {
  const NetworksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Networks", style: TextStyles.textExtraLargeBold),
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
      body: ListView.builder(
          padding: ThemeEdgeInsets.pageInsets,
          itemCount: 3,
          itemBuilder: (context, index) {
            return ThemedControls.card(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text("Qubic Mainnet", style: TextStyles.sliverCardPreLabel),
                ThemedControls.spacerVerticalSmall(),
                Text("https://rpc.qubic.org", style: TextStyles.secondaryText),
                Text("https://api.qubic.li", style: TextStyles.secondaryText),
                ThemedControls.spacerVerticalSmall(),
                Row(
                  children: [
                    Expanded(
                      child: ThemedControls.secondaryButtonWithChild(
                        onPressed: () {},
                        child: Text(
                          "Set as Default",
                          style: TextStyles.primaryButtonText
                              .copyWith(color: LightThemeColors.primary40),
                        ),
                      ),
                    ),
                    ThemedControls.spacerHorizontalSmall(),
                    SizedBox(
                      width: ButtonStyles.buttonHeight,
                      child: TextButton(
                          style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              backgroundColor:
                                  LightThemeColors.dangerBackgroundButton),
                          onPressed: () {},
                          child: SvgPicture.asset(AppIcons.close)),
                    ),
                  ],
                )
              ],
            ));
          }),
    );
  }
}
