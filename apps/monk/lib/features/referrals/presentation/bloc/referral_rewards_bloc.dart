import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/referral_reward.dart';
import '../../domain/repositories/referrals_repository.dart';

sealed class ReferralRewardsEvent extends Equatable {
  const ReferralRewardsEvent();
  @override
  List<Object?> get props => [];
}

class ReferralRewardsStarted extends ReferralRewardsEvent {
  const ReferralRewardsStarted();
}

class ReferralAdminQueueStarted extends ReferralRewardsEvent {
  const ReferralAdminQueueStarted();
}

class ReferralRewardApproved extends ReferralRewardsEvent {
  const ReferralRewardApproved(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}

class ReferralRewardRejected extends ReferralRewardsEvent {
  const ReferralRewardRejected({required this.id, required this.reason});
  final String id;
  final String reason;
  @override
  List<Object?> get props => [id, reason];
}

enum ReferralRewardsPhase { initial, loading, ready, failure }

class ReferralRewardsState extends Equatable {
  const ReferralRewardsState({
    this.phase = ReferralRewardsPhase.initial,
    this.summary,
    this.rewards = const [],
    this.adminQueue = const [],
    this.actionSuccess,
    this.failure,
  });

  final ReferralRewardsPhase phase;
  final ReferralSummary? summary;
  final List<ReferralReward> rewards;
  final List<ReferralReward> adminQueue;
  final String? actionSuccess;
  final Failure? failure;

  ReferralRewardsState copyWith({
    ReferralRewardsPhase? phase,
    ReferralSummary? summary,
    List<ReferralReward>? rewards,
    List<ReferralReward>? adminQueue,
    String? actionSuccess,
    Failure? failure,
    bool clearFailure = false,
    bool clearActionSuccess = false,
  }) {
    return ReferralRewardsState(
      phase: phase ?? this.phase,
      summary: summary ?? this.summary,
      rewards: rewards ?? this.rewards,
      adminQueue: adminQueue ?? this.adminQueue,
      actionSuccess:
          clearActionSuccess ? null : (actionSuccess ?? this.actionSuccess),
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props =>
      [phase, summary, rewards, adminQueue, actionSuccess, failure];
}

class ReferralRewardsBloc
    extends Bloc<ReferralRewardsEvent, ReferralRewardsState> {
  ReferralRewardsBloc(this._repo) : super(const ReferralRewardsState()) {
    on<ReferralRewardsStarted>(_onStarted);
    on<ReferralAdminQueueStarted>(_onAdminQueueStarted);
    on<ReferralRewardApproved>(_onApprove);
    on<ReferralRewardRejected>(_onReject);
  }

  final ReferralsRepository _repo;

  Future<void> _onStarted(
    ReferralRewardsStarted event,
    Emitter<ReferralRewardsState> emit,
  ) async {
    emit(state.copyWith(phase: ReferralRewardsPhase.loading, clearFailure: true));
    try {
      final summary = await _repo.getReferralSummary();
      final rewards = await _repo.getRewards();
      emit(
        state.copyWith(
          phase: ReferralRewardsPhase.ready,
          summary: summary,
          rewards: rewards,
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(phase: ReferralRewardsPhase.failure, failure: f));
    }
  }

  Future<void> _onAdminQueueStarted(
    ReferralAdminQueueStarted event,
    Emitter<ReferralRewardsState> emit,
  ) async {
    emit(state.copyWith(phase: ReferralRewardsPhase.loading, clearFailure: true));
    try {
      final queue = await _repo.getAdminRewardQueue();
      emit(
        state.copyWith(
          phase: ReferralRewardsPhase.ready,
          adminQueue: queue,
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(phase: ReferralRewardsPhase.failure, failure: f));
    }
  }

  Future<void> _onApprove(
    ReferralRewardApproved event,
    Emitter<ReferralRewardsState> emit,
  ) async {
    try {
      await _repo.approveReward(event.id);
      emit(state.copyWith(actionSuccess: 'Reward approved'));
      add(const ReferralAdminQueueStarted());
    } on Failure catch (f) {
      emit(state.copyWith(failure: f));
    }
  }

  Future<void> _onReject(
    ReferralRewardRejected event,
    Emitter<ReferralRewardsState> emit,
  ) async {
    try {
      await _repo.rejectReward(event.id, reason: event.reason);
      emit(state.copyWith(actionSuccess: 'Reward rejected'));
      add(const ReferralAdminQueueStarted());
    } on Failure catch (f) {
      emit(state.copyWith(failure: f));
    }
  }
}
