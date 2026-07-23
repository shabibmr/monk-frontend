import 'package:api_client/api_client.dart';

import '../../../../core/network/error_mapper.dart';
import '../../domain/entities/referral_reward.dart';
import '../../domain/repositories/referrals_repository.dart';

class ReferralsRepositoryImpl implements ReferralsRepository {
  ReferralsRepositoryImpl(this._client);
  final MonkApiClient _client;

  @override
  Future<ReferralSummary> getReferralSummary() async {
    try {
      final res = await _client.dio.get<Map<String, dynamic>>(
        '${ApiPaths.referralRewards}/summary',
      );
      if (res.data != null) {
        return ReferralSummary.fromJson(res.data!);
      }
      return const ReferralSummary(
        totalEarnedMinor: 0,
        pendingRewardsMinor: 0,
        totalReferralsCount: 0,
      );
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<List<ReferralReward>> getRewards() async {
    try {
      final res = await _client.dio.get<dynamic>(ApiPaths.referralRewards);
      final raw = res.data;
      final list = raw is List
          ? raw
          : (raw is Map && raw['data'] is List)
              ? raw['data'] as List
              : const [];
      return list
          .map((e) => ReferralReward.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<List<ReferralReward>> getAdminRewardQueue() async {
    try {
      final res = await _client.dio.get<dynamic>(ApiPaths.adminReferralRewards);
      final raw = res.data;
      final list = raw is List
          ? raw
          : (raw is Map && raw['data'] is List)
              ? raw['data'] as List
              : const [];
      return list
          .map((e) => ReferralReward.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<void> approveReward(String id) async {
    try {
      await _client.dio.post<void>(
        '${ApiPaths.adminReferralRewards}/$id/approve',
      );
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<void> rejectReward(String id, {required String reason}) async {
    try {
      await _client.dio.post<void>(
        '${ApiPaths.adminReferralRewards}/$id/reject',
        data: {'reason': reason},
      );
    } catch (e) {
      throw mapError(e);
    }
  }
}
