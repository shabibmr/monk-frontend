import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monk_shared/monk_shared.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/payment.dart';
import '../../domain/repositories/payment_repository.dart';

class EarningsState extends Equatable {
  const EarningsState({
    this.loading = false,
    this.acting = false,
    this.earnings,
    this.lastPayout,
    this.failure,
    this.infoMessage,
  });

  final bool loading;
  final bool acting;
  final Earnings? earnings;
  final PayoutRequest? lastPayout;
  final Failure? failure;
  final String? infoMessage;

  EarningsState copyWith({
    bool? loading,
    bool? acting,
    Earnings? earnings,
    PayoutRequest? lastPayout,
    Failure? failure,
    String? infoMessage,
    bool clearFailure = false,
    bool clearInfo = false,
  }) {
    return EarningsState(
      loading: loading ?? this.loading,
      acting: acting ?? this.acting,
      earnings: earnings ?? this.earnings,
      lastPayout: lastPayout ?? this.lastPayout,
      failure: clearFailure ? null : (failure ?? this.failure),
      infoMessage: clearInfo ? null : (infoMessage ?? this.infoMessage),
    );
  }

  @override
  List<Object?> get props =>
      [loading, acting, earnings, lastPayout, failure, infoMessage];
}

class EarningsCubit extends Cubit<EarningsState> {
  EarningsCubit(
    this._repo, {
    required this.profileId,
    required this.role,
    required this.isProfileOwner,
  }) : super(const EarningsState());

  final PaymentRepository _repo;
  final String profileId;
  final UserRole? role;
  final bool isProfileOwner;

  bool get canConfirmPayout =>
      canConfirmPayoutAsOwner(role: role, isProfileOwner: isProfileOwner);

  Future<void> load() async {
    emit(state.copyWith(loading: true, clearFailure: true, clearInfo: true));
    try {
      final e = await _repo.earnings(profileId);
      emit(state.copyWith(loading: false, earnings: e));
    } on Failure catch (f) {
      emit(state.copyWith(loading: false, failure: f));
    }
  }

  Future<void> requestPayout(int amountMinor) async {
    emit(state.copyWith(acting: true, clearFailure: true, clearInfo: true));
    try {
      final p = await _repo.requestPayout(profileId, amountMinor: amountMinor);
      emit(
        state.copyWith(
          acting: false,
          lastPayout: p,
          infoMessage: p.requiresOwnerConfirmation
              ? 'Withdrawal awaiting owner confirmation'
              : 'Withdrawal requested',
        ),
      );
      await load();
    } on Failure catch (f) {
      emit(state.copyWith(acting: false, failure: f));
    }
  }

  Future<void> confirmPayout(String payoutId, {String? token}) async {
    if (!canConfirmPayout) {
      emit(
        state.copyWith(
          failure: const ForbiddenFailure(
            'Only the profile owner can confirm withdrawal',
            errorCode: 'OWNER_CONFIRM_REQUIRED',
          ),
        ),
      );
      return;
    }
    emit(state.copyWith(acting: true, clearFailure: true, clearInfo: true));
    try {
      await _repo.confirmPayout(payoutId, token: token);
      emit(
        state.copyWith(
          acting: false,
          infoMessage: 'Payout confirmed',
        ),
      );
      await load();
    } on Failure catch (f) {
      emit(state.copyWith(acting: false, failure: f));
    }
  }
}
