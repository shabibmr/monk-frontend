import 'package:dio/dio.dart';

import '../api_paths.dart';
import '../models/publish_models.dart';

class PublishApi {
  PublishApi(this._dio);
  final Dio _dio;

  Future<PublishedPostDto> submit({
    required String collaborationId,
    required String deliverableId,
    required String liveUrl,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiPaths.publishedPost(collaborationId, deliverableId),
      data: {'liveUrl': liveUrl},
    );
    return PublishedPostDto.fromJson(res.data!);
  }

  Future<PublishedPostDto> get({
    required String collaborationId,
    required String deliverableId,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiPaths.publishedPost(collaborationId, deliverableId),
    );
    return PublishedPostDto.fromJson(res.data!);
  }

  Future<List<PublishedPostDto>> list(String collaborationId) async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiPaths.collaborationPublishedPosts(collaborationId),
    );
    final data = res.data?['data'] as List<dynamic>? ?? const [];
    return data
        .map((e) => PublishedPostDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PublishedPostDto> manualConfirm(
    String publishedPostId, {
    String? note,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiPaths.publishedPostManualConfirm(publishedPostId),
      data: {
        if (note != null) 'note': note,
      },
    );
    return PublishedPostDto.fromJson(res.data!);
  }

  Future<PublishScheduleDto> schedulePublish({
    required String deliverableId,
    required String scheduledAt,
    required String platform,
    String? notes,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiPaths.publishSchedule(deliverableId),
      data: {
        'scheduledAt': scheduledAt,
        'platform': platform,
        if (notes != null) 'notes': notes,
      },
    );
    return PublishScheduleDto.fromJson(res.data!);
  }

  Future<PublishScheduleDto?> getSchedule(String deliverableId) async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiPaths.publishSchedule(deliverableId),
    );
    if (res.data == null) return null;
    return PublishScheduleDto.fromJson(res.data!);
  }

  Future<PublishScheduleDto> cancelSchedule(String scheduleId) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiPaths.publishScheduleCancel(scheduleId),
    );
    return PublishScheduleDto.fromJson(res.data!);
  }
}
