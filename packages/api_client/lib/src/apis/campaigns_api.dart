import 'package:dio/dio.dart';

import '../api_paths.dart';
import '../models/campaign_models.dart';

class CampaignsApi {
  CampaignsApi(this._dio);
  final Dio _dio;

  Future<CampaignDto> create(Map<String, dynamic> body) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiPaths.campaigns,
      data: body,
    );
    return CampaignDto.fromJson(res.data!);
  }

  Future<List<CampaignDto>> list(String brandId) async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiPaths.campaigns,
      queryParameters: {'brandId': brandId},
    );
    final data = res.data?['data'] as List<dynamic>? ?? const [];
    return data
        .map((e) => CampaignDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<CampaignDetailDto> get(String id) async {
    final res = await _dio.get<Map<String, dynamic>>(ApiPaths.campaign(id));
    return CampaignDetailDto.fromJson(res.data!);
  }

  Future<CampaignDto> update(String id, Map<String, dynamic> body) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      ApiPaths.campaign(id),
      data: body,
    );
    return CampaignDto.fromJson(res.data!);
  }

  Future<CampaignDto> transition(
    String id, {
    required String to,
    String? reason,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiPaths.campaignTransitions(id),
      data: {
        'to': to,
        if (reason != null) 'reason': reason,
      },
    );
    return CampaignDto.fromJson(res.data!);
  }

  Future<DeliverableDto> addDeliverable(
    String campaignId,
    Map<String, dynamic> body,
  ) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiPaths.campaignDeliverables(campaignId),
      data: body,
    );
    return DeliverableDto.fromJson(res.data!);
  }

  Future<void> deleteDeliverable(String campaignId, String dId) async {
    await _dio.delete<void>(ApiPaths.campaignDeliverable(campaignId, dId));
  }
}
