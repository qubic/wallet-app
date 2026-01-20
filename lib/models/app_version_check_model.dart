import 'package:universal_platform/universal_platform.dart';

enum UpdateType {
  force,
  flexible,
  none,
}

class AppVersionCheckModel {
  final String version;
  final String? releaseNotes;
  final bool showLaterButton;
  final bool showIgnoreButton;
  final Map<String, String> updateUrls;
  final List<String> platforms;

  static const List<String> _defaultPlatforms = [
    'android',
    'ios',
  ];

  static const Map<String, String> _defaultUpdateUrls = {
    'ios': 'https://apps.apple.com/app/qubic-wallet/id6502265811',
    'android': 'https://play.google.com/store/apps/details?id=org.qubic.wallet',
  };

  AppVersionCheckModel({
    required this.version,
    this.releaseNotes,
    this.showLaterButton = false,
    this.showIgnoreButton = false,
    this.updateUrls = _defaultUpdateUrls,
    this.platforms = _defaultPlatforms,
  });

  /// Derive update type from button visibility:
  /// - If both buttons are hidden -> force update
  /// - If any button is visible -> flexible update
  UpdateType get updateType {
    if (!showLaterButton && !showIgnoreButton) {
      return UpdateType.force;
    }
    return UpdateType.flexible;
  }

  static AppVersionCheckModel? fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) {
      return null;
    }

    final updateUrls = json['update_urls'] != null
        ? Map<String, String>.from(json['update_urls'])
        : _defaultUpdateUrls;

    final platforms = json['platforms'] != null
        ? List<String>.from(json['platforms'])
        : _defaultPlatforms;

    return AppVersionCheckModel(
      version: json['version'],
      releaseNotes: json['release_notes'],
      showLaterButton: json['show_later_button'] ?? false,
      showIgnoreButton: json['show_ignore_button'] ?? false,
      updateUrls: updateUrls,
      platforms: platforms,
    );
  }

  bool isApplicableForCurrentPlatform() {
    if (UniversalPlatform.isIOS) return platforms.contains('ios');
    if (UniversalPlatform.isAndroid) return platforms.contains('android');
    return false;
  }

  String? getUpdateUrlForPlatform() {
    if (UniversalPlatform.isIOS) return updateUrls['ios'];
    if (UniversalPlatform.isAndroid) return updateUrls['android'];
    return null;
  }
}
