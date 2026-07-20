import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/creator_demographics.dart';
import '../../domain/repositories/discovery_repository.dart';

sealed class DiscoveryScoreEvent extends Equatable {
  const DiscoveryScoreEvent();
  @override
  List<Object?> get props => [];
}

class FetchDiscoveryScore extends DiscoveryScoreEvent {
  const FetchDiscoveryScore(this.influencerId);
  final String influencerId;
  @override
  List<Object?> get props => [influencerId];
}

class FetchCreatorDemographics extends DiscoveryScoreEvent {
  const FetchCreatorDemographics(this.influencerId);
  final String influencerId;
  @override
  List<Object?> get props => [influencerId];
}

enum DiscoveryScorePhase { initial, loading, ready, failure }

class DiscoveryScoreState extends Equatable {
  const DiscoveryScoreState({
    this.phase = DiscoveryScorePhase.initial,
    this.influencerId,
    this.score,
    this.demographics,
    this.failure,
  });

  final DiscoveryScorePhase phase;
  final String? influencerId;
  final num? score;
  final CreatorDemographics? demographics;
  final Failure? failure;

  DiscoveryScoreState copyWith({
    DiscoveryScorePhase? phase,
    String? influencerId,
    num? score,
    CreatorDemographics? demographics,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return DiscoveryScoreState(
      phase: phase ?? this.phase,
      influencerId: influencerId ?? this.influencerId,
      score: score ?? this.score,
      demographics: demographics ?? this.demographics,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [phase, influencerId, score, demographics, failure];
}

class DiscoveryScoreBloc
    extends Bloc<DiscoveryScoreEvent, DiscoveryScoreState> {
  DiscoveryScoreBloc(this._repo) : super(const DiscoveryScoreState()) {
    on<FetchDiscoveryScore>(_onFetchScore);
    on<FetchCreatorDemographics>(_onFetchDemographics);
  }

  final DiscoveryRepository _repo;

  Future<void> _onFetchScore(
    FetchDiscoveryScore event,
    Emitter<DiscoveryScoreState> emit,
  ) async {
    emit(
      state.copyWith(
        phase: DiscoveryScorePhase.loading,
        influencerId: event.influencerId,
        clearFailure: true,
      ),
    );
    try {
      final score = await _repo.getCreatorScore(event.influencerId);
      emit(
        state.copyWith(
          phase: DiscoveryScorePhase.ready,
          score: score,
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(phase: DiscoveryScorePhase.failure, failure: f));
    }
  }

  Future<void> _onFetchDemographics(
    FetchCreatorDemographics event,
    Emitter<DiscoveryScoreState> emit,
  ) async {
    emit(
      state.copyWith(
        phase: DiscoveryScorePhase.loading,
        influencerId: event.influencerId,
        clearFailure: true,
      ),
    );
    try {
      final demo = await _repo.getDemographics(event.influencerId);
      emit(
        state.copyWith(
          phase: DiscoveryScorePhase.ready,
          score: demo.creatorScore,
          demographics: demo,
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(phase: DiscoveryScorePhase.failure, failure: f));
    }
  }
}
