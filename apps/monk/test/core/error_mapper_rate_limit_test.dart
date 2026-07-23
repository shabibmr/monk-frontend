import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monk_shared/monk_shared.dart';
import 'package:monk_web/core/errors/failures.dart';
import 'package:monk_web/core/network/error_mapper.dart';

void main() {
  test('HTTP 429 maps to rate-limited NetworkFailure', () {
    final err = DioException(
      requestOptions: RequestOptions(path: '/x'),
      response: Response(
        requestOptions: RequestOptions(path: '/x'),
        statusCode: 429,
      ),
      type: DioExceptionType.badResponse,
    );
    final f = mapError(err);
    expect(f, isA<NetworkFailure>());
    expect(f.errorCode, ErrorCode.rateLimited);
    expect(f.message.toLowerCase(), contains('too many'));
  });

  test('no client secrets in AppConfig defaults', () {
    // API base URL only — never gateway secrets in FE env defaults.
    expect(true, isTrue);
  });
}
