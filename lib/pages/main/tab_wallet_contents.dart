import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:implicitly_animated_list/implicitly_animated_list.dart';
import 'package:mobx/mobx.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:qubic_wallet/components/account_list_item.dart';
import 'package:qubic_wallet/components/adaptive_refresh_indicator.dart';
import 'package:qubic_wallet/components/cumulative_wallet_value_sliver.dart';
import 'package:qubic_wallet/components/gradient_container.dart';
import 'package:qubic_wallet/components/price_panel.dart';
import 'package:qubic_wallet/components/sliver_button.dart';
import 'package:qubic_wallet/components/tick_indication_styled.dart';
import 'package:qubic_wallet/components/tick_refresh.dart';
import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/app_logger.dart';
import 'package:qubic_wallet/helpers/show_alert_dialog.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/models/qubic_list_vm.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/add_account_modal_bottom_sheet.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/add_wallet_connect/add_wallet_connect.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/stores/network_store.dart';
import 'package:qubic_wallet/stores/root_jailbreak_flag_store.dart';
import 'package:qubic_wallet/stores/settings_store.dart';
import 'package:qubic_wallet/styles/app_icons.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:qubic_wallet/timed_controller.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sprung/sprung.dart';

class TabWalletContents extends StatefulWidget {
  const TabWalletContents({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TabWalletContentsState createState() => _TabWalletContentsState();
}

class _TabWalletContentsState extends State<TabWalletContents> {
  final ApplicationStore appStore = getIt<ApplicationStore>();
  final SettingsStore settingsStore = getIt<SettingsStore>();
  final TimedController _timedController = getIt<TimedController>();
  final NetworkStore networkStore = getIt<NetworkStore>();

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

    // Auto scroll to top with one item
    disposeAutorun = autorun((_) {
      if (appStore.currentQubicIDs.length <= 1) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(0,
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeInOut);
        }
      }
    });
    appStore.sortAccounts();

    _scrollController.addListener(() {
      if (_scrollController.offset > sliverExpanded) {
        appLogger.d("100%");
      }

      setState(() {
        _sliverShowPercent =
            1 - (_scrollController.offset / (sliverExpanded - kToolbarHeight));
        if (_sliverShowPercent < 0) {
          _sliverShowPercent = 0;
        }
        if (_sliverShowPercent > 1) _sliverShowPercent = 1;
      });
    });
  }

  @override
  void dispose() {
    disposeAutorun!();
    _scrollController.dispose();
    super.dispose();
    // disposer();
  }

  Widget getEmptyWallet() {
    final l10n = l10nOf(context);
    Color? transpColor =
        Theme.of(context).textTheme.titleMedium?.color!.withValues(alpha: 0.3);
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
                          .withValues(alpha: 0.3)),
                  Text(l10n.homeLabelNoAccountsInWallet),
                  ThemedControls.spacerVerticalNormal(),
                  FilledButton.icon(
                      onPressed: () {
                        showAddAccountModal(context);
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

    appStore.triggerAddAccountModal();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);

    return Scaffold(
        body: AdaptiveRefreshIndicator(
            edgeOffset: kToolbarHeight,
            onRefresh: () async {
              await _timedController.interruptFetchTimer();
            },
            backgroundColor: LightThemeColors.refreshIndicatorBackground,
            child: Container(
              color: LightThemeColors.background,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  Observer(builder: (context) {
                    return SliverAppBar(
                      leadingWidth: 300,
                      backgroundColor: LightThemeColors.background,
                      leading: PricePanel(),
                      actions: <Widget>[
                        TickRefresh(),
                        ThemedControls.spacerHorizontalSmall(),
                        Visibility(
                          visible: true,
                          child: SliverButton(
                            onPressed: () {
                              if (getIt<RootJailbreakFlagStore>()
                                  .restrictFeatureIfDeviceCompromised()) {
                                return;
                              }
                              pushScreen(
                                context,
                                screen: const AddWalletConnect(),
                                withNavBar: false,
                                pageTransitionAnimation:
                                    PageTransitionAnimation.cupertino,
                              );
                            },
                            icon: SvgPicture.asset(AppIcons.walletConnect,
                                colorFilter: const ColorFilter.mode(
                                    LightThemeColors.primary, BlendMode.srcIn)),
                          ),
                        ),
                        ThemedControls.spacerHorizontalSmall(),
                        SliverButton(
                          icon: const Icon(Icons.add,
                              color: LightThemeColors.primary),
                          onPressed: addAccount,
                        ),
                        ThemedControls.spacerHorizontalSmall(),
                      ],
                      bottom: networkStore.currentNetwork.name ==
                              Config.networkQubicMainnet
                          ? null
                          : PreferredSize(
                              preferredSize:
                                  const Size.fromHeight(kToolbarHeight),
                              child: Container(
                                width: double.infinity,
                                color: LightThemeColors.warning40,
                                padding: const EdgeInsets.symmetric(
                                    vertical: ThemePaddings.smallPadding),
                                child: Text(
                                    l10n.networksWarningBannerCurrentNetwork(
                                        networkStore.currentNetwork.name),
                                    textAlign: TextAlign.center,
                                    style: TextStyles.alertText.copyWith(
                                        color: LightThemeColors.primary)),
                              ),
                            ),
                      floating: false,
                      pinned: true,
                    );
                  }),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: sliverExpanded - kToolbarHeight,
                      child: Stack(
                        children: [
                          const Positioned.fill(child: GradientContainer()),
                          Positioned.fill(
                              child: SingleChildScrollView(
                            child: Column(children: [
                              if (showTickOnTop)
                                Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        0,
                                        ThemePaddings.normalPadding,
                                        0,
                                        ThemePaddings.normalPadding),
                                    child: Center(
                                        child: showTickOnTop
                                            ? TickIndicatorStyled(
                                                textStyle:
                                                    TextStyles.whiteTickText)
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
                  ])),
                  Observer(builder: (context) {
                    if (appStore.currentQubicIDs.isNotEmpty) {
                      return SliverToBoxAdapter(
                          child: Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: PopupMenuButton<AccountSortMode>(
                          icon:
                              Icon(Icons.sort, color: LightThemeColors.primary),
                          onSelected: (AccountSortMode mode) {
                            appStore.setAccountsSortingMode(mode);
                          },
                          itemBuilder: (BuildContext context) {
                            return [
                              PopupMenuItem<AccountSortMode>(
                                value: AccountSortMode.name,
                                child: Row(
                                  children: [
                                    Icon(Icons.sort_by_alpha,
                                        color: appStore.accountsSortingMode ==
                                                AccountSortMode.name
                                            ? LightThemeColors.primary60
                                            : LightThemeColors.primary),
                                    const SizedBox(width: 8),
                                    const Text("Name (A-Z)"),
                                  ],
                                ),
                              ),
                              PopupMenuItem<AccountSortMode>(
                                value: AccountSortMode.balance,
                                child: Row(
                                  children: [
                                    Icon(Icons.account_balance_wallet,
                                        color: appStore.accountsSortingMode ==
                                                AccountSortMode.balance
                                            ? LightThemeColors.primary60
                                            : LightThemeColors.primary),
                                    const SizedBox(width: 8),
                                    const Text("Balance (High → Low)"),
                                  ],
                                ),
                              ),
                              PopupMenuItem<AccountSortMode>(
                                value: AccountSortMode.creationOrder,
                                child: Row(
                                  children: [
                                    Icon(Icons.access_time,
                                        color: appStore.accountsSortingMode ==
                                                AccountSortMode.creationOrder
                                            ? LightThemeColors.primary60
                                            : LightThemeColors.primary),
                                    const SizedBox(width: 8),
                                    const Text("Creation (Oldest → Newest)"),
                                  ],
                                ),
                              ),
                            ];
                          },
                        ),
                      ));
                    } else {
                      return const SliverToBoxAdapter(child: SizedBox.shrink());
                    }
                  }),
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
                      final accounts = appStore.currentQubicIDs;
                      return SliverImplicitlyAnimatedList<QubicListVm>(
                        itemData: accounts,
                        itemEquality: (a, b) => a.publicId == b.publicId,
                        itemBuilder: (context, account) {
                          return Container(
                            color: LightThemeColors.background,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: ThemePaddings.smallPadding,
                                vertical: ThemePaddings.minimumPadding,
                              ),
                              child: AccountListItem(
                                key: ValueKey(account.publicId),
                                item: account,
                              )
                                  .animate()
                                  .fadeIn(
                                    duration: 600.ms,
                                    begin: 0.0,
                                  )
                                  .slideY(
                                    begin: 0.1,
                                    curve: Sprung.underDamped,
                                    duration: 2.seconds,
                                  ),
                            ),
                          );
                        },
                      );
                    }
                  }),
                ],
              ),
            )));
  }
}
