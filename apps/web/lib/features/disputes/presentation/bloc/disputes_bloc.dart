import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/data_erasure_request.dart';
import '../../domain/entities/dispute.dart';
import '../../domain/repositories/dispute_repository.dart';

sealed class DisputesEvent extends Equatable {
  const DisputesEvent();
  @override
  List<Object?> get props => [];
}

class LoadDisputesRequested extends DisputesEvent {
  const LoadDisputesRequested({this.collaborationId});
  final String? collaborationId;

  @override
  List<Object?> get props => [collaborationId];
}

class LoadAdminDisputesRequested extends DisputesEvent {
  const LoadAdminDisputesRequested();
}

class FileDisputeSubmitted extends DisputesEvent {
  const FileDisputeSubmitted({
    required this.collaborationId,
    required this.reason,
    required this.description,
    this.paymentId,
    this.evidenceUrls = const [],
  });

  final String collaborationId;
  final String reason;
  final String description;
  final String? paymentId;
  final List<String> evidenceUrls;

  @override
  List<Object?> get props => [
        collaborationId,
        reason,
        description,
        paymentId,
        evidenceUrls,
      ];
}

class ResolveDisputeSubmitted extends DisputesEvent {
  const ResolveDisputeSubmitted({
    required this.disputeId,
    required this.resolution,
    this.notes,
  });

  final String disputeId;
  final String resolution;
  final String? notes;

  @override
  List<Object?> get props => [disputeId, resolution, notes];
}

class LoadDataErasureRequestsRequested extends DisputesEvent {
  const LoadDataErasureRequestsRequested();
}

class SubmitDataErasureRequested extends DisputesEvent {
  const SubmitDataErasureRequested(this.reason);
  final String reason;

  @override
  List<Object?> get props => [reason];
}

class DisputesState extends Equatable {
  const DisputesState({
    this.loading = false,
    this.submitting = false,
    this.disputes = const [],
    this.adminDisputes = const [],
    this.erasureRequests = const [],
    this.activeDispute,
    this.failure,
    this.infoMessage,
  });

  final bool loading;
  final bool submitting;
  final List<Dispute> disputes;
  final List<Dispute> adminDisputes;
  final List<DataErasureRequest> erasureRequests;
  final Dispute? activeDispute;
  final Failure? failure;
  final String? infoMessage;

  DisputesState copyWith({
    bool? loading,
    bool? submitting,
    List<Dispute>? disputes,
    List<Dispute>? adminDisputes,
    List<DataErasureRequest>? erasureRequests,
    Dispute? activeDispute,
    Failure? failure,
    String? infoMessage,
    bool clearFailure = false,
    bool clearInfo = false,
  }) {
    return DisputesState(
      loading: loading ?? this.loading,
      submitting: submitting ?? this.submitting,
      disputes: disputes ?? this.disputes,
      adminDisputes: adminDisputes ?? this.adminDisputes,
      erasureRequests: erasureRequests ?? this.erasureRequests,
      activeDispute: activeDispute ?? this.activeDispute,
      failure: clearFailure ? null : (failure ?? this.failure),
      infoMessage: clearInfo ? null : (infoMessage ?? this.infoMessage),
    );
  }

  @override
  List<Object?> get props => [
        loading,
        submitting,
        disputes,
        adminDisputes,
        erasureRequests,
        activeDispute,
        failure,
        infoMessage,
      ];
}

class DisputesBloc extends Bloc<DisputesEvent, DisputesState> {
  DisputesBloc(this._repo) : super(const DisputesState()) {
    on<LoadDisputesRequested>(_onLoadDisputes);
    on<LoadAdminDisputesRequested>(_onLoadAdminDisputes);
    on<FileDisputeSubmitted>(_onFileDispute);
    on<ResolveDisputeSubmitted>(_onResolveDispute);
    on<LoadDataErasureRequestsRequested>(_onLoadErasureRequests);
    on<SubmitDataErasureRequested>(_onSubmitErasureRequest);
  }

  final DisputeRepository _repo;

  Future<void> _onLoadDisputes(
    LoadDisputesRequested event,
    Emitter<DisputesState> emit,
  ) async {
    emit(state.copyWith(loading: true, clearFailure: true, clearInfo: true));
    try {
      final list =
          await _repo.getDisputes(collaborationId: event.collaborationId);
      emit(state.copyWith(loading: false, disputes: list));
    } on Failure catch (f) {
      emit(state.copyWith(loading: false, failure: f));
    }
  }

  Future<void> _onLoadAdminDisputes(
    LoadAdminDisputesRequested event,
    Emitter<DisputesState> emit,
  ) async {
    emit(state.copyWith(loading: true, clearFailure: true, clearInfo: true));
    try {
      final list = await _repo.getAdminDisputes();
      emit(state.copyWith(loading: false, adminDisputes: list));
    } on Failure catch (f) {
      emit(state.copyWith(loading: false, failure: f));
    }
  }

  Future<void> _onFileDispute(
    FileDisputeSubmitted event,
    Emitter<DisputesState> emit,
  ) async {
    emit(state.copyWith(submitting: true, clearFailure: true, clearInfo: true));
    try {
      final newD = await _repo.fileDispute(
        collaborationId: event.collaborationId,
        reason: event.reason,
        description: event.description,
        paymentId: event.paymentId,
        evidenceUrls: event.evidenceUrls,
      );
      emit(state.copyWith(
        submitting: false,
        activeDispute: newD,
        disputes: [...state.disputes, newD],
        infoMessage:
            'Dispute filed successfully. Escrow payment frozen pending admin resolution.',
      ));
    } on Failure catch (f) {
      emit(state.copyWith(submitting: false, failure: f));
    }
  }

  Future<void> _onResolveDispute(
    ResolveDisputeSubmitted event,
    Emitter<DisputesState> emit,
  ) async {
    emit(state.copyWith(submitting: true, clearFailure: true, clearInfo: true));
    try {
      final updated = await _repo.resolveDispute(
        disputeId: event.disputeId,
        resolution: event.resolution,
        notes: event.notes,
      );
      final list = state.adminDisputes
          .map((d) => d.id == updated.id ? updated : d)
          .toList();
      emit(state.copyWith(
        submitting: false,
        activeDispute: updated,
        adminDisputes: list,
        infoMessage: 'Dispute resolved successfully',
      ));
    } on Failure catch (f) {
      emit(state.copyWith(submitting: false, failure: f));
    }
  }

  Future<void> _onLoadErasureRequests(
    LoadDataErasureRequestsRequested event,
    Emitter<DisputesState> emit,
  ) async {
    emit(state.copyWith(loading: true, clearFailure: true, clearInfo: true));
    try {
      final list = await _repo.getDataErasureRequests();
      emit(state.copyWith(loading: false, erasureRequests: list));
    } on Failure catch (f) {
      emit(state.copyWith(loading: false, failure: f));
    }
  }

  Future<void> _onSubmitErasureRequest(
    SubmitDataErasureRequested event,
    Emitter<DisputesState> emit,
  ) async {
    emit(state.copyWith(submitting: true, clearFailure: true, clearInfo: true));
    try {
      final req = await _repo.submitDataErasureRequest(event.reason);
      emit(state.copyWith(
        submitting: false,
        erasureRequests: [...state.erasureRequests, req],
        infoMessage: 'Data erasure request submitted successfully',
      ));
    } on Failure catch (f) {
      emit(state.copyWith(submitting: false, failure: f));
    }
  }
}
