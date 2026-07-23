import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/analytics_metric.dart';

enum AnalyticsStatus {
  initial,
  loading,
  success,
  failure,
}

class AnalyticsState extends Equatable {
  const AnalyticsState({
    this.status = AnalyticsStatus.initial,
    this.postMetrics,
    this.comparisonReport,
    this.exportJobStatus,
    this.utmLinks = const [],
    this.isExporting = false,
    this.failure,
    this.infoMessage,
  });

  final AnalyticsStatus status;
  final AutomatedPostMetrics? postMetrics;
  final AnalyticsReport? comparisonReport;
  final ExportJobStatus? exportJobStatus;
  final List<UtmLinkMetric> utmLinks;
  final bool isExporting;
  final Failure? failure;
  final String? infoMessage;

  AnalyticsState copyWith({
    AnalyticsStatus? status,
    AutomatedPostMetrics? postMetrics,
    AnalyticsReport? comparisonReport,
    ExportJobStatus? exportJobStatus,
    List<UtmLinkMetric>? utmLinks,
    bool? isExporting,
    Failure? failure,
    String? infoMessage,
    bool clearFailure = false,
    bool clearMessage = false,
    bool clearExportJob = false,
  }) {
    return AnalyticsState(
      status: status ?? this.status,
      postMetrics: postMetrics ?? this.postMetrics,
      comparisonReport: comparisonReport ?? this.comparisonReport,
      exportJobStatus:
          clearExportJob ? null : (exportJobStatus ?? this.exportJobStatus),
      utmLinks: utmLinks ?? this.utmLinks,
      isExporting: isExporting ?? this.isExporting,
      failure: clearFailure ? null : (failure ?? this.failure),
      infoMessage: clearMessage ? null : (infoMessage ?? this.infoMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        postMetrics,
        comparisonReport,
        exportJobStatus,
        utmLinks,
        isExporting,
        failure,
        infoMessage,
      ];
}
