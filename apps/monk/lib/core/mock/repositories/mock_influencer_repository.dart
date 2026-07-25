import 'package:monk_shared/monk_shared.dart';

import '../../../features/onboarding_influencer/domain/entities/onboarding.dart';
import '../../../features/onboarding_influencer/domain/repositories/influencer_repository.dart';
import '../../errors/failures.dart';
import '../mock_ids.dart';
import '../mock_seed_store.dart';

/// Offline demo implementation of [InfluencerRepository].
///
/// Store keys (aligned with `seed_profiles.dart`):
/// - `onboarding_statuses` → `List<OnboardingStatus>`
/// - `social_accounts` → `List<SocialAccount>`
/// - `pricing_lines` → `List<PricingLine>`
/// - `referral_invites` → `List<ReferralInvite>` (mutations)
class MockInfluencerRepository implements InfluencerRepository {
  MockInfluencerRepository({required MockSeedStore store}) : _store = store;

  final MockSeedStore _store;

  static const onboardingKey = 'onboarding_statuses';
  static const socialKey = 'social_accounts';
  static const pricingKey = 'pricing_lines';
  static const referralsKey = 'referral_invites';

  @override
  Future<OnboardingStatus> loadOnboarding() async {
    await _store.delay();
    final profileId = _resolveProfileId(createIfMissing: true);

    final existing = _store.findWhere<OnboardingStatus>(
      onboardingKey,
      (o) => o.profileId == profileId,
    );
    if (existing != null) return existing;

    final account = _currentAccount();
    final completed = account?.influencerOnboardingComplete ?? false;
    final status = completed
        ? OnboardingStatus(
            profileId: profileId,
            progress: const OnboardingProgress(
              step1: true,
              step2: true,
              step3: true,
              step4: true,
              step5: true,
              step6: true,
            ),
            nextStep: 7,
            completed: true,
            verificationStatus: 'approved',
          )
        : OnboardingStatus(
            profileId: profileId,
            progress: const OnboardingProgress(step1: true),
            nextStep: 2,
            completed: false,
          );
    _store.add(onboardingKey, status);
    return status;
  }

  @override
  Future<void> ensureProfile({String? displayName}) async {
    await _store.delay();
    final profileId = _resolveProfileId(createIfMissing: true);
    final account = _currentAccount();
    if (account != null && account.profileId == null) {
      _store.registerAccount(
        DemoAccount(
          user: account.user,
          password: account.password,
          brandId: account.brandId,
          profileId: profileId,
          profileName: displayName ?? account.profileName ?? account.user.fullName,
          brandOnboardingComplete: account.brandOnboardingComplete,
          influencerOnboardingComplete: account.influencerOnboardingComplete,
          isManagerContext: account.isManagerContext,
          managerPermissions: account.managerPermissions,
        ),
      );
    }

    final onboarding = _store.findWhere<OnboardingStatus>(
      onboardingKey,
      (o) => o.profileId == profileId,
    );
    if (onboarding == null) {
      _store.add(
        onboardingKey,
        OnboardingStatus(
          profileId: profileId,
          progress: const OnboardingProgress(step1: true),
          nextStep: 2,
          completed: false,
        ),
      );
    } else if (!onboarding.progress.step1) {
      _markStep(profileId, 1);
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
    await _store.delay();
    _touchProfile(profileId);
    _store.singles['platforms_$profileId'] = {
      'primaryPlatform': primaryPlatform,
      if (secondaryPlatform != null) 'secondaryPlatform': secondaryPlatform,
      if (mainRegion != null) 'mainRegion': mainRegion,
      if (secondaryRegion != null) 'secondaryRegion': secondaryRegion,
      if (blogUrl != null) 'blogUrl': blogUrl,
      if (country != null) 'country': country,
      if (state != null) 'state': state,
      if (city != null) 'city': city,
    };
    _markStep(profileId, 2);
  }

  @override
  Future<List<SocialAccount>> listSocial(String profileId) async {
    await _store.delay();
    // Seed stores a flat catalog for the primary creator; return as-is for demo.
    return _store.list<SocialAccount>(socialKey);
  }

  @override
  Future<String> startOAuth({
    required String profileId,
    required String platform,
  }) async {
    await _store.delay();
    _touchProfile(profileId);
    return 'https://demo.influencersmonk.local/oauth/$platform'
        '?profileId=$profileId&mock=1';
  }

  @override
  Future<void> manualSocial({
    required String profileId,
    required String platform,
    required String handle,
  }) async {
    await _store.delay();
    _touchProfile(profileId);
    if (handle.trim().isEmpty) {
      throw const ValidationFailure('handle is required');
    }
    _store.add(
      socialKey,
      SocialAccount(
        id: 'social-${DateTime.now().millisecondsSinceEpoch}',
        platform: platform,
        handle: handle.trim(),
        followersCount: 12000,
        declaredOnly: true,
      ),
    );
    _markStep(profileId, 3);
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
    await _store.delay();
    _touchProfile(profileId);
    _store.singles['categories_$profileId'] = {
      'mainCategory': mainCategory,
      'secondaryCategories': secondaryCategories,
      if (audienceGender != null) 'audienceGender': audienceGender,
      'ageRanges': ageRanges,
      'monetization': monetization,
      'openToBarter': openToBarter,
      'licensingAvailable': licensingAvailable,
      if (biography != null) 'biography': biography,
      if (displayName != null) 'displayName': displayName,
    };
    if (pricing.isNotEmpty) {
      // Replace catalog with latest pricing for demo simplicity.
      _store.putAll(pricingKey, pricing);
    }
    _markStep(profileId, 4);
  }

  @override
  Future<ReferralInvite> createReferral({
    required String profileId,
    String? email,
  }) async {
    await _store.delay();
    _touchProfile(profileId);
    final invite = ReferralInvite(
      id: 'ref-${DateTime.now().millisecondsSinceEpoch}',
      code: 'DEMO${profileId.hashCode.abs() % 10000}',
      inviteeEmail: email,
      note: 'Mock referral invite',
    );
    _store.add(referralsKey, invite);
    _markStep(profileId, 5);
    return invite;
  }

  @override
  Future<void> inviteManager({
    required String profileId,
    required String email,
  }) async {
    await _store.delay();
    _touchProfile(profileId);
    if (email.trim().isEmpty) {
      throw const ValidationFailure('email is required');
    }
    final key = 'manager_invites_$profileId';
    final existing = (_store.singles[key] as List?) ?? <dynamic>[];
    _store.singles[key] = [
      ...existing,
      {'email': email.trim().toLowerCase(), 'status': 'pending'},
    ];
  }

  @override
  Future<List<ReferralInvite>> listReferrals(String profileId) async {
    await _store.delay();
    return _store.list<ReferralInvite>(referralsKey);
  }

  @override
  Future<void> completeOnboarding(String profileId) async {
    await _store.delay();
    _touchProfile(profileId);
    final completed = OnboardingStatus(
      profileId: profileId,
      progress: const OnboardingProgress(
        step1: true,
        step2: true,
        step3: true,
        step4: true,
        step5: true,
        step6: true,
      ),
      nextStep: 7,
      completed: true,
      verificationStatus: 'approved',
    );
    _store.replaceWhere<OnboardingStatus>(
      onboardingKey,
      (o) => o.profileId == profileId,
      completed,
    );

    final account = _currentAccount();
    if (account != null) {
      _store.registerAccount(
        DemoAccount(
          user: account.user,
          password: account.password,
          brandId: account.brandId,
          profileId: profileId,
          profileName: account.profileName,
          brandOnboardingComplete: account.brandOnboardingComplete,
          influencerOnboardingComplete: true,
          isManagerContext: account.isManagerContext,
          managerPermissions: account.managerPermissions,
        ),
      );
    }
  }

  @override
  Future<void> updateProfileBasics({
    required String profileId,
    String? displayName,
    String? biography,
  }) async {
    await _store.delay();
    _touchProfile(profileId);
    final prev =
        (_store.singles['categories_$profileId'] as Map?)?.cast<String, dynamic>() ??
            <String, dynamic>{};
    _store.singles['categories_$profileId'] = {
      ...prev,
      if (displayName != null) 'displayName': displayName,
      if (biography != null) 'biography': biography,
    };

    final account = _currentAccount();
    if (account != null &&
        displayName != null &&
        account.profileId == profileId) {
      _store.registerAccount(
        DemoAccount(
          user: account.user,
          password: account.password,
          brandId: account.brandId,
          profileId: account.profileId,
          profileName: displayName,
          brandOnboardingComplete: account.brandOnboardingComplete,
          influencerOnboardingComplete: account.influencerOnboardingComplete,
          isManagerContext: account.isManagerContext,
          managerPermissions: account.managerPermissions,
        ),
      );
    }
  }

  DemoAccount? _currentAccount() {
    final id = _store.currentUserId;
    if (id == null) return null;
    return _store.findAccountById(id);
  }

  String _resolveProfileId({required bool createIfMissing}) {
    final account = _currentAccount();
    if (account?.profileId != null) return account!.profileId!;

    // Seed maps incomplete creator onboarding to the user id.
    if (account != null) {
      final byUser = _store.findWhere<OnboardingStatus>(
        onboardingKey,
        (o) => o.profileId == account.user.id,
      );
      if (byUser != null) return account.user.id;
    }

    if (account != null &&
        account.user.role == UserRole.influencer &&
        account.influencerOnboardingComplete) {
      return MockIds.influencer1;
    }

    if (account != null && account.user.id == MockIds.creatorFresh) {
      return MockIds.creatorFresh;
    }

    if (!createIfMissing) {
      throw const NotFoundFailure('Influencer profile not found');
    }

    return account?.user.id ??
        'inf-demo-${DateTime.now().millisecondsSinceEpoch}';
  }

  void _touchProfile(String profileId) {
    if (profileId.isEmpty) {
      throw const NotFoundFailure('Influencer profile not found');
    }
  }

  void _markStep(String profileId, int step) {
    final current = _store.findWhere<OnboardingStatus>(
      onboardingKey,
      (o) => o.profileId == profileId,
    );
    if (current?.completed == true) return;

    final p = current?.progress ?? const OnboardingProgress();
    final next = OnboardingProgress(
      step1: p.step1 || step >= 1,
      step2: p.step2 || step >= 2,
      step3: p.step3 || step >= 3,
      step4: p.step4 || step >= 4,
      step5: p.step5 || step >= 5,
      step6: p.step6 || step >= 6,
    );
    final completed = next.completedSteps.length >= 6;
    final nextStep = completed
        ? 7
        : ([1, 2, 3, 4, 5, 6].firstWhere(
            (s) => !next.completedSteps.contains(s),
            orElse: () => 7,
          ));
    _store.replaceWhere<OnboardingStatus>(
      onboardingKey,
      (o) => o.profileId == profileId,
      OnboardingStatus(
        profileId: profileId,
        progress: next,
        nextStep: nextStep,
        completed: completed,
        verificationStatus: current?.verificationStatus,
      ),
    );
  }
}
