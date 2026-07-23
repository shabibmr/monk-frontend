import 'package:equatable/equatable.dart';

enum RecommendationType {
  creator,
  campaign;

  static RecommendationType fromString(String raw) {
    switch (raw.toLowerCase()) {
      case 'campaign':
        return RecommendationType.campaign;
      case 'creator':
      default:
        return RecommendationType.creator;
    }
  }
}

class Recommendation extends Equatable {
  const Recommendation({
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
  final RecommendationType type;
  final String title;
  final String subtitle;
  final String? avatarUrl;
  final double? matchScore;
  final String targetId;
  final List<String> tags;
  final double? estimatedBudget;
  final String? currency;

  String get matchScoreLabel {
    if (matchScore == null) return '';
    final pct = (matchScore! * 100).round();
    return '$pct% match';
  }

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        subtitle,
        avatarUrl,
        matchScore,
        targetId,
        tags,
        estimatedBudget,
        currency,
      ];
}
