import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:monk_shared/monk_shared.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:monk_web/core/errors/failures.dart';
import 'package:monk_web/core/session/session_cubit.dart';
import 'package:monk_web/core/session/token_store.dart';
import 'package:monk_web/features/auth/domain/entities/user.dart';
import 'package:monk_web/features/auth/domain/repositories/auth_repository.dart';
import 'package:monk_web/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:monk_web/features/auth/presentation/bloc/auth_event.dart';
import 'package:monk_web/features/auth/presentation/bloc/auth_state.dart';

class _MockAuthRepo extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepo repo;
  late SessionCubit session;

  const user = User(
    id: 'u1',
    email: 'a@b.com',
    role: UserRole.influencer,
    status: UserStatus.active,
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    repo = _MockAuthRepo();
    session = SessionCubit(TokenStore(prefs));
  });

  blocTest<AuthBloc, AuthState>(
    'login success sets authenticated',
    build: () {
      when(
        () => repo.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer(
        (_) async => const AuthSession(
          user: user,
          accessToken: 'a',
          refreshToken: 'r',
          expiresIn: 3600,
        ),
      );
      return AuthBloc(authRepository: repo, sessionCubit: session);
    },
    act: (bloc) => bloc.add(
      const AuthLoginRequested(email: 'a@b.com', password: 'secret12'),
    ),
    expect: () => [
      isA<AuthState>().having((s) => s.status, 'status', AuthStatus.loading),
      isA<AuthState>()
          .having((s) => s.status, 'status', AuthStatus.authenticated)
          .having((s) => s.user?.email, 'email', 'a@b.com'),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'login failure emits failure',
    build: () {
      when(
        () => repo.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(
        const AuthFailure(
          'Invalid email or password',
          errorCode: ErrorCode.invalidCredentials,
        ),
      );
      return AuthBloc(authRepository: repo, sessionCubit: session);
    },
    act: (bloc) => bloc.add(
      const AuthLoginRequested(email: 'a@b.com', password: 'bad'),
    ),
    expect: () => [
      isA<AuthState>().having((s) => s.status, 'status', AuthStatus.loading),
      isA<AuthState>()
          .having((s) => s.status, 'status', AuthStatus.failure)
          .having((s) => s.failure, 'failure', isA<AuthFailure>()),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'logout clears session',
    build: () {
      when(() => repo.logout()).thenAnswer((_) async {});
      return AuthBloc(authRepository: repo, sessionCubit: session);
    },
    seed: () => const AuthState(status: AuthStatus.authenticated, user: user),
    act: (bloc) => bloc.add(const AuthLogoutRequested()),
    expect: () => [
      isA<AuthState>().having((s) => s.status, 'status', AuthStatus.loading),
      isA<AuthState>().having(
        (s) => s.status,
        'status',
        AuthStatus.unauthenticated,
      ),
    ],
    verify: (_) {
      verify(() => repo.logout()).called(1);
    },
  );
}
