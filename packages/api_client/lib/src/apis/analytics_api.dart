import 'package:dio/dio.dart';

import '../api_paths.dart';
import '../models/analytics_models.dart';

class AnalyticsApi {
  AnalyticsApi(this._dio);
  final Dio _dio;

  Future<BrandDashboardDto> brandDashboard(String brandId) async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiPaths.brandDashboard(brandId),
    );
    return BrandDashboardDto.fromJson(res.data ?? const {});
  }

  Future<ProfileDashboardDto> profileDashboard(String profileId) async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiPaths.profileDashboard(profileId),
    );
    return ProfileDashboardDto.fromJson(res.data ?? const {});
  }

  Future<ManagerDashboardDto> managerDashboard() async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiPaths.managerDashboard,
    );
    return ManagerDashboardDto.fromJson(res.data ?? const {});
  }

  Future<ManualMetricDto> enterMetrics(
    String publishedPostId,
    Map<String, dynamic> body,
  ) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiPaths.publishedPostMetrics(publishedPostId),
      data: body,
    );
    return ManualMetricDto.fromJson(res.data!);
  }
}
