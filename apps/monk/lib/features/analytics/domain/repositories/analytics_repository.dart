import '../entities/analytics_metric.dart';

abstract class AnalyticsRepository {
  /// Fetches automated metrics (read-only IG/YT) for a published post.
  Future<AutomatedPostMetrics> getPostAutomatedMetrics(String publishedPostId);

  /// Fetches campaign performance report and period-over-period comparisons.
  Future<AnalyticsReport> getComparisonReport({
    String? campaignId,
    String? startDate,
    String? endDate,
    String? compareWithId,
  });

  /// Triggers an asynchronous export job (CSV, PDF, XLSX).
  Future<ExportJobStatus> triggerExportJob({
    required String reportType,
    required String format,
    Map<String, dynamic>? params,
  });

  /// Fetches status & progress of a running/completed export job.
  Future<ExportJobStatus> getExportJobStatus(String jobId);

  /// Fetches tracked UTM links performance metrics.
  Future<List<UtmLinkMetric>> getUtmLinks({String? campaignId});
}
