import 'package:equatable/equatable.dart';

class ContractDraftAssist extends Equatable {
  const ContractDraftAssist({
    required this.title,
    required this.draftClauseText,
    this.keyTermsSummary = const [],
    this.legalDisclaimer,
  });

  final String title;
  final String draftClauseText;
  final List<String> keyTermsSummary;
  final String? legalDisclaimer;

  factory ContractDraftAssist.fromJson(Map<String, dynamic> json) {
    final rawTerms = json['keyTermsSummary'] as List<dynamic>?;
    return ContractDraftAssist(
      title: json['title'] as String? ?? 'Contract Clause Draft',
      draftClauseText: json['draftClauseText'] as String? ?? json['text'] as String? ?? '',
      keyTermsSummary: rawTerms != null ? rawTerms.map((e) => e.toString()).toList() : const [],
      legalDisclaimer: json['legalDisclaimer'] as String? ?? 'AI-generated draft for review by legal representative.',
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'draftClauseText': draftClauseText,
        'keyTermsSummary': keyTermsSummary,
        'legalDisclaimer': legalDisclaimer,
      };

  @override
  List<Object?> get props => [title, draftClauseText, keyTermsSummary, legalDisclaimer];
}
