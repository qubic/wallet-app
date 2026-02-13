// ignore: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:qubic_wallet/components/transaction_details.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/address_ui_helper.dart';
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
  final NumberFormat numberFormat = NumberFormat.decimalPattern("en_US");
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
                  item: widget.item, assetTransfer: assetTransfer));
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
  String getAddressDisplayName(String address) {
    final QubicListVm? account = appStore.findAccountById(address);
    if (account != null) return account.name;
    final label = AddressUIHelper.getLabel(address);
    if (label != null) return label;
    return AddressUIHelper.truncateAddress(address);
  }

  /// Direction arrow: green down for incoming, red up for outgoing
  IconData get directionIcon {
    return isIncoming ? Icons.arrow_downward : Icons.arrow_upward;
  }

  Color get directionColor {
    return isIncoming
        ? LightThemeColors.successIncoming
        : LightThemeColors.error;
  }

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

    final formatted = numberFormat.format(amount);
    return "$formatted $unit";
  }

  /// Returns the color for the amount based on status and direction.
  /// Failed/invalid → grey, zero → green, otherwise green/red by direction.
  Color amountColorForStatus(ComputedTransactionStatus status) {
    if (status == ComputedTransactionStatus.failure ||
        status == ComputedTransactionStatus.invalid) {
      return LightThemeColors.secondaryTypography;
    }
    if (widget.item.amount == 0) return LightThemeColors.successIncoming;
    return isIncoming
        ? LightThemeColors.successIncoming
        : LightThemeColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.item.getStatus();
    final statusIcon =
        TransactionStatusHelpers.getTransactionStatusIcon(status);
    final statusColor =
        TransactionStatusHelpers.getTransactionStatusColor(status);
    final txType = TransactionUIHelpers.getTransactionType(
        widget.item.type ?? 0, widget.item.destId);

    return ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 400, maxWidth: 500),
        child: ThemedControls.card(
            padding: const EdgeInsets.only(
                left: ThemePaddings.smallPadding,
                right: ThemePaddings.normalPadding,
                top: ThemePaddings.smallPadding,
                bottom: ThemePaddings.smallPadding),
            child: InkWell(
                onTap: () => showDetails(context),
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Lines 1-2: Arrow centered vertically beside tx type + from/to
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(directionIcon, color: directionColor, size: 20),
                        const SizedBox(width: ThemePaddings.smallPadding),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Line 1: Transaction type + Status icon
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(txType,
                                        style: TextStyles.labelTextSmall,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1),
                                  ),
                                  const SizedBox(
                                      width: ThemePaddings.miniPadding),
                                  Icon(statusIcon,
                                      color: statusColor, size: 16),
                                ],
                              ),
                              const SizedBox(height: 2),
                              // Line 2: From/To + address label
                              Observer(builder: (context) {
                                final address = directionAddress;
                                final displayName =
                                    getAddressDisplayName(address);
                                final label = directionLabel(context);
                                final isSC =
                                    AddressUIHelper.isSmartContract(address);
                                return Row(
                                  children: [
                                    Text("$label: ",
                                        style:
                                            TextStyles.lightGreyTextSmall),
                                    if (isSC) ...[
                                      SvgPicture.asset(
                                          AppIcons.smartContract,
                                          width: 14,
                                          height: 14,
                                          colorFilter: ColorFilter.mode(
                                              TextStyles
                                                  .lightGreyTextSmall.color!,
                                              BlendMode.srcIn)),
                                      const SizedBox(width: 4),
                                    ],
                                    Flexible(
                                      child: Text(displayName,
                                          style:
                                              TextStyles.lightGreyTextSmall,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1),
                                    ),
                                  ],
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Line 3: Amount (right-aligned)
                    if (!isQxTransferShares ||
                        (isQxTransferShares && assetTransfer != null))
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(formattedAmount,
                            style: TextStyles.textSmall.copyWith(
                                fontWeight: FontWeight.w600,
                                color: amountColorForStatus(status))),
                      ),
                  ],
                ))));
  }
}
