import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:mobx/mobx.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:qubic_wallet/components/amount_formatted.dart';
import 'package:qubic_wallet/components/confirmation_dialog.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/dtos/qubic_asset_dto.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/currency_helpers.dart';
import 'package:qubic_wallet/helpers/id_validators.dart';
import 'package:qubic_wallet/helpers/re_auth_dialog.dart';
import 'package:qubic_wallet/models/qubic_list_vm.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/assets.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/explorer/explorer_result_page.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/receive.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/reveal_seed/reveal_seed.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/reveal_seed/reveal_seed_warning_sheet.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/send.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/transfers/transactions_for_id.dart';
import 'package:qubic_wallet/services/wallet_connect_service.dart';
import 'package:qubic_wallet/smart_contracts/sc_info.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/stores/settings_store.dart';
import 'package:qubic_wallet/styles/input_decorations.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:qubic_wallet/l10n/l10n.dart';

enum CardItem { delete, rename, reveal, viewTransactions, viewInExplorer }

class AccountListItem extends StatefulWidget {
  final QubicListVm item;

  const AccountListItem({super.key, required this.item});

  @override
  State<AccountListItem> createState() => _AccountListItemState();
}

class _AccountListItemState extends State<AccountListItem> {
  final _formKey = GlobalKey<FormBuilderState>();

  final SettingsStore _settingsStore = getIt<SettingsStore>();
  final ApplicationStore _appStore = getIt<ApplicationStore>();

  bool totalBalanceVisible = true;
  late ReactionDisposer _disposer;

  bool isItemWatchOnly() => widget.item.watchOnly;

  @override
  void initState() {
    super.initState();
    totalBalanceVisible = _settingsStore.settings.totalBalanceVisible ?? true;
    _disposer = autorun((_) {
      setState(() {
        totalBalanceVisible = _settingsStore.totalBalanceVisible;
      });
    });
  }

  @override
  void dispose() {
    _disposer();
    super.dispose();
  }

  showRenameDialog(BuildContext context) {
    final l10n = l10nOf(context);

    late BuildContext dialogContext;
    final controller = TextEditingController();

    controller.text = widget.item.name;
    controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: widget.item.name.length,
    );

    // set up the buttons
    Widget cancelButton = ThemedControls.transparentButtonNormal(
        onPressed: () {
          Navigator.pop(dialogContext);
        },
        text: l10n.generalButtonCancel);

    Widget continueButton = ThemedControls.primaryButtonNormal(
      text: l10n.generalButtonRename,
      onPressed: () {
        if (_formKey.currentState?.instantValue["accountName"] ==
            widget.item.name) {
          Navigator.pop(dialogContext);
          return;
        }

        _formKey.currentState?.validate();
        if (!_formKey.currentState!.isValid) {
          return;
        }

        _appStore.setName(widget.item.publicId,
            _formKey.currentState?.instantValue["accountName"]);

        //_appStore.removeID(item.publicId);
        Navigator.pop(dialogContext);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(l10n.renameAccountDialogTitle, style: TextStyles.alertHeader),
      scrollable: true,
      content: FormBuilder(
          key: _formKey,
          child: SizedBox(
              height: 72,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  FormBuilderTextField(
                    name: 'accountName',
                    //initialValue: item.name,
                    decoration: ThemeInputDecorations.normalInputbox.copyWith(
                      hintText: l10n.renameAccountDialogHintName,
                    ),
                    controller: controller,
                    focusNode: FocusNode()..requestFocus(),
                    style: TextStyles.inputBoxNormalStyle,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(
                          errorText: l10n.generalErrorRequiredField),
                      CustomFormFieldValidators.isNameAvailable(
                          currentQubicIDs: _appStore.currentQubicIDs,
                          ignorePublicId: widget.item.name,
                          context: context)
                    ]),
                  ),
                ],
              ))),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        dialogContext = context;
        return alert;
      },
    );
  }

  showRemoveDialog(BuildContext context) {
    final l10n = l10nOf(context);
    WalletConnectService wallet3ConnectService = getIt<WalletConnectService>();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          title: l10n.deleteAccountDialogTitle,
          content: isItemWatchOnly()
              ? l10n.deleteAccountDialogMessageWatchOnly
              : l10n.deleteAccountDialogMessage,
          continueText: l10n.deleteAccountDialogButtonDelete,
          continueFunction: () async {
            await _appStore.removeID(widget.item.publicId);
            wallet3ConnectService.triggerAccountsChangedEvent();
          },
        );
      },
    );
  }

  Widget getCardMenu(BuildContext context) {
    final l10n = l10nOf(context);
    return Theme(
        data: Theme.of(context).copyWith(
            menuTheme: MenuThemeData(
                style: MenuStyle(
          surfaceTintColor:
              WidgetStateProperty.all(LightThemeColors.cardBackground),
          elevation: WidgetStateProperty.all(50),
          backgroundColor:
              WidgetStateProperty.all(LightThemeColors.cardBackground),
        ))),
        child: PopupMenuButton<CardItem>(
            tooltip: "",
            icon: Icon(Icons.more_horiz,
                color: LightThemeColors.primary.withAlpha(140)),
            // Callback that sets the selected popup menu item.
            onSelected: (CardItem menuItem) async {
              if (menuItem == CardItem.rename) {
                showRenameDialog(context);
              }

              if (menuItem == CardItem.delete) {
                showRemoveDialog(context);
              }

              if (menuItem == CardItem.viewInExplorer) {
                pushScreen(
                  context,
                  screen: ExplorerResultPage(
                    resultType: ExplorerResultType.publicId,
                    qubicId: widget.item.publicId,
                  ),
                  withNavBar: false,
                  pageTransitionAnimation: PageTransitionAnimation.cupertino,
                );
              }

              if (menuItem == CardItem.viewTransactions) {
                pushScreen(
                  context,
                  screen: TransactionsForId(
                      publicQubicId: widget.item.publicId, item: widget.item),
                  withNavBar: false, // OPTIONAL VALUE. True by default.
                  pageTransitionAnimation: PageTransitionAnimation.cupertino,
                );
              }

              if (menuItem == CardItem.reveal) {
                showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    useSafeArea: true,
                    useRootNavigator: true,
                    backgroundColor: LightThemeColors.background,
                    builder: (BuildContext context) {
                      return SafeArea(
                          child: RevealSeedWarningSheet(
                              item: widget.item,
                              onAccept: () async {
                                if (await reAuthDialog(context) == false) {
                                  Navigator.pop(context);
                                  return;
                                }
                                Navigator.pop(context);
                                pushScreen(
                                  context,
                                  screen: RevealSeed(item: widget.item),
                                  withNavBar:
                                      false, // OPTIONAL VALUE. True by default.
                                  pageTransitionAnimation:
                                      PageTransitionAnimation.cupertino,
                                );
                              },
                              onReject: () async {
                                Navigator.pop(context);
                              }));
                    });
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<CardItem>>[
                  PopupMenuItem<CardItem>(
                    value: CardItem.viewTransactions,
                    child: Text(l10n.accountButtonViewTransfer),
                  ),
                  PopupMenuItem<CardItem>(
                    value: CardItem.viewInExplorer,
                    child: Text(l10n.accountButtonViewInExplorer),
                  ),
                  if (!isItemWatchOnly()) // Check if item is not watch-only
                    PopupMenuItem<CardItem>(
                      value: CardItem.reveal,
                      child: Text(l10n.accountButtonRevealPrivateSeed),
                    ),
                  PopupMenuItem<CardItem>(
                    value: CardItem.rename,
                    child: Text(l10n.generalButtonRename),
                  ),
                  PopupMenuItem<CardItem>(
                    value: CardItem.delete,
                    child: Text(l10n.generalButtonDelete),
                  ),
                ]));
  }

  Widget getButtonBar(BuildContext context) {
    final l10n = l10nOf(context);

    return ButtonBar(
      alignment: MainAxisAlignment.start,
      overflowDirection: VerticalDirection.down,
      overflowButtonSpacing: ThemePaddings.smallPadding,
      buttonPadding: const EdgeInsets.fromLTRB(ThemeFontSizes.large,
          ThemeFontSizes.large, ThemeFontSizes.large, ThemeFontSizes.large),
      children: isItemWatchOnly()
          ? [getAssetsButton(context)]
          : [
              widget.item.amount != null //&& widget.item.
                  ? ThemedControls.primaryButtonBig(
                      onPressed: () {
                        // Perform some action
                        pushScreen(
                          context,
                          screen: Send(item: widget.item),
                          withNavBar: false, // OPTIONAL VALUE. True by default.
                          pageTransitionAnimation:
                              PageTransitionAnimation.cupertino,
                        );
                      },
                      text: l10n.accountButtonSend,
                      icon: LightThemeColors.shouldInvertIcon
                          ? ThemedControls.invertedColors(
                              child: Image.asset("assets/images/send.png"))
                          : Image.asset("assets/images/send.png"))
                  : Container(),
              ThemedControls.primaryButtonBig(
                onPressed: () {
                  pushScreen(
                    context,
                    screen: Receive(item: widget.item),
                    withNavBar: false, // OPTIONAL VALUE. True by default.
                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                  );
                },
                icon: !LightThemeColors.shouldInvertIcon
                    ? ThemedControls.invertedColors(
                        child: Image.asset("assets/images/receive.png"))
                    : Image.asset("assets/images/receive.png"),
                text: l10n.accountButtonReceive,
              ),
              getAssetsButton(context),
            ],
    );
  }

  Widget getAssetsButton(BuildContext context) {
    final l10n = l10nOf(context);
    return widget.item.assets.keys.isNotEmpty
        ? ThemedControls.primaryButtonBig(
            text: l10n.accountButtonAssets,
            onPressed: () {
              pushScreen(
                context,
                screen: Assets(publicId: widget.item.publicId),
                withNavBar: false, // OPTIONAL VALUE. True by default.
                pageTransitionAnimation: PageTransitionAnimation.cupertino,
              );
            })
        : Container();
  }

  Widget getAssets(BuildContext context) {
    List<Widget> shares = [];
    final l10n = l10nOf(context);

    for (var key in widget.item.assets.keys) {
      var asset = widget.item.assets[key];

      if (asset!.ownedAmount! > 0) {
        shares.add(AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (Widget child, Animation<double> animation) {
              //return FadeTransition(opacity: animation, child: child);
              return SizeTransition(sizeFactor: animation, child: child);
              //return ScaleTransition(scale: animation, child: child);
            },
            child: AmountFormatted(
              key: ValueKey<String>(
                  "qubicAsset${widget.item.publicId}-$key-$asset"),
              amount: asset.ownedAmount,
              isInHeader: false,
              labelOffset: -0,
              labelHorizOffset: -6,
              textStyle: MediaQuery.of(context).size.width < 400
                  ? TextStyles.accountAmount.copyWith(fontSize: 16)
                  : TextStyles.accountAmount,
              labelStyle: TextStyles.accountAmountLabel,
              currencyName: asset.assetName,
            )));
      }
    }
    return AnimatedCrossFade(
        firstChild: Container(
            width: double.infinity,
            alignment: Alignment.centerRight,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.end, children: shares)),
        secondChild:
            shares.isNotEmpty ? Text(l10n.generalLabelHidden) : Container(),
        crossFadeState: totalBalanceVisible
            ? CrossFadeState.showFirst
            : CrossFadeState.showSecond,
        duration: 300.ms);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return Container(
        constraints: const BoxConstraints(minWidth: 400, maxWidth: 500),
        child: Card(
            color: LightThemeColors.cardBackground,
            elevation: 0,
            child: Column(children: [
              Padding(
                  padding: const EdgeInsets.fromLTRB(
                      ThemePaddings.normalPadding,
                      ThemePaddings.normalPadding,
                      ThemePaddings.normalPadding,
                      0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Flex(
                            direction: Axis.horizontal,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                  fit: FlexFit.loose,
                                  child: Row(children: [
                                    Text(widget.item.name,
                                        style: TextStyles.accountName),
                                    ThemedControls.spacerHorizontalSmall(),
                                    isItemWatchOnly()
                                        ? const Icon(
                                            Icons.remove_red_eye_rounded,
                                            color: LightThemeColors.color4,
                                          )
                                        : Container(),
                                  ])),
                              getCardMenu(context)
                            ]),
                        ThemedControls.spacerVerticalSmall(),
                        Text(widget.item.publicId),
                        ThemedControls.spacerVerticalSmall(),
                        AnimatedCrossFade(
                          duration: const Duration(milliseconds: 300),
                          firstChild: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 500),
                              transitionBuilder:
                                  (Widget child, Animation<double> animation) {
                                //return FadeTransition(opacity: animation, child: child);
                                return SizeTransition(
                                    sizeFactor: animation, child: child);
                                //return ScaleTransition(scale: animation, child: child);
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AmountFormatted(
                                    key: ValueKey<String>(
                                        "qubicAmount${widget.item.publicId}-${widget.item.amount}"),
                                    amount: widget.item.amount,
                                    isInHeader: false,
                                    labelOffset: -0,
                                    labelHorizOffset: -6,
                                    textStyle:
                                        MediaQuery.of(context).size.width < 400
                                            ? TextStyles.accountAmount
                                                .copyWith(fontSize: 22)
                                            : TextStyles.accountAmount,
                                    labelStyle: TextStyles.accountAmountLabel,
                                    currencyName:
                                        l10n.generalLabelCurrencyQubic,
                                  ),
                                  Text(
                                      CurrencyHelpers.formatToUsdCurrency(
                                          (widget.item.amount ?? 0) *
                                              (_appStore.marketInfo?.price ??
                                                  0)),
                                      style: TextStyles.sliverSmall),
                                  if (widget.item.assets.isNotEmpty)
                                    ThemedControls.spacerVerticalSmall(),
                                ],
                              )),
                          secondChild: Text(l10n.generalLabelHidden,
                              style: MediaQuery.of(context).size.width < 400
                                  ? TextStyles.accountAmount
                                      .copyWith(fontSize: 22)
                                  : TextStyles.accountAmount),
                          crossFadeState: totalBalanceVisible
                              ? CrossFadeState.showFirst
                              : CrossFadeState.showSecond,
                        ),
                        getAssets(context)
                      ])),
              getButtonBar(context),
            ])));
  }
}
