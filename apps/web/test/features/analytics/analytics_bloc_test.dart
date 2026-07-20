import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:monk_web/core/errors/failures.dart';
import 'package:monk_web/features/analytics/domain/entities/analytics_metric.dart';
import 'package:monk_web/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:monk_web/features/analytics/presentation/bloc/analytics_bloc.dart';

class _MockAnalyticsRepository extends Mock implements AnalyticsRepository {}

void main() {
  late _MockAnalyticsRepository repository;

  const sampleMetrics = AutomatedPostMetrics(
    id: 'm1',
    publishedPostId: 'p1',
    platform: 'instagram',
    reach: 5000,
    impressions: 12000,
    views: 8000,
    likes: 450,
    comments: 30,
    shares: 15,
    clicks: 120,
    engagementRateBps: 425,
  );

  const sampleReport = AnalyticsReport(
    id: 'r1',
    title: 'Q3 Campaign Report',
    totalReach: 50000,
    totalImpressions: 120000,
    totalEngagement: 8500,
    totalSpendMinor: 150000,
    currency: 'USD',
    metricsComparison: [
      MetricComparisonItem(
        metricName: 'Reach',
        currentValue: 50000,
        previousValue: 40000,
        changePercentage: 25.0,
        isPositive: true,
      ),
    ],
  );

  const sampleExportJob = ExportJobStatus(
    jobId: 'job_123',
    reportType: 'campaign_performance',
    format: 'csv',
    status: 'pending',
    progressPercent: 10,
  );

  const sampleCompletedExportJob = ExportJobStatus(
    jobId: 'job_123',
    reportType: 'campaign_performance',
    format: 'csv',
    status: 'completed',
    progressPercent: 100,
    downloadUrl: 'https://example.com/export.csv',
  );

  const sampleUtmLinks = [
    UtmLinkMetric(
      id: 'u1',
      code: 'SUMMER2026',
      targetUrl: 'https://brand.com/summer',
      fullUtmUrl: 'https://brand.com/summer?utm_source=monk',
      clicks: 450,
      conversions: 32,
      revenueMinor: 48000,
    ),
  ];

  setUp(() {
    repository = _MockAnalyticsRepository();
  });

  group('AnalyticsBloc - FetchPostAutomatedMetrics', () {
    blocTest<AnalyticsBloc, AnalyticsState>(
      'emits [loading, success] when post metrics fetch succeeds',
      build: () {
        when(() => repository.getPostAutomatedMetrics('p1'))
            .thenAnswer((_) async => sampleMetrics);
        return AnalyticsBloc(repository: repository);
      },
      act: (bloc) => bloc.add(const FetchPostAutomatedMetrics('p1')),
      expect: () => [
        const AnalyticsState(
          status: AnalyticsStatus.loading,
        ),
        const AnalyticsState(
          status: AnalyticsStatus.success,
          postMetrics: sampleMetrics,
        ),
      ],
      verify: (_) {
        verify(() => repository.getPostAutomatedMetrics('p1')).called(1);
      },
    );

    blocTest<AnalyticsBloc, AnalyticsState>(
      'emits [loading, failure] when post metrics fetch fails',
      build: () {
        when(() => repository.getPostAutomatedMetrics('p1')).thenThrow(
          const NetworkFailure('Network error'),
        );
        return AnalyticsBloc(repository: repository);
      },
      act: (bloc) => bloc.add(const FetchPostAutomatedMetrics('p1')),
      expect: () => [
        const AnalyticsState(
          status: AnalyticsStatus.loading,
        ),
        const AnalyticsState(
          status: AnalyticsStatus.failure,
          failure: NetworkFailure('Network error'),
        ),
      ],
    );
  });

  group('AnalyticsBloc - FetchComparisonReport', () {
    blocTest<AnalyticsBloc, AnalyticsState>(
      'emits [loading, success] when comparison report fetch succeeds',
      build: () {
        when(
          () => repository.getComparisonReport(
            campaignId: any(named: 'campaignId'),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            compareWithId: any(named: 'compareWithId'),
          ),
        ).thenAnswer((_) async => sampleReport);
        return AnalyticsBloc(repository: repository);
      },
      act: (bloc) => bloc.add(const FetchComparisonReport(campaignId: 'c1')),
      expect: () => [
        const AnalyticsState(
          status: AnalyticsStatus.loading,
        ),
        const AnalyticsState(
          status: AnalyticsStatus.success,
          comparisonReport: sampleReport,
        ),
      ],
    );
  });

  group('AnalyticsBloc - TriggerExportJob & Polling', () {
    blocTest<AnalyticsBloc, AnalyticsState>(
      'triggers export job and updates state with job status',
      build: () {
        when(
          () => repository.triggerExportJob(
            reportType: 'campaign_performance',
            format: 'csv',
            params: any(named: 'params'),
          ),
        ).thenAnswer((_) async => sampleExportJob);
        return AnalyticsBloc(repository: repository);
      },
      act: (bloc) => bloc.add(
        const TriggerExportJob(
          reportType: 'campaign_performance',
          format: 'csv',
        ),
      ),
      expect: () => [
        const AnalyticsState(
          isExporting: true,
          infoMessage: 'Export job initiated…',
        ),
        const AnalyticsState(
          isExporting: true,
          exportJobStatus: sampleExportJob,
          infoMessage: 'Export job queued (CSV)',
        ),
      ],
    );

    blocTest<AnalyticsBloc, AnalyticsState>(
      'polls export job status until completed',
      build: () {
        when(() => repository.getExportJobStatus('job_123'))
            .thenAnswer((_) async => sampleCompletedExportJob);
        return AnalyticsBloc(repository: repository);
      },
      act: (bloc) => bloc.add(const PollExportJobStatus('job_123')),
      expect: () => [
        const AnalyticsState(
          isExporting: false,
          exportJobStatus: sampleCompletedExportJob,
        ),
      ],
    );
  });

  group('AnalyticsBloc - FetchUtmLinks', () {
    blocTest<AnalyticsBloc, AnalyticsState>(
      'emits [loading, success] when fetching UTM links succeeds',
      build: () {
        when(() => repository.getUtmLinks(campaignId: 'c1'))
            .thenAnswer((_) async => sampleUtmLinks);
        return AnalyticsBloc(repository: repository);
      },
      act: (bloc) => bloc.add(const FetchUtmLinks(campaignId: 'c1')),
      expect: () => [
        const AnalyticsState(
          status: AnalyticsStatus.loading,
        ),
        const AnalyticsState(
          status: AnalyticsStatus.success,
          utmLinks: sampleUtmLinks,
        ),
      ],
    );
  });

  group('AnalyticsBloc - ResetExportStatus', () {
    blocTest<AnalyticsBloc, AnalyticsState>(
      'resets export job status and flags',
      build: () => AnalyticsBloc(repository: repository),
      seed: () => const AnalyticsState(
        isExporting: true,
        exportJobStatus: sampleExportJob,
        infoMessage: 'Active export',
      ),
      act: (bloc) => bloc.add(const ResetExportStatus()),
      expect: () => [
        const AnalyticsState(
          isExporting: false,
          exportJobStatus: null,
          infoMessage: null,
        ),
      ],
    );
  });
}
