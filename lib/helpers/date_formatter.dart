import 'package:intl/intl.dart';

class DateFormatter {
  // Short DateTime format: e.g., 12 Mar 2025, 13:49:13
  static String formatShortWithTime(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm:ss').format(date);
  }
}
