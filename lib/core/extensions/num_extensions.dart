import 'package:intl/intl.dart';

extension NumExtensions on num {
  String toCurrency({String symbol = '\$', int decimalDigits = 2}) {
    final format = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: decimalDigits,
    );
    return format.format(this);
  }

  String toCompactCurrency({String symbol = '\$'}) {
    final format = NumberFormat.compactCurrency(symbol: symbol);
    return format.format(this);
  }

  String toPercentage({int decimalDigits = 0}) {
    return '${(this * 100).toStringAsFixed(decimalDigits)}%';
  }
}
