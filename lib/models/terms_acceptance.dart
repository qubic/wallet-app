import 'package:hive/hive.dart';

class TermsAcceptance {
  String version;
  DateTime acceptedAt;
  String appVersion;

  TermsAcceptance({
    required this.version,
    required this.acceptedAt,
    required this.appVersion,
  });

  TermsAcceptance.fromJson(Map<String, dynamic> json)
      : version = json['version'] as String,
        acceptedAt = DateTime.parse(json['acceptedAt'] as String),
        appVersion = json['appVersion'] as String;

  Map<String, dynamic> toJson() => {
        'version': version,
        'acceptedAt': acceptedAt.toIso8601String(),
        'appVersion': appVersion,
      };

  @override
  String toString() {
    return 'TermsAcceptance(version: $version, acceptedAt: $acceptedAt, appVersion: $appVersion)';
  }
}

class TermsAcceptanceAdapter extends TypeAdapter<TermsAcceptance> {
  @override
  TermsAcceptance read(BinaryReader reader) {
    final version = reader.readString();
    final acceptedAt = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    final appVersion = reader.readString();
    return TermsAcceptance(
      version: version,
      acceptedAt: acceptedAt,
      appVersion: appVersion,
    );
  }

  @override
  void write(BinaryWriter writer, TermsAcceptance obj) {
    writer.writeString(obj.version);
    writer.writeInt(obj.acceptedAt.millisecondsSinceEpoch);
    writer.writeString(obj.appVersion);
  }

  @override
  int get typeId => 5; // FavoriteDapp uses 4, so we use 5
}
