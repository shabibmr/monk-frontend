import 'package:equatable/equatable.dart';

sealed class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();

  @override
  List<Object?> get props => [];
}

class FetchPostAutomatedMetrics extends AnalyticsEvent {
  const FetchPostAutomatedMetrics(this.publishedPostId);
  final String publishedPostId;

  @override
  List<Object?> get props => [publishedPostId];
}

class FetchComparisonReport extends AnalyticsEvent {
  const FetchComparisonReport({
    this.campaignId,
    this.startDate,
    this.endDate,
    this.compareWithId,
  });

  final String? campaignId;
  final String? startDate;
  final String? endDate;
  final String? compareWithId;

  @override
  List<Object?> get props => [campaignId, startDate, endDate, compareWithId];
}

class TriggerExportJob extends AnalyticsEvent {
  const TriggerExportJob({
    required this.reportType,
    required this.format,
    this.params,
  });

  final String reportType;
  final String format;
  final Map<String, dynamic>? params;

  @override
  List<Object?> get props => [reportType, format, params];
}

class PollExportJobStatus extends AnalyticsEvent {
  const PollExportJobStatus(this.jobId);
  final String jobId;

  @override
  List<Object?> get props => [jobId];
}

class FetchUtmLinks extends AnalyticsEvent {
  const FetchUtmLinks({this.campaignId});
  final String? campaignId;

  @override
  List<Object?> get props => [campaignId];
}

class ResetExportStatus extends AnalyticsEvent {
  const ResetExportStatus();
}
