class DappDto {
  final String id;
  final String? nameId;
  final String? icon;
  final String? url;
  final String? descriptionId;
  final String? customDescriptionId;
  final String? description;
  final String? name;

  DappDto({
    required this.id,
    required this.nameId,
    required this.icon,
    required this.url,
    required this.descriptionId,
    required this.customDescriptionId,
    this.description,
    this.name,
  });

  factory DappDto.fromJson(Map<String, dynamic> json) {
    return DappDto(
      id: json['id'],
      nameId: json['nameId'],
      icon: json['icon'],
      url: json['url'],
      descriptionId: json['descriptionId'],
      customDescriptionId: json['customDescriptionId'],
    );
  }

  DappDto copyWith({
    String? id,
    String? nameId,
    String? icon,
    String? url,
    String? descriptionId,
    String? customDescriptionId,
    String? description,
    String? name,
  }) {
    return DappDto(
      id: id ?? this.id,
      nameId: nameId ?? this.nameId,
      icon: icon ?? this.icon,
      url: url ?? this.url,
      descriptionId: descriptionId ?? this.descriptionId,
      customDescriptionId: customDescriptionId ?? this.customDescriptionId,
      description: description ?? this.description,
      name: name ?? this.name,
    );
  }

  @override
  String toString() {
    return 'DappDto(id: $id, nameId: $nameId, icon: $icon, url: $url, descriptionId: $descriptionId, customDescriptionId: $customDescriptionId, description: $description, name: $name)';
  }
}

class FeaturedAppDto {
  final String? id;
  final String? customDescriptionId;

  FeaturedAppDto({
    required this.id,
    required this.customDescriptionId,
  });

  factory FeaturedAppDto.fromJson(Map<String, dynamic> json) {
    return FeaturedAppDto(
      id: json['id'],
      customDescriptionId: json['customDescriptionId'],
    );
  }
}

class DappsResponse {
  final String version;
  final FeaturedAppDto? featuredApp;
  final List<String> topApps;
  List<DappDto> dapps;

  DappsResponse({
    required this.version,
    this.featuredApp,
    required this.topApps,
    required this.dapps,
  });

  factory DappsResponse.fromJson(Map<String, dynamic> json) {
    return DappsResponse(
      version: json['version'],
      featuredApp: json['featuredApp'] != null
          ? FeaturedAppDto.fromJson(json['featuredApp'])
          : null,
      topApps: List<String>.from(json['topApps']),
      dapps: (json['dapps'] as List).map((e) => DappDto.fromJson(e)).toList(),
    );
  }

  @override
  String toString() {
    return 'DappsResponse(version: $version, featuredApp: $featuredApp, topApps: $topApps, dapps: $dapps)';
  }
}
