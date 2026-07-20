import '../entities/recommendation.dart';

abstract class RecommendationsRepository {
  Future<List<Recommendation>> getRecommendations({
    String? campaignId,
    String? type,
    String? category,
  });
}
