import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/kyc.dart';
import '../../domain/repositories/kyc_repository.dart';

sealed class VerificationEvent extends Equatable {
  const VerificationEvent();
  @override
  List<Object?> get props => [];
}

class VerificationQueueLoaded extends VerificationEvent {
  const VerificationQueueLoaded();
}

class VerificationApproved extends VerificationEvent {
  const VerificationApproved(this.kycId);
  final String kycId;
  @override
  List<Object?> get props => [kycId];
}

class VerificationRejected extends VerificationEvent {
  const VerificationRejected(this.kycId, {this.templateKey, this.reason});
  final String kycId;
  final String? templateKey;
  final String? reason;
  @override
  List<Object?> get props => [kycId, templateKey, reason];
}

class VerificationSelected extends VerificationEvent {
  const VerificationSelected(this.kycId);
  final String kycId;
  @override
  List<Object?> get props => [kycId];
}

enum VerificationPhase { loading, ready, acting, failure }

class VerificationState extends Equatable {
  const VerificationState({
    this.phase = VerificationPhase.loading,
    this.influencers = const [],
    this.kyc = const [],
    this.templates = const [],
    this.selectedKycId,
    this.failure,
    this.infoMessage,
  });

  final VerificationPhase phase;
  final List<QueueInfluencer> influencers;
  final List<KycRecord> kyc;
  final List<RejectionTemplate> templates;
  final String? selectedKycId;
  final Failure? failure;
  final String? infoMessage;

  KycRecord? get selected {
    if (selectedKycId == null) return null;
    try {
      return kyc.firstWhere((e) => e.id == selectedKycId);
    } catch (_) {
      return null;
    }
  }

  VerificationState copyWith({
    VerificationPhase? phase,
    List<QueueInfluencer>? influencers,
    List<KycRecord>? kyc,
    List<RejectionTemplate>? templates,
    String? selectedKycId,
    Failure? failure,
    String? infoMessage,
    bool clearFailure = false,
    bool clearSelected = false,
  }) {
    return VerificationState(
      phase: phase ?? this.phase,
      influencers: influencers ?? this.influencers,
      kyc: kyc ?? this.kyc,
      templates: templates ?? this.templates,
      selectedKycId:
          clearSelected ? null : (selectedKycId ?? this.selectedKycId),
      failure: clearFailure ? null : (failure ?? this.failure),
      infoMessage: infoMessage ?? this.infoMessage,
    );
  }

  @override
  List<Object?> get props => [
        phase,
        influencers,
        kyc,
        templates,
        selectedKycId,
        failure,
        infoMessage,
      ];
}

class VerificationBloc extends Bloc<VerificationEvent, VerificationState> {
  VerificationBloc(this._repo) : super(const VerificationState()) {
    on<VerificationQueueLoaded>(_onLoad);
    on<VerificationApproved>(_onApprove);
    on<VerificationRejected>(_onReject);
    on<VerificationSelected>(_onSelect);
  }

  final KycRepository _repo;

  Future<void> _onLoad(
    VerificationQueueLoaded event,
    Emitter<VerificationState> emit,
  ) async {
    emit(state.copyWith(phase: VerificationPhase.loading, clearFailure: true));
    try {
      final queue = await _repo.adminQueue();
      final templates = await _repo.rejectionTemplates();
      emit(
        state.copyWith(
          phase: VerificationPhase.ready,
          influencers: queue.influencers,
          kyc: queue.kyc,
          templates: templates,
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(phase: VerificationPhase.failure, failure: f));
    }
  }

  void _onSelect(
    VerificationSelected event,
    Emitter<VerificationState> emit,
  ) {
    emit(state.copyWith(selectedKycId: event.kycId));
  }

  Future<void> _onApprove(
    VerificationApproved event,
    Emitter<VerificationState> emit,
  ) async {
    emit(state.copyWith(phase: VerificationPhase.acting, clearFailure: true));
    try {
      await _repo.adminApprove(event.kycId);
      final queue = await _repo.adminQueue();
      emit(
        state.copyWith(
          phase: VerificationPhase.ready,
          influencers: queue.influencers,
          kyc: queue.kyc,
          infoMessage: 'KYC approved',
          clearSelected: true,
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(phase: VerificationPhase.failure, failure: f));
    }
  }

  Future<void> _onReject(
    VerificationRejected event,
    Emitter<VerificationState> emit,
  ) async {
    emit(state.copyWith(phase: VerificationPhase.acting, clearFailure: true));
    try {
      await _repo.adminReject(
        event.kycId,
        templateKey: event.templateKey,
        reason: event.reason,
      );
      final queue = await _repo.adminQueue();
      emit(
        state.copyWith(
          phase: VerificationPhase.ready,
          influencers: queue.influencers,
          kyc: queue.kyc,
          infoMessage: 'KYC rejected',
          clearSelected: true,
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(phase: VerificationPhase.failure, failure: f));
    }
  }
}
