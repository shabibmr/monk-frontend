import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monk_shared/monk_shared.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/errors/error_presenter.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/referral_reward.dart';
import '../../domain/repositories/referrals_repository.dart';
import '../bloc/referral_rewards_bloc.dart';

class ReferralRewardsScreen extends StatelessWidget {
  const ReferralRewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReferralRewardsBloc(getIt<ReferralsRepository>())
        ..add(const ReferralRewardsStarted()),
      child: const _ReferralRewardsView(),
    );
  }
}

class _ReferralRewardsView extends StatelessWidget {
  const _ReferralRewardsView();

  EntityStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return EntityStatus.paidOut;
      case 'approved':
        return EntityStatus.approved;
      case 'pending':
        return EntityStatus.inProgress;
      case 'rejected':
        return EntityStatus.rejected;
      default:
        return EntityStatus.draft;
    }
  }

  String _formatAttribution(String type) {
    switch (type) {
      case 'user_signup':
        return 'User Signup';
      case 'first_deal':
        return 'First Deal Closed';
      case 'campaign_published':
        return 'Campaign Published';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Referral Rewards')),
      body: BlocConsumer<ReferralRewardsBloc, ReferralRewardsState>(
        listener: (context, state) {
          if (state.failure != null) {
            ErrorPresenter.show(context, state.failure!);
          }
        },
        builder: (context, state) {
          if (state.phase == ReferralRewardsPhase.loading ||
              state.phase == ReferralRewardsPhase.initial) {
            return ListView(
              padding: const EdgeInsets.all(ImSpacing.space24),
              children: const [
                ImSkeletonCard(),
                SizedBox(height: ImSpacing.space16),
                ImSkeletonCard(),
              ],
            );
          }

          final summary = state.summary ??
              const ReferralSummary(
                totalEarnedMinor: 0,
                pendingRewardsMinor: 0,
                totalReferralsCount: 0,
              );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(ImSpacing.space24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Referral Earnings & Attribution',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: ImSpacing.space16),

                // KPI summary card
                ImCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Paid Earnings',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: ImColors.ink600),
                            ),
                            const SizedBox(height: ImSpacing.space4),
                            ImMoneyText(
                              minorUnits: summary.totalEarnedMinor,
                              currencyCode: summary.currency,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(color: ImColors.teal700),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: ImSpacing.space12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pending Rewards',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: ImColors.ink600),
                            ),
                            const SizedBox(height: ImSpacing.space4),
                            ImMoneyText(
                              minorUnits: summary.pendingRewardsMinor,
                              currencyCode: summary.currency,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(color: ImColors.coral600),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: ImSpacing.space12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Referrals',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: ImColors.ink600),
                            ),
                            const SizedBox(height: ImSpacing.space4),
                            Text(
                              '${summary.totalReferralsCount}',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: ImSpacing.space24),
                Text(
                  'Attribution Breakdown',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: ImSpacing.space12),

                // Attribution Breakdown Widget
                _AttributionBreakdownWidget(summary: summary),

                const SizedBox(height: ImSpacing.space24),
                Text(
                  'Reward History',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: ImSpacing.space12),

                if (state.rewards.isEmpty)
                  const ImEmptyState(
                    message: 'No referral rewards recorded yet.',
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.rewards.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: ImSpacing.space12),
                    itemBuilder: (context, index) {
                      final item = state.rewards[index];
                      return ImCard(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.referredUserLabel ??
                                      'Referred User ${item.referredUserId.substring(0, 6)}',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: ImSpacing.space4),
                                Text(
                                  'Trigger: ${_formatAttribution(item.attributionType)}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                if (item.rejectionReason != null) ...[
                                  const SizedBox(height: ImSpacing.space4),
                                  Text(
                                    'Reason: ${item.rejectionReason}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: ImColors.coral600),
                                  ),
                                ],
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                ImMoneyText(
                                  minorUnits: item.rewardAmountMinor,
                                  currencyCode: item.currency,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: ImSpacing.space4),
                                ImStatusChip(
                                  status: _parseStatus(item.status),
                                  label: item.status.toUpperCase(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AttributionBreakdownWidget extends StatelessWidget {
  const _AttributionBreakdownWidget({required this.summary});
  final ReferralSummary summary;

  @override
  Widget build(BuildContext context) {
    final breakdown = summary.attributionBreakdown;
    final signupCount = breakdown['user_signup'] ?? 0;
    final dealCount = breakdown['first_deal'] ?? 0;
    final campaignCount = breakdown['campaign_published'] ?? 0;

    return Row(
      children: [
        Expanded(
          child: ImCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User Signups',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: ImSpacing.space4),
                Text(
                  '$signupCount',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: ImSpacing.space12),
        Expanded(
          child: ImCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'First Collab Deals',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: ImSpacing.space4),
                Text(
                  '$dealCount',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: ImSpacing.space12),
        Expanded(
          child: ImCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Campaign Publishes',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: ImSpacing.space4),
                Text(
                  '$campaignCount',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
