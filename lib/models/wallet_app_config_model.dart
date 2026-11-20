class WalletAppConfigResponse {
  /// Offset added to the current tick when building a transaction's target
  /// tick. Null when the key is absent.
  final int? defaultTickOffset;

  WalletAppConfigResponse({this.defaultTickOffset});

  factory WalletAppConfigResponse.fromJson(Map<String, dynamic> json) {
    return WalletAppConfigResponse(
      defaultTickOffset: json['default_tick_offset'],
    );
  }
}
