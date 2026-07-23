import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:monk_web/core/errors/failures.dart';
import 'package:monk_web/features/discovery/domain/entities/creator_demographics.dart';
import 'package:monk_web/features/discovery/domain/repositories/discovery_repository.dart';
import 'package:monk_web/features/discovery/presentation/bloc/discovery_score_bloc.dart';

class _MockDiscoveryRepo extends Mock implements DiscoveryRepository {}

void main() {
  late _MockDiscoveryRepo repo;

  const demoData = CreatorDemographics(
    influencerId: 'inf-123',
    creatorScore: 92.0,
    fakeFollowerScore: 8.5,
    credibilityGrade: 'A+',
  );

  setUp(() {
    repo = _MockDiscoveryRepo();
  });

  group('DiscoveryScoreBloc', () {
    blocTest<DiscoveryScoreBloc, DiscoveryScoreState>(
      'emits [loading, ready] when FetchDiscoveryScore succeeds',
      build: () {
        when(() => repo.getCreatorScore('inf-123'))
            .thenAnswer((_) async => 92.0);
        return DiscoveryScoreBloc(repo);
      },
      act: (bloc) => bloc.add(const FetchDiscoveryScore('inf-123')),
      expect: () => [
        isA<DiscoveryScoreState>()
            .having((s) => s.phase, 'phase', DiscoveryScorePhase.loading),
        isA<DiscoveryScoreState>()
            .having((s) => s.phase, 'phase', DiscoveryScorePhase.ready)
            .having((s) => s.score, 'score', 92.0),
      ],
    );

    blocTest<DiscoveryScoreBloc, DiscoveryScoreState>(
      'emits [loading, ready] with demographics when FetchCreatorDemographics succeeds',
      build: () {
        when(() => repo.getDemographics('inf-123'))
            .thenAnswer((_) async => demoData);
        return DiscoveryScoreBloc(repo);
      },
      act: (bloc) => bloc.add(const FetchCreatorDemographics('inf-123')),
      expect: () => [
        isA<DiscoveryScoreState>()
            .having((s) => s.phase, 'phase', DiscoveryScorePhase.loading),
        isA<DiscoveryScoreState>()
            .having((s) => s.phase, 'phase', DiscoveryScorePhase.ready)
            .having((s) => s.demographics, 'demographics', demoData)
            .having((s) => s.score, 'score', 92.0),
      ],
    );

    blocTest<DiscoveryScoreBloc, DiscoveryScoreState>(
      'emits [loading, failure] when FetchDiscoveryScore throws failure',
      build: () {
        when(() => repo.getCreatorScore('inf-123'))
            .thenThrow(const ServerFailure('Network Error'));
        return DiscoveryScoreBloc(repo);
      },
      act: (bloc) => bloc.add(const FetchDiscoveryScore('inf-123')),
      expect: () => [
        isA<DiscoveryScoreState>()
            .having((s) => s.phase, 'phase', DiscoveryScorePhase.loading),
        isA<DiscoveryScoreState>()
            .having((s) => s.phase, 'phase', DiscoveryScorePhase.failure)
            .having((s) => s.failure?.message, 'message', 'Network Error'),
      ],
    );
  });
}
