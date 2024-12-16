/// A request event - for in app exchange of info when a dApp makes a request (e.g. wallet_requestAccounts)
class RequestEvent {
  final String topic;
  final int requestId;
  const RequestEvent({required this.topic, required this.requestId});
}
