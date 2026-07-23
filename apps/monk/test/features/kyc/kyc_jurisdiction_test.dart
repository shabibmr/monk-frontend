import 'package:flutter_test/flutter_test.dart';
import 'package:monk_web/features/kyc/domain/entities/kyc.dart';

void main() {
  test('India fields for IN and empty default', () {
    expect(showIndiaFields('IN'), isTrue);
    expect(showIndiaFields(''), isTrue);
    expect(showIndiaFields('AE'), isFalse);
  });

  test('UAE license fields only for AE', () {
    expect(showUaeLicenseFields('AE'), isTrue);
    expect(showUaeLicenseFields('UAE'), isTrue);
    expect(showUaeLicenseFields('IN'), isFalse);
  });
}
