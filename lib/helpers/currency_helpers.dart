import 'package:intl/intl.dart';

class CurrencyHelpers {
  static String formatToUsdCurrency(num amount) {
    return NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(amount);
  }
}
