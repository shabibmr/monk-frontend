import 'package:flutter_test/flutter_test.dart';
import 'package:monk_web/core/mock/mock_ids.dart';
import 'package:monk_web/core/mock/mock_seed_store.dart';
import 'package:monk_web/core/mock/repositories/mock_negotiation_repository.dart';
import 'package:monk_web/features/negotiations/domain/entities/negotiation.dart';

void main() {
  late MockSeedStore store;
  late MockNegotiationRepository repo;

  setUp(() {
    store = MockSeedStore(latencyMs: 0)..initialize();
    store.currentUserId = MockIds.brand1;
    repo = MockNegotiationRepository(store);
  });

  test('accept pending offer creates/updates collaboration', () async {
    final result = await repo.accept(
      negotiationId: MockIds.negotiation1,
      offerId: 'offer-demo-2',
    );
    expect(result.status, 'accepted');
    expect(result.collaboration, isNotNull);
    expect(result.collaboration!.id, isNotEmpty);

    final after = store.list<CollaborationSnapshot>('collaborations');
    expect(after, isNotEmpty);
    expect(
      after.any((c) => c.id == result.collaboration!.id),
      isTrue,
    );
  });
}
