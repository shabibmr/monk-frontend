import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/campaign.dart';
import '../../domain/repositories/campaign_repository.dart';

sealed class CampaignDetailEvent extends Equatable {
  const CampaignDetailEvent();
  @override
  List<Object?> get props => [];
}

class CampaignDetailLoaded extends CampaignDetailEvent {
  const CampaignDetailLoaded(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}

class CampaignTransitionRequested extends CampaignDetailEvent {
  const CampaignTransitionRequested(this.to, {this.reason});
  final String to;
  final String? reason;
  @override
  List<Object?> get props => [to, reason];
}

class CampaignDeliverableAdded extends CampaignDetailEvent {
  const CampaignDeliverableAdded({
    required this.platform,
    required this.deliverableType,
    this.captionGuidelines,
  });
  final String platform;
  final String deliverableType;
  final String? captionGuidelines;
  @override
  List<Object?> get props => [platform, deliverableType, captionGuidelines];
}

class CampaignDeliverableRemoved extends CampaignDetailEvent {
  const CampaignDeliverableRemoved(this.deliverableId);
  final String deliverableId;
  @override
  List<Object?> get props => [deliverableId];
}

enum CampaignDetailPhase { loading, ready, acting, failure }

class CampaignDetailState extends Equatable {
  const CampaignDetailState({
    this.phase = CampaignDetailPhase.loading,
    this.detail,
    this.failure,
    this.infoMessage,
  });

  final CampaignDetailPhase phase;
  final CampaignDetail? detail;
  final Failure? failure;
  final String? infoMessage;

  List<String> get allowedTransitions {
    final d = detail;
    if (d == null) return const [];
    return allowedBrandTransitions(
      status: d.campaign.status,
      mode: d.campaign.mode,
      deliverableCount: d.deliverables.length,
    );
  }

  CampaignDetailState copyWith({
    CampaignDetailPhase? phase,
    CampaignDetail? detail,
    Failure? failure,
    String? infoMessage,
    bool clearFailure = false,
  }) {
    return CampaignDetailState(
      phase: phase ?? this.phase,
      detail: detail ?? this.detail,
      failure: clearFailure ? null : (failure ?? this.failure),
      infoMessage: infoMessage ?? this.infoMessage,
    );
  }

  @override
  List<Object?> get props => [phase, detail, failure, infoMessage];
}

class CampaignDetailBloc
    extends Bloc<CampaignDetailEvent, CampaignDetailState> {
  CampaignDetailBloc(this._repo) : super(const CampaignDetailState()) {
    on<CampaignDetailLoaded>(_onLoad);
    on<CampaignTransitionRequested>(_onTransition);
    on<CampaignDeliverableAdded>(_onAdd);
    on<CampaignDeliverableRemoved>(_onRemove);
  }

  final CampaignRepository _repo;
  String? _id;

  Future<void> _onLoad(
    CampaignDetailLoaded event,
    Emitter<CampaignDetailState> emit,
  ) async {
    _id = event.id;
    emit(state.copyWith(phase: CampaignDetailPhase.loading, clearFailure: true));
    try {
      final detail = await _repo.get(event.id);
      emit(
        state.copyWith(phase: CampaignDetailPhase.ready, detail: detail),
      );
    } on Failure catch (f) {
      emit(state.copyWith(phase: CampaignDetailPhase.failure, failure: f));
    }
  }

  Future<void> _onTransition(
    CampaignTransitionRequested event,
    Emitter<CampaignDetailState> emit,
  ) async {
    final id = _id;
    if (id == null) return;
    if (!state.allowedTransitions.contains(event.to)) {
      emit(
        state.copyWith(
          failure: ConflictFailure(
            'This status change is not available right now.',
            errorCode: 'INVALID_STATE_TRANSITION',
          ),
        ),
      );
      return;
    }
    emit(state.copyWith(phase: CampaignDetailPhase.acting, clearFailure: true));
    try {
      await _repo.transition(id, to: event.to, reason: event.reason);
      final detail = await _repo.get(id);
      emit(
        state.copyWith(
          phase: CampaignDetailPhase.ready,
          detail: detail,
          infoMessage: 'Status updated to ${event.to.replaceAll('_', ' ')}',
        ),
      );
    } on Failure catch (f) {
      // 409 INVALID_STATE_TRANSITION → ConflictFailure via error mapper
      emit(state.copyWith(phase: CampaignDetailPhase.failure, failure: f));
    }
  }

  Future<void> _onAdd(
    CampaignDeliverableAdded event,
    Emitter<CampaignDetailState> emit,
  ) async {
    final id = _id;
    if (id == null) return;
    emit(state.copyWith(phase: CampaignDetailPhase.acting, clearFailure: true));
    try {
      await _repo.addDeliverable(id, {
        'platform': event.platform,
        'deliverableType': event.deliverableType,
        if (event.captionGuidelines != null)
          'captionGuidelines': event.captionGuidelines,
      });
      final detail = await _repo.get(id);
      emit(
        state.copyWith(
          phase: CampaignDetailPhase.ready,
          detail: detail,
          infoMessage: 'Deliverable added (disclosure tags from API)',
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(phase: CampaignDetailPhase.failure, failure: f));
    }
  }

  Future<void> _onRemove(
    CampaignDeliverableRemoved event,
    Emitter<CampaignDetailState> emit,
  ) async {
    final id = _id;
    if (id == null) return;
    emit(state.copyWith(phase: CampaignDetailPhase.acting, clearFailure: true));
    try {
      await _repo.deleteDeliverable(id, event.deliverableId);
      final detail = await _repo.get(id);
      emit(state.copyWith(phase: CampaignDetailPhase.ready, detail: detail));
    } on Failure catch (f) {
      emit(state.copyWith(phase: CampaignDetailPhase.failure, failure: f));
    }
  }
}
