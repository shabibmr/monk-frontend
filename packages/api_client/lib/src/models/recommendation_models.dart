class RecommendationDto {
  const RecommendationDto({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    this.avatarUrl,
    this.matchScore,
    required this.targetId,
    this.tags = const [],
    this.estimatedBudget,
    this.currency,
  });

  final String id;
  final String type; // 'creator' | 'campaign'
  final String title;
  final String subtitle;
  final String? avatarUrl;
  final double? matchScore;
  final String targetId;
  final List<String> tags;
  final double? estimatedBudget;
  final String? currency;

  factory RecommendationDto.fromJson(Map<String, dynamic> json) {
    return RecommendationDto(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? 'creator',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      matchScore: (json['matchScore'] as num?)?.toDouble(),
      targetId: json['targetId'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      estimatedBudget: (json['estimatedBudget'] as num?)?.toDouble(),
      currency: json['currency'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'title': title,
        'subtitle': subtitle,
        'avatarUrl': avatarUrl,
        'matchScore': matchScore,
        'targetId': targetId,
        'tags': tags,
        'estimatedBudget': estimatedBudget,
        'currency': currency,
      };
}
