import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/publish_schedule.dart';
import '../../domain/repositories/publish_repository.dart';

abstract class SchedulePublishEvent extends Equatable {
  const SchedulePublishEvent();

  @override
  List<Object?> get props => [];
}

class LoadScheduleRequested extends SchedulePublishEvent {
  const LoadScheduleRequested({
    required this.deliverableId,
    required this.approvalStatus,
  });

  final String deliverableId;
  final String approvalStatus;

  @override
  List<Object?> get props => [deliverableId, approvalStatus];
}

class SubmitScheduleRequested extends SchedulePublishEvent {
  const SubmitScheduleRequested({
    required this.deliverableId,
    required this.scheduledAt,
    required this.platform,
    this.notes,
  });

  final String deliverableId;
  final DateTime scheduledAt;
  final String platform;
  final String? notes;

  @override
  List<Object?> get props => [deliverableId, scheduledAt, platform, notes];
}

class CancelScheduleRequested extends SchedulePublishEvent {
  const CancelScheduleRequested(this.scheduleId);

  final String scheduleId;

  @override
  List<Object?> get props => [scheduleId];
}

class SchedulePublishState extends Equatable {
  const SchedulePublishState({
    this.deliverableId = '',
    this.approvalStatus = 'pending',
    this.schedule,
    this.isLoading = false,
    this.isSubmitting = false,
    this.failure,
    this.successMessage,
  });

  final String deliverableId;
  final String approvalStatus;
  final PublishSchedule? schedule;
  final bool isLoading;
  final bool isSubmitting;
  final Failure? failure;
  final String? successMessage;

  bool get isContentApproved => approvalStatus.toLowerCase() == 'approved';

  SchedulePublishState copyWith({
    String? deliverableId,
    String? approvalStatus,
    PublishSchedule? Function()? schedule,
    bool? isLoading,
    bool? isSubmitting,
    Failure? Function()? failure,
    String? Function()? successMessage,
  }) {
    return SchedulePublishState(
      deliverableId: deliverableId ?? this.deliverableId,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      schedule: schedule != null ? schedule() : this.schedule,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      failure: failure != null ? failure() : this.failure,
      successMessage:
          successMessage != null ? successMessage() : this.successMessage,
    );
  }

  @override
  List<Object?> get props => [
        deliverableId,
        approvalStatus,
        schedule,
        isLoading,
        isSubmitting,
        failure,
        successMessage,
      ];
}

class SchedulePublishBloc
    extends Bloc<SchedulePublishEvent, SchedulePublishState> {
  SchedulePublishBloc(this._repository)
      : super(const SchedulePublishState()) {
    on<LoadScheduleRequested>(_onLoadScheduleRequested);
    on<SubmitScheduleRequested>(_onSubmitScheduleRequested);
    on<CancelScheduleRequested>(_onCancelScheduleRequested);
  }

  final PublishRepository _repository;

  Future<void> _onLoadScheduleRequested(
    LoadScheduleRequested event,
    Emitter<SchedulePublishState> emit,
  ) async {
    emit(
      state.copyWith(
        deliverableId: event.deliverableId,
        approvalStatus: event.approvalStatus,
        isLoading: true,
        failure: () => null,
      ),
    );

    try {
      final schedule = await _repository.getSchedule(event.deliverableId);
      emit(
        state.copyWith(
          isLoading: false,
          schedule: () => schedule,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          failure: () =>
              e is Failure ? e : ServerFailure(e.toString()),
        ),
      );
    }
  }

  Future<void> _onSubmitScheduleRequested(
    SubmitScheduleRequested event,
    Emitter<SchedulePublishState> emit,
  ) async {
    // Invariant: Publish schedule action is ONLY enabled after content has reached approved status.
    if (!state.isContentApproved) {
      emit(
        state.copyWith(
          failure: () => const ValidationFailure(
            'Cannot schedule publish: Content must be approved first',
            errorCode: 'APPROVAL_REQUIRED',
          ),
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isSubmitting: true,
        failure: () => null,
        successMessage: () => null,
      ),
    );

    try {
      final res = await _repository.schedulePublish(
        deliverableId: event.deliverableId,
        scheduledAt: event.scheduledAt,
        platform: event.platform,
        notes: event.notes,
      );
      emit(
        state.copyWith(
          isSubmitting: false,
          schedule: () => res,
          successMessage: () => 'Publish schedule set successfully',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isSubmitting: false,
          failure: () =>
              e is Failure ? e : ServerFailure(e.toString()),
        ),
      );
    }
  }

  Future<void> _onCancelScheduleRequested(
    CancelScheduleRequested event,
    Emitter<SchedulePublishState> emit,
  ) async {
    emit(
      state.copyWith(
        isSubmitting: true,
        failure: () => null,
        successMessage: () => null,
      ),
    );

    try {
      final res = await _repository.cancelSchedule(event.scheduleId);
      emit(
        state.copyWith(
          isSubmitting: false,
          schedule: () => res,
          successMessage: () => 'Publish schedule cancelled',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isSubmitting: false,
          failure: () =>
              e is Failure ? e : ServerFailure(e.toString()),
        ),
      );
    }
  }
}
