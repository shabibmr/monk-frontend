import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/payment.dart';
import '../../domain/repositories/payment_repository.dart';

class PaymentState extends Equatable {
  const PaymentState({
    this.loading = false,
    this.acting = false,
    this.payments = const [],
    this.barterOnly = false,
    this.failure,
    this.infoMessage,
    this.lastCheckout,
  });

  final bool loading;
  final bool acting;
  final List<Payment> payments;
  final bool barterOnly;
  final Failure? failure;
  final String? infoMessage;
  final Map<String, dynamic>? lastCheckout;

  PaymentState copyWith({
    bool? loading,
    bool? acting,
    List<Payment>? payments,
    bool? barterOnly,
    Failure? failure,
    String? infoMessage,
    Map<String, dynamic>? lastCheckout,
    bool clearFailure = false,
    bool clearInfo = false,
  }) {
    return PaymentState(
      loading: loading ?? this.loading,
      acting: acting ?? this.acting,
      payments: payments ?? this.payments,
      barterOnly: barterOnly ?? this.barterOnly,
      failure: clearFailure ? null : (failure ?? this.failure),
      infoMessage: clearInfo ? null : (infoMessage ?? this.infoMessage),
      lastCheckout: lastCheckout ?? this.lastCheckout,
    );
  }

  @override
  List<Object?> get props =>
      [loading, acting, payments, barterOnly, failure, infoMessage, lastCheckout];
}

class PaymentCubit extends Cubit<PaymentState> {
  PaymentCubit(this._repo, this.collaborationId)
      : super(const PaymentState());

  final PaymentRepository _repo;
  final String collaborationId;
  bool _fundInFlight = false;

  Future<void> load() async {
    emit(state.copyWith(loading: true, clearFailure: true, clearInfo: true));
    try {
      final list = await _repo.listPayments(collaborationId);
      emit(
        state.copyWith(
          loading: false,
          payments: list,
          barterOnly: false,
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(loading: false, failure: f));
    }
  }

  Future<void> fund() async {
    // Debounce / double-submit guard (sync flag before any await).
    if (_fundInFlight) return;
    _fundInFlight = true;
    emit(state.copyWith(acting: true, clearFailure: true, clearInfo: true));
    try {
      final p = await _repo.fund(collaborationId);
      final list = await _repo.listPayments(collaborationId);
      emit(
        state.copyWith(
          acting: false,
          payments: list,
          lastCheckout: p.checkout,
          infoMessage: 'Funding order created',
        ),
      );
    } on Failure catch (f) {
      final barter = f.errorCode == 'BARTER_NO_FUNDING';
      emit(
        state.copyWith(
          acting: false,
          failure: f,
          barterOnly: barter || state.barterOnly,
        ),
      );
    } finally {
      _fundInFlight = false;
    }
  }

  Future<void> release(String paymentId) async {
    emit(state.copyWith(acting: true, clearFailure: true, clearInfo: true));
    try {
      await _repo.release(paymentId);
      await load();
      emit(state.copyWith(acting: false, infoMessage: 'Payment released'));
    } on Failure catch (f) {
      emit(state.copyWith(acting: false, failure: f));
    }
  }

  Future<void> refund(String paymentId) async {
    emit(state.copyWith(acting: true, clearFailure: true, clearInfo: true));
    try {
      await _repo.refund(paymentId);
      await load();
      emit(state.copyWith(acting: false, infoMessage: 'Refund initiated'));
    } on Failure catch (f) {
      emit(state.copyWith(acting: false, failure: f));
    }
  }
}
