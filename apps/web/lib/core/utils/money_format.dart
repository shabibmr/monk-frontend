import 'package:intl/intl.dart';

/// Formats minor units for display only. Never do money math here.
String formatMoneyMinor(int minorUnits, String currencyCode) {
  final major = minorUnits / 100.0;
  final format = NumberFormat.currency(
    name: currencyCode,
    symbol: _symbol(currencyCode),
    decimalDigits: 2,
  );
  return format.format(major);
}

String _symbol(String code) {
  switch (code.toUpperCase()) {
    case 'INR':
      return '₹';
    case 'AED':
      return 'AED ';
    default:
      return '$code ';
  }
}
