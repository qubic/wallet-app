// A request event for wallet_requestAccounts
import 'package:qubic_wallet/models/wallet_connect/request_event.dart';

class RequestAccountsEvent extends RequestEvent {
  RequestAccountsEvent(
      {required super.topic,
      required super.requestId,
      required super.redirectUrl});
}
