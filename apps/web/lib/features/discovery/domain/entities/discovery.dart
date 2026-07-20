import 'package:equatable/equatable.dart';

class DiscoveryFilters extends Equatable {
  const DiscoveryFilters({
    this.q = '',
    this.platform,
    this.country,
    this.openToBarter,
    this.minCreatorScore,
    this.maxFakeFollowersScore,
    this.sort = 'relevant',
  });

  final String q;
  final String? platform;
  final String? country;
  final bool? openToBarter;
  final double? minCreatorScore;
  final double? maxFakeFollowersScore;
  final String sort;

  DiscoveryFilters copyWith({
    String? q,
    String? platform,
    String? country,
    bool? openToBarter,
    double? minCreatorScore,
    double? maxFakeFollowersScore,
    String? sort,
    bool clearPlatform = false,
    bool clearCountry = false,
    bool clearBarter = false,
    bool clearMinScore = false,
    bool clearMaxFake = false,
  }) {
    return DiscoveryFilters(
      q: q ?? this.q,
      platform: clearPlatform ? null : (platform ?? this.platform),
      country: clearCountry ? null : (country ?? this.country),
      openToBarter: clearBarter ? null : (openToBarter ?? this.openToBarter),
      minCreatorScore: clearMinScore
          ? null
          : (minCreatorScore ?? this.minCreatorScore),
      maxFakeFollowersScore: clearMaxFake
          ? null
          : (maxFakeFollowersScore ?? this.maxFakeFollowersScore),
      sort: sort ?? this.sort,
    );
  }

  Map<String, dynamic> toQuery({String? cursor, int limit = 20}) {
    return {
      if (q.trim().isNotEmpty) 'q': q.trim(),
      if (platform != null && platform!.isNotEmpty) 'platform': platform,
      if (country != null && country!.isNotEmpty) 'country': country,
      if (openToBarter != null) 'openToBarter': openToBarter,
      if (minCreatorScore != null) 'minCreatorScore': minCreatorScore,
      if (maxFakeFollowersScore != null)
        'maxFakeFollowersScore': maxFakeFollowersScore,
      'sort': sort,
      'limit': limit,
      if (cursor != null) 'cursor': cursor,
    };
  }

  @override
  List<Object?> get props => [
        q,
        platform,
        country,
        openToBarter,
        minCreatorScore,
        maxFakeFollowersScore,
        sort,
      ];
}

class DiscoveryInfluencer extends Equatable {
  const DiscoveryInfluencer({
    required this.id,
    this.displayName,
    this.biography,
    this.country,
    this.city,
    this.primaryPlatform,
    this.openToBarter,
    this.followersCount,
    this.engagementRate,
    this.minPriceMinor,
    this.currency = 'INR',
    this.creatorScore,
    this.fakeFollowerScore,
    this.credibilityGrade,
  });

  final String id;
  final String? displayName;
  final String? biography;
  final String? country;
  final String? city;
  final String? primaryPlatform;
  final bool? openToBarter;
  final int? followersCount;
  final num? engagementRate;
  final int? minPriceMinor;
  final String currency;
  final num? creatorScore;
  final num? fakeFollowerScore;
  final String? credibilityGrade;

  String get label =>
      displayName?.isNotEmpty == true ? displayName! : id.substring(0, 8);

  @override
  List<Object?> get props => [
        id,
        displayName,
        biography,
        country,
        city,
        primaryPlatform,
        openToBarter,
        followersCount,
        engagementRate,
        minPriceMinor,
        currency,
        creatorScore,
        fakeFollowerScore,
        credibilityGrade,
      ];
}

class Shortlist extends Equatable {
  const Shortlist({required this.id, required this.name});
  final String id;
  final String name;
  @override
  List<Object?> get props => [id, name];
}

class ShortlistItem extends Equatable {
  const ShortlistItem({
    required this.id,
    required this.influencerProfileId,
    this.note,
    this.displayName,
  });
  final String id;
  final String influencerProfileId;
  final String? note;
  final String? displayName;
  @override
  List<Object?> get props => [id, influencerProfileId, note, displayName];
}

