class NetworkModel {
  final String name;
  final String rpcUrl;
  final String liUrl;

  const NetworkModel(
    this.name,
    this.rpcUrl,
    this.liUrl,
  );

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'rpcUrl': rpcUrl,
      'liUrl': liUrl,
    };
  }

  factory NetworkModel.fromJson(Map<String, dynamic> json) {
    return NetworkModel(
      json['name'] as String,
      json['rpcUrl'] as String,
      json['liUrl'] as String,
    );
  }

  @override
  String toString() =>
      'NetworkModel(name: $name, rpcUrl: $rpcUrl, liUrl: $liUrl)';

  @override
  int get hashCode => name.hashCode ^ rpcUrl.hashCode ^ liUrl.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NetworkModel &&
        other.name == name &&
        other.rpcUrl == rpcUrl &&
        other.liUrl == liUrl;
  }
}
