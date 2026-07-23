import 'package:equatable/equatable.dart';

class MetricTotals extends Equatable {
  const MetricTotals({
    this.reach = 0,
    this.impressions = 0,
    this.views = 0,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.clicks = 0,
    this.engagement = 0,
    this.engagementRateBps,
  });

  final int reach;
  final int impressions;
  final int views;
  final int likes;
  final int comments;
  final int shares;
  final int clicks;
  final int engagement;
  final int? engagementRateBps;

  bool get isEmpty =>
      reach == 0 &&
      impressions == 0 &&
      views == 0 &&
      likes == 0 &&
      comments == 0 &&
      shares == 0 &&
      clicks == 0;

  @override
  List<Object?> get props => [
        reach,
        impressions,
        views,
        likes,
        comments,
        shares,
        clicks,
        engagement,
        engagementRateBps,
      ];
}

class BrandDashboard extends Equatable {
  const BrandDashboard({
    required this.brandId,
    this.campaigns = const {},
    this.pendingApprovals = 0,
    this.spendMinor = 0,
    this.pendingPaymentsCount = 0,
    this.pendingPaymentsAmountMinor = 0,
    this.metrics = const MetricTotals(),
    this.managedCollaborationsActive = 0,
    this.upcomingPosts = 0,
    this.automatedSync = false,
  });

  final String brandId;
  final Map<String, int> campaigns;
  final int pendingApprovals;
  final int spendMinor;
  final int pendingPaymentsCount;
  final int pendingPaymentsAmountMinor;
  final MetricTotals metrics;
  final int managedCollaborationsActive;
  final int upcomingPosts;
  final bool automatedSync;

  int get totalCampaigns =>
      campaigns.values.fold<int>(0, (a, b) => a + b);

  bool get isEmpty =>
      totalCampaigns == 0 &&
      pendingApprovals == 0 &&
      spendMinor == 0 &&
      metrics.isEmpty;

  @override
  List<Object?> get props => [
        brandId,
        campaigns,
        pendingApprovals,
        spendMinor,
        pendingPaymentsCount,
        pendingPaymentsAmountMinor,
        metrics,
        managedCollaborationsActive,
        upcomingPosts,
        automatedSync,
      ];
}

class ProfileDashboard extends Equatable {
  const ProfileDashboard({
    required this.profileId,
    this.invitations = 0,
    this.pendingContent = 0,
    this.earningsPendingMinor = 0,
    this.earningsReleasedMinor = 0,
    this.deadlines = const [],
    this.metrics = const MetricTotals(),
    this.automatedSync = false,
  });

  final String profileId;
  final int invitations;
  final int pendingContent;
  final int earningsPendingMinor;
  final int earningsReleasedMinor;
  final List<Map<String, dynamic>> deadlines;
  final MetricTotals metrics;
  final bool automatedSync;

  bool get isEmpty =>
      invitations == 0 &&
      pendingContent == 0 &&
      earningsPendingMinor == 0 &&
      earningsReleasedMinor == 0 &&
      metrics.isEmpty;

  @override
  List<Object?> get props => [
        profileId,
        invitations,
        pendingContent,
        earningsPendingMinor,
        earningsReleasedMinor,
        deadlines,
        metrics,
        automatedSync,
      ];
}

class ManagerDashboard extends Equatable {
  const ManagerDashboard({
    this.rosterSize = 0,
    this.openTasks = 0,
    this.collaborations = 0,
    this.metrics = const MetricTotals(),
    this.earningsRollupMinor = 0,
    this.rosterProfileIds = const [],
    this.automatedSync = false,
  });

  final int rosterSize;
  final int openTasks;
  final int collaborations;
  final MetricTotals metrics;
  final int earningsRollupMinor;
  final List<String> rosterProfileIds;
  final bool automatedSync;

  bool get isEmpty =>
      rosterSize == 0 && openTasks == 0 && collaborations == 0;

  @override
  List<Object?> get props => [
        rosterSize,
        openTasks,
        collaborations,
        metrics,
        earningsRollupMinor,
        rosterProfileIds,
        automatedSync,
      ];
}

class ManualMetricEntry extends Equatable {
  const ManualMetricEntry({
    required this.id,
    required this.publishedPostId,
    this.reach,
    this.impressions,
    this.views,
    this.likes,
    this.comments,
    this.shares,
    this.clicks,
  });

  final String id;
  final String publishedPostId;
  final int? reach;
  final int? impressions;
  final int? views;
  final int? likes;
  final int? comments;
  final int? shares;
  final int? clicks;

  @override
  List<Object?> get props => [
        id,
        publishedPostId,
        reach,
        impressions,
        views,
        likes,
        comments,
        shares,
        clicks,
      ];
}
