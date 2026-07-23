import 'package:equatable/equatable.dart';

class FraudRiskReport extends Equatable {
  const FraudRiskReport({
    required this.entityId,
    required this.riskScore,
    required this.isDuplicate,
    required this.flaggedReasons,
    required this.recommendation,
    this.riskLevel = 'low',
  });

  final String entityId;
  final double riskScore; // Driven purely by API scores (no client-side math)
  final bool isDuplicate;
  final List<String> flaggedReasons;
  final String recommendation;
  final String riskLevel; // Driven purely by API

  bool get hasRiskFlag => isDuplicate || riskScore > 0.5 || flaggedReasons.isNotEmpty;

  factory FraudRiskReport.fromJson(Map<String, dynamic> json, String entityId) {
    final rawReasons = json['flaggedReasons'] as List<dynamic>?;
    final score = (json['riskScore'] as num?)?.toDouble() ?? 0.0;
    return FraudRiskReport(
      entityId: entityId,
      riskScore: score,
      isDuplicate: json['isDuplicate'] as bool? ?? false,
      flaggedReasons: rawReasons != null ? rawReasons.map((e) => e.toString()).toList() : const [],
      recommendation: json['recommendation'] as String? ?? 'Proceed with standard workflow.',
      riskLevel: json['riskLevel'] as String? ?? (score >= 0.7 ? 'high' : score >= 0.4 ? 'medium' : 'low'),
    );
  }

  Map<String, dynamic> toJson() => {
        'entityId': entityId,
        'riskScore': riskScore,
        'isDuplicate': isDuplicate,
        'flaggedReasons': flaggedReasons,
        'recommendation': recommendation,
        'riskLevel': riskLevel,
      };

  @override
  List<Object?> get props => [
        entityId,
        riskScore,
        isDuplicate,
        flaggedReasons,
        recommendation,
        riskLevel,
      ];
}
