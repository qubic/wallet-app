class DappDto {
  final String id;
  final String? nameId;
  final String? icon;
  String? url;
  final String? descriptionId;
  final String? customDescriptionId;
  final String? openButtonTitleId;
  final String? description;
  final String? name;
  final String? openButtonTitle;
  final List<String>? excludedPlatforms;

  DappDto({
    required this.id,
    required this.nameId,
    required this.icon,
    required this.url,
    required this.descriptionId,
    required this.customDescriptionId,
    required this.openButtonTitleId,
    this.description,
    this.name,
    this.openButtonTitle,
    this.excludedPlatforms,
  });

  factory DappDto.fromJson(Map<String, dynamic> json) {
    return DappDto(
      id: json['id'],
      nameId: json['nameId'],
      icon: json['icon'],
      url: json['url'],
      descriptionId: json['descriptionId'],
      customDescriptionId: json['customDescriptionId'],
      openButtonTitleId: json['openButtonTitleId'],
      openButtonTitle: json['openButtonTitle'],
      excludedPlatforms: json['excludedPlatforms'] != null
          ? List<String>.from(json['excludedPlatforms'])
          : null,
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
    String? openButtonTitleId,
    String? openButtonTitle,
    List<String>? excludedPlatforms,
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
      openButtonTitleId: openButtonTitleId ?? this.openButtonTitleId,
      openButtonTitle: openButtonTitle ?? this.openButtonTitle,
      excludedPlatforms: excludedPlatforms ?? this.excludedPlatforms,
    );
  }

  @override
  String toString() {
    return 'DappDto(id: $id, nameId: $nameId, icon: $icon, url: $url, descriptionId: $descriptionId, customDescriptionId: $customDescriptionId, description: $description, name: $name openButtonTitle: $openButtonTitle, excludedPlatforms: $excludedPlatforms)';
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

  DappsResponse copyWith({
    String? version,
    FeaturedAppDto? featuredApp,
    List<String>? topApps,
    List<DappDto>? dapps,
  }) {
    return DappsResponse(
      version: version ?? this.version,
      featuredApp: featuredApp ?? this.featuredApp,
      topApps: topApps ?? this.topApps,
      dapps: dapps ?? this.dapps,
    );
  }
}
