import '../../../../core/network/error_mapper.dart';
import '../../domain/entities/analytics_metric.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../datasources/analytics_remote_datasource.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  AnalyticsRepositoryImpl(this._remote);
  final AnalyticsRemoteDataSource _remote;

  @override
  Future<AutomatedPostMetrics> getPostAutomatedMetrics(
    String publishedPostId,
  ) async {
    try {
      return await _remote.getPostAutomatedMetrics(publishedPostId);
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<AnalyticsReport> getComparisonReport({
    String? campaignId,
    String? startDate,
    String? endDate,
    String? compareWithId,
  }) async {
    try {
      return await _remote.getComparisonReport(
        campaignId: campaignId,
        startDate: startDate,
        endDate: endDate,
        compareWithId: compareWithId,
      );
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<ExportJobStatus> triggerExportJob({
    required String reportType,
    required String format,
    Map<String, dynamic>? params,
  }) async {
    try {
      return await _remote.triggerExportJob(
        reportType: reportType,
        format: format,
        params: params,
      );
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<ExportJobStatus> getExportJobStatus(String jobId) async {
    try {
      return await _remote.getExportJobStatus(jobId);
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<List<UtmLinkMetric>> getUtmLinks({String? campaignId}) async {
    try {
      return await _remote.getUtmLinks(campaignId: campaignId);
    } catch (e) {
      throw mapError(e);
    }
  }
}
