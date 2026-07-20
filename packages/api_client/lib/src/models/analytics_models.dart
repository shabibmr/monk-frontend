class MetricTotalsDto {
  const MetricTotalsDto({
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

  factory MetricTotalsDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const MetricTotalsDto();
    int n(Object? v) => v is int
        ? v
        : v is num
            ? v.toInt()
            : int.tryParse('$v') ?? 0;
    return MetricTotalsDto(
      reach: n(json['reach']),
      impressions: n(json['impressions']),
      views: n(json['views']),
      likes: n(json['likes']),
      comments: n(json['comments']),
      shares: n(json['shares']),
      clicks: n(json['clicks']),
      engagement: n(json['engagement']),
      engagementRateBps: json['engagementRateBps'] is int
          ? json['engagementRateBps'] as int
          : int.tryParse('${json['engagementRateBps']}'),
    );
  }
}

class BrandDashboardDto {
  const BrandDashboardDto({
    required this.brandId,
    this.campaigns = const {},
    this.pendingApprovals = 0,
    this.spendMinor = 0,
    this.pendingPaymentsCount = 0,
    this.pendingPaymentsAmountMinor = 0,
    this.metrics = const MetricTotalsDto(),
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
  final MetricTotalsDto metrics;
  final int managedCollaborationsActive;
  final int upcomingPosts;
  final bool automatedSync;

  factory BrandDashboardDto.fromJson(Map<String, dynamic> json) {
    final campaigns = json['campaigns'];
    final pending = json['pendingPayments'];
    int n(Object? v) => v is int
        ? v
        : v is num
            ? v.toInt()
            : int.tryParse('$v') ?? 0;
    return BrandDashboardDto(
      brandId: json['brandId'] as String? ?? '',
      campaigns: campaigns is Map
          ? campaigns.map((k, v) => MapEntry(k.toString(), n(v)))
          : const {},
      pendingApprovals: n(json['pendingApprovals']),
      spendMinor: n(json['spendMinor']),
      pendingPaymentsCount: pending is Map ? n(pending['count']) : 0,
      pendingPaymentsAmountMinor:
          pending is Map ? n(pending['amountMinor']) : 0,
      metrics: MetricTotalsDto.fromJson(
        json['metrics'] as Map<String, dynamic>?,
      ),
      managedCollaborationsActive: n(json['managedCollaborationsActive']),
      upcomingPosts: n(json['upcomingPosts']),
      automatedSync: json['automatedSync'] as bool? ?? false,
    );
  }
}

class ProfileDashboardDto {
  const ProfileDashboardDto({
    required this.profileId,
    this.invitations = 0,
    this.pendingContent = 0,
    this.earningsPendingMinor = 0,
    this.earningsReleasedMinor = 0,
    this.deadlines = const [],
    this.metrics = const MetricTotalsDto(),
    this.automatedSync = false,
  });

  final String profileId;
  final int invitations;
  final int pendingContent;
  final int earningsPendingMinor;
  final int earningsReleasedMinor;
  final List<Map<String, dynamic>> deadlines;
  final MetricTotalsDto metrics;
  final bool automatedSync;

  factory ProfileDashboardDto.fromJson(Map<String, dynamic> json) {
    int n(Object? v) => v is int
        ? v
        : v is num
            ? v.toInt()
            : int.tryParse('$v') ?? 0;
    final earnings = json['earnings'];
    final deadlines = json['deadlines'] as List<dynamic>? ?? const [];
    return ProfileDashboardDto(
      profileId: json['profileId'] as String? ?? '',
      invitations: n(json['invitations']),
      pendingContent: n(json['pendingContent']),
      earningsPendingMinor:
          earnings is Map ? n(earnings['pendingMinor']) : 0,
      earningsReleasedMinor:
          earnings is Map ? n(earnings['releasedMinor']) : 0,
      deadlines: deadlines
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList(),
      metrics: MetricTotalsDto.fromJson(
        json['metrics'] as Map<String, dynamic>?,
      ),
      automatedSync: json['automatedSync'] as bool? ?? false,
    );
  }
}

class ManagerDashboardDto {
  const ManagerDashboardDto({
    this.rosterSize = 0,
    this.openTasks = 0,
    this.collaborations = 0,
    this.metrics = const MetricTotalsDto(),
    this.earningsRollupMinor = 0,
    this.rosterProfileIds = const [],
    this.automatedSync = false,
  });

  final int rosterSize;
  final int openTasks;
  final int collaborations;
  final MetricTotalsDto metrics;
  final int earningsRollupMinor;
  final List<String> rosterProfileIds;
  final bool automatedSync;

  factory ManagerDashboardDto.fromJson(Map<String, dynamic> json) {
    int n(Object? v) => v is int
        ? v
        : v is num
            ? v.toInt()
            : int.tryParse('$v') ?? 0;
    final ids = json['rosterProfileIds'];
    return ManagerDashboardDto(
      rosterSize: n(json['rosterSize']),
      openTasks: n(json['openTasks']),
      collaborations: n(json['collaborations']),
      metrics: MetricTotalsDto.fromJson(
        json['metrics'] as Map<String, dynamic>?,
      ),
      earningsRollupMinor: n(json['earningsRollupMinor']),
      rosterProfileIds: ids is List
          ? ids.map((e) => e.toString()).toList()
          : const [],
      automatedSync: json['automatedSync'] as bool? ?? false,
    );
  }
}

class ManualMetricDto {
  const ManualMetricDto({
    required this.id,
    required this.publishedPostId,
    this.reach,
    this.impressions,
    this.views,
    this.likes,
    this.comments,
    this.shares,
    this.clicks,
    this.enteredAt,
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
  final String? enteredAt;

  factory ManualMetricDto.fromJson(Map<String, dynamic> json) {
    int? ni(Object? v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse('$v');
    }

    return ManualMetricDto(
      id: json['id'] as String,
      publishedPostId: json['publishedPostId'] as String? ?? '',
      reach: ni(json['reach']),
      impressions: ni(json['impressions']),
      views: ni(json['views']),
      likes: ni(json['likes']),
      comments: ni(json['comments']),
      shares: ni(json['shares']),
      clicks: ni(json['clicks']),
      enteredAt: json['enteredAt']?.toString(),
    );
  }
}
