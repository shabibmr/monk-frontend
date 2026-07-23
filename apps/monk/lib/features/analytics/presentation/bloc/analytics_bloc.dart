import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/analytics_repository.dart';
import 'analytics_event.dart';
import 'analytics_state.dart';

export 'analytics_event.dart';
export 'analytics_state.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  AnalyticsBloc({required AnalyticsRepository repository})
      : _repository = repository,
        super(const AnalyticsState()) {
    on<FetchPostAutomatedMetrics>(_onFetchPostAutomatedMetrics);
    on<FetchComparisonReport>(_onFetchComparisonReport);
    on<TriggerExportJob>(_onTriggerExportJob);
    on<PollExportJobStatus>(_onPollExportJobStatus);
    on<FetchUtmLinks>(_onFetchUtmLinks);
    on<ResetExportStatus>(_onResetExportStatus);
  }

  final AnalyticsRepository _repository;

  Future<void> _onFetchPostAutomatedMetrics(
    FetchPostAutomatedMetrics event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(state.copyWith(status: AnalyticsStatus.loading, clearFailure: true));
    try {
      final metrics =
          await _repository.getPostAutomatedMetrics(event.publishedPostId);
      emit(
        state.copyWith(
          status: AnalyticsStatus.success,
          postMetrics: metrics,
        ),
      );
    } catch (e) {
      final failure = e is Failure ? e : UnexpectedFailure(e.toString());
      emit(
        state.copyWith(
          status: AnalyticsStatus.failure,
          failure: failure,
        ),
      );
    }
  }

  Future<void> _onFetchComparisonReport(
    FetchComparisonReport event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(state.copyWith(status: AnalyticsStatus.loading, clearFailure: true));
    try {
      final report = await _repository.getComparisonReport(
        campaignId: event.campaignId,
        startDate: event.startDate,
        endDate: event.endDate,
        compareWithId: event.compareWithId,
      );
      emit(
        state.copyWith(
          status: AnalyticsStatus.success,
          comparisonReport: report,
        ),
      );
    } catch (e) {
      final failure = e is Failure ? e : UnexpectedFailure(e.toString());
      emit(
        state.copyWith(
          status: AnalyticsStatus.failure,
          failure: failure,
        ),
      );
    }
  }

  Future<void> _onTriggerExportJob(
    TriggerExportJob event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(
      state.copyWith(
        isExporting: true,
        clearFailure: true,
        infoMessage: 'Export job initiated…',
      ),
    );
    try {
      final jobStatus = await _repository.triggerExportJob(
        reportType: event.reportType,
        format: event.format,
        params: event.params,
      );
      emit(
        state.copyWith(
          isExporting: !jobStatus.isCompleted && !jobStatus.isFailed,
          exportJobStatus: jobStatus,
          infoMessage: 'Export job queued (${jobStatus.format.toUpperCase()})',
        ),
      );
    } catch (e) {
      final failure = e is Failure ? e : UnexpectedFailure(e.toString());
      emit(
        state.copyWith(
          isExporting: false,
          failure: failure,
        ),
      );
    }
  }

  Future<void> _onPollExportJobStatus(
    PollExportJobStatus event,
    Emitter<AnalyticsState> emit,
  ) async {
    try {
      final jobStatus = await _repository.getExportJobStatus(event.jobId);
      emit(
        state.copyWith(
          isExporting: jobStatus.isInProgress,
          exportJobStatus: jobStatus,
        ),
      );
    } catch (e) {
      final failure = e is Failure ? e : UnexpectedFailure(e.toString());
      emit(
        state.copyWith(
          isExporting: false,
          failure: failure,
        ),
      );
    }
  }

  Future<void> _onFetchUtmLinks(
    FetchUtmLinks event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(state.copyWith(status: AnalyticsStatus.loading, clearFailure: true));
    try {
      final utmList =
          await _repository.getUtmLinks(campaignId: event.campaignId);
      emit(
        state.copyWith(
          status: AnalyticsStatus.success,
          utmLinks: utmList,
        ),
      );
    } catch (e) {
      final failure = e is Failure ? e : UnexpectedFailure(e.toString());
      emit(
        state.copyWith(
          status: AnalyticsStatus.failure,
          failure: failure,
        ),
      );
    }
  }

  void _onResetExportStatus(
    ResetExportStatus event,
    Emitter<AnalyticsState> emit,
  ) {
    emit(
      state.copyWith(
        isExporting: false,
        clearExportJob: true,
        clearMessage: true,
      ),
    );
  }
}
