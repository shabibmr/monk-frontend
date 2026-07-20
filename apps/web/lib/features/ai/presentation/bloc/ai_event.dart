import 'package:equatable/equatable.dart';

import '../../domain/entities/ai_assist_result.dart';

abstract class AiEvent extends Equatable {
  const AiEvent();

  @override
  List<Object?> get props => [];
}

class CheckAiFeatureFlagEvent extends AiEvent {
  const CheckAiFeatureFlagEvent();
}

class GenerateAiAssistEvent extends AiEvent {
  const GenerateAiAssistEvent({
    required this.assistType,
    this.context = const {},
  });

  final String assistType; // 'caption', 'brief', 'contract', 'pitch'
  final Map<String, dynamic> context;

  @override
  List<Object?> get props => [assistType, context];
}

class AcceptAiOutputEvent extends AiEvent {
  const AcceptAiOutputEvent(this.result);

  final AiAssistResult result;

  @override
  List<Object?> get props => [result];
}

class ResetAiPanelEvent extends AiEvent {
  const ResetAiPanelEvent();
}
