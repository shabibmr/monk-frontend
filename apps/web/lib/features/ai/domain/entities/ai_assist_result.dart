import 'package:equatable/equatable.dart';

import 'brief_assist.dart';
import 'caption_assist.dart';
import 'contract_draft_assist.dart';
import 'pitch_summary.dart';

class AiAssistResult extends Equatable {
  const AiAssistResult({
    required this.assistType,
    this.rawOutput,
    this.captionAssist,
    this.contractDraftAssist,
    this.pitchSummary,
    this.briefAssist,
    this.isAccepted = false,
  });

  final String assistType; // 'caption', 'brief', 'contract', 'pitch'
  final String? rawOutput;
  final CaptionAssist? captionAssist;
  final ContractDraftAssist? contractDraftAssist;
  final PitchSummary? pitchSummary;
  final BriefAssist? briefAssist;
  final bool isAccepted;

  AiAssistResult copyWith({
    String? assistType,
    String? rawOutput,
    CaptionAssist? captionAssist,
    ContractDraftAssist? contractDraftAssist,
    PitchSummary? pitchSummary,
    BriefAssist? briefAssist,
    bool? isAccepted,
  }) {
    return AiAssistResult(
      assistType: assistType ?? this.assistType,
      rawOutput: rawOutput ?? this.rawOutput,
      captionAssist: captionAssist ?? this.captionAssist,
      contractDraftAssist: contractDraftAssist ?? this.contractDraftAssist,
      pitchSummary: pitchSummary ?? this.pitchSummary,
      briefAssist: briefAssist ?? this.briefAssist,
      isAccepted: isAccepted ?? this.isAccepted,
    );
  }

  /// Extracts formatted string content ready to be applied/accepted by user into a form field
  String get printableContent {
    if (captionAssist != null) {
      final tags = captionAssist!.disclosureTags.join(' ');
      return '${captionAssist!.captionText}\n\n$tags'.trim();
    }
    if (contractDraftAssist != null) {
      return contractDraftAssist!.draftClauseText;
    }
    if (pitchSummary != null) {
      return pitchSummary!.pitchText;
    }
    if (briefAssist != null) {
      return briefAssist!.generatedBriefText;
    }
    return rawOutput ?? '';
  }

  factory AiAssistResult.fromJson(Map<String, dynamic> json, String assistType) {
    final rawText = json['output'] as String? ?? json['text'] as String? ?? json.toString();
    CaptionAssist? caption;
    ContractDraftAssist? contract;
    PitchSummary? pitch;
    BriefAssist? brief;

    if (assistType == 'caption' || json.containsKey('captionText')) {
      caption = CaptionAssist.fromJson(json);
    }
    if (assistType == 'contract' || json.containsKey('draftClauseText')) {
      contract = ContractDraftAssist.fromJson(json);
    }
    if (assistType == 'pitch' || json.containsKey('pitchText')) {
      pitch = PitchSummary.fromJson(json);
    }
    if (assistType == 'brief' || json.containsKey('generatedBriefText')) {
      brief = BriefAssist.fromJson(json);
    }

    return AiAssistResult(
      assistType: assistType,
      rawOutput: rawText,
      captionAssist: caption,
      contractDraftAssist: contract,
      pitchSummary: pitch,
      briefAssist: brief,
      isAccepted: json['isAccepted'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        assistType,
        rawOutput,
        captionAssist,
        contractDraftAssist,
        pitchSummary,
        briefAssist,
        isAccepted,
      ];
}
