import 'package:flutter/material.dart';
import 'package:monk_shared/monk_shared.dart';

import '../../../../core/widgets/im_button.dart';
import '../../../../core/widgets/im_card.dart';
import '../../../../core/widgets/im_money_text.dart';
import '../../../../core/widgets/im_status_chip.dart';
import '../../domain/entities/subscription_details.dart';

class ActivePlanCard extends StatelessWidget {
  const ActivePlanCard({
    super.key,
    required this.subscription,
    required this.onUpgradePressed,
  });

  final SubscriptionDetails subscription;
  final VoidCallback onUpgradePressed;

  EntityStatus _parseStatus(String s) {
    switch (s.toLowerCase()) {
      case 'active':
      case 'paid':
        return EntityStatus.approved;
      case 'pending':
      case 'trialing':
        return EntityStatus.inProgress;
      case 'canceled':
      case 'failed':
      case 'void':
        return EntityStatus.failed;
      default:
        return EntityStatus.approved;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final plan = subscription.currentPlan;

    return ImCard(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Active Subscription',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      plan.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                ImStatusChip(
                  status: _parseStatus(subscription.status),
                  label: subscription.status.toUpperCase(),
                ),
              ],
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recurring Billing Price',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        ImMoneyText(
                          minorUnits: plan.priceMinorUnits,
                          currencyCode: plan.currency,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        Text(
                          ' / ${plan.billingInterval}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Next Renewal Date',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subscription.renewsAt,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Campaign Usage: ${subscription.activeCampaignCount} / ${subscription.campaignLimit} active campaigns',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: subscription.campaignLimit > 0
                  ? (subscription.activeCampaignCount / subscription.campaignLimit).clamp(0.0, 1.0)
                  : 1.0,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ImButton(
                  label: 'Upgrade / Change Plan',
                  onPressed: onUpgradePressed,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
