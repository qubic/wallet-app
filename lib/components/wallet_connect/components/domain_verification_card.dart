import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/add_wallet_connect/add_wallet_connect.dart';
import 'package:qubic_wallet/styles/app_icons.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

class DomainVerificationCard extends StatelessWidget {
  final DomainType domainType;
  const DomainVerificationCard({super.key, required this.domainType});

  bool isScam() => domainType == DomainType.scam;
  bool isMisMatch() => domainType == DomainType.mismatch;
  bool isUnknown() => domainType == DomainType.unknown;

  @override
  Widget build(BuildContext context) {
    return ThemedControls.card(
        borderColor:
            isUnknown() ? LightThemeColors.warning40 : LightThemeColors.error40,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            SvgPicture.asset(isUnknown() ? AppIcons.warning : AppIcons.danger,
                height: 20),
            ThemedControls.spacerHorizontalSmall(),
            Text(
              isScam()
                  ? "Known Security Risk"
                  : isMisMatch()
                      ? "Domain Mismatch"
                      : "Unknown Domain",
              style: TextStyles.labelText.copyWith(
                  color: isUnknown()
                      ? LightThemeColors.warning40
                      : LightThemeColors.error40),
            )
          ]),
          ThemedControls.spacerVerticalSmall(),
          Text(
            isScam()
                ? "This domain is flagged as unsafe by multiple security providers. Leave it immediately to protect your assets"
                : isMisMatch()
                    ? "This website has a domain that does not match the sender of this request. Approving may lead to loss of funds"
                    : "This domain cannot be verified. Check the request carefully before approving",
            style: TextStyles.secondaryText,
          )
        ]));
  }
}
