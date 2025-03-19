class NetworkModel {
  final String name;
  final String rpcUrl;
  final String liUrl;
  final String explorerUrl;

  const NetworkModel({
    required this.name,
    required this.rpcUrl,
    required this.liUrl,
    required this.explorerUrl,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'rpcUrl': rpcUrl,
      'liUrl': liUrl,
      'explorerUrl': explorerUrl,
    };
  }

  factory NetworkModel.fromJson(Map<String, dynamic> json) {
    return NetworkModel(
      name: json['name'],
      rpcUrl: json['rpcUrl'],
      liUrl: json['liUrl'],
      explorerUrl: json['explorerUrl'],
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
