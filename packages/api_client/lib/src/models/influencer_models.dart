class OnboardingProgressDto {
  const OnboardingProgressDto({
    this.step1 = false,
    this.step2 = false,
    this.step3 = false,
    this.step4 = false,
    this.step5 = false,
    this.step6 = false,
  });

  final bool step1;
  final bool step2;
  final bool step3;
  final bool step4;
  final bool step5;
  final bool step6;

  factory OnboardingProgressDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const OnboardingProgressDto();
    return OnboardingProgressDto(
      step1: json['step1'] == true,
      step2: json['step2'] == true,
      step3: json['step3'] == true,
      step4: json['step4'] == true,
      step5: json['step5'] == true,
      step6: json['step6'] == true,
    );
  }

  bool get isComplete =>
      step1 && step2 && step3 && step4 && step5 && step6;
}

class OnboardingStatusDto {
  const OnboardingStatusDto({
    required this.profileId,
    required this.progress,
    required this.nextStep,
    required this.completed,
    this.verificationStatus,
  });

  final String profileId;
  final OnboardingProgressDto progress;
  final int nextStep;
  final bool completed;
  final String? verificationStatus;

  factory OnboardingStatusDto.fromJson(Map<String, dynamic> json) {
    return OnboardingStatusDto(
      profileId: json['profileId'] as String,
      progress: OnboardingProgressDto.fromJson(
        json['progress'] as Map<String, dynamic>?,
      ),
      nextStep: json['nextStep'] as int? ?? 1,
      completed: json['completed'] == true,
      verificationStatus: json['verificationStatus'] as String?,
    );
  }
}

class InfluencerProfileDto {
  const InfluencerProfileDto({
    required this.id,
    this.displayName,
    this.biography,
    this.primaryPlatform,
    this.secondaryPlatform,
    this.mainRegionOfInfluence,
    this.secondaryRegionOfInfluence,
    this.blogUrl,
    this.country,
    this.state,
    this.city,
    this.openToBarter,
    this.licensingAvailable,
    this.verificationStatus,
    this.onboardingCompletedAt,
    this.languages = const [],
    this.audienceGender,
    this.audienceAgeRanges = const [],
    this.monetizationMethods = const [],
  });

  final String id;
  final String? displayName;
  final String? biography;
  final String? primaryPlatform;
  final String? secondaryPlatform;
  final String? mainRegionOfInfluence;
  final String? secondaryRegionOfInfluence;
  final String? blogUrl;
  final String? country;
  final String? state;
  final String? city;
  final bool? openToBarter;
  final bool? licensingAvailable;
  final String? verificationStatus;
  final String? onboardingCompletedAt;
  final List<String> languages;
  final String? audienceGender;
  final List<String> audienceAgeRanges;
  final List<String> monetizationMethods;

  factory InfluencerProfileDto.fromJson(Map<String, dynamic> json) {
    List<String> strList(Object? v) {
      if (v is List) return v.map((e) => e.toString()).toList();
      return const [];
    }

    return InfluencerProfileDto(
      id: json['id'] as String,
      displayName: json['displayName'] as String?,
      biography: json['biography'] as String?,
      primaryPlatform: json['primaryPlatform'] as String?,
      secondaryPlatform: json['secondaryPlatform'] as String?,
      mainRegionOfInfluence: json['mainRegionOfInfluence'] as String?,
      secondaryRegionOfInfluence: json['secondaryRegionOfInfluence'] as String?,
      blogUrl: json['blogUrl'] as String?,
      country: json['country'] as String?,
      state: json['state'] as String?,
      city: json['city'] as String?,
      openToBarter: json['openToBarter'] as bool?,
      licensingAvailable: json['licensingAvailable'] as bool?,
      verificationStatus: json['verificationStatus'] as String?,
      onboardingCompletedAt: json['onboardingCompletedAt']?.toString(),
      languages: strList(json['languages']),
      audienceGender: json['audienceGender'] as String?,
      audienceAgeRanges: strList(json['audienceAgeRanges']),
      monetizationMethods: strList(json['monetizationMethods']),
    );
  }
}

class SocialAccountDto {
  const SocialAccountDto({
    required this.id,
    required this.platform,
    this.handle,
    this.followersCount,
    this.engagementRate,
    this.status,
    this.declaredOnly,
  });

  final String id;
  final String platform;
  final String? handle;
  final int? followersCount;
  final num? engagementRate;
  final String? status;
  final bool? declaredOnly;

  factory SocialAccountDto.fromJson(Map<String, dynamic> json) {
    return SocialAccountDto(
      id: json['id'] as String,
      platform: json['platform'] as String,
      handle: json['handle'] as String?,
      followersCount: json['followersCount'] as int?,
      engagementRate: json['engagementRate'] as num?,
      status: json['status'] as String?,
      declaredOnly: json['declaredOnly'] as bool?,
    );
  }
}

class PricingLineDto {
  const PricingLineDto({
    required this.deliverableType,
    required this.priceMinor,
    required this.currency,
  });

  final String deliverableType;
  final int priceMinor;
  final String currency;

  Map<String, dynamic> toJson() => {
        'deliverableType': deliverableType,
        'priceMinor': priceMinor,
        'currency': currency,
      };

  factory PricingLineDto.fromJson(Map<String, dynamic> json) {
    return PricingLineDto(
      deliverableType: json['deliverableType'] as String,
      priceMinor: json['priceMinor'] as int,
      currency: json['currency'] as String,
    );
  }
}

class ReferralInviteDto {
  const ReferralInviteDto({
    required this.id,
    required this.code,
    this.inviteeEmail,
    this.reward,
    this.note,
  });

  final String id;
  final String code;
  final String? inviteeEmail;
  final Object? reward;
  final String? note;

  factory ReferralInviteDto.fromJson(Map<String, dynamic> json) {
    return ReferralInviteDto(
      id: json['id'] as String,
      code: json['code'] as String,
      inviteeEmail: json['inviteeEmail'] as String?,
      reward: json['reward'],
      note: json['note'] as String?,
    );
  }
}

class OAuthStartDto {
  const OAuthStartDto({
    required this.platform,
    required this.authorizationUrl,
    this.state,
    this.expiresIn,
  });

  final String platform;
  final String authorizationUrl;
  final String? state;
  final int? expiresIn;

  factory OAuthStartDto.fromJson(Map<String, dynamic> json) {
    return OAuthStartDto(
      platform: json['platform'] as String,
      authorizationUrl: json['authorizationUrl'] as String,
      state: json['state'] as String?,
      expiresIn: json['expiresIn'] as int?,
    );
  }
}
