import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:monk_web/core/errors/failures.dart';
import 'package:monk_web/features/recommendations/domain/entities/recommendation.dart';
import 'package:monk_web/features/recommendations/domain/repositories/recommendations_repository.dart';
import 'package:monk_web/features/recommendations/presentation/bloc/recommendations_bloc.dart';

class _MockRepo extends Mock implements RecommendationsRepository {}

void main() {
  late _MockRepo repo;

  const rec1 = Recommendation(
    id: 'r1',
    type: RecommendationType.creator,
    title: 'Alex Tech',
    subtitle: '@alextech',
    matchScore: 0.92,
    targetId: 'inf_1',
    tags: ['tech', 'gaming'],
    estimatedBudget: 500.0,
    currency: 'USD',
  );

  const rec2 = Recommendation(
    id: 'r2',
    type: RecommendationType.campaign,
    title: 'Summer Launch',
    subtitle: 'Acme Corp',
    matchScore: 0.88,
    targetId: 'camp_1',
    tags: ['lifestyle'],
    estimatedBudget: 1200.0,
    currency: 'USD',
  );

  setUp(() {
    repo = _MockRepo();
  });

  blocTest<RecommendationsBloc, RecommendationsState>(
    'emits [loading, loaded] when recommendations fetched successfully',
    build: () {
      when(() => repo.getRecommendations(
            campaignId: any(named: 'campaignId'),
            type: any(named: 'type'),
            category: any(named: 'category'),
          )).thenAnswer((_) async => [rec1, rec2]);
      return RecommendationsBloc(repo);
    },
    act: (b) => b.add(const FetchRecommendationsRequested()),
    expect: () => [
      const RecommendationsState(status: RecommendationsStatus.loading),
      const RecommendationsState(
        status: RecommendationsStatus.loaded,
        recommendations: [rec1, rec2],
      ),
    ],
  );

  blocTest<RecommendationsBloc, RecommendationsState>(
    'emits [loading, empty] when API returns empty list',
    build: () {
      when(() => repo.getRecommendations(
            campaignId: any(named: 'campaignId'),
            type: any(named: 'type'),
            category: any(named: 'category'),
          )).thenAnswer((_) async => []);
      return RecommendationsBloc(repo);
    },
    act: (b) => b.add(const FetchRecommendationsRequested(type: 'creator')),
    expect: () => [
      const RecommendationsState(status: RecommendationsStatus.loading),
      const RecommendationsState(
        status: RecommendationsStatus.empty,
        recommendations: [],
      ),
    ],
  );

  blocTest<RecommendationsBloc, RecommendationsState>(
    'emits [loading, error] when repository throws failure',
    build: () {
      when(() => repo.getRecommendations(
            campaignId: any(named: 'campaignId'),
            type: any(named: 'type'),
            category: any(named: 'category'),
          )).thenThrow(const ServerFailure('Internal server error'));
      return RecommendationsBloc(repo);
    },
    act: (b) => b.add(const FetchRecommendationsRequested()),
    expect: () => [
      const RecommendationsState(status: RecommendationsStatus.loading),
      const RecommendationsState(
        status: RecommendationsStatus.error,
        failure: ServerFailure('Internal server error'),
      ),
    ],
  );

  blocTest<RecommendationsBloc, RecommendationsState>(
    'removes recommendation on DismissRecommendationRequested',
    build: () {
      when(() => repo.getRecommendations(
            campaignId: any(named: 'campaignId'),
            type: any(named: 'type'),
            category: any(named: 'category'),
          )).thenAnswer((_) async => [rec1, rec2]);
      final bloc = RecommendationsBloc(repo);
      bloc.add(const FetchRecommendationsRequested());
      return bloc;
    },
    skip: 2, // skip loading and loaded initial states
    act: (b) => b.add(const DismissRecommendationRequested('r1')),
    expect: () => [
      const RecommendationsState(
        status: RecommendationsStatus.loaded,
        recommendations: [rec2],
      ),
    ],
  );
}
