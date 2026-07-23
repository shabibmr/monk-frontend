import '../../../features/dashboards/domain/entities/dashboard.dart';
import '../../../features/dashboards/domain/repositories/dashboard_repository.dart';
import '../../../features/publish/domain/entities/published_post.dart';
import '../../errors/failures.dart';
import '../mock_ids.dart';
import '../mock_seed_store.dart';

/// In-memory [DashboardRepository].
///
/// Store keys:
/// - singles `brand_dashboards` → `Map<String, BrandDashboard>`
/// - singles `profile_dashboards` → `Map<String, ProfileDashboard>`
/// - singles `manager_dashboard` → `ManagerDashboard`
/// - `manual_metrics` → `List<ManualMetricEntry>`
class MockDashboardRepository implements DashboardRepository {
  MockDashboardRepository(this._store);

  final MockSeedStore _store;

  void _ensureFixtures() {
    final brands = _brandMap();
    brands.putIfAbsent(
      MockIds.brandOrg1,
      () => BrandDashboard(
        brandId: MockIds.brandOrg1,
        campaigns: const {
          'draft': 1,
          'applications_open': 1,
          'in_progress': 1,
          'completed': 1,
        },
        pendingApprovals: 2,
        spendMinor: 2750000,
        pendingPaymentsCount: 1,
        pendingPaymentsAmountMinor: 1500000,
        metrics: const MetricTotals(
          reach: 420000,
          impressions: 890000,
          views: 310000,
          likes: 28500,
          comments: 2100,
          shares: 980,
          clicks: 5400,
          engagement: 36980,
          engagementRateBps: 415,
        ),
        managedCollaborationsActive: 2,
        upcomingPosts: 3,
        automatedSync: false,
      ),
    );

    final profiles = _profileMap();
    profiles.putIfAbsent(
      MockIds.influencer1,
      () => ProfileDashboard(
        profileId: MockIds.influencer1,
        invitations: 1,
        pendingContent: 1,
        earningsPendingMinor: 1275000,
        earningsReleasedMinor: 350000,
        deadlines: const [
          {
            'collaborationId': MockIds.collab1,
            'label': 'Submit reel draft',
            'dueAt': '2026-08-01T00:00:00.000Z',
          },
        ],
        metrics: const MetricTotals(
          reach: 180000,
          impressions: 320000,
          views: 150000,
          likes: 12000,
          comments: 890,
          shares: 340,
          clicks: 2100,
          engagement: 15330,
          engagementRateBps: 480,
        ),
        automatedSync: false,
      ),
    );

    _store.singles.putIfAbsent(
      'manager_dashboard',
      () => ManagerDashboard(
        rosterSize: 1,
        openTasks: 3,
        collaborations: 2,
        metrics: const MetricTotals(
          reach: 180000,
          impressions: 320000,
          views: 150000,
          likes: 12000,
          comments: 890,
          shares: 340,
          clicks: 2100,
          engagement: 15330,
        ),
        earningsRollupMinor: 1625000,
        rosterProfileIds: const [MockIds.influencer1],
        automatedSync: false,
      ),
    );
  }

  Map<String, BrandDashboard> _brandMap() {
    final raw = _store.singles['brand_dashboards'];
    if (raw is Map<String, BrandDashboard>) return raw;
    // Also accept singular key used by some seed sketches.
    final singular = _store.singles['brand_dashboard'];
    if (singular is BrandDashboard) {
      final map = <String, BrandDashboard>{singular.brandId: singular};
      _store.singles['brand_dashboards'] = map;
      return map;
    }
    if (raw is Map) {
      final converted = <String, BrandDashboard>{};
      raw.forEach((k, v) {
        if (v is BrandDashboard) converted[k.toString()] = v;
      });
      _store.singles['brand_dashboards'] = converted;
      return converted;
    }
    final map = <String, BrandDashboard>{};
    _store.singles['brand_dashboards'] = map;
    return map;
  }

  Map<String, ProfileDashboard> _profileMap() {
    final raw = _store.singles['profile_dashboards'];
    if (raw is Map<String, ProfileDashboard>) return raw;
    final singular = _store.singles['profile_dashboard'];
    if (singular is ProfileDashboard) {
      final map = <String, ProfileDashboard>{singular.profileId: singular};
      _store.singles['profile_dashboards'] = map;
      return map;
    }
    if (raw is Map) {
      final converted = <String, ProfileDashboard>{};
      raw.forEach((k, v) {
        if (v is ProfileDashboard) converted[k.toString()] = v;
      });
      _store.singles['profile_dashboards'] = converted;
      return converted;
    }
    final map = <String, ProfileDashboard>{};
    _store.singles['profile_dashboards'] = map;
    return map;
  }

  @override
  Future<BrandDashboard> brandDashboard(String brandId) async {
    await _store.delay();
    _ensureFixtures();
    return _brandMap()[brandId] ??
        BrandDashboard(
          brandId: brandId,
          campaigns: const {},
          metrics: const MetricTotals(),
        );
  }

  @override
  Future<ProfileDashboard> profileDashboard(String profileId) async {
    await _store.delay();
    _ensureFixtures();
    return _profileMap()[profileId] ??
        ProfileDashboard(
          profileId: profileId,
          metrics: const MetricTotals(),
        );
  }

  @override
  Future<ManagerDashboard> managerDashboard() async {
    await _store.delay();
    _ensureFixtures();
    final raw = _store.singles['manager_dashboard'];
    if (raw is ManagerDashboard) return raw;
    return const ManagerDashboard();
  }

  @override
  Future<ManualMetricEntry> enterMetrics({
    required String publishedPostId,
    required Map<String, dynamic> body,
  }) async {
    await _store.delay();
    _ensureFixtures();

    // Soft-check published post exists when store has posts.
    final posts = _store.list<PublishedPost>('published_posts');
    if (posts.isNotEmpty &&
        !posts.any((p) => p.id == publishedPostId) &&
        publishedPostId != MockIds.published1) {
      throw NotFoundFailure('Published post not found: $publishedPostId');
    }

    int? asInt(String key) {
      final v = body[key];
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v);
      return null;
    }

    final entry = ManualMetricEntry(
      id: 'metric-mock-${DateTime.now().microsecondsSinceEpoch}',
      publishedPostId: publishedPostId,
      reach: asInt('reach'),
      impressions: asInt('impressions'),
      views: asInt('views'),
      likes: asInt('likes'),
      comments: asInt('comments'),
      shares: asInt('shares'),
      clicks: asInt('clicks'),
    );
    _store.add('manual_metrics', entry);
    return entry;
  }
}
