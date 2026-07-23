import '../../../features/analytics/domain/entities/analytics_metric.dart';
import '../../../features/analytics/domain/repositories/analytics_repository.dart';
import '../../errors/failures.dart';
import '../mock_ids.dart';
import '../mock_seed_store.dart';

/// Offline demo implementation of [AnalyticsRepository].
class MockAnalyticsRepository implements AnalyticsRepository {
  MockAnalyticsRepository(this.store);

  final MockSeedStore store;

  static const _metricsKey = 'automated_metrics';
  static const _utmKey = 'utm_links';
  static const _exportsKey = 'export_jobs';
  static const _reportKey = 'analytics_report';

  void _ensureSeeded() {
    if (store.list<AutomatedPostMetrics>(_metricsKey).isNotEmpty ||
        store.list<AnalyticsReport>(_reportKey).isNotEmpty) {
      return;
    }
    final now = DateTime.now();
    final history = List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      return MetricDataPoint(
        timestamp: day,
        label: '${day.month}/${day.day}',
        value: 12000 + i * 1800.0,
        secondaryValue: 800 + i * 120.0,
      );
    });

    store.putAll(_metricsKey, [
      AutomatedPostMetrics(
        id: 'metrics-demo-1',
        publishedPostId: MockIds.published1,
        platform: 'instagram',
        reach: 48500,
        impressions: 92000,
        views: 61000,
        likes: 4200,
        comments: 310,
        shares: 180,
        clicks: 960,
        engagementRateBps: 615,
        lastSyncedAt: now.subtract(const Duration(hours: 2)),
        history: history,
      ),
    ]);

    final utm = [
      UtmLinkMetric(
        id: 'utm-demo-1',
        code: 'SUMMER26',
        targetUrl: 'https://shop.demo.local/summer',
        fullUtmUrl:
            'https://shop.demo.local/summer?utm_source=monk&utm_campaign=camp-demo-1&utm_content=SUMMER26',
        clicks: 1840,
        conversions: 126,
        revenueMinor: 378000,
        campaignId: MockIds.campaign1,
      ),
      UtmLinkMetric(
        id: 'utm-demo-2',
        code: 'CREATOR1',
        targetUrl: 'https://shop.demo.local/serum',
        fullUtmUrl:
            'https://shop.demo.local/serum?utm_source=monk&utm_campaign=camp-demo-1&utm_content=CREATOR1',
        clicks: 920,
        conversions: 54,
        revenueMinor: 162000,
        campaignId: MockIds.campaign1,
      ),
    ];
    store.putAll(_utmKey, utm);

    store.putAll(_reportKey, [
      AnalyticsReport(
        id: 'report-demo-1',
        title: 'Campaign Performance — Summer Launch',
        campaignId: MockIds.campaign1,
        startDate: now.subtract(const Duration(days: 30)),
        endDate: now,
        totalReach: 128500,
        totalImpressions: 245000,
        totalEngagement: 18200,
        totalSpendMinor: 4500000,
        currency: 'INR',
        metricsComparison: const [
          MetricComparisonItem(
            metricName: 'Reach',
            currentValue: 128500,
            previousValue: 98000,
            changePercentage: 31.1,
            isPositive: true,
          ),
          MetricComparisonItem(
            metricName: 'Engagement',
            currentValue: 18200,
            previousValue: 15100,
            changePercentage: 20.5,
            isPositive: true,
          ),
          MetricComparisonItem(
            metricName: 'Spend',
            currentValue: 45000,
            previousValue: 42000,
            changePercentage: 7.1,
            isPositive: false,
          ),
        ],
        utmLinks: utm,
        chartSeries: history,
      ),
    ]);
  }

  @override
  Future<AutomatedPostMetrics> getPostAutomatedMetrics(
    String publishedPostId,
  ) async {
    await store.delay();
    _ensureSeeded();
    final existing = store.findWhere<AutomatedPostMetrics>(
      _metricsKey,
      (m) => m.publishedPostId == publishedPostId,
    );
    if (existing != null) return existing;

    // Canned metrics for any unknown post id so demo screens never empty-crash.
    final canned = AutomatedPostMetrics(
      id: 'metrics-$publishedPostId',
      publishedPostId: publishedPostId,
      platform: 'instagram',
      reach: 12000,
      impressions: 24000,
      views: 15000,
      likes: 900,
      comments: 45,
      shares: 22,
      clicks: 180,
      engagementRateBps: 480,
      lastSyncedAt: DateTime.now(),
    );
    store.add(_metricsKey, canned);
    return canned;
  }

  @override
  Future<AnalyticsReport> getComparisonReport({
    String? campaignId,
    String? startDate,
    String? endDate,
    String? compareWithId,
  }) async {
    await store.delay();
    _ensureSeeded();
    final reports = store.list<AnalyticsReport>(_reportKey);
    final base = reports.isEmpty
        ? null
        : reports.firstWhere(
            (r) => campaignId == null || r.campaignId == campaignId,
            orElse: () => reports.first,
          );
    if (base == null) {
      throw const NotFoundFailure('Analytics report is unavailable.');
    }
    return AnalyticsReport(
      id: base.id,
      title: campaignId != null
          ? 'Campaign Performance — $campaignId'
          : base.title,
      campaignId: campaignId ?? base.campaignId,
      startDate: startDate != null
          ? DateTime.tryParse(startDate) ?? base.startDate
          : base.startDate,
      endDate: endDate != null
          ? DateTime.tryParse(endDate) ?? base.endDate
          : base.endDate,
      totalReach: base.totalReach,
      totalImpressions: base.totalImpressions,
      totalEngagement: base.totalEngagement,
      totalSpendMinor: base.totalSpendMinor,
      currency: base.currency,
      metricsComparison: base.metricsComparison,
      utmLinks: store.list<UtmLinkMetric>(_utmKey).where((u) {
        if (campaignId == null || campaignId.isEmpty) return true;
        return u.campaignId == campaignId;
      }).toList(),
      chartSeries: base.chartSeries,
    );
  }

  @override
  Future<ExportJobStatus> triggerExportJob({
    required String reportType,
    required String format,
    Map<String, dynamic>? params,
  }) async {
    await store.delay();
    _ensureSeeded();
    final allowed = {'csv', 'pdf', 'xlsx'};
    if (!allowed.contains(format.toLowerCase())) {
      throw ValidationFailure(
        'Unsupported export format "$format". Use csv, pdf, or xlsx.',
      );
    }
    final job = ExportJobStatus(
      jobId: 'export-mock-${DateTime.now().millisecondsSinceEpoch}',
      reportType: reportType,
      format: format.toLowerCase(),
      status: 'completed',
      progressPercent: 100,
      downloadUrl:
          'https://cdn.monk.local/exports/$reportType.${format.toLowerCase()}',
      createdAt: DateTime.now(),
    );
    store.add(_exportsKey, job);
    return job;
  }

  @override
  Future<ExportJobStatus> getExportJobStatus(String jobId) async {
    await store.delay();
    _ensureSeeded();
    final job =
        store.findWhere<ExportJobStatus>(_exportsKey, (j) => j.jobId == jobId);
    if (job == null) {
      throw NotFoundFailure('Export job not found: $jobId');
    }
    return job;
  }

  @override
  Future<List<UtmLinkMetric>> getUtmLinks({String? campaignId}) async {
    await store.delay();
    _ensureSeeded();
    final all = store.list<UtmLinkMetric>(_utmKey);
    if (campaignId == null || campaignId.isEmpty) return all;
    return all.where((u) => u.campaignId == campaignId).toList();
  }
}
