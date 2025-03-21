class NetworkModel {
  final String name;
  final String rpcUrl;
  final String explorerUrl;

  const NetworkModel({
    required this.name,
    required this.rpcUrl,
    required this.explorerUrl,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'rpcUrl': rpcUrl,
      'explorerUrl': explorerUrl,
    };
  }

  factory NetworkModel.fromJson(Map<String, dynamic> json) {
    return NetworkModel(
      name: json['name'],
      rpcUrl: json['rpcUrl'],
      explorerUrl: json['explorerUrl'],
    );
  }

  @override
  String toString() =>
      'NetworkModel(name: $name, rpcUrl: $rpcUrl, explorerUrl: $explorerUrl)';

  @override
  int get hashCode => name.hashCode ^ rpcUrl.hashCode ^ explorerUrl.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NetworkModel &&
        other.name == name &&
        other.rpcUrl == rpcUrl &&
        other.explorerUrl == explorerUrl;
  }
}
