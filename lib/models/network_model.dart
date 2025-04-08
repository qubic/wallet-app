import 'package:hive_flutter/adapters.dart';

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

class NetworkAdapter extends TypeAdapter<NetworkModel> {
  @override
  NetworkModel read(BinaryReader reader) {
    return NetworkModel(
      name: reader.readString(),
      rpcUrl: reader.readString(),
      explorerUrl: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, NetworkModel obj) {
    writer.writeString(obj.name);
    writer.writeString(obj.rpcUrl);
    writer.writeString(obj.explorerUrl);
  }

  @override
  int get typeId => 3;
}
