import 'package:flutter/material.dart';
import '../extensions/num_extensions.dart';

class CurrencyText extends StatelessWidget {
  final double amount;
  final TextStyle? style;
  final String symbol;
  final String? prefix;
  final String? suffix;
  final int decimalDigits;
  final double decimalScale;

  const CurrencyText({
    super.key,
    required this.amount,
    this.style,
    this.symbol = '\$',
    this.prefix,
    this.suffix,
    this.decimalDigits = 2,
    this.decimalScale = 0.7,
  });

  @override
  Widget build(BuildContext context) {
    final currencyString = amount.toCurrency(
      symbol: symbol,
      decimalDigits: decimalDigits,
    );

    // Encuentra la última aparición del separador decimal. 
    // Dado que toCurrency usa NumberFormat.currency por defecto, 
    // el separador suele ser '.' para USD o el definido por la región.
    final lastDotIndex = currencyString.lastIndexOf('.');
    
    if (lastDotIndex == -1) {
      return Text(currencyString, style: style);
    }

    final mainPart = currencyString.substring(0, lastDotIndex);
    final decimalPart = currencyString.substring(lastDotIndex);

    final baseStyle = style ?? Theme.of(context).textTheme.bodyMedium!;

    return Text.rich(
      TextSpan(
        style: baseStyle,
        children: [
          if (prefix != null) TextSpan(text: prefix),
          TextSpan(text: mainPart),
          TextSpan(
            text: decimalPart,
            style: baseStyle.copyWith(
              fontSize: (baseStyle.fontSize ?? 14) * decimalScale,
              color: baseStyle.color?.withValues(alpha: 0.85),
            ),
          ),
          if (suffix != null) TextSpan(text: suffix),
        ],
      ),
    );
  }
}
