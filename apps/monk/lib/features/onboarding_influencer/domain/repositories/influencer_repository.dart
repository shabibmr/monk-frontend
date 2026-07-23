import '../entities/onboarding.dart';

abstract class InfluencerRepository {
  Future<OnboardingStatus> loadOnboarding();
  Future<void> ensureProfile({String? displayName});
  Future<void> savePlatforms({
    required String profileId,
    required String primaryPlatform,
    String? secondaryPlatform,
    String? mainRegion,
    String? secondaryRegion,
    String? blogUrl,
    String? country,
    String? state,
    String? city,
  });
  Future<List<SocialAccount>> listSocial(String profileId);
  Future<String> startOAuth({
    required String profileId,
    required String platform,
  });
  Future<void> manualSocial({
    required String profileId,
    required String platform,
    required String handle,
  });
  Future<void> saveCategoriesPricing({
    required String profileId,
    required String mainCategory,
    List<String> secondaryCategories,
    String? audienceGender,
    List<String> ageRanges,
    List<String> monetization,
    bool openToBarter,
    bool licensingAvailable,
    String? biography,
    String? displayName,
    required List<PricingLine> pricing,
  });
  Future<ReferralInvite> createReferral({
    required String profileId,
    String? email,
  });
  Future<void> inviteManager({
    required String profileId,
    required String email,
  });
  Future<List<ReferralInvite>> listReferrals(String profileId);
  Future<void> completeOnboarding(String profileId);

  Future<void> updateProfileBasics({
    required String profileId,
    String? displayName,
    String? biography,
  });
}
