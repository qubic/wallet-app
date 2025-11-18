import 'package:hive/hive.dart';

class FavoriteDappModel {
  String name;
  String url;
  DateTime createdAt;
  String? iconUrl;

  FavoriteDappModel({
    required this.name,
    required this.url,
    required this.createdAt,
    this.iconUrl,
  });

  FavoriteDappModel.fromJson(Map<String, dynamic> json)
      : name = json['name'] as String,
        url = json['url'] as String,
        createdAt = DateTime.parse(json['createdAt'] as String),
        iconUrl = json['iconUrl'] as String?;

  Map<String, dynamic> toJson() => {
        'name': name,
        'url': url,
        'createdAt': createdAt.toIso8601String(),
        'iconUrl': iconUrl,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteDappModel &&
          runtimeType == other.runtimeType &&
          url == other.url;

  @override
  int get hashCode => url.hashCode;
}

class FavoriteDappAdapter extends TypeAdapter<FavoriteDappModel> {
  @override
  FavoriteDappModel read(BinaryReader reader) {
    final name = reader.readString();
    final url = reader.readString();
    final createdAt = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    // Read iconUrl if available (backward compatibility)
    String? iconUrl;
    try {
      iconUrl = reader.readString();
      if (iconUrl.isEmpty) iconUrl = null;
    } catch (e) {
      iconUrl = null;
    }
    return FavoriteDappModel(
      name: name,
      url: url,
      createdAt: createdAt,
      iconUrl: iconUrl,
    );
  }

  @override
  void write(BinaryWriter writer, FavoriteDappModel obj) {
    writer.writeString(obj.name);
    writer.writeString(obj.url);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
    writer.writeString(obj.iconUrl ?? '');
  }

  @override
  int get typeId => 4;
}
