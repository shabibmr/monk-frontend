import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:monk_web/core/session/session_cubit.dart';
import 'package:monk_web/core/session/token_store.dart';
import 'package:monk_web/features/onboarding_brand/domain/entities/brand.dart';
import 'package:monk_web/features/onboarding_brand/domain/repositories/brand_repository.dart';
import 'package:monk_web/features/onboarding_brand/presentation/bloc/brand_onboarding_bloc.dart';

class _MockBrandRepo extends Mock implements BrandRepository {}

void main() {
  late _MockBrandRepo repo;
  late SessionCubit session;

  const brand = Brand(id: 'b1', companyName: 'Acme');

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    repo = _MockBrandRepo();
    session = SessionCubit(TokenStore(prefs));
  });

  blocTest<BrandOnboardingBloc, BrandOnboardingState>(
    'empty brands → form phase',
    build: () {
      when(() => repo.listMine()).thenAnswer((_) async => const []);
      return BrandOnboardingBloc(repository: repo, sessionCubit: session);
    },
    act: (b) => b.add(const BrandOnboardingStarted()),
    expect: () => [
      isA<BrandOnboardingState>()
          .having((s) => s.phase, 'phase', BrandOnboardingPhase.loading),
      isA<BrandOnboardingState>()
          .having((s) => s.phase, 'phase', BrandOnboardingPhase.form),
    ],
    verify: (_) {
      expect(session.state.brandOnboardingComplete, isFalse);
    },
  );

  blocTest<BrandOnboardingBloc, BrandOnboardingState>(
    'create brand moves to team step',
    build: () {
      when(() => repo.create(any())).thenAnswer((_) async => brand);
      return BrandOnboardingBloc(repository: repo, sessionCubit: session);
    },
    seed: () => const BrandOnboardingState(phase: BrandOnboardingPhase.form),
    act: (b) => b.add(
      const BrandOnboardingSubmitted({'companyName': 'Acme', 'country': 'IN'}),
    ),
    expect: () => [
      isA<BrandOnboardingState>()
          .having((s) => s.phase, 'phase', BrandOnboardingPhase.saving),
      isA<BrandOnboardingState>()
          .having((s) => s.phase, 'phase', BrandOnboardingPhase.team)
          .having((s) => s.brand?.id, 'brand', 'b1'),
    ],
    verify: (_) {
      expect(session.state.activeBrandId, 'b1');
      expect(session.state.brandOnboardingComplete, isTrue);
    },
  );

  blocTest<BrandOnboardingBloc, BrandOnboardingState>(
    'finish marks done',
    build: () {
      return BrandOnboardingBloc(repository: repo, sessionCubit: session);
    },
    seed: () => const BrandOnboardingState(
      phase: BrandOnboardingPhase.team,
      brand: brand,
    ),
    act: (b) => b.add(const BrandOnboardingFinished()),
    expect: () => [
      isA<BrandOnboardingState>()
          .having((s) => s.phase, 'phase', BrandOnboardingPhase.done),
    ],
  );
}
