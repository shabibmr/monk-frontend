import 'package:api_client/api_client.dart';

class RecommendationsRemoteDataSource {
  RecommendationsRemoteDataSource(this._client);
  final MonkApiClient _client;

  Future<List<RecommendationDto>> getRecommendations({
    String? campaignId,
    String? type,
    String? category,
  }) {
    return _client.recommendations.getRecommendations(
      campaignId: campaignId,
      type: type,
      category: category,
    );
  }
}
