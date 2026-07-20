import 'package:dio/dio.dart';

import '../api_paths.dart';
import '../models/review_models.dart';

class ReviewsApi {
  ReviewsApi(this._dio);
  final Dio _dio;

  Future<ReviewDto> create(
    String collaborationId, {
    required int rating,
    String? body,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiPaths.collaborationReviews(collaborationId),
      data: {
        'rating': rating,
        if (body != null) 'body': body,
      },
    );
    return ReviewDto.fromJson(res.data!);
  }

  Future<List<ReviewDto>> listForCollaboration(String collaborationId) async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiPaths.collaborationReviews(collaborationId),
    );
    final data = res.data?['data'] as List<dynamic>? ?? const [];
    return data
        .map((e) => ReviewDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ReviewDto>> listForProfile(String profileId) async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiPaths.profileReviews(profileId),
    );
    final data = res.data?['data'] as List<dynamic>? ?? const [];
    return data
        .map((e) => ReviewDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ReviewDto>> listForBrand(String brandId) async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiPaths.brandReviews(brandId),
    );
    final data = res.data?['data'] as List<dynamic>? ?? const [];
    return data
        .map((e) => ReviewDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ReviewDto> hide(String reviewId) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiPaths.reviewHide(reviewId),
    );
    return ReviewDto.fromJson(res.data!);
  }
}
