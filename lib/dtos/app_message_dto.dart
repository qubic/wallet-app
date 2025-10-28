class AppMessageDto {
  final String? id;
  final String title;
  final String message;
  final bool blocking;
  final String platform; // e.g. "all", "ios", "android"
  final DateTime? startDate;
  final DateTime? endDate;

  AppMessageDto({
    required this.id,
    required this.title,
    required this.message,
    required this.blocking,
    required this.platform,
    this.startDate,
    this.endDate,
  });

  factory AppMessageDto.fromJson(Map<String, dynamic> json) {
    return AppMessageDto(
      id: json['id'],
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      blocking: json['blocking'] ?? false,
      platform: json['platform'] ?? 'all',
      startDate: _parseDate(json['start_date']),
      endDate: _parseDate(json['end_date']),
    );
  }

  /// Check if the message is currently active
  bool get isActive {
    final now = DateTime.now().toUtc();
    if (startDate != null && now.isBefore(startDate!)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;
    return true;
  }

  /// Check if message applies to current platform
  bool appliesToPlatform(String currentPlatform) {
    final lowerPlatform = platform.toLowerCase();
    return lowerPlatform == 'all' ||
        lowerPlatform == currentPlatform.toLowerCase();
  }

  bool isValid(String currentPlatform) {
    return isActive && appliesToPlatform(currentPlatform);
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value).toUtc();
    } catch (_) {
      return null;
    }
  }
}
