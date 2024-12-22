import 'package:qubic_wallet/models/wallet_connect/request_send_qubic_event.dart';

class RequestSendTransactionEvent extends RequestSendQubicEvent {
  final int? inputType;
  final String? payload;

  RequestSendTransactionEvent({
    required super.topic,
    required super.requestId,
    required super.fromID,
    required super.toID,
    required super.amount,
    required super.tick,
    this.inputType,
    this.payload,
  });

  @override
  dynamic getData() {
    final baseData = super.getData();
    return {
      ...baseData,
      if (inputType != null) 'inputType': inputType,
      if (payload != null) 'payload': payload,
    };
  }

  factory RequestSendTransactionEvent.fromMap(
      Map<String, dynamic> map, String topic, int requestId) {
    final baseEvent = RequestSendQubicEvent.fromMap(map, topic, requestId);
    return RequestSendTransactionEvent(
      topic: baseEvent.topic,
      requestId: baseEvent.requestId,
      fromID: baseEvent.fromID,
      toID: baseEvent.toID,
      amount: baseEvent.amount,
      tick: baseEvent.tick,
      inputType:
          map["inputType"] != null ? int.tryParse(map["inputType"]) : null,
      payload: map["payload"],
    );
  }
}
