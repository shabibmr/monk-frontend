import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/barter.dart';
import '../../domain/repositories/barter_repository.dart';

sealed class BarterEvent extends Equatable {
  const BarterEvent();
  @override
  List<Object?> get props => [];
}

class BarterLoaded extends BarterEvent {
  const BarterLoaded(this.collaborationId);
  final String collaborationId;
  @override
  List<Object?> get props => [collaborationId];
}

class BarterShipSubmitted extends BarterEvent {
  const BarterShipSubmitted({
    required this.trackingRef,
    this.shippingCarrier,
    this.notes,
  });
  final String trackingRef;
  final String? shippingCarrier;
  final String? notes;
  @override
  List<Object?> get props => [trackingRef, shippingCarrier, notes];
}

class BarterReceiveSubmitted extends BarterEvent {
  const BarterReceiveSubmitted({this.notes});
  final String? notes;
  @override
  List<Object?> get props => [notes];
}

class BarterEvidenceSubmitted extends BarterEvent {
  const BarterEvidenceSubmitted(this.fileIds);
  final List<String> fileIds;
  @override
  List<Object?> get props => [fileIds];
}

class BarterOpenContentSubmitted extends BarterEvent {
  const BarterOpenContentSubmitted();
}

class BarterState extends Equatable {
  const BarterState({
    this.loading = false,
    this.acting = false,
    this.status,
    this.failure,
    this.infoMessage,
  });

  final bool loading;
  final bool acting;
  final BarterStatus? status;
  final Failure? failure;
  final String? infoMessage;

  BarterState copyWith({
    bool? loading,
    bool? acting,
    BarterStatus? status,
    Failure? failure,
    String? infoMessage,
    bool clearFailure = false,
    bool clearInfo = false,
  }) {
    return BarterState(
      loading: loading ?? this.loading,
      acting: acting ?? this.acting,
      status: status ?? this.status,
      failure: clearFailure ? null : (failure ?? this.failure),
      infoMessage: clearInfo ? null : (infoMessage ?? this.infoMessage),
    );
  }

  @override
  List<Object?> get props => [loading, acting, status, failure, infoMessage];
}

class BarterBloc extends Bloc<BarterEvent, BarterState> {
  BarterBloc(this._repo) : super(const BarterState()) {
    on<BarterLoaded>(_onLoad);
    on<BarterShipSubmitted>(_onShip);
    on<BarterReceiveSubmitted>(_onReceive);
    on<BarterEvidenceSubmitted>(_onEvidence);
    on<BarterOpenContentSubmitted>(_onOpenContent);
  }

  final BarterRepository _repo;
  String? _id;

  Future<void> _onLoad(BarterLoaded event, Emitter<BarterState> emit) async {
    _id = event.collaborationId;
    emit(state.copyWith(loading: true, clearFailure: true, clearInfo: true));
    try {
      final s = await _repo.get(event.collaborationId);
      emit(state.copyWith(loading: false, status: s));
    } on Failure catch (f) {
      emit(state.copyWith(loading: false, failure: f));
    }
  }

  Future<void> _onShip(
    BarterShipSubmitted event,
    Emitter<BarterState> emit,
  ) async {
    final id = _id;
    if (id == null) return;
    final tracking = event.trackingRef.trim();
    if (tracking.isEmpty) {
      emit(
        state.copyWith(
          failure: const ValidationFailure(
            'Tracking reference is required to ship',
            errorCode: 'TRACKING_REQUIRED',
          ),
        ),
      );
      return;
    }
    emit(state.copyWith(acting: true, clearFailure: true, clearInfo: true));
    try {
      final s = await _repo.ship(
        collaborationId: id,
        trackingRef: tracking,
        shippingCarrier: event.shippingCarrier,
        notes: event.notes,
      );
      emit(
        state.copyWith(
          acting: false,
          status: s,
          infoMessage: 'Marked as shipped',
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(acting: false, failure: f));
    }
  }

  Future<void> _onReceive(
    BarterReceiveSubmitted event,
    Emitter<BarterState> emit,
  ) async {
    final id = _id;
    if (id == null) return;
    emit(state.copyWith(acting: true, clearFailure: true, clearInfo: true));
    try {
      final s = await _repo.receive(
        collaborationId: id,
        notes: event.notes,
      );
      emit(
        state.copyWith(
          acting: false,
          status: s,
          infoMessage: 'Product received — content unlocked',
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(acting: false, failure: f));
    }
  }

  Future<void> _onEvidence(
    BarterEvidenceSubmitted event,
    Emitter<BarterState> emit,
  ) async {
    final id = _id;
    if (id == null) return;
    if (event.fileIds.isEmpty) {
      emit(
        state.copyWith(
          failure: const ValidationFailure(
            'At least one evidence file id is required',
          ),
        ),
      );
      return;
    }
    emit(state.copyWith(acting: true, clearFailure: true, clearInfo: true));
    try {
      final s = await _repo.addEvidence(
        collaborationId: id,
        fileIds: event.fileIds,
      );
      emit(
        state.copyWith(
          acting: false,
          status: s,
          infoMessage: 'Evidence attached',
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(acting: false, failure: f));
    }
  }

  Future<void> _onOpenContent(
    BarterOpenContentSubmitted event,
    Emitter<BarterState> emit,
  ) async {
    final id = _id;
    if (id == null) return;
    emit(state.copyWith(acting: true, clearFailure: true, clearInfo: true));
    try {
      final s = await _repo.openContent(id);
      emit(
        state.copyWith(
          acting: false,
          status: s,
          infoMessage: 'Content path opened',
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(acting: false, failure: f));
    }
  }
}
