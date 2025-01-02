/// A request event - for in app exchange of info when a dApp makes a request (e.g. wallet_requestAccounts)
class RequestEvent {
  final String topic;
  final int requestId;
  RequestEvent({required this.topic, required this.requestId});
}

const String wcRequestParamFrom = "from";
const String wcRequestParamTo = "to";
const String wcRequestParamAmount = "amount";
const String wcRequestParamTick = "tick";
