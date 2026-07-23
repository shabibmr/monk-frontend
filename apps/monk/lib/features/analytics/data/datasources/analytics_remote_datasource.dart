import 'package:api_client/api_client.dart';
import '../../domain/entities/analytics_metric.dart';

class AnalyticsRemoteDataSource {
  AnalyticsRemoteDataSource(this._client);
  final MonkApiClient _client;

  Future<AutomatedPostMetrics> getPostAutomatedMetrics(
    String publishedPostId,
  ) async {
    final path = ApiPaths.publishedPostAutomatedMetrics(publishedPostId);
    final response = await _client.dio.get<Map<String, dynamic>>(path);
    final data = response.data ?? <String, dynamic>{};
    return AutomatedPostMetrics.fromJson(data);
  }

  Future<AnalyticsReport> getComparisonReport({
    String? campaignId,
    String? startDate,
    String? endDate,
    String? compareWithId,
  }) async {
    final queryParams = <String, dynamic>{
      if (campaignId != null) 'campaignId': campaignId,
      if (startDate != null) 'startDate': startDate,
      if (endDate != null) 'endDate': endDate,
      if (compareWithId != null) 'compareWithId': compareWithId,
    };
    final response = await _client.dio.get<Map<String, dynamic>>(
      ApiPaths.analyticsReports,
      queryParameters: queryParams,
    );
    final data = response.data ?? <String, dynamic>{};
    return AnalyticsReport.fromJson(data);
  }

  Future<ExportJobStatus> triggerExportJob({
    required String reportType,
    required String format,
    Map<String, dynamic>? params,
  }) async {
    final response = await _client.dio.post<Map<String, dynamic>>(
      ApiPaths.analyticsExport,
      data: {
        'reportType': reportType,
        'format': format,
        if (params != null) 'params': params,
      },
    );
    final data = response.data ?? <String, dynamic>{};
    return ExportJobStatus.fromJson(data);
  }

  Future<ExportJobStatus> getExportJobStatus(String jobId) async {
    final path = '${ApiPaths.analyticsExport}/$jobId';
    final response = await _client.dio.get<Map<String, dynamic>>(path);
    final data = response.data ?? <String, dynamic>{};
    return ExportJobStatus.fromJson(data);
  }

  Future<List<UtmLinkMetric>> getUtmLinks({String? campaignId}) async {
    final queryParams = <String, dynamic>{
      if (campaignId != null) 'campaignId': campaignId,
    };
    final response = await _client.dio.get<List<dynamic>>(
      ApiPaths.utmLinks,
      queryParameters: queryParams,
    );
    final list = response.data ?? <dynamic>[];
    return list
        .map((item) => UtmLinkMetric.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
