import 'package:flutter_test/flutter_test.dart';
import 'package:monk_web/core/utils/money_format.dart';

void main() {
  test('formats INR minor units', () {
    final text = formatMoneyMinor(475000, 'INR');
    expect(text, contains('4,750.00'));
  });

  test('formats AED minor units', () {
    final text = formatMoneyMinor(10050, 'AED');
    expect(text, contains('100.50'));
  });
}
