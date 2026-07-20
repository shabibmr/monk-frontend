import 'package:equatable/equatable.dart';

class BriefAssist extends Equatable {
  const BriefAssist({
    required this.generatedBriefText,
    this.campaignObjectives = const [],
    this.deliverableRequirements = const [],
    this.doAndDonts = const [],
  });

  final String generatedBriefText;
  final List<String> campaignObjectives;
  final List<String> deliverableRequirements;
  final List<String> doAndDonts;

  factory BriefAssist.fromJson(Map<String, dynamic> json) {
    final rawObj = json['campaignObjectives'] as List<dynamic>?;
    final rawDeliv = json['deliverableRequirements'] as List<dynamic>?;
    final rawRules = json['doAndDonts'] as List<dynamic>?;

    return BriefAssist(
      generatedBriefText: json['generatedBriefText'] as String? ?? json['text'] as String? ?? '',
      campaignObjectives: rawObj != null ? rawObj.map((e) => e.toString()).toList() : const [],
      deliverableRequirements: rawDeliv != null ? rawDeliv.map((e) => e.toString()).toList() : const [],
      doAndDonts: rawRules != null ? rawRules.map((e) => e.toString()).toList() : const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'generatedBriefText': generatedBriefText,
        'campaignObjectives': campaignObjectives,
        'deliverableRequirements': deliverableRequirements,
        'doAndDonts': doAndDonts,
      };

  @override
  List<Object?> get props => [
        generatedBriefText,
        campaignObjectives,
        deliverableRequirements,
        doAndDonts,
      ];
}
