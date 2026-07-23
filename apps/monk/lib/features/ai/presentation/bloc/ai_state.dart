import 'package:equatable/equatable.dart';

import '../../domain/entities/ai_assist_result.dart';

enum AiStatus { initial, loading, generated, accepted, disabled, error }

class AiState extends Equatable {
  const AiState({
    this.isEnabled = true,
    this.status = AiStatus.initial,
    this.result,
    this.acceptedContent,
    this.errorMessage,
  });

  final bool isEnabled;
  final AiStatus status;
  final AiAssistResult? result;
  final String? acceptedContent;
  final String? errorMessage;

  bool get isLoading => status == AiStatus.loading;
  bool get isGenerated => status == AiStatus.generated;
  bool get isAccepted => status == AiStatus.accepted;
  bool get hasError => status == AiStatus.error;

  AiState copyWith({
    bool? isEnabled,
    AiStatus? status,
    AiAssistResult? result,
    String? acceptedContent,
    String? errorMessage,
  }) {
    return AiState(
      isEnabled: isEnabled ?? this.isEnabled,
      status: status ?? this.status,
      result: result ?? this.result,
      acceptedContent: acceptedContent ?? this.acceptedContent,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        isEnabled,
        status,
        result,
        acceptedContent,
        errorMessage,
      ];
}
