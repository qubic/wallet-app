// ignore: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:qubic_wallet/components/transaction_details.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/address_ui_helper.dart';
import 'package:qubic_wallet/helpers/format_helpers.dart';
import 'package:qubic_wallet/helpers/transaction_status_helpers.dart';
import 'package:qubic_wallet/helpers/transaction_ui_helpers.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/models/qubic_asset_transfer.dart';
import 'package:qubic_wallet/models/qubic_list_vm.dart';
import 'package:qubic_wallet/models/transaction_vm.dart';
import 'package:qubic_wallet/resources/qubic_cmd.dart';
import 'package:qubic_wallet/smart_contracts/qx_info.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/styles/app_icons.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TransactionItem extends StatefulWidget {
  final TransactionVm item;
  final String currentAccountId;

  const TransactionItem(
      {super.key, required this.item, required this.currentAccountId});

  @override
  State<TransactionItem> createState() => _TransactionItemState();
}

class _TransactionItemState extends State<TransactionItem> {
  final ApplicationStore appStore = getIt<ApplicationStore>();
  QubicAssetTransfer? assetTransfer;

  bool get isQxTransferShares =>
      QxInfo.isQxTransferShares(widget.item.destId, widget.item.type);

  /// True when the current account is the destination (receiving funds)
  late final bool isIncoming;

  @override
  void initState() {
    super.initState();
    isIncoming = widget.item.destId == widget.currentAccountId;

    if (isQxTransferShares) {
      getIt<QubicCmd>()
          .parseAssetTransferPayload(widget.item.inputHex!)
          .then((value) {
        setState(() {
          assetTransfer = value;
        });
      });
    }
  }

  void showDetails(BuildContext context) {
    showModalBottomSheet<void>(
        useRootNavigator: true,
        showDragHandle: false,
        useSafeArea: true,
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
              child: TransactionDetails(
                  item: widget.item,
                  assetTransfer: assetTransfer,
                  currentAccountId: widget.currentAccountId));
        });
  }

  /// Returns the address to display based on direction
  String get directionAddress {
    if (isIncoming) {
      return widget.item.sourceId;
    }
    if (isQxTransferShares && assetTransfer != null) {
      return assetTransfer!.newOwnerAndPossessor;
    }
    return widget.item.destId;
  }

  /// Returns the direction label ("From" or "To")
  String directionLabel(BuildContext context) {
    final l10n = l10nOf(context);
    if (isIncoming) {
      return l10n.generalLabelFrom;
    }
    return l10n.generalLabelTo;
  }

  /// Returns the display name for an address:
  /// account name > smart contract/token label > truncated address
  String getAddressDisplayName(BuildContext context, String address) {
    final QubicListVm? account = appStore.findAccountById(address);
    if (account != null) return account.name;
    final label = AddressUIHelper.getLabel(context, address);
    if (label != null) return label;
    return AddressUIHelper.truncateAddress(address);
  }

  /// Direction arrow asset: receive for incoming, send for outgoing
  String get directionIconAsset {
    return isIncoming ? AppIcons.receiveArrow : AppIcons.sendArrow;
  }

  /// Direction is conveyed by the icon shape (send vs receive); status is
  /// conveyed by the inline status label. The badge itself is always the
  /// neutral app accent so it matches the rest of the UI.
  Color get directionBadgeColor => LightThemeColors.buttonPrimary;

  /// Returns the formatted amount string (color conveys direction, no +/- prefix)
  String get formattedAmount {
    final int amount;
    final String unit;

    if (isQxTransferShares && assetTransfer != null) {
      amount = int.tryParse(assetTransfer!.numberOfUnits) ?? 0;
      unit = assetTransfer!.assetName;
    } else {
      amount = widget.item.amount;
      unit = "QUBIC";
    }

    final formatted = formatAmount(amount);
    return "$formatted $unit";
  }

  /// Returns the color for the amount based on status and direction.
  /// Failed/invalid → grey (didn't happen), zero amount → grey (no balance
  /// change), otherwise green/red by direction.
  Color amountColorForStatus(ComputedTransactionStatus status) {
    if (status == ComputedTransactionStatus.failure ||
        status == ComputedTransactionStatus.invalid) {
      return LightThemeColors.secondaryTypography;
    }
    if (widget.item.amount == 0) {
      return LightThemeColors.secondaryTypography;
    }
    return isIncoming
        ? LightThemeColors.successIncoming
        : LightThemeColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.item.getStatus();
    final statusColor =
        TransactionStatusHelpers.getTransactionStatusColor(status);
    final l10n = l10nOf(context);
    String? statusLabel;
    switch (status) {
      case ComputedTransactionStatus.pending:
        statusLabel = l10n.transactionLabelStatusPending;
        break;
      case ComputedTransactionStatus.failure:
        statusLabel = l10n.transactionLabelStatusFailed;
        break;
      case ComputedTransactionStatus.invalid:
        statusLabel = l10n.transactionLabelStatusInvalid;
        break;
      case ComputedTransactionStatus.success:
      case ComputedTransactionStatus.executed:
        statusLabel = null;
    }
    final showAmount =
        !isQxTransferShares || (isQxTransferShares && assetTransfer != null);
    final whiteSmall = TextStyles.lightGreyTextSmall
        .copyWith(color: LightThemeColors.primary);

    return ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 400, maxWidth: 500),
        child: ThemedControls.card(
            padding: const EdgeInsets.only(
                left: ThemePaddings.smallPadding,
                right: ThemePaddings.normalPadding,
                top: ThemePaddings.mediumPadding,
                bottom: ThemePaddings.mediumPadding),
            child: InkWell(
                onTap: () => showDetails(context),
                borderRadius: BorderRadius.circular(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _DirectionBadge(
                      color: directionBadgeColor,
                      iconAsset: directionIconAsset,
                    ),
                    const SizedBox(width: ThemePaddings.smallPadding),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Line 1: Transaction type [+ status] ............ Amount
                          // Priority: amount + status always fit; type truncates first.
                          // Wrapped in an Observer so the type label updates
                          // reactively once the ecosystem store loads protocol
                          // input types or smart contract data.
                          Observer(builder: (context) {
                            final isSimpleTransfer = (widget.item.type ?? 0) == 0;
                            final txType = isSimpleTransfer
                                ? (isIncoming
                                    ? l10n.transactionItemLabelReceived
                                    : l10n.transactionItemLabelSent)
                                : TransactionUIHelpers.getTransactionType(
                                    widget.item.type ?? 0, widget.item.destId);
                            return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text(txType,
                                          style: TextStyles.labelTextSmall,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1),
                                    ),
                                    if (statusLabel != null) ...[
                                      Text(' · ',
                                          style: TextStyles.labelTextSmall
                                              .copyWith(color: statusColor)),
                                      Text(statusLabel,
                                          style: TextStyles.labelTextSmall
                                              .copyWith(color: statusColor),
                                          maxLines: 1),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(width: ThemePaddings.smallPadding),
                              if (showAmount)
                                Text(formattedAmount,
                                    style: TextStyles.textSmall.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: amountColorForStatus(status))),
                            ],
                            );
                          }),
                          const SizedBox(height: 2),
                          // Line 2: From/To + name (truncatedAddress) — white text
                          Observer(builder: (context) {
                            final address = directionAddress;
                            final displayName =
                                getAddressDisplayName(context, address);
                            final truncated =
                                AddressUIHelper.truncateAddress(address);
                            final hasName = displayName != truncated;
                            final label = directionLabel(context);
                            final isSC =
                                AddressUIHelper.isSmartContract(address);
                            return Row(
                              children: [
                                Text("$label: ", style: whiteSmall),
                                if (isSC) ...[
                                  SvgPicture.asset(AppIcons.smartContract,
                                      width: 14,
                                      height: 14,
                                      colorFilter: ColorFilter.mode(
                                          whiteSmall.color!, BlendMode.srcIn)),
                                  const SizedBox(width: 4),
                                ],
                                Flexible(
                                  child: Text(displayName,
                                      style: whiteSmall,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1),
                                ),
                                if (hasName)
                                  Text(' ($truncated)', style: whiteSmall),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ))));
  }
}

/// Circular direction badge matching the wallet-extension transaction row:
/// a 28px circle with a tinted border + fill, centered direction icon.
class _DirectionBadge extends StatelessWidget {
  final Color color;
  final String iconAsset;

  const _DirectionBadge({required this.color, required this.iconAsset});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.10),
        border: Border.all(color: color.withValues(alpha: 0.40), width: 1),
      ),
      child: Center(
        child: SvgPicture.asset(
          iconAsset,
          width: 14,
          height: 14,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
      ),
    );
  }
}
