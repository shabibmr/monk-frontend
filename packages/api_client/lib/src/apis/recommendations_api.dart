import 'package:dio/dio.dart';

import '../api_paths.dart';
import '../models/recommendation_models.dart';

class RecommendationsApi {
  RecommendationsApi(this._dio);
  final Dio _dio;

  Future<List<RecommendationDto>> getRecommendations({
    String? campaignId,
    String? type,
    String? category,
  }) async {
    final path = campaignId != null
        ? ApiPaths.campaignRecommendations(campaignId)
        : ApiPaths.recommendations;

    final res = await _dio.get<Map<String, dynamic>>(
      path,
      queryParameters: {
        if (type != null) 'type': type,
        if (category != null) 'category': category,
      },
    );
    final data = res.data?['data'] as List<dynamic>? ?? const [];
    return data
        .map((e) => RecommendationDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
