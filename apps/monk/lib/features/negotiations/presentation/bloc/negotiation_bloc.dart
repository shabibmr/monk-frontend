import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/negotiation.dart';
import '../../domain/repositories/negotiation_repository.dart';

// ── Events ──────────────────────────────────────────────────

sealed class NegotiationEvent extends Equatable {
  const NegotiationEvent();
  @override
  List<Object?> get props => [];
}

class NegotiationLoaded extends NegotiationEvent {
  const NegotiationLoaded(this.negotiationId);
  final String negotiationId;
  @override
  List<Object?> get props => [negotiationId];
}

class NegotiationOpened extends NegotiationEvent {
  const NegotiationOpened({
    required this.applicationId,
    required this.body,
  });
  final String applicationId;
  final Map<String, dynamic> body;
  @override
  List<Object?> get props => [applicationId, body];
}

class NegotiationCounterSubmitted extends NegotiationEvent {
  const NegotiationCounterSubmitted(this.body);
  final Map<String, dynamic> body;
  @override
  List<Object?> get props => [body];
}

class NegotiationOfferAccepted extends NegotiationEvent {
  const NegotiationOfferAccepted(this.offerId);
  final String offerId;
  @override
  List<Object?> get props => [offerId];
}

class NegotiationOfferDeclined extends NegotiationEvent {
  const NegotiationOfferDeclined(this.offerId);
  final String offerId;
  @override
  List<Object?> get props => [offerId];
}

class NegotiationCancelled extends NegotiationEvent {
  const NegotiationCancelled();
}

// ── State ───────────────────────────────────────────────────

class NegotiationState extends Equatable {
  const NegotiationState({
    this.loading = false,
    this.acting = false,
    this.negotiation,
    this.acceptResult,
    this.failure,
    this.infoMessage,
    this.validationMessage,
  });

  final bool loading;
  final bool acting;
  final Negotiation? negotiation;
  final AcceptNegotiationResult? acceptResult;
  final Failure? failure;
  final String? infoMessage;
  final String? validationMessage;

  bool get termsLocked =>
      negotiation?.isLocked == true || acceptResult != null;

  bool get canSubmitCounter =>
      negotiation != null &&
      negotiation!.canCounter &&
      !termsLocked &&
      !acting;

  NegotiationState copyWith({
    bool? loading,
    bool? acting,
    Negotiation? negotiation,
    AcceptNegotiationResult? acceptResult,
    Failure? failure,
    String? infoMessage,
    String? validationMessage,
    bool clearFailure = false,
    bool clearInfo = false,
    bool clearValidation = false,
  }) {
    return NegotiationState(
      loading: loading ?? this.loading,
      acting: acting ?? this.acting,
      negotiation: negotiation ?? this.negotiation,
      acceptResult: acceptResult ?? this.acceptResult,
      failure: clearFailure ? null : (failure ?? this.failure),
      infoMessage: clearInfo ? null : (infoMessage ?? this.infoMessage),
      validationMessage: clearValidation
          ? null
          : (validationMessage ?? this.validationMessage),
    );
  }

  @override
  List<Object?> get props => [
        loading,
        acting,
        negotiation,
        acceptResult,
        failure,
        infoMessage,
        validationMessage,
      ];
}

// ── Bloc ────────────────────────────────────────────────────

class NegotiationBloc extends Bloc<NegotiationEvent, NegotiationState> {
  NegotiationBloc(this._repo) : super(const NegotiationState()) {
    on<NegotiationLoaded>(_onLoad);
    on<NegotiationOpened>(_onOpen);
    on<NegotiationCounterSubmitted>(_onCounter);
    on<NegotiationOfferAccepted>(_onAccept);
    on<NegotiationOfferDeclined>(_onDecline);
    on<NegotiationCancelled>(_onCancel);
  }

  final NegotiationRepository _repo;
  String? _id;

  Future<void> _onLoad(
    NegotiationLoaded event,
    Emitter<NegotiationState> emit,
  ) async {
    _id = event.negotiationId;
    emit(state.copyWith(loading: true, clearFailure: true, clearInfo: true));
    try {
      final n = await _repo.get(event.negotiationId);
      emit(state.copyWith(loading: false, negotiation: n));
    } on Failure catch (f) {
      emit(state.copyWith(loading: false, failure: f));
    }
  }

  Future<void> _onOpen(
    NegotiationOpened event,
    Emitter<NegotiationState> emit,
  ) async {
    emit(
      state.copyWith(
        acting: true,
        clearFailure: true,
        clearInfo: true,
        clearValidation: true,
      ),
    );
    try {
      final n = await _repo.open(
        applicationId: event.applicationId,
        body: event.body,
      );
      _id = n.id;
      emit(
        state.copyWith(
          acting: false,
          negotiation: n,
          infoMessage: 'Negotiation opened',
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(acting: false, failure: f));
    }
  }

  Future<void> _onCounter(
    NegotiationCounterSubmitted event,
    Emitter<NegotiationState> emit,
  ) async {
    final id = _id ?? state.negotiation?.id;
    if (id == null) return;
    if (state.negotiation != null && !state.negotiation!.canCounter) {
      emit(
        state.copyWith(
          validationMessage: 'Maximum rounds reached — no further offers',
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        acting: true,
        clearFailure: true,
        clearInfo: true,
        clearValidation: true,
      ),
    );
    try {
      final n = await _repo.counter(negotiationId: id, body: event.body);
      emit(
        state.copyWith(
          acting: false,
          negotiation: n,
          infoMessage: 'Counter-offer sent',
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(acting: false, failure: f));
    }
  }

  Future<void> _onAccept(
    NegotiationOfferAccepted event,
    Emitter<NegotiationState> emit,
  ) async {
    final id = _id ?? state.negotiation?.id;
    if (id == null) return;
    emit(
      state.copyWith(
        acting: true,
        clearFailure: true,
        clearInfo: true,
      ),
    );
    try {
      final result = await _repo.accept(
        negotiationId: id,
        offerId: event.offerId,
      );
      // Reload for locked status; keep commission snapshot from accept.
      Negotiation? refreshed;
      try {
        refreshed = await _repo.get(id);
      } catch (_) {
        refreshed = state.negotiation != null
            ? Negotiation(
                id: state.negotiation!.id,
                applicationId: state.negotiation!.applicationId,
                status: 'accepted',
                roundCount: state.negotiation!.roundCount,
                maxRounds: state.negotiation!.maxRounds,
                offers: state.negotiation!.offers,
              )
            : null;
      }
      emit(
        state.copyWith(
          acting: false,
          negotiation: refreshed,
          acceptResult: result,
          infoMessage: 'Terms accepted and locked',
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(acting: false, failure: f));
    }
  }

  Future<void> _onDecline(
    NegotiationOfferDeclined event,
    Emitter<NegotiationState> emit,
  ) async {
    final id = _id ?? state.negotiation?.id;
    if (id == null) return;
    emit(state.copyWith(acting: true, clearFailure: true, clearInfo: true));
    try {
      final n = await _repo.decline(
        negotiationId: id,
        offerId: event.offerId,
      );
      emit(
        state.copyWith(
          acting: false,
          negotiation: n,
          infoMessage: 'Offer declined',
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(acting: false, failure: f));
    }
  }

  Future<void> _onCancel(
    NegotiationCancelled event,
    Emitter<NegotiationState> emit,
  ) async {
    final id = _id ?? state.negotiation?.id;
    if (id == null) return;
    emit(state.copyWith(acting: true, clearFailure: true, clearInfo: true));
    try {
      final n = await _repo.cancel(id);
      emit(
        state.copyWith(
          acting: false,
          negotiation: n,
          infoMessage: 'Negotiation cancelled',
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(acting: false, failure: f));
    }
  }
}
