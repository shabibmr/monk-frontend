import '../../../features/ai/domain/entities/ai_assist_result.dart';
import '../../../features/ai/domain/entities/brief_assist.dart';
import '../../../features/ai/domain/entities/caption_assist.dart';
import '../../../features/ai/domain/entities/contract_draft_assist.dart';
import '../../../features/ai/domain/entities/pitch_summary.dart';
import '../../../features/ai/domain/repositories/ai_repository.dart';
import '../../errors/failures.dart';
import '../../network/api_client_factory.dart';
import '../mock_seed_store.dart';

/// Offline demo implementation of [AiRepository].
class MockAiRepository implements AiRepository {
  MockAiRepository({
    required this.store,
    required this.config,
  });

  final MockSeedStore store;
  final AppConfig config;

  @override
  bool isAiEnabled() => config.enableAi;

  @override
  Future<AiAssistResult> requestAiAssist({
    required String assistType,
    required Map<String, dynamic> context,
  }) async {
    await store.delay();
    if (!isAiEnabled()) {
      throw const ForbiddenFailure(
        'AI feature is currently disabled by configuration (ENABLE_AI).',
      );
    }

    final type = assistType.toLowerCase().trim();
    switch (type) {
      case 'caption':
        return const AiAssistResult(
          assistType: 'caption',
          rawOutput:
              'Glow with confidence this summer — my go-to serum routine in 15 seconds. #ad',
          captionAssist: CaptionAssist(
            captionText:
                'Glow with confidence this summer — my go-to serum routine in 15 seconds. Skin feels hydrated without the greasy finish.',
            disclosureTags: ['#ad', '#sponsored'],
            suggestedHashtags: [
              '#SummerGlow',
              '#SkincareRoutine',
              '#MonkCreators',
            ],
            tone: 'friendly',
          ),
        );
      case 'brief':
        return const AiAssistResult(
          assistType: 'brief',
          rawOutput:
              'Create a 15–30s vertical reel showcasing product unboxing and first impressions.',
          briefAssist: BriefAssist(
            generatedBriefText:
                'Create a 15–30s vertical reel showcasing product unboxing and first impressions. Highlight texture, scent, and 3-day skin feel. Include clear brand disclosure.',
            campaignObjectives: [
              'Drive product awareness',
              'Demonstrate authentic first-use',
              'Drive UTM clicks to PDP',
            ],
            deliverableRequirements: [
              '1 Instagram Reel (9:16)',
              'On-screen brand mention in first 3s',
              'CTA with tracked link in bio/story',
            ],
            doAndDonts: [
              'Do: natural lighting and honest reaction',
              'Do not: make medical claims',
              'Do not: omit #ad disclosure',
            ],
          ),
        );
      case 'contract':
        return const AiAssistResult(
          assistType: 'contract',
          rawOutput:
              'Creator shall deliver one (1) Instagram Reel within seven (7) days of product receipt.',
          contractDraftAssist: ContractDraftAssist(
            title: 'Deliverables & Timeline Clause',
            draftClauseText:
                'Creator shall deliver one (1) Instagram Reel within seven (7) days of product receipt. Brand has three (3) business days to request one round of revisions. Licensed usage is digital-only in India for 180 days unless extended in writing.',
            keyTermsSummary: [
              '1 deliverable: IG Reel',
              '7-day delivery window post-receipt',
              '1 revision round',
              '180-day digital license (IN)',
            ],
            legalDisclaimer:
                'AI-generated draft for review by a legal representative.',
          ),
        );
      case 'pitch':
        return const AiAssistResult(
          assistType: 'pitch',
          rawOutput:
              'Beauty micro-creator with strong skincare engagement and authentic UGC style.',
          pitchSummary: PitchSummary(
            pitchText:
                'Beauty micro-creator with strong skincare engagement and authentic UGC style. Audience skews 18–34 metro India; average reel views 25k with 6%+ engagement. Ideal for serum/routine education content.',
            highlights: [
              'Skincare niche authority',
              'High save/share rate on routine reels',
              'Reliable turnaround on brand briefs',
            ],
            targetAudienceMatch: 'High — beauty & lifestyle 18–34',
            suggestedRateEstimate: 'INR 15,000 – 25,000 per reel',
          ),
        );
      default:
        return AiAssistResult(
          assistType: assistType,
          rawOutput:
              'Demo AI assist for "$assistType". Context keys: ${context.keys.join(', ')}.',
        );
    }
  }
}
