part of '../approve_wc_method_screen.dart';

class _ApprovalHeader extends StatelessWidget {
  const _ApprovalHeader({
    required this.data,
  });

  final ApprovalDataModel data;

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return Column(
      children: [
        SizedBox(
          height: 80,
          width: 80,
          child: data.pairingMetadata != null &&
                  data.pairingMetadata!.icons.isNotEmpty
              ? FadeInImage(
                  image: NetworkImage(data.pairingMetadata!.icons[0]),
                  placeholder: const AssetImage(Config.dAppDefaultImageName),
                  imageErrorBuilder: (context, error, stackTrace) =>
                      Image.asset(Config.dAppDefaultImageName),
                  fit: BoxFit.contain,
                )
              : Image.asset(Config.dAppDefaultImageName),
        ),
        //dAPP title
        ThemedControls.spacerVerticalBig(),
        Text(
            data.pairingMetadata == null ||
                    data.pairingMetadata?.name == null ||
                    data.pairingMetadata!.name.isEmpty
                ? l10n.wcUnknownDapp
                : data.pairingMetadata!.name,
            style: TextStyles.walletConnectDappTitle),
        ThemedControls.spacerVerticalSmall(),
        Text(
            data.pairingMetadata == null ||
                    data.pairingMetadata?.url == null ||
                    data.pairingMetadata!.url.isEmpty
                ? l10n.wcUnknownDapp
                : data.pairingMetadata!.url,
            style: TextStyles.walletConnectDappUrl),
      ],
    );
  }
}
