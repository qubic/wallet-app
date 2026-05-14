import 'package:intl/intl.dart';

class DateFormatter {
  // Short DateTime format: e.g., 12 Mar 2025, 13:49:13
  static String formatShortWithTime(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm:ss').format(date);
  }

  // Compact DateTime format without seconds: e.g., 12 Mar 2025, 13:49
  static String formatShort(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }

  // Medium date format (day only): e.g., "12 March 2025" or "12 March" if current year
  static String formatMediumDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year) {
      return DateFormat('d MMMM').format(date);
    }
    return DateFormat('d MMMM yyyy').format(date);
  }

  // Returns true if two dates are on the same calendar day
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // Returns true if the date is today
  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }
}
