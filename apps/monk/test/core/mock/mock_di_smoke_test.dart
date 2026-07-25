import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:monk_web/core/di/injection.dart';
import 'package:monk_web/core/mock/repositories/mock_auth_repository.dart';
import 'package:monk_web/core/network/api_client_factory.dart';
import 'package:monk_web/features/auth/domain/repositories/auth_repository.dart';
import 'package:monk_web/features/payments/domain/repositories/payment_repository.dart';
import 'package:monk_web/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:monk_web/features/referrals/domain/repositories/referrals_repository.dart';

void main() {
  tearDown(() async {
    await getIt.reset();
  });

  test('configureDependencies with useMocks registers mock auth', () async {
    SharedPreferences.setMockInitialValues({});
    await configureDependencies(
      config: const AppConfig(
        apiBaseUrl: 'http://localhost:0',
        useMocks: true,
        mockLatencyMs: 0,
      ),
    );

    final auth = getIt<AuthRepository>();
    expect(auth, isA<MockAuthRepository>());
    expect(getIt.isRegistered<PaymentRepository>(), isTrue);
    expect(getIt.isRegistered<AnalyticsRepository>(), isTrue);
    expect(getIt.isRegistered<ReferralsRepository>(), isTrue);
  });
}
