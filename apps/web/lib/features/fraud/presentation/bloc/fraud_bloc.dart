import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/fraud_repository.dart';
import 'fraud_event.dart';
import 'fraud_state.dart';

class FraudBloc extends Bloc<FraudEvent, FraudState> {
  FraudBloc(this._repository) : super(const FraudState()) {
    on<FetchFraudReportEvent>(_onFetchReport);
    on<DismissFraudWarningEvent>(_onDismissWarning);
  }

  final FraudRepository _repository;

  Future<void> _onFetchReport(
    FetchFraudReportEvent event,
    Emitter<FraudState> emit,
  ) async {
    emit(state.copyWith(status: FraudStatus.loading, errorMessage: null, isDismissed: false));

    try {
      final report = await _repository.getFraudRiskReport(event.entityId);
      emit(state.copyWith(
        status: FraudStatus.success,
        report: report,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: FraudStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  void _onDismissWarning(
    DismissFraudWarningEvent event,
    Emitter<FraudState> emit,
  ) {
    emit(state.copyWith(isDismissed: true));
  }
}
