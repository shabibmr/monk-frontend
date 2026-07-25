import 'package:flutter_test/flutter_test.dart';
import 'package:monk_web/core/mock/mock_ids.dart';
import 'package:monk_web/core/mock/mock_seed_store.dart';

void main() {
  late MockSeedStore store;

  setUp(() {
    store = MockSeedStore(latencyMs: 0)..initialize();
  });

  test('short usernames resolve', () {
    for (final email in [
      MockIds.emailCreator1,
      MockIds.emailBrand1,
      MockIds.emailManager1,
      MockIds.emailAdmin,
      MockIds.emailAgency1,
      MockIds.emailBrandFresh,
      MockIds.emailCreatorFresh,
    ]) {
      expect(
        store.findAccountByEmail(email),
        isNotNull,
        reason: 'missing $email',
      );
    }
  });

  test('legacy demo emails resolve', () {
    expect(
      store.findAccountByEmail('demo.creator1@influencersmonk.local')?.user.id,
      MockIds.creator1,
    );
    expect(
      store.findAccountByEmail('demo.brand1@influencersmonk.local')?.user.id,
      MockIds.brand1,
    );
  });

  test('first-name aliases resolve', () {
    expect(store.findAccountByEmail('arjun')?.user.id, MockIds.creator1);
    expect(store.findAccountByEmail('priya')?.user.id, MockIds.brand1);
    expect(store.findAccountByEmail('meera')?.user.id, MockIds.manager1);
    expect(store.findAccountByEmail('alex')?.user.id, MockIds.agency1);
  });

  test('local-part@anything resolves', () {
    expect(
      store.findAccountByEmail('creator@example.com')?.user.id,
      MockIds.creator1,
    );
    expect(
      store.findAccountByEmail('brand@acme.test')?.user.id,
      MockIds.brand1,
    );
  });
}
