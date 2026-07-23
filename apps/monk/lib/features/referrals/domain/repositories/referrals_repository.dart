import '../entities/referral_reward.dart';

abstract class ReferralsRepository {
  Future<ReferralSummary> getReferralSummary();
  Future<List<ReferralReward>> getRewards();
  Future<List<ReferralReward>> getAdminRewardQueue();
  Future<void> approveReward(String id);
  Future<void> rejectReward(String id, {required String reason});
}
