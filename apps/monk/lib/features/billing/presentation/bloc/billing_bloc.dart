import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/repositories/billing_repository.dart';
import 'billing_event.dart';
import 'billing_state.dart';

class BillingBloc extends Bloc<BillingEvent, BillingState> {
  BillingBloc(this._repository) : super(const BillingState()) {
    on<FetchBillingDetailsStarted>(_onFetchStarted);
    on<UpgradePlanRequested>(_onUpgradeRequested);
  }

  final BillingRepository _repository;

  Future<void> _onFetchStarted(
    FetchBillingDetailsStarted event,
    Emitter<BillingState> emit,
  ) async {
    emit(state.copyWith(phase: BillingPhase.loading, failure: null));
    try {
      final subscription = await _repository.getCurrentSubscription();
      final plans = await _repository.getAvailablePlans();
      final invoices = await _repository.getInvoiceHistory();

      emit(
        state.copyWith(
          phase: BillingPhase.ready,
          subscription: subscription,
          availablePlans: plans,
          invoices: invoices,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          phase: BillingPhase.failure,
          failure: e is Failure ? e : ServerFailure(e.toString()),
        ),
      );
    }
  }

  Future<void> _onUpgradeRequested(
    UpgradePlanRequested event,
    Emitter<BillingState> emit,
  ) async {
    emit(state.copyWith(isUpgrading: true, failure: null));
    try {
      final updatedSub = await _repository.subscribeToPlan(event.planId);
      emit(
        state.copyWith(
          subscription: updatedSub,
          isUpgrading: false,
          actionSuccessMessage: 'Successfully upgraded subscription plan to ${updatedSub.currentPlan.name}',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isUpgrading: false,
          failure: e is Failure ? e : ServerFailure(e.toString()),
        ),
      );
    }
  }
}
