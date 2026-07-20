import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:monk_web/core/errors/failures.dart';
import 'package:monk_web/features/dashboards/domain/entities/dashboard.dart';
import 'package:monk_web/features/dashboards/domain/repositories/dashboard_repository.dart';
import 'package:monk_web/features/dashboards/presentation/cubit/dashboard_cubit.dart';
import 'package:monk_web/features/dashboards/presentation/cubit/metrics_form_cubit.dart';

class _MockRepo extends Mock implements DashboardRepository {}

void main() {
  late _MockRepo repo;

  const brand = BrandDashboard(
    brandId: 'b1',
    campaigns: {'active': 2, 'draft': 1},
    pendingApprovals: 3,
    spendMinor: 50000,
    pendingPaymentsCount: 1,
    pendingPaymentsAmountMinor: 10000,
    metrics: MetricTotals(reach: 1000, impressions: 2000, engagement: 50),
    upcomingPosts: 2,
  );

  const emptyBrand = BrandDashboard(brandId: 'b1');

  setUp(() {
    repo = _MockRepo();
  });

  test('KPIs render from API fixtures on entity', () {
    expect(brand.totalCampaigns, 3);
    expect(brand.spendMinor, 50000);
    expect(brand.metrics.reach, 1000);
    expect(brand.isEmpty, isFalse);
    expect(emptyBrand.isEmpty, isTrue);
  });

  blocTest<DashboardCubit, DashboardState>(
    'empty dashboard state',
    build: () {
      when(() => repo.brandDashboard('b1')).thenAnswer((_) async => emptyBrand);
      return DashboardCubit(repo);
    },
    act: (c) => c.loadBrand('b1'),
    expect: () => [
      isA<DashboardState>().having((s) => s.loading, 'loading', true),
      isA<DashboardState>()
          .having((s) => s.brand?.isEmpty, 'empty', true)
          .having((s) => s.loading, 'loading', false),
    ],
  );

  blocTest<DashboardCubit, DashboardState>(
    'brand KPIs load from API',
    build: () {
      when(() => repo.brandDashboard('b1')).thenAnswer((_) async => brand);
      return DashboardCubit(repo);
    },
    act: (c) => c.loadBrand('b1'),
    verify: (c) {
      expect(c.state.brand?.pendingApprovals, 3);
      expect(c.state.brand?.metrics.impressions, 2000);
    },
  );

  blocTest<MetricsFormCubit, MetricsFormState>(
    'manual metrics save success',
    build: () {
      when(
        () => repo.enterMetrics(
          publishedPostId: any(named: 'publishedPostId'),
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async => const ManualMetricEntry(
          id: 'm1',
          publishedPostId: 'post1',
          reach: 100,
          likes: 10,
        ),
      );
      return MetricsFormCubit(repo);
    },
    act: (c) => c.save(
      publishedPostId: 'post1',
      body: {'reach': 100, 'likes': 10},
    ),
    verify: (c) {
      expect(c.state.lastEntry?.reach, 100);
      expect(c.state.infoMessage, 'Metrics saved');
      verify(
        () => repo.enterMetrics(
          publishedPostId: 'post1',
          body: {'reach': 100, 'likes': 10},
        ),
      ).called(1);
    },
  );

  blocTest<MetricsFormCubit, MetricsFormState>(
    'manual metrics save failure',
    build: () {
      when(
        () => repo.enterMetrics(
          publishedPostId: any(named: 'publishedPostId'),
          body: any(named: 'body'),
        ),
      ).thenThrow(const ServerFailure('save failed'));
      return MetricsFormCubit(repo);
    },
    act: (c) => c.save(
      publishedPostId: 'post1',
      body: {'reach': 1},
    ),
    verify: (c) {
      expect(c.state.failure, isA<ServerFailure>());
      expect(c.state.lastEntry, isNull);
    },
  );
}
