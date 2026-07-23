import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:monk_web/core/session/session_cubit.dart';
import 'package:monk_web/core/session/token_store.dart';
import 'package:monk_web/features/onboarding_influencer/domain/entities/onboarding.dart';
import 'package:monk_web/features/onboarding_influencer/domain/repositories/influencer_repository.dart';
import 'package:monk_web/features/onboarding_influencer/presentation/bloc/onboarding_bloc.dart';
import 'package:monk_web/features/onboarding_influencer/presentation/bloc/onboarding_event.dart';
import 'package:monk_web/features/onboarding_influencer/presentation/bloc/onboarding_state.dart';

class _MockRepo extends Mock implements InfluencerRepository {}

void main() {
  late _MockRepo repo;
  late SessionCubit session;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    repo = _MockRepo();
    session = SessionCubit(TokenStore(prefs));
  });

  blocTest<OnboardingBloc, OnboardingState>(
    'loads onboarding and lands on next step',
    build: () {
      when(() => repo.loadOnboarding()).thenAnswer(
        (_) async => const OnboardingStatus(
          profileId: 'p1',
          progress: OnboardingProgress(step1: true),
          nextStep: 2,
          completed: false,
        ),
      );
      return OnboardingBloc(repository: repo, sessionCubit: session);
    },
    act: (b) => b.add(const OnboardingStarted()),
    expect: () => [
      isA<OnboardingState>()
          .having((s) => s.phase, 'phase', OnboardingPhase.loading),
      isA<OnboardingState>()
          .having((s) => s.phase, 'phase', OnboardingPhase.ready)
          .having((s) => s.currentStep, 'step', 2)
          .having((s) => s.profileId, 'id', 'p1'),
    ],
  );

  blocTest<OnboardingBloc, OnboardingState>(
    'cannot skip forward via GoToStep',
    build: () {
      return OnboardingBloc(repository: repo, sessionCubit: session);
    },
    seed: () => const OnboardingState(
      phase: OnboardingPhase.ready,
      profileId: 'p1',
      currentStep: 2,
      progress: OnboardingProgress(step1: true),
    ),
    act: (b) => b.add(const OnboardingGoToStep(5)),
    expect: () => <OnboardingState>[],
  );

  test('majorToMinor converts fixed scale', () {
    expect(majorToMinor('10'), 1000);
    expect(majorToMinor('10.50'), 1050);
    expect(majorToMinor('0.05'), 5);
  });
}
