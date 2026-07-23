import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monk_shared/monk_shared.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/widgets.dart';
import '../bloc/ai_bloc.dart';
import '../bloc/ai_event.dart';
import '../bloc/ai_state.dart';

class AiSidePanel extends StatelessWidget {
  const AiSidePanel({
    super.key,
    required this.assistType,
    this.contextData = const {},
    this.onApplyOutput,
    this.title,
  });

  final String assistType; // 'caption', 'brief', 'contract', 'pitch'
  final Map<String, dynamic> contextData;
  final ValueChanged<String>? onApplyOutput;
  final String? title;

  String get _panelTitle {
    if (title != null) return title!;
    switch (assistType) {
      case 'caption':
        return 'AI Caption Generator';
      case 'brief':
        return 'AI Brief Builder';
      case 'contract':
        return 'AI Contract Drafter';
      case 'pitch':
        return 'AI Pitch Summarizer';
      default:
        return 'AI Assistant Side Panel';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AiBloc, AiState>(
      listener: (context, state) {
        if (state.status == AiStatus.error && state.errorMessage != null) {
          ImToast.show(
            context,
            message: state.errorMessage!,
            tone: ImToastTone.danger,
          );
        } else if (state.status == AiStatus.accepted) {
          ImToast.show(
            context,
            message: 'AI Output accepted and applied!',
            tone: ImToastTone.success,
          );
        }
      },
      builder: (context, state) {
        if (!state.isEnabled) {
          return ImCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.stars_rounded, color: ImColors.ink400),
                    const SizedBox(width: ImSpacing.space8),
                    Text(
                      _panelTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Spacer(),
                    const ImStatusChip(
                      status: EntityStatus.held,
                      label: 'Disabled',
                    ),
                  ],
                ),
                const SizedBox(height: ImSpacing.space12),
                const Text(
                  'AI Features are currently disabled in this environment by configuration (ENABLE_AI).',
                  style: TextStyle(color: ImColors.ink500, fontSize: 13),
                ),
              ],
            ),
          );
        }

        return ImCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: ImColors.brand600),
                  const SizedBox(width: ImSpacing.space8),
                  Expanded(
                    child: Text(
                      _panelTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  if (state.isAccepted)
                    const ImStatusChip(
                      status: EntityStatus.approved,
                      label: 'Accepted',
                    )
                  else if (state.isGenerated)
                    const ImStatusChip(
                      status: EntityStatus.inReview,
                      label: 'Review Required',
                    ),
                ],
              ),
              const SizedBox(height: ImSpacing.space12),
              if (state.status == AiStatus.initial || state.hasError) ...[
                Text(
                  'Click generate to request AI guidance for $assistType assist.',
                  style: const TextStyle(color: ImColors.ink600, fontSize: 13),
                ),
                const SizedBox(height: ImSpacing.space16),
                ImButton(
                  label: 'Generate Output',
                  icon: const Icon(Icons.bolt, size: 16),
                  onPressed: () {
                    context.read<AiBloc>().add(
                          GenerateAiAssistEvent(
                            assistType: assistType,
                            context: contextData,
                          ),
                        );
                  },
                ),
              ] else if (state.isLoading) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: ImSpacing.space24),
                  child: Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: ImSpacing.space12),
                        Text(
                          'Generating AI Output...',
                          style: TextStyle(color: ImColors.ink600),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else if (state.result != null) ...[
                _buildAssistDetails(context, state),
                const SizedBox(height: ImSpacing.space16),
                const Divider(),
                const SizedBox(height: ImSpacing.space8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ImButton(
                      label: 'Regenerate',
                      variant: ImButtonVariant.secondary,
                      onPressed: () {
                        context.read<AiBloc>().add(
                              GenerateAiAssistEvent(
                                assistType: assistType,
                                context: contextData,
                              ),
                            );
                      },
                    ),
                    const SizedBox(width: ImSpacing.space8),
                    ImButton(
                      label: state.isAccepted ? 'Applied' : 'Accept & Apply',
                      variant: state.isAccepted
                          ? ImButtonVariant.secondary
                          : ImButtonVariant.primary,
                      icon: Icon(
                        state.isAccepted ? Icons.check : Icons.input,
                        size: 16,
                      ),
                      onPressed: () {
                        final res = state.result!;
                        context.read<AiBloc>().add(AcceptAiOutputEvent(res));
                        if (onApplyOutput != null) {
                          onApplyOutput!(res.printableContent);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildAssistDetails(BuildContext context, AiState state) {
    final res = state.result!;
    if (res.captionAssist != null) {
      final caption = res.captionAssist!;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Generated Caption:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: ImSpacing.space4),
          Container(
            padding: const EdgeInsets.all(ImSpacing.space12),
            decoration: BoxDecoration(
              color: ImColors.ink100.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(ImRadii.radiusSm),
            ),
            child: Text(
              caption.captionText,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(height: ImSpacing.space12),
          const Text(
            'Required Disclosure Tags:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: ImColors.ink700,
            ),
          ),
          const SizedBox(height: ImSpacing.space4),
          Wrap(
            spacing: 6,
            children: caption.disclosureTags
                .map(
                  (tag) => Chip(
                    label: Text(
                      tag,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: ImColors.brand700,
                      ),
                    ),
                    backgroundColor: ImColors.brand100,
                    visualDensity: VisualDensity.compact,
                  ),
                )
                .toList(),
          ),
          if (caption.suggestedHashtags.isNotEmpty) ...[
            const SizedBox(height: ImSpacing.space8),
            Text(
              'Hashtags: ${caption.suggestedHashtags.join(' ')}',
              style: const TextStyle(color: ImColors.ink500, fontSize: 12),
            ),
          ],
        ],
      );
    }

    if (res.contractDraftAssist != null) {
      final contract = res.contractDraftAssist!;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            contract.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: ImSpacing.space6),
          Container(
            padding: const EdgeInsets.all(ImSpacing.space12),
            decoration: BoxDecoration(
              color: ImColors.ink100.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(ImRadii.radiusSm),
            ),
            child: Text(
              contract.draftClauseText,
              style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
            ),
          ),
          if (contract.keyTermsSummary.isNotEmpty) ...[
            const SizedBox(height: ImSpacing.space8),
            const Text(
              'Key Terms:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            ...contract.keyTermsSummary.map(
              (term) => Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 2.0),
                child: Text('• $term', style: const TextStyle(fontSize: 12)),
              ),
            ),
          ],
          if (contract.legalDisclaimer != null) ...[
            const SizedBox(height: ImSpacing.space8),
            Text(
              contract.legalDisclaimer!,
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                color: ImColors.ink500,
                fontSize: 11,
              ),
            ),
          ],
        ],
      );
    }

    if (res.pitchSummary != null) {
      final pitch = res.pitchSummary!;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pitch Summary:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: ImSpacing.space4),
          Text(pitch.pitchText, style: const TextStyle(fontSize: 13)),
          if (pitch.highlights.isNotEmpty) ...[
            const SizedBox(height: ImSpacing.space8),
            const Text(
              'Highlights:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            ...pitch.highlights.map(
              (h) => Text('• $h', style: const TextStyle(fontSize: 12)),
            ),
          ],
          if (pitch.suggestedRateEstimate != null) ...[
            const SizedBox(height: ImSpacing.space8),
            Row(
              children: [
                const Text(
                  'Suggested Rate: ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                Text(
                  pitch.suggestedRateEstimate!,
                  style: const TextStyle(
                    color: ImColors.brand700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ],
      );
    }

    if (res.briefAssist != null) {
      final brief = res.briefAssist!;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Generated Brief Guidance:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: ImSpacing.space4),
          Text(brief.generatedBriefText, style: const TextStyle(fontSize: 13)),
          if (brief.campaignObjectives.isNotEmpty) ...[
            const SizedBox(height: ImSpacing.space8),
            const Text(
              'Objectives:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            ...brief.campaignObjectives.map(
              (o) => Text('• $o', style: const TextStyle(fontSize: 12)),
            ),
          ],
        ],
      );
    }

    return Text(res.printableContent);
  }
}
