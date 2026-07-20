import 'package:dio/dio.dart';

import '../api_paths.dart';
import '../models/application_models.dart';

class ApplicationsApi {
  ApplicationsApi(this._dio);
  final Dio _dio;

  Future<MarketplacePageDto> browseMarketplace({
    String? platform,
    String? objective,
    String? collabType,
    String? cursor,
    int? limit,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiPaths.marketplaceCampaigns,
      queryParameters: {
        if (platform != null && platform.isNotEmpty) 'platform': platform,
        if (objective != null && objective.isNotEmpty) 'objective': objective,
        if (collabType != null && collabType.isNotEmpty) 'collabType': collabType,
        if (cursor != null) 'cursor': cursor,
        if (limit != null) 'limit': limit,
      },
    );
    return MarketplacePageDto.fromJson(res.data ?? const {});
  }

  Future<MarketplaceCampaignDto> getMarketplaceCampaign(String id) async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiPaths.marketplaceCampaign(id),
    );
    return MarketplaceCampaignDto.fromJson(res.data!);
  }

  Future<ApplicationDto> apply(
    String campaignId,
    Map<String, dynamic> body,
  ) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiPaths.campaignApplications(campaignId),
      data: body,
    );
    return ApplicationDto.fromJson(res.data!);
  }

  Future<List<ApplicationDto>> brandInbox(
    String brandId, {
    String? campaignId,
    String? status,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiPaths.brandApplications(brandId),
      queryParameters: {
        if (campaignId != null) 'campaignId': campaignId,
        if (status != null) 'status': status,
      },
    );
    final data = res.data?['data'] as List<dynamic>? ?? const [];
    return data
        .map((e) => ApplicationDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ApplicationDto>> listMine(String profileId) async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiPaths.applicationsMe,
      queryParameters: {'profileId': profileId},
    );
    final data = res.data?['data'] as List<dynamic>? ?? const [];
    return data
        .map((e) => ApplicationDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ApplicationDto> shortlist(String id) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiPaths.applicationShortlist(id),
    );
    return ApplicationDto.fromJson(res.data!);
  }

  Future<ApplicationDto> reject(String id, {required String reason}) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiPaths.applicationReject(id),
      data: {'reason': reason},
    );
    return ApplicationDto.fromJson(res.data!);
  }

  Future<ApplicationDto> withdraw(String id) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiPaths.applicationWithdraw(id),
    );
    return ApplicationDto.fromJson(res.data!);
  }

  Future<ApplicationDto> invite(
    String campaignId, {
    required String profileId,
    String? message,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiPaths.campaignInvites(campaignId),
      data: {
        'profileId': profileId,
        if (message != null) 'message': message,
      },
    );
    return ApplicationDto.fromJson(res.data!);
  }

  Future<ApplicationDto> acceptInvite(String id) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiPaths.applicationAcceptInvite(id),
    );
    return ApplicationDto.fromJson(res.data!);
  }

  Future<ApplicationDto> declineInvite(String id) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiPaths.applicationDeclineInvite(id),
    );
    return ApplicationDto.fromJson(res.data!);
  }
}
