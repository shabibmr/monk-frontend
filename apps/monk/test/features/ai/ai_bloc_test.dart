import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:monk_web/features/ai/domain/entities/ai_assist_result.dart';
import 'package:monk_web/features/ai/domain/entities/caption_assist.dart';
import 'package:monk_web/features/ai/domain/entities/contract_draft_assist.dart';
import 'package:monk_web/features/ai/domain/repositories/ai_repository.dart';
import 'package:monk_web/features/ai/presentation/bloc/ai_bloc.dart';
import 'package:monk_web/features/ai/presentation/bloc/ai_event.dart';
import 'package:monk_web/features/ai/presentation/bloc/ai_state.dart';

class _MockAiRepository extends Mock implements AiRepository {}

void main() {
  late _MockAiRepository repo;

  const captionResult = AiAssistResult(
    assistType: 'caption',
    rawOutput: 'Awesome summer campaign caption!',
    captionAssist: CaptionAssist(
      captionText: 'Awesome summer campaign caption!',
      disclosureTags: ['#ad', '#sponsored'],
      suggestedHashtags: ['#summer', '#glow'],
    ),
  );

  const contractResult = AiAssistResult(
    assistType: 'contract',
    contractDraftAssist: ContractDraftAssist(
      title: 'Exclusivity Clause',
      draftClauseText: 'The creator shall not promote competing products for 30 days.',
      keyTermsSummary: ['30 days exclusivity', 'Skincare category'],
    ),
  );

  setUp(() {
    repo = _MockAiRepository();
  });

  group('AiBloc', () {
    blocTest<AiBloc, AiState>(
      'checks feature flag and emits disabled state when feature is off',
      build: () {
        when(() => repo.isAiEnabled()).thenReturn(false);
        return AiBloc(repo);
      },
      act: (bloc) => bloc.add(const CheckAiFeatureFlagEvent()),
      expect: () => [
        const AiState(
          isEnabled: false,
          status: AiStatus.disabled,
          errorMessage: 'AI Feature is disabled',
        ),
      ],
    );

    blocTest<AiBloc, AiState>(
      'generates caption assist with required disclosure tags',
      build: () {
        when(() => repo.isAiEnabled()).thenReturn(true);
        when(() => repo.requestAiAssist(
              assistType: 'caption',
              context: any(named: 'context'),
            )).thenAnswer((_) async => captionResult);
        return AiBloc(repo);
      },
      act: (bloc) => bloc.add(
        const GenerateAiAssistEvent(
          assistType: 'caption',
          context: {'product': 'Glow Serum'},
        ),
      ),
      expect: () => [
        const AiState(status: AiStatus.loading),
        const AiState(
          status: AiStatus.generated,
          result: captionResult,
        ),
      ],
      verify: (_) {
        verify(() => repo.requestAiAssist(
              assistType: 'caption',
              context: {'product': 'Glow Serum'},
            )).called(1);
      },
    );

    blocTest<AiBloc, AiState>(
      'generates contract draft assist successfully',
      build: () {
        when(() => repo.isAiEnabled()).thenReturn(true);
        when(() => repo.requestAiAssist(
              assistType: 'contract',
              context: any(named: 'context'),
            )).thenAnswer((_) async => contractResult);
        return AiBloc(repo);
      },
      act: (bloc) => bloc.add(
        const GenerateAiAssistEvent(
          assistType: 'contract',
        ),
      ),
      expect: () => [
        const AiState(status: AiStatus.loading),
        const AiState(
          status: AiStatus.generated,
          result: contractResult,
        ),
      ],
    );

    blocTest<AiBloc, AiState>(
      'user accepts AI output and updates state to accepted with printable content',
      seed: () => const AiState(
        status: AiStatus.generated,
        result: captionResult,
      ),
      build: () => AiBloc(repo),
      act: (bloc) => bloc.add(const AcceptAiOutputEvent(captionResult)),
      expect: () => [
        AiState(
          status: AiStatus.accepted,
          result: captionResult.copyWith(isAccepted: true),
          acceptedContent: 'Awesome summer campaign caption!\n\n#ad #sponsored',
        ),
      ],
    );

    blocTest<AiBloc, AiState>(
      'handles errors during generation gracefully',
      build: () {
        when(() => repo.isAiEnabled()).thenReturn(true);
        when(() => repo.requestAiAssist(
              assistType: 'caption',
              context: any(named: 'context'),
            )).thenThrow(Exception('API Service Unavailable'));
        return AiBloc(repo);
      },
      act: (bloc) => bloc.add(
        const GenerateAiAssistEvent(assistType: 'caption'),
      ),
      expect: () => [
        const AiState(status: AiStatus.loading),
        const AiState(
          status: AiStatus.error,
          errorMessage: 'API Service Unavailable',
        ),
      ],
    );
  });
}
