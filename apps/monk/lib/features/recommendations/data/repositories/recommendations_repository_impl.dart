import 'package:api_client/api_client.dart';

import '../../../../core/network/error_mapper.dart';
import '../../domain/entities/recommendation.dart';
import '../../domain/repositories/recommendations_repository.dart';
import '../datasources/recommendations_remote_datasource.dart';

class RecommendationsRepositoryImpl implements RecommendationsRepository {
  RecommendationsRepositoryImpl(this._remoteDataSource);
  final RecommendationsRemoteDataSource _remoteDataSource;

  Recommendation _map(RecommendationDto d) => Recommendation(
        id: d.id,
        type: RecommendationType.fromString(d.type),
        title: d.title,
        subtitle: d.subtitle,
        avatarUrl: d.avatarUrl,
        matchScore: d.matchScore,
        targetId: d.targetId,
        tags: d.tags,
        estimatedBudget: d.estimatedBudget,
        currency: d.currency,
      );

  @override
  Future<List<Recommendation>> getRecommendations({
    String? campaignId,
    String? type,
    String? category,
  }) async {
    try {
      final list = await _remoteDataSource.getRecommendations(
        campaignId: campaignId,
        type: type,
        category: category,
      );
      return list.map(_map).toList();
    } catch (e) {
      throw mapError(e);
    }
  }
}
