import 'package:equatable/equatable.dart';

class CaptionAssist extends Equatable {
  const CaptionAssist({
    required this.captionText,
    this.disclosureTags = const ['#ad', '#sponsored'],
    this.suggestedHashtags = const [],
    this.tone,
  });

  final String captionText;
  final List<String> disclosureTags;
  final List<String> suggestedHashtags;
  final String? tone;

  factory CaptionAssist.fromJson(Map<String, dynamic> json) {
    final rawTags = json['disclosureTags'] as List<dynamic>?;
    final tags = rawTags != null
        ? rawTags.map((e) => e.toString()).toList()
        : const ['#ad', '#sponsored'];

    final normalizedTags = List<String>.from(tags);
    if (!normalizedTags.contains('#ad')) normalizedTags.add('#ad');
    if (!normalizedTags.contains('#sponsored')) normalizedTags.add('#sponsored');

    final rawHashtags = json['suggestedHashtags'] as List<dynamic>?;

    return CaptionAssist(
      captionText: json['captionText'] as String? ?? json['text'] as String? ?? '',
      disclosureTags: normalizedTags,
      suggestedHashtags: rawHashtags != null ? rawHashtags.map((e) => e.toString()).toList() : const [],
      tone: json['tone'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'captionText': captionText,
        'disclosureTags': disclosureTags,
        'suggestedHashtags': suggestedHashtags,
        'tone': tone,
      };

  @override
  List<Object?> get props => [captionText, disclosureTags, suggestedHashtags, tone];
}
