import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/ai_repository.dart';
import 'ai_event.dart';
import 'ai_state.dart';

class AiBloc extends Bloc<AiEvent, AiState> {
  AiBloc(this._repository) : super(const AiState()) {
    on<CheckAiFeatureFlagEvent>(_onCheckFeatureFlag);
    on<GenerateAiAssistEvent>(_onGenerateAssist);
    on<AcceptAiOutputEvent>(_onAcceptOutput);
    on<ResetAiPanelEvent>(_onResetPanel);
  }

  final AiRepository _repository;

  void _onCheckFeatureFlag(CheckAiFeatureFlagEvent event, Emitter<AiState> emit) {
    final enabled = _repository.isAiEnabled();
    if (!enabled) {
      emit(state.copyWith(
        isEnabled: false,
        status: AiStatus.disabled,
        errorMessage: 'AI Feature is disabled',
      ));
    } else {
      emit(state.copyWith(isEnabled: true));
    }
  }

  Future<void> _onGenerateAssist(
    GenerateAiAssistEvent event,
    Emitter<AiState> emit,
  ) async {
    final enabled = _repository.isAiEnabled();
    if (!enabled) {
      emit(state.copyWith(
        isEnabled: false,
        status: AiStatus.disabled,
        errorMessage: 'AI Feature is disabled in configuration',
      ));
      return;
    }

    emit(state.copyWith(status: AiStatus.loading, errorMessage: null));

    try {
      final res = await _repository.requestAiAssist(
        assistType: event.assistType,
        context: event.context,
      );
      emit(state.copyWith(
        status: AiStatus.generated,
        result: res,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AiStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  void _onAcceptOutput(AcceptAiOutputEvent event, Emitter<AiState> emit) {
    final acceptedResult = event.result.copyWith(isAccepted: true);
    emit(state.copyWith(
      status: AiStatus.accepted,
      result: acceptedResult,
      acceptedContent: acceptedResult.printableContent,
    ));
  }

  void _onResetPanel(ResetAiPanelEvent event, Emitter<AiState> emit) {
    emit(AiState(isEnabled: _repository.isAiEnabled()));
  }
}
