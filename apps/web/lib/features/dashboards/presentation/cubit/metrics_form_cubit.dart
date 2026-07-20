import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/dashboard.dart';
import '../../domain/repositories/dashboard_repository.dart';

class MetricsFormState extends Equatable {
  const MetricsFormState({
    this.saving = false,
    this.lastEntry,
    this.failure,
    this.infoMessage,
  });

  final bool saving;
  final ManualMetricEntry? lastEntry;
  final Failure? failure;
  final String? infoMessage;

  MetricsFormState copyWith({
    bool? saving,
    ManualMetricEntry? lastEntry,
    Failure? failure,
    String? infoMessage,
    bool clearFailure = false,
    bool clearInfo = false,
  }) {
    return MetricsFormState(
      saving: saving ?? this.saving,
      lastEntry: lastEntry ?? this.lastEntry,
      failure: clearFailure ? null : (failure ?? this.failure),
      infoMessage: clearInfo ? null : (infoMessage ?? this.infoMessage),
    );
  }

  @override
  List<Object?> get props => [saving, lastEntry, failure, infoMessage];
}

class MetricsFormCubit extends Cubit<MetricsFormState> {
  MetricsFormCubit(this._repo) : super(const MetricsFormState());

  final DashboardRepository _repo;

  Future<void> save({
    required String publishedPostId,
    required Map<String, dynamic> body,
  }) async {
    if (publishedPostId.trim().isEmpty) {
      emit(
        state.copyWith(
          failure: const ValidationFailure(
            'Published post UUID required',
            errorCode: 'VALIDATION_ERROR',
          ),
        ),
      );
      return;
    }
    emit(state.copyWith(saving: true, clearFailure: true, clearInfo: true));
    try {
      final entry = await _repo.enterMetrics(
        publishedPostId: publishedPostId.trim(),
        body: body,
      );
      emit(
        state.copyWith(
          saving: false,
          lastEntry: entry,
          infoMessage: 'Metrics saved',
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(saving: false, failure: f));
    }
  }
}
