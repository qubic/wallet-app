import 'package:intl/intl.dart';

class CurrencyHelpers {
  static String formatToUsdCurrency(num amount) {
    int decimalDigits = amount < 1 ? 10 : 2;
    return NumberFormat.currency(symbol: '\$', decimalDigits: decimalDigits)
        .format(amount);
  }
}
