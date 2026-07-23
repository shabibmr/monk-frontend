import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:monk_web/core/errors/failures.dart';
import 'package:monk_web/core/session/session_cubit.dart';
import 'package:monk_web/core/session/token_store.dart';
import 'package:monk_web/features/manager/domain/entities/roster.dart';
import 'package:monk_web/features/manager/domain/repositories/manager_repository.dart';
import 'package:monk_web/features/manager/presentation/cubit/roster_cubit.dart';

class _MockRepo extends Mock implements ManagerRepository {}

void main() {
  late _MockRepo repo;
  late SessionCubit session;

  const entry = RosterEntry(
    profileId: 'p1',
    displayName: 'Creator One',
    permissions: ['view_earnings'],
    inviteStatus: 'accepted',
    verificationStatus: 'approved',
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    repo = _MockRepo();
    session = SessionCubit(TokenStore(prefs));
  });

  blocTest<RosterCubit, RosterState>(
    'loads roster',
    build: () {
      when(() => repo.getRoster()).thenAnswer((_) async => [entry]);
      return RosterCubit(repository: repo, sessionCubit: session);
    },
    act: (c) => c.load(),
    expect: () => [
      isA<RosterState>().having((s) => s.loading, 'loading', true),
      isA<RosterState>()
          .having((s) => s.loading, 'loading', false)
          .having((s) => s.entries.length, 'len', 1),
    ],
  );

  blocTest<RosterCubit, RosterState>(
    'switch profile sets session context',
    build: () {
      when(() => repo.switchContext('p1')).thenAnswer(
        (_) async => const SwitchContextResult(
          profileId: 'p1',
          permissions: ['view_earnings', 'edit_profile'],
          withdrawalRequiresOwnerConfirmation: true,
          canInitiateWithdrawal: false,
        ),
      );
      return RosterCubit(repository: repo, sessionCubit: session);
    },
    act: (c) => c.selectProfile(entry),
    expect: () => [
      isA<RosterState>().having((s) => s.loading, 'loading', true),
      isA<RosterState>()
          .having((s) => s.loading, 'loading', false)
          .having((s) => s.infoMessage, 'msg', contains('Creator One')),
    ],
    verify: (_) {
      expect(session.state.activeProfileId, 'p1');
      expect(session.state.isManagerContext, isTrue);
      expect(session.state.activeProfileName, 'Creator One');
      expect(session.state.managerPermissions, contains('view_earnings'));
    },
  );

  blocTest<RosterCubit, RosterState>(
    'forbidden switch clears context',
    build: () {
      when(() => repo.switchContext('p1')).thenThrow(
        const ForbiddenFailure('No active access'),
      );
      return RosterCubit(repository: repo, sessionCubit: session);
    },
    seed: () {
      session.setActiveProfile(
        profileId: 'old',
        isManagerContext: true,
        displayName: 'Old',
      );
      return const RosterState(entries: [entry]);
    },
    act: (c) => c.selectProfile(entry),
    verify: (_) {
      expect(session.state.activeProfileId, isNull);
      expect(session.state.isManagerContext, isFalse);
    },
  );
}
