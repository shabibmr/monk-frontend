import 'package:api_client/api_client.dart';

import '../../../../core/network/error_mapper.dart';
import '../../domain/entities/dashboard.dart';
import '../../domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl(this._client);
  final MonkApiClient _client;

  MetricTotals _mapMetrics(MetricTotalsDto d) => MetricTotals(
        reach: d.reach,
        impressions: d.impressions,
        views: d.views,
        likes: d.likes,
        comments: d.comments,
        shares: d.shares,
        clicks: d.clicks,
        engagement: d.engagement,
        engagementRateBps: d.engagementRateBps,
      );

  @override
  Future<BrandDashboard> brandDashboard(String brandId) async {
    try {
      final d = await _client.analytics.brandDashboard(brandId);
      return BrandDashboard(
        brandId: d.brandId,
        campaigns: d.campaigns,
        pendingApprovals: d.pendingApprovals,
        spendMinor: d.spendMinor,
        pendingPaymentsCount: d.pendingPaymentsCount,
        pendingPaymentsAmountMinor: d.pendingPaymentsAmountMinor,
        metrics: _mapMetrics(d.metrics),
        managedCollaborationsActive: d.managedCollaborationsActive,
        upcomingPosts: d.upcomingPosts,
        automatedSync: d.automatedSync,
      );
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<ProfileDashboard> profileDashboard(String profileId) async {
    try {
      final d = await _client.analytics.profileDashboard(profileId);
      return ProfileDashboard(
        profileId: d.profileId,
        invitations: d.invitations,
        pendingContent: d.pendingContent,
        earningsPendingMinor: d.earningsPendingMinor,
        earningsReleasedMinor: d.earningsReleasedMinor,
        deadlines: d.deadlines,
        metrics: _mapMetrics(d.metrics),
        automatedSync: d.automatedSync,
      );
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<ManagerDashboard> managerDashboard() async {
    try {
      final d = await _client.analytics.managerDashboard();
      return ManagerDashboard(
        rosterSize: d.rosterSize,
        openTasks: d.openTasks,
        collaborations: d.collaborations,
        metrics: _mapMetrics(d.metrics),
        earningsRollupMinor: d.earningsRollupMinor,
        rosterProfileIds: d.rosterProfileIds,
        automatedSync: d.automatedSync,
      );
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<ManualMetricEntry> enterMetrics({
    required String publishedPostId,
    required Map<String, dynamic> body,
  }) async {
    try {
      final d = await _client.analytics.enterMetrics(publishedPostId, body);
      return ManualMetricEntry(
        id: d.id,
        publishedPostId: d.publishedPostId,
        reach: d.reach,
        impressions: d.impressions,
        views: d.views,
        likes: d.likes,
        comments: d.comments,
        shares: d.shares,
        clicks: d.clicks,
      );
    } catch (e) {
      throw mapError(e);
    }
  }
}
