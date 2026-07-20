import 'package:dio/dio.dart';

import '../api_paths.dart';
import '../models/influencer_models.dart';

class InfluencersApi {
  InfluencersApi(this._dio);
  final Dio _dio;

  Future<InfluencerProfileDto> ensureProfile({String? displayName}) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiPaths.influencerProfiles,
      data: {
        if (displayName != null && displayName.isNotEmpty)
          'displayName': displayName,
      },
    );
    return InfluencerProfileDto.fromJson(res.data!);
  }

  Future<InfluencerProfileDto> me() async {
    final res =
        await _dio.get<Map<String, dynamic>>(ApiPaths.influencerMe);
    return InfluencerProfileDto.fromJson(res.data!);
  }

  Future<OnboardingStatusDto> onboarding() async {
    final res =
        await _dio.get<Map<String, dynamic>>(ApiPaths.influencerOnboarding);
    return OnboardingStatusDto.fromJson(res.data!);
  }

  Future<InfluencerProfileDto> patchPlatforms(
    String profileId,
    Map<String, dynamic> body,
  ) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      ApiPaths.platforms(profileId),
      data: body,
    );
    return InfluencerProfileDto.fromJson(res.data!);
  }

  Future<InfluencerProfileDto> patchCategories(
    String profileId,
    Map<String, dynamic> body,
  ) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      ApiPaths.categories(profileId),
      data: body,
    );
    return InfluencerProfileDto.fromJson(res.data!);
  }

  Future<List<PricingLineDto>> putPricing(
    String profileId,
    List<PricingLineDto> lines,
  ) async {
    final res = await _dio.put<Map<String, dynamic>>(
      ApiPaths.pricing(profileId),
      data: {'lines': lines.map((e) => e.toJson()).toList()},
    );
    final data = res.data?['data'] as List<dynamic>? ?? const [];
    return data
        .map((e) => PricingLineDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<InfluencerProfileDto> completeOnboarding(String profileId) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiPaths.onboardingComplete(profileId),
      data: {'confirm': true},
    );
    return InfluencerProfileDto.fromJson(res.data!);
  }

  Future<OAuthStartDto> startOAuth({
    required String platform,
    required String profileId,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiPaths.oauthStart(platform),
      queryParameters: {'profileId': profileId},
    );
    return OAuthStartDto.fromJson(res.data!);
  }

  Future<List<SocialAccountDto>> listSocial(String profileId) async {
    final res = await _dio.get<dynamic>(ApiPaths.socialAccounts(profileId));
    final raw = res.data;
    final list = raw is List
        ? raw
        : (raw is Map && raw['data'] is List)
            ? raw['data'] as List
            : const [];
    return list
        .map((e) => SocialAccountDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> manualSocial({
    required String profileId,
    required String platform,
    required String handle,
  }) async {
    await _dio.post<void>(
      ApiPaths.socialManual,
      queryParameters: {'profileId': profileId},
      data: {'platform': platform, 'handle': handle},
    );
  }

  Future<void> inviteManager({
    required String profileId,
    required String email,
    List<String> permissions = const ['edit_profile', 'view_earnings'],
  }) async {
    await _dio.post<void>(
      ApiPaths.profileAccess(profileId),
      data: {'email': email, 'permissions': permissions},
    );
  }

  Future<ReferralInviteDto> createReferral({
    required String profileId,
    String? inviteeEmail,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiPaths.referralInvites,
      data: {
        'profileId': profileId,
        if (inviteeEmail != null) 'inviteeEmail': inviteeEmail,
      },
    );
    return ReferralInviteDto.fromJson(res.data!);
  }

  Future<List<ReferralInviteDto>> listReferrals(String profileId) async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiPaths.referralInvites,
      queryParameters: {'profileId': profileId},
    );
    final data = res.data?['data'] as List<dynamic>? ?? const [];
    return data
        .map((e) => ReferralInviteDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
