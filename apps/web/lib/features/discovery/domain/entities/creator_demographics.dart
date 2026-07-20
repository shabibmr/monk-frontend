import 'package:equatable/equatable.dart';

class CreatorDemographics extends Equatable {
  const CreatorDemographics({
    required this.influencerId,
    required this.creatorScore,
    required this.fakeFollowerScore,
    this.credibilityGrade = 'A',
    this.genderBreakdown = const {},
    this.ageBreakdown = const {},
    this.topLocations = const {},
    this.topLanguages = const [],
  });

  final String influencerId;
  final num creatorScore;
  final num fakeFollowerScore;
  final String credibilityGrade;
  final Map<String, num> genderBreakdown;
  final Map<String, num> ageBreakdown;
  final Map<String, num> topLocations;
  final List<String> topLanguages;

  factory CreatorDemographics.fromJson(Map<String, dynamic> json) {
    final gender = (json['genderBreakdown'] as Map<String, dynamic>?)?.map(
          (k, v) => MapEntry(k, (v as num).toDouble()),
        ) ??
        const {'female': 60.0, 'male': 40.0};
    final age = (json['ageBreakdown'] as Map<String, dynamic>?)?.map(
          (k, v) => MapEntry(k, (v as num).toDouble()),
        ) ??
        const {'18-24': 40.0, '25-34': 45.0, '35-44': 15.0};
    final loc = (json['topLocations'] as Map<String, dynamic>?)?.map(
          (k, v) => MapEntry(k, (v as num).toDouble()),
        ) ??
        const {'India': 70.0, 'United States': 20.0, 'UAE': 10.0};
    final lang = (json['topLanguages'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const ['English', 'Hindi'];

    return CreatorDemographics(
      influencerId: json['influencerId'] as String? ?? '',
      creatorScore: (json['creatorScore'] as num?)?.toDouble() ?? 85.0,
      fakeFollowerScore:
          (json['fakeFollowerScore'] as num?)?.toDouble() ?? 12.0,
      credibilityGrade: json['credibilityGrade'] as String? ?? 'A',
      genderBreakdown: gender,
      ageBreakdown: age,
      topLocations: loc,
      topLanguages: lang,
    );
  }

  @override
  List<Object?> get props => [
        influencerId,
        creatorScore,
        fakeFollowerScore,
        credibilityGrade,
        genderBreakdown,
        ageBreakdown,
        topLocations,
        topLanguages,
      ];
}
