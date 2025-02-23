import 'package:flutter/material.dart';
import 'package:qubic_wallet/models/dapp_model.dart';
import 'package:qubic_wallet/styles/edge_insets.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

class TabDApps extends StatelessWidget {
  const TabDApps({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: ThemeEdgeInsets.pageInsets,
        children: [
          Text(
            "Popular dApps",
            style: TextStyles.pageTitle,
          ),
          ThemedControls.card(
              child: Column(
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(dAppsList[0].icon, height: 40),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dAppsList[0].name,
                          style: TextStyles.labelText,
                        ),
                        Text(
                          dAppsList[0].description,
                          style: TextStyles.smallInfoText,
                        ),
                      ],
                    ),
                  ),
                  ThemedControls.transparentButtonSmall(
                      onPressed: () {}, text: "Open"),
                ],
              )
            ],
          ))
        ],
      ),
    );
  }
}
