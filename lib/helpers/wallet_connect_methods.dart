import 'package:flutter/widgets.dart';
import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/models/wallet_connect.dart';
import 'package:reown_walletkit/reown_walletkit.dart';

/// Returns a list of localized strings matching the available WC pairing methods
List<String> getLocalizedPairingMethods(
    List<String> pairingMethods, BuildContext context) {
  final l10n = l10nOf(context);
  List<String> methods = [];
  for (var pairingMethod in pairingMethods) {
    if (pairingMethod == WcMethods.wRequestAccounts) {
      methods.add(l10n.wcScopeRequestAccounts);
    } else if (pairingMethod == WcMethods.wSendQubic) {
      methods.add(l10n.wcScopeSendQubic);
    } else if (pairingMethod == WcMethods.wSendAsset) {
      methods.add(l10n.wcScopeSendAssets);
    } else if (pairingMethod == WcMethods.wSignTransaction) {
      methods.add(l10n.wcScopeSignTransaction);
    } else if (pairingMethod == WcMethods.wSign) {
      methods.add(l10n.wcScopeSign);
    }
  }
  return methods;
}

String handleUnSupportedNetworkError(
    SessionProposalErrorEvent args, AppLocalizations l10n) {
  List<String> unSupportedNetworks = [];
  List<String?> requiredNetworkIDs = [];
  args.requiredNamespaces.forEach((key, value) {
    requiredNetworkIDs.addAll(value.chains?.toList() ?? []);
  });
  for (var network in requiredNetworkIDs) {
    if (network != null && network != Config.walletConnectChainId) {
      unSupportedNetworks.add(network);
    }
  }
  final title = l10n.wcErrorUnsupportedNetwork;
  final desc = l10n.wcErrorUnsupportedNetworkDescription(
      getUnsupportedNetworks(unSupportedNetworks));

  return "$title: $desc";
}

String formatNetworkName(String network) {
  int colonIndex = network.indexOf(':');
  bool isEIP = network.startsWith('eip155');

  // Check if the network starts with "qubic"
  if (network.startsWith('qubic') && colonIndex > -1) {
    String qubicEnv =
        network.substring(colonIndex + 1); // Get the environment after "qubic:"
    return 'Qubic ${qubicEnv[0].toUpperCase()}${qubicEnv.substring(1)}'; // Capitalize first letter of environment
  }

  // If not EIP and colon is found
  if (!isEIP && colonIndex > -1) {
    String name = network.substring(0, colonIndex);
    return name[0].toUpperCase() + name.substring(1); // Capitalize first letter
  }

  // If it's an EIP network or no colon is found, return the full network
  return network;
}

String getUnsupportedNetworks(List<String> unsupportedNetworks) {
  if (unsupportedNetworks.length == 1) {
    return formatNetworkName(unsupportedNetworks[0]);
  } else {
    final networks = unsupportedNetworks.map(formatNetworkName).toList();
    return "$networks";
  }
}

String? validateWalletConnectURL(String? valueCandidate, BuildContext context) {
  final l10n = l10nOf(context);

  const requiredPatterns = ['expiryTimestamp=', 'symKey=', '@'];
  const requiredStart = 'wc:';

  if (valueCandidate == null ||
      !valueCandidate.startsWith(requiredStart) ||
      !requiredPatterns.every((pattern) => valueCandidate.contains(pattern))) {
    return l10n.wcErrorInvalidURL;
  }

  if (valueCandidate.contains("@1")) {
    return l10n.wcErrorDeprecatedURL;
  }

  return null;
}
