import 'package:equatable/equatable.dart';

import '../../domain/entities/onboarding.dart';

sealed class OnboardingEvent extends Equatable {
  const OnboardingEvent();
  @override
  List<Object?> get props => [];
}

class OnboardingStarted extends OnboardingEvent {
  const OnboardingStarted();
}

class OnboardingGoToStep extends OnboardingEvent {
  const OnboardingGoToStep(this.step);
  final int step;
  @override
  List<Object?> get props => [step];
}

class OnboardingSavePlatforms extends OnboardingEvent {
  const OnboardingSavePlatforms({
    required this.primaryPlatform,
    this.secondaryPlatform,
    this.mainRegion,
    this.secondaryRegion,
    this.blogUrl,
    this.country,
    this.city,
  });

  final String primaryPlatform;
  final String? secondaryPlatform;
  final String? mainRegion;
  final String? secondaryRegion;
  final String? blogUrl;
  final String? country;
  final String? city;

  @override
  List<Object?> get props => [
        primaryPlatform,
        secondaryPlatform,
        mainRegion,
        secondaryRegion,
        blogUrl,
        country,
        city,
      ];
}

class OnboardingRefreshSocial extends OnboardingEvent {
  const OnboardingRefreshSocial();
}

class OnboardingManualSocial extends OnboardingEvent {
  const OnboardingManualSocial({
    required this.platform,
    required this.handle,
  });
  final String platform;
  final String handle;
  @override
  List<Object?> get props => [platform, handle];
}

class OnboardingStartOAuth extends OnboardingEvent {
  const OnboardingStartOAuth(this.platform);
  final String platform;
  @override
  List<Object?> get props => [platform];
}

class OnboardingContinueFromSocial extends OnboardingEvent {
  const OnboardingContinueFromSocial();
}

class OnboardingSaveCategoriesPricing extends OnboardingEvent {
  const OnboardingSaveCategoriesPricing({
    required this.mainCategory,
    this.secondaryCategories = const [],
    this.audienceGender,
    this.ageRanges = const [],
    this.monetization = const [],
    this.openToBarter = false,
    this.licensingAvailable = false,
    this.biography,
    this.displayName,
    required this.pricing,
  });

  final String mainCategory;
  final List<String> secondaryCategories;
  final String? audienceGender;
  final List<String> ageRanges;
  final List<String> monetization;
  final bool openToBarter;
  final bool licensingAvailable;
  final String? biography;
  final String? displayName;
  final List<PricingLine> pricing;

  @override
  List<Object?> get props => [
        mainCategory,
        secondaryCategories,
        audienceGender,
        ageRanges,
        monetization,
        openToBarter,
        licensingAvailable,
        biography,
        displayName,
        pricing,
      ];
}

class OnboardingSaveTeam extends OnboardingEvent {
  const OnboardingSaveTeam({
    this.managerEmail,
    this.referralEmail,
    this.skip = false,
  });
  final String? managerEmail;
  final String? referralEmail;
  final bool skip;
  @override
  List<Object?> get props => [managerEmail, referralEmail, skip];
}

class OnboardingConfirmComplete extends OnboardingEvent {
  const OnboardingConfirmComplete();
}
