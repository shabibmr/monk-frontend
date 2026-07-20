import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:monk_web/core/errors/failures.dart';
import 'package:monk_web/features/referrals/domain/entities/referral_reward.dart';
import 'package:monk_web/features/referrals/domain/repositories/referrals_repository.dart';
import 'package:monk_web/features/referrals/presentation/bloc/referral_rewards_bloc.dart';

class _MockReferralsRepo extends Mock implements ReferralsRepository {}

void main() {
  late _MockReferralsRepo repo;

  const summary = ReferralSummary(
    totalEarnedMinor: 100000,
    pendingRewardsMinor: 25000,
    totalReferralsCount: 5,
    currency: 'INR',
    attributionBreakdown: {'user_signup': 3, 'first_deal': 2},
  );

  const rewardItem = ReferralReward(
    id: 'rew-1',
    referrerId: 'user-1',
    referredUserId: 'user-2',
    rewardAmountMinor: 25000,
    currency: 'INR',
    status: 'pending',
    attributionType: 'user_signup',
  );

  setUp(() {
    repo = _MockReferralsRepo();
  });

  group('ReferralRewardsBloc', () {
    blocTest<ReferralRewardsBloc, ReferralRewardsState>(
      'loads summary and rewards on ReferralRewardsStarted',
      build: () {
        when(() => repo.getReferralSummary()).thenAnswer((_) async => summary);
        when(() => repo.getRewards()).thenAnswer((_) async => [rewardItem]);
        return ReferralRewardsBloc(repo);
      },
      act: (bloc) => bloc.add(const ReferralRewardsStarted()),
      expect: () => [
        isA<ReferralRewardsState>()
            .having((s) => s.phase, 'phase', ReferralRewardsPhase.loading),
        isA<ReferralRewardsState>()
            .having((s) => s.phase, 'phase', ReferralRewardsPhase.ready)
            .having((s) => s.summary, 'summary', summary)
            .having((s) => s.rewards.length, 'rewards.length', 1),
      ],
    );

    blocTest<ReferralRewardsBloc, ReferralRewardsState>(
      'loads admin queue on ReferralAdminQueueStarted',
      build: () {
        when(() => repo.getAdminRewardQueue())
            .thenAnswer((_) async => [rewardItem]);
        return ReferralRewardsBloc(repo);
      },
      act: (bloc) => bloc.add(const ReferralAdminQueueStarted()),
      expect: () => [
        isA<ReferralRewardsState>()
            .having((s) => s.phase, 'phase', ReferralRewardsPhase.loading),
        isA<ReferralRewardsState>()
            .having((s) => s.phase, 'phase', ReferralRewardsPhase.ready)
            .having((s) => s.adminQueue.length, 'adminQueue.length', 1),
      ],
    );

    blocTest<ReferralRewardsBloc, ReferralRewardsState>(
      'approves reward and triggers admin queue reload',
      build: () {
        when(() => repo.approveReward('rew-1')).thenAnswer((_) async {});
        when(() => repo.getAdminRewardQueue()).thenAnswer((_) async => const []);
        return ReferralRewardsBloc(repo);
      },
      act: (bloc) => bloc.add(const ReferralRewardApproved('rew-1')),
      expect: () => [
        isA<ReferralRewardsState>()
            .having((s) => s.actionSuccess, 'actionSuccess', 'Reward approved'),
        isA<ReferralRewardsState>()
            .having((s) => s.phase, 'phase', ReferralRewardsPhase.loading),
        isA<ReferralRewardsState>()
            .having((s) => s.phase, 'phase', ReferralRewardsPhase.ready)
            .having((s) => s.adminQueue, 'adminQueue', isEmpty),
      ],
      verify: (_) {
        verify(() => repo.approveReward('rew-1')).called(1);
      },
    );

    blocTest<ReferralRewardsBloc, ReferralRewardsState>(
      'rejects reward with reason and reloads admin queue',
      build: () {
        when(() => repo.rejectReward('rew-1', reason: 'Duplicate referral'))
            .thenAnswer((_) async {});
        when(() => repo.getAdminRewardQueue()).thenAnswer((_) async => const []);
        return ReferralRewardsBloc(repo);
      },
      act: (bloc) => bloc.add(
        const ReferralRewardRejected(
          id: 'rew-1',
          reason: 'Duplicate referral',
        ),
      ),
      expect: () => [
        isA<ReferralRewardsState>()
            .having((s) => s.actionSuccess, 'actionSuccess', 'Reward rejected'),
        isA<ReferralRewardsState>()
            .having((s) => s.phase, 'phase', ReferralRewardsPhase.loading),
        isA<ReferralRewardsState>()
            .having((s) => s.phase, 'phase', ReferralRewardsPhase.ready),
      ],
      verify: (_) {
        verify(
          () => repo.rejectReward('rew-1', reason: 'Duplicate referral'),
        ).called(1);
      },
    );

    blocTest<ReferralRewardsBloc, ReferralRewardsState>(
      'emits failure on error',
      build: () {
        when(() => repo.getReferralSummary())
            .thenThrow(const ServerFailure('Failed to fetch summary'));
        return ReferralRewardsBloc(repo);
      },
      act: (bloc) => bloc.add(const ReferralRewardsStarted()),
      expect: () => [
        isA<ReferralRewardsState>()
            .having((s) => s.phase, 'phase', ReferralRewardsPhase.loading),
        isA<ReferralRewardsState>()
            .having((s) => s.phase, 'phase', ReferralRewardsPhase.failure)
            .having((s) => s.failure?.message, 'message', 'Failed to fetch summary'),
      ],
    );
  });
}
