import 'dart:async';

import 'package:mobx/mobx.dart';
import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/models/wallet_connect.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/stores/settings_store.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

class WalletConnectService {
  final ApplicationStore appStore = getIt<ApplicationStore>();
  final SettingsStore settingsStore = getIt<SettingsStore>();
  bool isReady = false;

  PairingInfo? pairingInfo;

  Web3Wallet? web3Wallet;

  /// Event that is triggered when a session is connected
  StreamController<SessionConnect?> onSessionConnect =
      StreamController<SessionConnect?>.broadcast();

  /// Event that is triggered when a session proposal is received
  StreamController<SessionProposalEvent?> onSessionProposal =
      StreamController<SessionProposalEvent?>.broadcast();

  /// Event that is triggered when a session is disconnected
  StreamController<SessionDelete?> onSessionDisconnect =
      StreamController<SessionDelete?>.broadcast();

  /// Event that is triggered when a session is disconnected
  StreamController<SessionExpire?> onSessionExpire =
      StreamController<SessionExpire?>.broadcast();

  /// Event that is triggered when a session proposal event is expired
  StreamController<SessionProposalEvent?> onProposalExpire =
      StreamController<SessionProposalEvent?>.broadcast();

  StreamController<RequestAccountsEvent> onRequestAccounts =
      StreamController<RequestAccountsEvent>.broadcast();
  StreamController<void> onRequestSendQubic =
      StreamController<SessionConnect?>.broadcast();
  StreamController<void> onRequestSendToken =
      StreamController<SessionConnect?>.broadcast();

  void disconnect() {
    web3Wallet!
        .getActiveSessions()
        .forEach(((String session, SessionData sessionData) {
      //web3Wallet!.sessions.delete(session);
      web3Wallet!.disconnectSession(
          reason: WalletConnectError(
              code: -1, message: "User forcefully disconnected"),
          topic: sessionData.topic);
    }));
  }

  /// Checks that walletconnect is initialized before trying to trigger an event
  bool shouldTriggerEvent() {
    if (!settingsStore.settings.walletConnectEnabled) {
      return false;
    }
    if (web3Wallet == null) {
      return false;
    }
    if (web3Wallet!.getActiveSessions().isEmpty) {
      return false;
    }
    return true;
  }

  //Trigger of events to be received in a dapp
  //Triggers an amount changed event for the wallet connect clients
  void triggerAmountChangedEvent() {
    if (!shouldTriggerEvent()) {
      return;
    }
    // web3Wallet!.emitSessionEvent(
    //     topic: sessionInfo!.session.topic,
    //     chainId: Config.walletConnectChainId,
    //     event: SessionEventParams(
    //         name: "amountChanged",
    //         data: {"amount": appStore.currentQubicIDs.length}));
  }

//Triggers an token amount change event for the wallet connect clients
  void triggerTokenAmountChangedEvent() {
    if (!shouldTriggerEvent()) {
      return;
    }
  }

  //accountsChanged
  void triggerAccountsChangedEvent() {
    if (!shouldTriggerEvent()) {
      return;
    }
  }

  //tickChanged
  void triggerTickChangedEvent() {
    if (!shouldTriggerEvent()) {
      return;
    }
  }

  initialize() async {
    if (web3Wallet != null) {
      return;
    }

    web3Wallet = await Web3Wallet.createInstance(
        projectId: Config.walletConnectProjectId,
        metadata: const PairingMetadata(
          name: Config.walletConnectName,
          description: Config.walletConnectDescription,
          url: Config.walletConnectURL,
          icons: [...Config.walletConnectIcons],
          redirect: Redirect(
            native: Config.walletConnectRedirectNative,
            universal: Config.walletConnectRedirectUniversal,
          ),
        ));

    //Event bubbling
    web3Wallet!.onSessionConnect.subscribe((args) {
      onSessionConnect.add(args);
    });

    web3Wallet!.onSessionDelete.subscribe((SessionDelete? args) {
      onSessionDisconnect.add(args);
    });

    web3Wallet!.onSessionExpire.subscribe((SessionExpire? args) {
      onSessionExpire.add(args);
    });

    web3Wallet!.onProposalExpire.subscribe((SessionProposalEvent? args) {
      onProposalExpire.add(args);
    });

    web3Wallet!.onSessionProposal.subscribe((SessionProposalEvent? args) {
      onSessionProposal.add(args);
    });

    web3Wallet!.onProposalExpire.subscribe((SessionProposalEvent? args) {
      onSessionProposal.add(args);
    });

    web3Wallet!.core.relayClient.onRelayClientDisconnect.subscribe((args) {
      if (settingsStore.settings.walletConnectEnabled) {
        web3Wallet!.core.relayClient.connect();
      }
    });

    //Event emitter registrations
    web3Wallet!.registerEventEmitter(
        chainId: Config.walletConnectChainId, event: wcEvents.amountChanged);
    web3Wallet!.registerEventEmitter(
        chainId: Config.walletConnectChainId,
        event: wcEvents.tokenAmountChanged);
    web3Wallet!.registerEventEmitter(
        chainId: Config.walletConnectChainId, event: wcEvents.accountsChanged);
    web3Wallet!.registerEventEmitter(
        chainId: Config.walletConnectChainId, event: wcEvents.tickChanged);

    web3Wallet!.registerRequestHandler(
        chainId: Config.walletConnectChainId,
        method: wcMethods.wRequestAccounts,
        handler: (topic, args) {
          onRequestAccounts.add(RequestAccountsEvent(topic: topic));
          print("GOT wallet_requestAccounts");
          print(topic);
          List<dynamic> data = [];
          appStore.currentQubicIDs.forEach(((id) {
            dynamic item = {};
            item["address"] = id.publicId;
            item["name"] = id.name;
            data.add(item);
          }));

          web3Wallet!.emitSessionEvent(
              topic: topic,
              chainId: Config.walletConnectChainId,
              event: SessionEventParams(name: "accountsChanged", data: data));
        });

    web3Wallet!.registerRequestHandler(
        chainId: Config.walletConnectChainId,
        method: wcMethods.wSendQubic,
        handler: (name, args) {});

    web3Wallet!.registerRequestHandler(
        chainId: Config.walletConnectChainId,
        method: wcMethods.wSendAsset,
        handler: (name, args) {});

    web3Wallet!.registerAccount(
        accountAddress:
            "000000000000000000000000000000000000000000000000000000000000",
        chainId: Config.walletConnectChainId);

    appStore.currentQubicIDs.forEach(((id) {
      web3Wallet!.registerAccount(
          accountAddress: id.publicId, chainId: Config.walletConnectChainId);
    }));
  }

  WalletConnectService() {}

  /// Pairs WC with a URL
  Future<PairingInfo> pair(Uri uri) async {
    pairingInfo = await web3Wallet!.pair(uri: uri);
    return pairingInfo!;
  }
}
