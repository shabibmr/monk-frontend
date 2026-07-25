import 'package:flutter_test/flutter_test.dart';
import 'package:monk_shared/monk_shared.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:monk_web/core/errors/failures.dart';
import 'package:monk_web/core/mock/mock_ids.dart';
import 'package:monk_web/core/mock/mock_seed_store.dart';
import 'package:monk_web/core/mock/repositories/mock_auth_repository.dart';
import 'package:monk_web/core/session/session_cubit.dart';
import 'package:monk_web/core/session/token_store.dart';

void main() {
  late MockSeedStore store;
  late TokenStore tokenStore;
  late SessionCubit session;
  late MockAuthRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    tokenStore = TokenStore(prefs);
    session = SessionCubit(tokenStore);
    store = MockSeedStore(latencyMs: 0)..initialize();
    repo = MockAuthRepository(
      store: store,
      tokenStore: tokenStore,
      sessionCubit: session,
    );
  });

  test('login creator succeeds with demo password', () async {
    final sessionResult = await repo.login(
      email: MockIds.emailCreator1,
      password: MockIds.demoPassword,
    );
    expect(sessionResult.user.email, MockIds.emailCreator1);
    expect(sessionResult.user.role, UserRole.influencer);
    expect(session.state.needsInfluencerOnboarding, isFalse);
  });

  test('login with bad password fails', () async {
    expect(
      () => repo.login(email: MockIds.emailCreator1, password: 'wrong'),
      throwsA(isA<AuthFailure>()),
    );
  });

  test('Arjun creator is fully onboarded; newcreator needs onboarding', () async {
    await repo.login(
      email: MockIds.emailCreator1,
      password: MockIds.demoPassword,
    );
    expect(session.state.needsInfluencerOnboarding, isFalse);

    await repo.logout();
    await repo.login(
      email: MockIds.emailCreatorFresh,
      password: MockIds.demoPassword,
    );
    expect(session.state.needsInfluencerOnboarding, isTrue);
  });
}
