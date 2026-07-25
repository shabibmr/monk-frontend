import '../../../features/referrals/domain/entities/referral_reward.dart';
import '../../../features/referrals/domain/repositories/referrals_repository.dart';
import '../../errors/failures.dart';
import '../mock_ids.dart';
import '../mock_seed_store.dart';

/// Offline demo implementation of [ReferralsRepository].
class MockReferralsRepository implements ReferralsRepository {
  MockReferralsRepository(this.store);

  final MockSeedStore store;

  static const _rewardsKey = 'referral_rewards';
  static const _summaryKey = 'referral_summary';

  void _ensureSeeded() {
    if (store.list<ReferralReward>(_rewardsKey).isNotEmpty) return;
    final now = DateTime.now();
    store.putAll(_rewardsKey, [
      ReferralReward(
        id: MockIds.referralReward1,
        referrerId: MockIds.creator1,
        referredUserId: MockIds.creatorFresh,
        referredUserLabel: 'Demo Creator Fresh',
        rewardAmountMinor: 50000,
        currency: 'INR',
        status: 'pending',
        attributionType: 'user_signup',
        createdAt: now.subtract(const Duration(days: 4)),
      ),
      ReferralReward(
        id: 'ref-reward-demo-2',
        referrerId: MockIds.creator1,
        referredUserId: 'user-demo-referred-2',
        referredUserLabel: 'Maya Lin',
        rewardAmountMinor: 100000,
        currency: 'INR',
        status: 'approved',
        attributionType: 'first_deal',
        createdAt: now.subtract(const Duration(days: 20)),
        reviewedAt: now.subtract(const Duration(days: 18)),
      ),
      ReferralReward(
        id: 'ref-reward-demo-3',
        referrerId: MockIds.brand1,
        referredUserId: MockIds.brandFresh,
        referredUserLabel: 'Fresh Brand Co',
        rewardAmountMinor: 75000,
        currency: 'INR',
        status: 'pending',
        attributionType: 'user_signup',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      ReferralReward(
        id: 'ref-reward-demo-4',
        referrerId: MockIds.creator1,
        referredUserId: 'user-demo-referred-4',
        referredUserLabel: 'Sam Chen',
        rewardAmountMinor: 150000,
        currency: 'INR',
        status: 'paid',
        attributionType: 'campaign_published',
        createdAt: now.subtract(const Duration(days: 45)),
        reviewedAt: now.subtract(const Duration(days: 40)),
      ),
    ]);
    _recomputeSummary();
  }

  void _recomputeSummary() {
    final rewards = store.list<ReferralReward>(_rewardsKey);
    final me = store.currentUserId ?? MockIds.creator1;
    final mine = rewards.where((r) => r.referrerId == me).toList();
    final earned = mine
        .where((r) => r.status == 'approved' || r.status == 'paid')
        .fold<int>(0, (sum, r) => sum + r.rewardAmountMinor);
    final pending = mine
        .where((r) => r.status == 'pending')
        .fold<int>(0, (sum, r) => sum + r.rewardAmountMinor);
    final breakdown = <String, int>{};
    for (final r in mine) {
      breakdown[r.attributionType] =
          (breakdown[r.attributionType] ?? 0) + 1;
    }
    store.singles[_summaryKey] = ReferralSummary(
      totalEarnedMinor: earned,
      pendingRewardsMinor: pending,
      totalReferralsCount: mine.length,
      currency: 'INR',
      attributionBreakdown: breakdown,
    );
  }

  @override
  Future<ReferralSummary> getReferralSummary() async {
    await store.delay();
    _ensureSeeded();
    _recomputeSummary();
    return store.singles[_summaryKey] as ReferralSummary;
  }

  @override
  Future<List<ReferralReward>> getRewards() async {
    await store.delay();
    _ensureSeeded();
    final me = store.currentUserId ?? MockIds.creator1;
    return store
        .list<ReferralReward>(_rewardsKey)
        .where((r) => r.referrerId == me)
        .toList();
  }

  @override
  Future<List<ReferralReward>> getAdminRewardQueue() async {
    await store.delay();
    _ensureSeeded();
    return store
        .list<ReferralReward>(_rewardsKey)
        .where((r) => r.status == 'pending')
        .toList();
  }

  @override
  Future<void> approveReward(String id) async {
    await store.delay();
    _ensureSeeded();
    final existing =
        store.findWhere<ReferralReward>(_rewardsKey, (r) => r.id == id);
    if (existing == null) {
      throw NotFoundFailure('Referral reward not found: $id');
    }
    if (existing.status != 'pending') {
      throw ConflictFailure(
        'Reward is not pending (current: ${existing.status}).',
      );
    }
    final updated = ReferralReward(
      id: existing.id,
      referrerId: existing.referrerId,
      referredUserId: existing.referredUserId,
      referredUserLabel: existing.referredUserLabel,
      rewardAmountMinor: existing.rewardAmountMinor,
      currency: existing.currency,
      status: 'approved',
      attributionType: existing.attributionType,
      createdAt: existing.createdAt,
      reviewedAt: DateTime.now(),
      rejectionReason: null,
    );
    store.replaceWhere<ReferralReward>(_rewardsKey, (r) => r.id == id, updated);
    _recomputeSummary();
  }

  @override
  Future<void> rejectReward(String id, {required String reason}) async {
    await store.delay();
    _ensureSeeded();
    if (reason.trim().isEmpty) {
      throw const ValidationFailure('Rejection reason is required.');
    }
    final existing =
        store.findWhere<ReferralReward>(_rewardsKey, (r) => r.id == id);
    if (existing == null) {
      throw NotFoundFailure('Referral reward not found: $id');
    }
    if (existing.status != 'pending') {
      throw ConflictFailure(
        'Reward is not pending (current: ${existing.status}).',
      );
    }
    final updated = ReferralReward(
      id: existing.id,
      referrerId: existing.referrerId,
      referredUserId: existing.referredUserId,
      referredUserLabel: existing.referredUserLabel,
      rewardAmountMinor: existing.rewardAmountMinor,
      currency: existing.currency,
      status: 'rejected',
      attributionType: existing.attributionType,
      createdAt: existing.createdAt,
      reviewedAt: DateTime.now(),
      rejectionReason: reason,
    );
    store.replaceWhere<ReferralReward>(_rewardsKey, (r) => r.id == id, updated);
    _recomputeSummary();
  }
}
