import 'package:flutter_test/flutter_test.dart';
import 'package:monk_web/core/mock/mock_ids.dart';
import 'package:monk_web/core/mock/mock_seed_store.dart';
import 'package:monk_web/core/mock/repositories/mock_payment_repository.dart';
import 'package:monk_web/features/payments/domain/entities/payment.dart';

void main() {
  late MockSeedStore store;
  late MockPaymentRepository repo;

  setUp(() {
    store = MockSeedStore(latencyMs: 0)..initialize();
    repo = MockPaymentRepository(store);
  });

  test('seeded earnings are readable (B2 singles map, not fixture fallback)', () async {
    final raw = store.singles['earnings'];
    expect(raw, isA<Map>());
    expect((raw as Map).containsKey(MockIds.influencer1), isTrue);
    expect(raw[MockIds.influencer1], isA<Earnings>());

    final earnings = await repo.earnings(MockIds.influencer1);
    expect(earnings.profileId, MockIds.influencer1);
    expect(earnings.pendingMinor, 2125000);
    expect(earnings.availableMinor, 1850000);
    expect(earnings.withdrawnMinor, 7200000);
    expect(earnings.currency, 'INR');
  });

  test('confirmPayout finds seeded owner-confirm row (B3)', () async {
    await repo.confirmPayout(
      'payout-demo-2',
      token: 'mock-payout-confirm-token',
    );
    final after = await repo.earnings(MockIds.influencer1);
    // amount 1850000 moved from pending → withdrawn
    expect(after.withdrawnMinor, 7200000 + 1850000);
    expect(after.pendingMinor, 2125000 - 1850000);
  });
}
