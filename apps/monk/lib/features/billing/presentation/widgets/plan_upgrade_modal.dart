import 'package:flutter/material.dart';

import '../../../../core/widgets/im_button.dart';
import '../../../../core/widgets/im_card.dart';
import '../../../../core/widgets/im_money_text.dart';
import '../../domain/entities/subscription_plan.dart';

class PlanUpgradeModal extends StatelessWidget {
  const PlanUpgradeModal({
    super.key,
    required this.plans,
    required this.currentPlanId,
    required this.onSelectPlan,
    this.isSubmitting = false,
  });

  final List<SubscriptionPlan> plans;
  final String currentPlanId;
  final ValueChanged<String> onSelectPlan;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 650),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Choose Subscription Plan',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Select a plan that best fits your brand or organization needs. Multi-currency pricing is automatically formatted based on your billing region.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: plans.map((plan) {
                    final isCurrent = plan.id == currentPlanId;
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: ImCard(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (plan.isRecommended)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'RECOMMENDED',
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: theme.colorScheme.onPrimaryContainer,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 8),
                                Text(
                                  plan.name,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ImMoneyText(
                                  minorUnits: plan.priceMinorUnits,
                                  currencyCode: plan.currency,
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                Text(
                                  'per ${plan.billingInterval}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const Divider(height: 24),
                                ...plan.features.map(
                                  (f) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle_outline,
                                          size: 16,
                                          color: theme.colorScheme.primary,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            f,
                                            style: theme.textTheme.bodySmall,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ImButton(
                                    label: isCurrent ? 'Current Plan' : 'Select Plan',
                                    variant: isCurrent
                                        ? ImButtonVariant.secondary
                                        : ImButtonVariant.primary,
                                    loading: isSubmitting,
                                    onPressed: isCurrent
                                        ? null
                                        : () => onSelectPlan(plan.id),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
