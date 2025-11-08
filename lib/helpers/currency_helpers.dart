import 'package:intl/intl.dart';

class CurrencyHelpers {
  static String formatToUsdCurrency(num amount) {
    final decimalDigits = (amount > 0 && amount < 1) ? 10 : 2;
    return NumberFormat.currency(symbol: '\$', decimalDigits: decimalDigits)
        .format(amount);
  }

  /// Formats a Qubic price value to display as "price per billion".
  ///
  /// Takes a [price] value (e.g., 0.000000978) and returns a formatted
  /// string like "$978 / bQUBIC".
  static String formatQubicPrice(num? price) {
    if (price == null) return '\$0';

    final pricePerBillion = price * 1000000000;

    // Format the number with commas and appropriate decimal places
    final formatter = NumberFormat('#,##0.##', 'en_US');
    final formattedPrice = formatter.format(pricePerBillion);

    return '\$$formattedPrice / bQUBIC';
  }
}
