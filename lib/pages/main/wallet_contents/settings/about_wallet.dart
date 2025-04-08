import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:qubic_wallet/components/copyable_text.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/global_snack_bar.dart';
import 'package:qubic_wallet/resources/secure_storage.dart';
import 'package:qubic_wallet/services/qubic_hub_service.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/stores/qubic_hub_store.dart';
import 'package:qubic_wallet/stores/settings_store.dart';
import 'package:qubic_wallet/styles/edge_insets.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:url_launcher/link.dart';

class AboutWallet extends StatefulWidget {
  const AboutWallet({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AboutWalletState createState() => _AboutWalletState();
}

class _AboutWalletState extends State<AboutWallet> {
  final ApplicationStore appStore = getIt<ApplicationStore>();
  final SettingsStore settingsStore = getIt<SettingsStore>();
  final SecureStorage secureStorage = getIt<SecureStorage>();
  final QubicHubStore qubicHubStore = getIt<QubicHubStore>();
  //final QubicHubService qubicService = getIt<QubicHubService>();
  final GlobalSnackBar snackBar = getIt<GlobalSnackBar>();
  bool isLoading = false;
  @override
  void initState() {
    /* super.initState();
    setState(() {
      isLoading = true;
    });
    //qubicService.loadUpdateInfo().then((value) {
      setState(() {
        isLoading = false;
      });
    }, onError: (e) {
      setState(() {
        isLoading = false;
      });
      appStore.reportGlobalError(e.toString().replaceAll("Exception: ", ""));
    }); */
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget getLoadingIndicator() {
    return isLoading
        ? const Padding(
            padding: EdgeInsets.only(top: ThemePaddings.normalPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                    width: 15, height: 15, child: CircularProgressIndicator()),
                Text("  Checking for updates...")
              ],
            ))
        : Container();
  }

  Widget getCopyableDetails(BuildContext context, String text, String value) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
          width: double.infinity,
          alignment: Alignment.center,
          child: Text(text,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(fontFamily: ThemeFonts.primary))),
      CopyableText(
          copiedText: value,
          child: Text(value,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(fontFamily: ThemeFonts.secondary)))
    ]);
  }

  Widget getLogo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
            width: 150,
            //    MediaQuery.of(context).size.height *                                              0.15,
            child: Image(image: AssetImage('assets/images/logo_qh.png'))),
        Text("qubic wallet",
            textAlign: TextAlign.center,
            style: Theme.of(context).primaryTextTheme.displayLarge?.copyWith(
                fontFamily: ThemeFonts.primary,
                color: Theme.of(context).textTheme.bodyMedium?.color)),
        Observer(builder: (BuildContext context) {
          if (qubicHubStore.versionInfo == null) {
            return Container();
          }
          return Text("Version ${qubicHubStore.versionInfo}",
              textAlign: TextAlign.center,
              style: Theme.of(context).primaryTextTheme.bodyLarge?.copyWith(
                  fontFamily: ThemeFonts.primary,
                  color: Theme.of(context).textTheme.bodyLarge?.color));
        }),
        Text("Copyright (C) 2024  Qubic.org",
            style: Theme.of(context).primaryTextTheme.bodyLarge?.copyWith(
                fontFamily: ThemeFonts.primary,
                color: Theme.of(context).textTheme.bodyLarge?.color)),
        // Text("Copyright (C) 2023 - ${DateTime.now().year} Qubic-Hub",
        //     style: Theme.of(context).primaryTextTheme.bodyLarge?.copyWith(
        //         fontFamily: ThemeFonts.primary,
        //         color: Theme.of(context).textTheme.bodyLarge?.color)),
        Link(
            uri: Uri.parse("https://qubic.org"),
            target: LinkTarget.blank,
            builder: (context, followLink) {
              return TextButton(
                  onPressed: followLink,
                  child: Text("https://qubic.org",
                      style: Theme.of(context)
                          .primaryTextTheme
                          .bodyLarge
                          ?.copyWith(
                              fontFamily: ThemeFonts.primary,
                              color: Theme.of(context).colorScheme.primary)));
            }),
        getCopyableDetails(context, "Donations",
            "WZFSPXPLXKNWFDLNMZHQTGMSRIHBEBITVDUXOSVSZGBREGIUVNWVZBIETEQF")
      ],
    );
  }

  Widget getScrollView() {
    return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Row(children: [
          Container(
              child: Expanded(
                  child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ThemedControls.spacerHorizontalNormal(),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: SizedBox(
                        height: 28,
                        child: Image(
                            image: AssetImage('assets/images/logo.png')))),
                ThemedControls.spacerHorizontalNormal(),
                ThemedControls.pageHeader(
                    headerText: "About Qubic Wallet",
                    subheaderText: "Version ${qubicHubStore.versionInfo}"),
              ]),
              Row(children: [
                const SizedBox(width: 56),
                Expanded(
                    child: Text(
                        "${"Copyright (c) 2023 - ${DateTime.now().year}"} Qubic.ORG (based on Wallet by Qubic-Hub)",
                        style: Theme.of(context).textTheme.bodyMedium)),
              ]),
              ThemedControls.spacerVerticalBig(),
              Text("More info at", style: TextStyles.labelText),
              Row(children: [
                Link(
                    uri: Uri.parse("https://qubic.org"),
                    target: LinkTarget.blank,
                    builder: (context, followLink) {
                      return TextButton(
                          onPressed: followLink,
                          child: Text("https://qubic.org",
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .bodyLarge
                                  ?.copyWith(
                                      fontFamily: ThemeFonts.primary,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary)));
                    })
              ]),
              ThemedControls.spacerVerticalNormal(),

              ThemedControls.card(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Donations", style: TextStyles.labelText),
                  ThemedControls.spacerVerticalNormal(),
                  Row(children: [
                    const Expanded(
                        child: Text(
                            "WZFSPXPLXKNWFDLNMZHQTGMSRIHBEBITVDUXOSVSZGBREGIUVNWVZBIETEQF")),
                    ThemedControls.spacerVerticalNormal(),
                    IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          Clipboard.setData(const ClipboardData(
                              text:
                                  "WZFSPXPLXKNWFDLNMZHQTGMSRIHBEBITVDUXOSVSZGBREGIUVNWVZBIETEQF"));
                          appStore.reportGlobalNotification(
                              "Donation address copied to clipboard");
                        })
                  ])
                ],
              )),
              getLoadingIndicator(),
              // Observer(builder: (context) {
              //   if (qubicHubStore.updateDetails != null) {
              //     return AvailableUpdateCard(
              //         updateDetails: qubicHubStore.updateDetails!);
              //   }
              //   return Container();
              // })
            ],
          )))
        ]));
  }

  List<Widget> getButtons() {
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
        ),
        body: SafeArea(
            minimum: ThemeEdgeInsets.pageInsets,
            child: Column(children: [
              Expanded(child: getScrollView()),
              Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: getButtons())
            ])));
  }
}
