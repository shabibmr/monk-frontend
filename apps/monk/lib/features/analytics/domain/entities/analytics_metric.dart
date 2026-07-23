import 'package:equatable/equatable.dart';

/// Represents a single metric data point over time for charts.
class MetricDataPoint extends Equatable {
  const MetricDataPoint({
    required this.timestamp,
    required this.label,
    required this.value,
    this.secondaryValue,
  });

  final DateTime timestamp;
  final String label;
  final double value;
  final double? secondaryValue;

  @override
  List<Object?> get props => [timestamp, label, value, secondaryValue];

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'label': label,
        'value': value,
        if (secondaryValue != null) 'secondaryValue': secondaryValue,
      };

  factory MetricDataPoint.fromJson(Map<String, dynamic> json) {
    return MetricDataPoint(
      timestamp: DateTime.parse(json['timestamp'] as String),
      label: json['label'] as String,
      value: (json['value'] as num).toDouble(),
      secondaryValue: (json['secondaryValue'] as num?)?.toDouble(),
    );
  }
}

/// Automated IG/YT metrics for a published post.
class AutomatedPostMetrics extends Equatable {
  const AutomatedPostMetrics({
    required this.id,
    required this.publishedPostId,
    required this.platform,
    this.reach = 0,
    this.impressions = 0,
    this.views = 0,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.clicks = 0,
    this.engagementRateBps = 0,
    this.lastSyncedAt,
    this.history = const [],
    this.isSyncing = false,
  });

  final String id;
  final String publishedPostId;
  final String platform;
  final int reach;
  final int impressions;
  final int views;
  final int likes;
  final int comments;
  final int shares;
  final int clicks;
  final int engagementRateBps;
  final DateTime? lastSyncedAt;
  final List<MetricDataPoint> history;
  final bool isSyncing;

  int get totalEngagement => likes + comments + shares + clicks;

  @override
  List<Object?> get props => [
        id,
        publishedPostId,
        platform,
        reach,
        impressions,
        views,
        likes,
        comments,
        shares,
        clicks,
        engagementRateBps,
        lastSyncedAt,
        history,
        isSyncing,
      ];

  Map<String, dynamic> toJson() => {
        'id': id,
        'publishedPostId': publishedPostId,
        'platform': platform,
        'reach': reach,
        'impressions': impressions,
        'views': views,
        'likes': likes,
        'comments': comments,
        'shares': shares,
        'clicks': clicks,
        'engagementRateBps': engagementRateBps,
        if (lastSyncedAt != null)
          'lastSyncedAt': lastSyncedAt!.toIso8601String(),
        'history': history.map((e) => e.toJson()).toList(),
        'isSyncing': isSyncing,
      };

  factory AutomatedPostMetrics.fromJson(Map<String, dynamic> json) {
    return AutomatedPostMetrics(
      id: json['id'] as String? ?? '',
      publishedPostId: json['publishedPostId'] as String? ?? '',
      platform: json['platform'] as String? ?? 'unknown',
      reach: (json['reach'] as num?)?.toInt() ?? 0,
      impressions: (json['impressions'] as num?)?.toInt() ?? 0,
      views: (json['views'] as num?)?.toInt() ?? 0,
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      comments: (json['comments'] as num?)?.toInt() ?? 0,
      shares: (json['shares'] as num?)?.toInt() ?? 0,
      clicks: (json['clicks'] as num?)?.toInt() ?? 0,
      engagementRateBps: (json['engagementRateBps'] as num?)?.toInt() ?? 0,
      lastSyncedAt: json['lastSyncedAt'] != null
          ? DateTime.tryParse(json['lastSyncedAt'] as String)
          : null,
      history: (json['history'] as List<dynamic>?)
              ?.map((e) => MetricDataPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isSyncing: json['isSyncing'] as bool? ?? false,
    );
  }
}

/// Comparison metric between time periods or campaigns.
class MetricComparisonItem extends Equatable {
  const MetricComparisonItem({
    required this.metricName,
    required this.currentValue,
    required this.previousValue,
    required this.changePercentage,
    required this.isPositive,
  });

  final String metricName;
  final double currentValue;
  final double previousValue;
  final double changePercentage;
  final bool isPositive;

  @override
  List<Object?> get props => [
        metricName,
        currentValue,
        previousValue,
        changePercentage,
        isPositive,
      ];

  Map<String, dynamic> toJson() => {
        'metricName': metricName,
        'currentValue': currentValue,
        'previousValue': previousValue,
        'changePercentage': changePercentage,
        'isPositive': isPositive,
      };

  factory MetricComparisonItem.fromJson(Map<String, dynamic> json) {
    return MetricComparisonItem(
      metricName: json['metricName'] as String,
      currentValue: (json['currentValue'] as num).toDouble(),
      previousValue: (json['previousValue'] as num).toDouble(),
      changePercentage: (json['changePercentage'] as num).toDouble(),
      isPositive: json['isPositive'] as bool,
    );
  }
}

/// UTM link performance entity.
class UtmLinkMetric extends Equatable {
  const UtmLinkMetric({
    required this.id,
    required this.code,
    required this.targetUrl,
    required this.fullUtmUrl,
    required this.clicks,
    required this.conversions,
    this.revenueMinor = 0,
    this.campaignId,
  });

  final String id;
  final String code;
  final String targetUrl;
  final String fullUtmUrl;
  final int clicks;
  final int conversions;
  final int revenueMinor;
  final String? campaignId;

  @override
  List<Object?> get props => [
        id,
        code,
        targetUrl,
        fullUtmUrl,
        clicks,
        conversions,
        revenueMinor,
        campaignId,
      ];

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'targetUrl': targetUrl,
        'fullUtmUrl': fullUtmUrl,
        'clicks': clicks,
        'conversions': conversions,
        'revenueMinor': revenueMinor,
        if (campaignId != null) 'campaignId': campaignId,
      };

  factory UtmLinkMetric.fromJson(Map<String, dynamic> json) {
    return UtmLinkMetric(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      targetUrl: json['targetUrl'] as String? ?? '',
      fullUtmUrl: json['fullUtmUrl'] as String? ?? '',
      clicks: (json['clicks'] as num?)?.toInt() ?? 0,
      conversions: (json['conversions'] as num?)?.toInt() ?? 0,
      revenueMinor: (json['revenueMinor'] as num?)?.toInt() ?? 0,
      campaignId: json['campaignId'] as String?,
    );
  }
}

/// Analytics Report encompassing overall campaign performance & comparisons.
class AnalyticsReport extends Equatable {
  const AnalyticsReport({
    required this.id,
    required this.title,
    this.campaignId,
    this.startDate,
    this.endDate,
    this.totalReach = 0,
    this.totalImpressions = 0,
    this.totalEngagement = 0,
    this.totalSpendMinor = 0,
    this.currency = 'USD',
    this.metricsComparison = const [],
    this.utmLinks = const [],
    this.chartSeries = const [],
  });

  final String id;
  final String title;
  final String? campaignId;
  final DateTime? startDate;
  final DateTime? endDate;
  final int totalReach;
  final int totalImpressions;
  final int totalEngagement;
  final int totalSpendMinor;
  final String currency;
  final List<MetricComparisonItem> metricsComparison;
  final List<UtmLinkMetric> utmLinks;
  final List<MetricDataPoint> chartSeries;

  @override
  List<Object?> get props => [
        id,
        title,
        campaignId,
        startDate,
        endDate,
        totalReach,
        totalImpressions,
        totalEngagement,
        totalSpendMinor,
        currency,
        metricsComparison,
        utmLinks,
        chartSeries,
      ];

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        if (campaignId != null) 'campaignId': campaignId,
        if (startDate != null) 'startDate': startDate!.toIso8601String(),
        if (endDate != null) 'endDate': endDate!.toIso8601String(),
        'totalReach': totalReach,
        'totalImpressions': totalImpressions,
        'totalEngagement': totalEngagement,
        'totalSpendMinor': totalSpendMinor,
        'currency': currency,
        'metricsComparison': metricsComparison.map((e) => e.toJson()).toList(),
        'utmLinks': utmLinks.map((e) => e.toJson()).toList(),
        'chartSeries': chartSeries.map((e) => e.toJson()).toList(),
      };

  factory AnalyticsReport.fromJson(Map<String, dynamic> json) {
    return AnalyticsReport(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Analytics Report',
      campaignId: json['campaignId'] as String?,
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'] as String)
          : null,
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'] as String)
          : null,
      totalReach: (json['totalReach'] as num?)?.toInt() ?? 0,
      totalImpressions: (json['totalImpressions'] as num?)?.toInt() ?? 0,
      totalEngagement: (json['totalEngagement'] as num?)?.toInt() ?? 0,
      totalSpendMinor: (json['totalSpendMinor'] as num?)?.toInt() ?? 0,
      currency: json['currency'] as String? ?? 'USD',
      metricsComparison: (json['metricsComparison'] as List<dynamic>?)
              ?.map((e) =>
                  MetricComparisonItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      utmLinks: (json['utmLinks'] as List<dynamic>?)
              ?.map((e) => UtmLinkMetric.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      chartSeries: (json['chartSeries'] as List<dynamic>?)
              ?.map((e) => MetricDataPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}

/// Status of an asynchronous export job.
class ExportJobStatus extends Equatable {
  const ExportJobStatus({
    required this.jobId,
    required this.reportType,
    required this.format,
    required this.status,
    this.progressPercent = 0,
    this.downloadUrl,
    this.errorMessage,
    this.createdAt,
  });

  final String jobId;
  final String reportType;
  final String format;
  final String status; // 'pending', 'processing', 'completed', 'failed'
  final int progressPercent;
  final String? downloadUrl;
  final String? errorMessage;
  final DateTime? createdAt;

  bool get isCompleted => status.toLowerCase() == 'completed';
  bool get isFailed => status.toLowerCase() == 'failed';
  bool get isInProgress =>
      status.toLowerCase() == 'pending' || status.toLowerCase() == 'processing';

  @override
  List<Object?> get props => [
        jobId,
        reportType,
        format,
        status,
        progressPercent,
        downloadUrl,
        errorMessage,
        createdAt,
      ];

  Map<String, dynamic> toJson() => {
        'jobId': jobId,
        'reportType': reportType,
        'format': format,
        'status': status,
        'progressPercent': progressPercent,
        if (downloadUrl != null) 'downloadUrl': downloadUrl,
        if (errorMessage != null) 'errorMessage': errorMessage,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      };

  factory ExportJobStatus.fromJson(Map<String, dynamic> json) {
    return ExportJobStatus(
      jobId: json['jobId'] as String? ?? json['id'] as String? ?? '',
      reportType: json['reportType'] as String? ?? 'campaign_performance',
      format: json['format'] as String? ?? 'csv',
      status: json['status'] as String? ?? 'pending',
      progressPercent: (json['progressPercent'] as num?)?.toInt() ?? 0,
      downloadUrl: json['downloadUrl'] as String?,
      errorMessage: json['errorMessage'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }
}
