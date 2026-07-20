import 'package:flutter_test/flutter_test.dart';
import 'package:monk_web/core/utils/money_format.dart';

void main() {
  test('smoke money format', () {
    expect(formatMoneyMinor(100, 'INR'), contains('1.00'));
  });
}
