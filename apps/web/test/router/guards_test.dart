import 'package:flutter_test/flutter_test.dart';
import 'package:monk_shared/monk_shared.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:monk_web/core/router/guards.dart';
import 'package:monk_web/core/session/session_cubit.dart';
import 'package:monk_web/core/session/token_store.dart';
import 'package:monk_web/features/auth/domain/entities/user.dart';

void main() {
  late SessionCubit session;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    session = SessionCubit(TokenStore(prefs));
    await session.hydrate();
  });

  test('unauthenticated protected route → login', () {
    final result = appRedirect(
      session: session,
      location: '/b/dashboard',
      matchedLocation: '/b/dashboard',
    );
    expect(result, contains('/login'));
  });

  test('wrong role → 403', () {
    session.setSession(
      const User(
        id: '1',
        email: 'c@x.com',
        role: UserRole.influencer,
        status: UserStatus.active,
      ),
    );
    final result = appRedirect(
      session: session,
      location: '/b/dashboard',
      matchedLocation: '/b/dashboard',
    );
    expect(result, '/403');
  });

  test('authenticated on login → role home', () {
    session.setSession(
      const User(
        id: '1',
        email: 'b@x.com',
        role: UserRole.brandUser,
        status: UserStatus.active,
      ),
    );
    session.setBrandOnboardingComplete(true);
    final result = appRedirect(
      session: session,
      location: '/login',
      matchedLocation: '/login',
    );
    expect(result, '/b/dashboard');
  });

  test('brand without company → onboarding', () {
    session.setSession(
      const User(
        id: '1',
        email: 'b@x.com',
        role: UserRole.brandUser,
        status: UserStatus.active,
      ),
    );
    session.setBrandOnboardingComplete(false);
    final result = appRedirect(
      session: session,
      location: '/b/dashboard',
      matchedLocation: '/b/dashboard',
    );
    expect(result, '/b/onboarding');
  });
}
