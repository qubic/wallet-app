import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:qubic_wallet/components/account_list_item.dart';
import 'package:qubic_wallet/components/adabtive_refresh_indicator.dart';
import 'package:qubic_wallet/components/cumulative_wallet_value_sliver.dart';
import 'package:qubic_wallet/components/gradient_container.dart';
import 'package:qubic_wallet/components/id_list_item.dart';
import 'package:qubic_wallet/components/sliver_button.dart';
import 'package:qubic_wallet/components/tick_indication_styled.dart';
import 'package:qubic_wallet/components/tick_refresh.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/show_alert_dialog.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/add_account.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:qubic_wallet/timed_controller.dart';
import 'package:qubic_wallet/l10n/l10n.dart';

class TabWalletContents extends StatefulWidget {
  const TabWalletContents({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TabWalletContentsState createState() => _TabWalletContentsState();
}

class _TabWalletContentsState extends State<TabWalletContents> {
  final ApplicationStore appStore = getIt<ApplicationStore>();
  final TimedController _timedController = getIt<TimedController>();

  final double sliverCollapsed = 80;
  final double sliverExpanded = 185;

  double _sliverShowPercent = 1;
  final bool showTickOnTop = false;
  final ScrollController _scrollController = ScrollController();
  String? signInError;
  // int? currentTick;

  ReactionDisposer? disposeAutorun;

  @override
  void initState() {
    super.initState();

    disposeAutorun = autorun((_) {
      if (appStore.currentQubicIDs.length <= 1) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(0,
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeInOut);
        }
      }
    });

    _scrollController.addListener(() {
      if (_scrollController.offset > sliverExpanded) {
        debugPrint("100%");
      }

      setState(() {
        _sliverShowPercent =
            1 - (_scrollController.offset / (sliverExpanded - sliverCollapsed));
        if (_sliverShowPercent < 0) {
          _sliverShowPercent = 0;
        }
        if (_sliverShowPercent > 1) _sliverShowPercent = 1;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    disposeAutorun!();
    _scrollController.dispose();
    // disposer();
  }

  List<Widget> getAccounts() {
    List<Widget> accounts = [];
    for (var element in appStore.currentQubicIDs) {
      accounts.add(Padding(
          padding: const EdgeInsets.symmetric(
              vertical: ThemePaddings.normalPadding / 2),
          child: IdListItem(item: element)));
    }
    return accounts;
  }

  List<Widget> getAccountCards() {
    List<Widget> cards = [];

    cards.add(Container());

    cards.add(const CumulativeWalletValueSliver());

    for (var element in appStore.currentQubicIDs) {
      cards.add(Padding(
          padding: const EdgeInsets.symmetric(
              vertical: ThemePaddings.normalPadding / 2),
          child: IdListItem(item: element)));
    }
    return cards;
  }

  Widget getEmptyWallet() {
    final l10n = l10nOf(context);
    Color? transpColor =
        Theme.of(context).textTheme.titleMedium?.color!.withOpacity(0.3);
    return Center(
        child: DottedBorder(
            color: transpColor!,
            strokeWidth: 3,
            borderType: BorderType.RRect,
            radius: const Radius.circular(20),
            dashPattern: const [10, 5],
            child: Padding(
              padding: const EdgeInsets.all(ThemePaddings.bigPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wallet_outlined,
                      size: 100,
                      color: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.color!
                          .withOpacity(0.3)),
                  Text(l10n.homeLabelNoAccountsInWallet),
                  ThemedControls.spacerVerticalNormal(),
                  FilledButton.icon(
                      onPressed: () {
                        pushScreen(
                          context,
                          screen: const AddAccount(),
                          withNavBar: false, // OPTIONAL VALUE. True by default.
                          pageTransitionAnimation:
                              PageTransitionAnimation.cupertino,
                        );
                      },
                      icon: const Icon(Icons.add_box),
                      label: Text(l10n.homeButtonAddAccount))
                ],
              ),
            )));
  }

  bool isLoading = false;

  void addAccount() {
    final l10n = l10nOf(context);
    if (appStore.currentQubicIDs.length >= 15) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return getAlertDialog(
                l10n.addAccountDialogTitleMaxNumberOfAccountsReached,
                l10n.addAccountDialogMessageMaxNumberOfAccountsReached,
                primaryButtonLabel: l10n.generalButtonOK,
                primaryButtonFunction: () {
              Navigator.of(context).pop();
            }, secondaryButtonLabel: null);
          });
      return;
    }
    pushScreen(
      context,
      screen: const AddAccount(),
      withNavBar: false, // OPTIONAL VALUE. True by default.
      pageTransitionAnimation: PageTransitionAnimation.cupertino,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);

    return Scaffold(
        body: AdabtiveRefreshIndicator(
            edgeOffset: sliverExpanded,
            onRefresh: () async {
              await _timedController.interruptFetchTimer();
            },
            child: Container(
              color: LightThemeColors.background,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    backgroundColor: LightThemeColors.background,
                    actions: <Widget>[
                      TickRefresh(),
                      ThemedControls.spacerHorizontalSmall(),
                      SliverButton(
                        icon: const Icon(Icons.add,
                            color: LightThemeColors.primary),
                        onPressed: addAccount,
                      ),
                      ThemedControls.spacerHorizontalSmall(),
                    ],
                    floating: false,
                    pinned: true,
                    collapsedHeight: sliverCollapsed,
                    expandedHeight: sliverExpanded,
                    flexibleSpace: Stack(
                      children: [
                        const Positioned.fill(child: GradientContainer()),
                        Positioned.fill(
                            child: SingleChildScrollView(
                          child: Column(children: [
                            Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    0,
                                    ThemePaddings.normalPadding,
                                    0,
                                    ThemePaddings.normalPadding),
                                child: Center(
                                    child: showTickOnTop
                                        ? TickIndicatorStyled(
                                            textStyle: TextStyles.whiteTickText)
                                        : Container())),
                            Transform.translate(
                                offset:
                                    Offset(0, -10 * (1 - _sliverShowPercent)),
                                child: Opacity(
                                    opacity: _sliverShowPercent,
                                    child:
                                        const CumulativeWalletValueSliver())),
                          ]),
                        )),
                        Positioned(
                          bottom: -7,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 20,
                            decoration: const BoxDecoration(
                              color: LightThemeColors.background,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(40),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  SliverList(
                      delegate: SliverChildListDelegate([
                    Observer(builder: (builder) {
                      if (appStore.currentQubicIDs.length > 15) {
                        return Padding(
                            padding: const EdgeInsets.fromLTRB(
                                ThemePaddings.normalPadding,
                                ThemePaddings.smallPadding,
                                ThemePaddings.normalPadding,
                                ThemePaddings.miniPadding),
                            child: ThemedControls.card(
                                child: Column(children: [
                              const Icon(Icons.warning_amber_rounded,
                                  color: LightThemeColors.error, size: 40),
                              ThemedControls.spacerVerticalNormal(),
                              Text(l10n.homeWarningTooManyAccounts,
                                  textAlign: TextAlign.center,
                                  style: TextStyles.textNormal)
                            ])));
                      } else {
                        return Container();
                      }
                    }),
                    Container(
                        child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                                ThemePaddings.normalPadding,
                                ThemePaddings.smallPadding,
                                ThemePaddings.normalPadding,
                                ThemePaddings.miniPadding),
                            child: Text(l10n.homeHeader,
                                style: TextStyles.sliverCardPreLabel)))
                  ])),
                  Observer(builder: (context) {
                    if (appStore.currentQubicIDs.isEmpty) {
                      return SliverList(
                          delegate:
                              SliverChildBuilderDelegate((context, index) {
                        return Container(
                            color: LightThemeColors.background,
                            child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: ThemePaddings.smallPadding,
                                    vertical: ThemePaddings.normalPadding / 2),
                                child: Card(
                                    color: LightThemeColors.cardBackground,
                                    elevation: 0,
                                    child: Column(children: [
                                      ThemedControls.spacerVerticalBig(),
                                      Padding(
                                        padding: const EdgeInsets.all(
                                            20.0), // Set the padding value
                                        child: Text(
                                            l10n.homeLabelNoAccountsInWallet,
                                            style:
                                                TextStyles.secondaryTextNormal,
                                            textAlign: TextAlign.center),
                                      ),
                                      ThemedControls.spacerVerticalBig(),
                                      ThemedControls.primaryButtonBigWithChild(
                                          onPressed: addAccount,
                                          child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.add),
                                                ThemedControls
                                                    .spacerHorizontalSmall(),
                                                Text(l10n.homeButtonAddAccount),
                                              ])),
                                      ThemedControls.spacerVerticalBig(),
                                    ]))));
                      }, childCount: 1));
                    } else {
                      return SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return Container(
                              color: LightThemeColors.background,
                              child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: ThemePaddings.smallPadding,
                                      vertical:
                                          ThemePaddings.normalPadding / 2),
                                  child: AccountListItem(
                                      item: appStore.currentQubicIDs[0])));
                        }, childCount: 100),
                      );
                    }
                  }),
                ],
              ),
            )));
  }
}
