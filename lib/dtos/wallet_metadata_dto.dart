/// DTO for wallet app metadata fetched from static API
/// Contains terms of service configuration and other app-level settings
class WalletMetadataDto {
  final TermsMetadataDto? terms;

  WalletMetadataDto({
    required this.terms,
  });

  factory WalletMetadataDto.fromJson(Map<String, dynamic> json) {
    return WalletMetadataDto(
      terms: json['terms'] != null
          ? TermsMetadataDto.fromJson(json['terms'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'terms': terms?.toJson(),
      };
}

/// DTO for terms of service metadata
class TermsMetadataDto {
  final String version;
  final bool requiresAcceptance;
  final String contentUrl;

  TermsMetadataDto({
    required this.version,
    required this.requiresAcceptance,
    required this.contentUrl,
  });

  factory TermsMetadataDto.fromJson(Map<String, dynamic> json) {
    return TermsMetadataDto(
      version: json['version'] as String,
      requiresAcceptance: json['requiresAcceptance'] as bool,
      contentUrl: json['contentUrl'] as String,
    );
  }

  /// Constructs the full URL for the terms content
  /// If contentUrl is already a full URL (has scheme/host), returns it as-is
  /// Otherwise, combines the static API base URL with the wallet-app path and content URL
  String getFullUrl(String baseUrl) {
    try {
      final uri = Uri.parse(contentUrl);
      // If it has a scheme (http/https), it's already a full URL
      if (uri.hasScheme) {
        return contentUrl;
      }
    } catch (e) {
      // If parsing fails, treat as relative path
    }

    // Relative path - prepend base URL
    return '$baseUrl/wallet-app/$contentUrl';
  }

  Map<String, dynamic> toJson() => {
        'version': version,
        'requiresAcceptance': requiresAcceptance,
        'contentUrl': contentUrl,
      };

  @override
  String toString() {
    return 'TermsMetadataDto(version: $version, requiresAcceptance: $requiresAcceptance, contentUrl: $contentUrl)';
  }
}
