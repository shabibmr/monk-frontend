import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monk_shared/monk_shared.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/errors/error_presenter.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/repositories/referrals_repository.dart';
import '../bloc/referral_rewards_bloc.dart';

class AdminReferralsScreen extends StatelessWidget {
  const AdminReferralsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReferralRewardsBloc(getIt<ReferralsRepository>())
        ..add(const ReferralAdminQueueStarted()),
      child: const _AdminReferralsView(),
    );
  }
}

class _AdminReferralsView extends StatelessWidget {
  const _AdminReferralsView();

  void _showRejectDialog(BuildContext context, String rewardId) {
    final reasonController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Reject Referral Reward'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please state the reason for rejecting this reward:'),
              const SizedBox(height: ImSpacing.space12),
              ImTextField(
                label: 'Rejection Reason',
                controller: reasonController,
                hint: 'e.g. Invalid referral, self-referral detected',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ImButton(
              label: 'Reject Reward',
              variant: ImButtonVariant.destructive,
              onPressed: () {
                final reason = reasonController.text.trim();
                if (reason.isEmpty) return;
                Navigator.of(dialogContext).pop();
                context.read<ReferralRewardsBloc>().add(
                      ReferralRewardRejected(id: rewardId, reason: reason),
                    );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin — Referral Rewards Queue')),
      body: BlocConsumer<ReferralRewardsBloc, ReferralRewardsState>(
        listener: (context, state) {
          if (state.failure != null) {
            ErrorPresenter.show(context, state.failure!);
          }
          if (state.actionSuccess != null) {
            ImToast.show(
              context,
              message: state.actionSuccess!,
              tone: ImToastTone.success,
            );
          }
        },
        builder: (context, state) {
          if (state.phase == ReferralRewardsPhase.loading ||
              state.phase == ReferralRewardsPhase.initial) {
            return ListView.separated(
              padding: const EdgeInsets.all(ImSpacing.space24),
              itemCount: 4,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: ImSpacing.space12),
              itemBuilder: (context, index) => const ImSkeletonCard(),
            );
          }

          if (state.adminQueue.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(ImSpacing.space24),
              child: ImEmptyState(
                message: 'No pending referral rewards in the queue.',
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(ImSpacing.space24),
            itemCount: state.adminQueue.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: ImSpacing.space12),
            itemBuilder: (context, index) {
              final reward = state.adminQueue[index];
              return ImCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Referrer ID: ${reward.referrerId}',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: ImSpacing.space4),
                              Text(
                                'Referred User: ${reward.referredUserLabel ?? reward.referredUserId}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            ImMoneyText(
                              minorUnits: reward.rewardAmountMinor,
                              currencyCode: reward.currency,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: ImColors.teal700,
                                  ),
                            ),
                            const SizedBox(height: ImSpacing.space4),
                            ImStatusChip(
                              status: reward.status.toLowerCase() == 'pending'
                                  ? EntityStatus.inProgress
                                  : EntityStatus.completed,
                              label: reward.status.toUpperCase(),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: ImSpacing.space12),
                    Text(
                      'Trigger Event: ${reward.attributionType}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: ImColors.ink600,
                          ),
                    ),
                    const SizedBox(height: ImSpacing.space16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ImButton(
                          label: 'Reject',
                          variant: ImButtonVariant.destructive,
                          onPressed: () => _showRejectDialog(context, reward.id),
                        ),
                        const SizedBox(width: ImSpacing.space12),
                        ImButton(
                          label: 'Approve Payout',
                          onPressed: () {
                            context.read<ReferralRewardsBloc>().add(
                                  ReferralRewardApproved(reward.id),
                                );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
