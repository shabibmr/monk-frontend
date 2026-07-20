class DiscoveryInfluencerDto {
  const DiscoveryInfluencerDto({
    required this.id,
    this.displayName,
    this.biography,
    this.country,
    this.city,
    this.openToBarter,
    this.licensingAvailable,
    this.primaryPlatform,
    this.verificationStatus,
    this.socialAccounts = const [],
    this.pricing = const [],
    this.marketplaceVisible = true,
  });

  final String id;
  final String? displayName;
  final String? biography;
  final String? country;
  final String? city;
  final bool? openToBarter;
  final bool? licensingAvailable;
  final String? primaryPlatform;
  final String? verificationStatus;
  final List<DiscoverySocialDto> socialAccounts;
  final List<DiscoveryPricingDto> pricing;
  final bool marketplaceVisible;

  factory DiscoveryInfluencerDto.fromJson(Map<String, dynamic> json) {
    final social = json['socialAccounts'] as List<dynamic>? ?? const [];
    final pricing = json['pricing'] as List<dynamic>? ?? const [];
    final badges = json['badges'] as Map<String, dynamic>? ?? const {};
    return DiscoveryInfluencerDto(
      id: json['id'] as String,
      displayName: json['displayName'] as String?,
      biography: json['biography'] as String?,
      country: json['country'] as String?,
      city: json['city'] as String?,
      openToBarter: json['openToBarter'] as bool?,
      licensingAvailable: json['licensingAvailable'] as bool?,
      primaryPlatform: json['primaryPlatform'] as String?,
      verificationStatus: json['verificationStatus'] as String?,
      socialAccounts: social
          .map((e) => DiscoverySocialDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      pricing: pricing
          .map((e) => DiscoveryPricingDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      marketplaceVisible: badges['marketplaceVisible'] != false,
    );
  }
}

class DiscoverySocialDto {
  const DiscoverySocialDto({
    required this.platform,
    this.handle,
    this.followersCount,
    this.engagementRate,
  });

  final String platform;
  final String? handle;
  final int? followersCount;
  final num? engagementRate;

  factory DiscoverySocialDto.fromJson(Map<String, dynamic> json) {
    return DiscoverySocialDto(
      platform: json['platform'] as String? ?? '',
      handle: json['handle'] as String?,
      followersCount: json['followersCount'] as int?,
      engagementRate: json['engagementRate'] as num?,
    );
  }
}

class DiscoveryPricingDto {
  const DiscoveryPricingDto({
    required this.deliverableType,
    required this.priceMinor,
    required this.currency,
  });

  final String deliverableType;
  final int priceMinor;
  final String currency;

  factory DiscoveryPricingDto.fromJson(Map<String, dynamic> json) {
    return DiscoveryPricingDto(
      deliverableType: json['deliverableType'] as String? ?? '',
      priceMinor: json['priceMinor'] as int? ?? 0,
      currency: json['currency'] as String? ?? 'INR',
    );
  }
}

class DiscoveryPageDto {
  const DiscoveryPageDto({
    required this.data,
    this.nextCursor,
  });

  final List<DiscoveryInfluencerDto> data;
  final String? nextCursor;

  factory DiscoveryPageDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List<dynamic>? ?? const [];
    return DiscoveryPageDto(
      data: data
          .map(
            (e) => DiscoveryInfluencerDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      nextCursor: json['nextCursor'] as String?,
    );
  }
}

class ShortlistDto {
  const ShortlistDto({
    required this.id,
    required this.name,
    this.brandId,
  });

  final String id;
  final String name;
  final String? brandId;

  factory ShortlistDto.fromJson(Map<String, dynamic> json) {
    return ShortlistDto(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      brandId: json['brandId'] as String?,
    );
  }
}

class ShortlistItemDto {
  const ShortlistItemDto({
    required this.id,
    required this.influencerProfileId,
    this.note,
    this.displayName,
  });

  final String id;
  final String influencerProfileId;
  final String? note;
  final String? displayName;

  factory ShortlistItemDto.fromJson(Map<String, dynamic> json) {
    final inf = json['influencer'] as Map<String, dynamic>?;
    return ShortlistItemDto(
      id: json['id'] as String,
      influencerProfileId: json['influencerProfileId'] as String? ??
          json['influencerId'] as String? ??
          '',
      note: json['note'] as String?,
      displayName: inf?['displayName'] as String? ?? json['displayName'] as String?,
    );
  }
}
