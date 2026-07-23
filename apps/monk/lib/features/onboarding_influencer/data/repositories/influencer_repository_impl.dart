import 'package:api_client/api_client.dart';

import '../../../../core/network/error_mapper.dart';
import '../../domain/entities/onboarding.dart';
import '../../domain/repositories/influencer_repository.dart';

class InfluencerRepositoryImpl implements InfluencerRepository {
  InfluencerRepositoryImpl(this._client);
  final MonkApiClient _client;

  @override
  Future<OnboardingStatus> loadOnboarding() async {
    try {
      // Ensure shell exists (step 1).
      await _client.influencers.ensureProfile();
      final s = await _client.influencers.onboarding();
      return OnboardingStatus(
        profileId: s.profileId,
        progress: OnboardingProgress(
          step1: s.progress.step1,
          step2: s.progress.step2,
          step3: s.progress.step3,
          step4: s.progress.step4,
          step5: s.progress.step5,
          step6: s.progress.step6,
        ),
        nextStep: s.nextStep == 0 ? 6 : s.nextStep,
        completed: s.completed,
        verificationStatus: s.verificationStatus,
      );
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<void> ensureProfile({String? displayName}) async {
    try {
      await _client.influencers.ensureProfile(displayName: displayName);
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
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
  }) async {
    try {
      await _client.influencers.patchPlatforms(profileId, {
        'primaryPlatform': primaryPlatform,
        if (secondaryPlatform != null) 'secondaryPlatform': secondaryPlatform,
        if (mainRegion != null) 'mainRegionOfInfluence': mainRegion,
        if (secondaryRegion != null)
          'secondaryRegionOfInfluence': secondaryRegion,
        if (blogUrl != null) 'blogUrl': blogUrl,
        if (country != null) 'country': country,
        if (state != null) 'state': state,
        if (city != null) 'city': city,
      });
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<List<SocialAccount>> listSocial(String profileId) async {
    try {
      final list = await _client.influencers.listSocial(profileId);
      return list
          .map(
            (e) => SocialAccount(
              id: e.id,
              platform: e.platform,
              handle: e.handle,
              followersCount: e.followersCount,
              declaredOnly: e.declaredOnly,
            ),
          )
          .toList();
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<String> startOAuth({
    required String profileId,
    required String platform,
  }) async {
    try {
      final res = await _client.influencers.startOAuth(
        platform: platform,
        profileId: profileId,
      );
      return res.authorizationUrl;
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<void> manualSocial({
    required String profileId,
    required String platform,
    required String handle,
  }) async {
    try {
      await _client.influencers.manualSocial(
        profileId: profileId,
        platform: platform,
        handle: handle,
      );
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<void> saveCategoriesPricing({
    required String profileId,
    required String mainCategory,
    List<String> secondaryCategories = const [],
    String? audienceGender,
    List<String> ageRanges = const [],
    List<String> monetization = const [],
    bool openToBarter = false,
    bool licensingAvailable = false,
    String? biography,
    String? displayName,
    required List<PricingLine> pricing,
  }) async {
    try {
      await _client.influencers.patchCategories(profileId, {
        'mainCategoryName': mainCategory,
        if (secondaryCategories.isNotEmpty)
          'secondaryCategoryNames': secondaryCategories,
        if (audienceGender != null) 'audienceGender': audienceGender,
        if (ageRanges.isNotEmpty) 'audienceAgeRanges': ageRanges,
        if (monetization.isNotEmpty) 'monetizationMethods': monetization,
        'openToBarter': openToBarter,
        'licensingAvailable': licensingAvailable,
        if (biography != null) 'biography': biography,
        if (displayName != null) 'displayName': displayName,
      });
      await _client.influencers.putPricing(
        profileId,
        pricing
            .map(
              (p) => PricingLineDto(
                deliverableType: p.deliverableType,
                priceMinor: p.priceMinor,
                currency: p.currency,
              ),
            )
            .toList(),
      );
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<ReferralInvite> createReferral({
    required String profileId,
    String? email,
  }) async {
    try {
      final r = await _client.influencers.createReferral(
        profileId: profileId,
        inviteeEmail: email,
      );
      return ReferralInvite(
        id: r.id,
        code: r.code,
        inviteeEmail: r.inviteeEmail,
        note: r.note,
      );
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<void> inviteManager({
    required String profileId,
    required String email,
  }) async {
    try {
      await _client.influencers.inviteManager(
        profileId: profileId,
        email: email,
      );
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<List<ReferralInvite>> listReferrals(String profileId) async {
    try {
      final list = await _client.influencers.listReferrals(profileId);
      return list
          .map(
            (r) => ReferralInvite(
              id: r.id,
              code: r.code,
              inviteeEmail: r.inviteeEmail,
              note: r.note,
            ),
          )
          .toList();
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<void> completeOnboarding(String profileId) async {
    try {
      await _client.influencers.completeOnboarding(profileId);
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<void> updateProfileBasics({
    required String profileId,
    String? displayName,
    String? biography,
  }) async {
    try {
      await _client.influencers.patchCategories(profileId, {
        if (displayName != null) 'displayName': displayName,
        if (biography != null) 'biography': biography,
      });
    } catch (e) {
      throw mapError(e);
    }
  }
}
