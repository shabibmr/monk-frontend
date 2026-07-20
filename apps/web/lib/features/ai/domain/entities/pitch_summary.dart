import 'package:equatable/equatable.dart';

class PitchSummary extends Equatable {
  const PitchSummary({
    required this.pitchText,
    this.highlights = const [],
    this.targetAudienceMatch,
    this.suggestedRateEstimate,
  });

  final String pitchText;
  final List<String> highlights;
  final String? targetAudienceMatch;
  final String? suggestedRateEstimate;

  factory PitchSummary.fromJson(Map<String, dynamic> json) {
    final rawHighlights = json['highlights'] as List<dynamic>?;
    return PitchSummary(
      pitchText: json['pitchText'] as String? ?? json['text'] as String? ?? '',
      highlights: rawHighlights != null ? rawHighlights.map((e) => e.toString()).toList() : const [],
      targetAudienceMatch: json['targetAudienceMatch'] as String?,
      suggestedRateEstimate: json['suggestedRateEstimate'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'pitchText': pitchText,
        'highlights': highlights,
        'targetAudienceMatch': targetAudienceMatch,
        'suggestedRateEstimate': suggestedRateEstimate,
      };

  @override
  List<Object?> get props => [pitchText, highlights, targetAudienceMatch, suggestedRateEstimate];
}
