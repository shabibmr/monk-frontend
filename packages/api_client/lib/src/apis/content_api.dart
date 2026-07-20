import 'package:dio/dio.dart';

import '../api_paths.dart';
import '../models/content_models.dart';

class ContentApi {
  ContentApi(this._dio);
  final Dio _dio;

  Future<List<ContentSubmissionDto>> listSubmissions(
    String collaborationId,
  ) async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiPaths.collaborationSubmissions(collaborationId),
    );
    final data = res.data?['data'] as List<dynamic>? ?? const [];
    return data
        .map((e) => ContentSubmissionDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ContentVersionDto> createVersion({
    required String collaborationId,
    required String deliverableId,
    required Map<String, dynamic> body,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiPaths.collaborationDeliverableVersions(
        collaborationId,
        deliverableId,
      ),
      data: body,
    );
    return ContentVersionDto.fromJson(res.data!);
  }

  Future<ContentVersionDto> submit(String versionId) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiPaths.contentVersionSubmit(versionId),
    );
    return ContentVersionDto.fromJson(res.data!);
  }

  Future<ContentVersionDto> getVersion(String versionId) async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiPaths.contentVersion(versionId),
    );
    return ContentVersionDto.fromJson(res.data!);
  }

  Future<ContentVersionDto> review(
    String versionId, {
    required String decision,
    String? comment,
    String? overrideReason,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiPaths.contentVersionReview(versionId),
      data: {
        'decision': decision,
        if (comment != null) 'comment': comment,
        if (overrideReason != null) 'overrideReason': overrideReason,
      },
    );
    return ContentVersionDto.fromJson(res.data!);
  }

  Future<ContentCommentDto> addComment(
    String versionId, {
    required String body,
    String? parentCommentId,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiPaths.contentVersionComments(versionId),
      data: {
        'body': body,
        if (parentCommentId != null) 'parentCommentId': parentCommentId,
      },
    );
    return ContentCommentDto.fromJson(res.data!);
  }

  Future<List<ContentCommentDto>> listComments(String versionId) async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiPaths.contentVersionComments(versionId),
    );
    final data = res.data?['data'] as List<dynamic>? ?? const [];
    return data
        .map((e) => ContentCommentDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
