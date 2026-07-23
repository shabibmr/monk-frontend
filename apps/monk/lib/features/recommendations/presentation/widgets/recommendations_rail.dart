import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monk_shared/monk_shared.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/im_button.dart';
import '../../../../core/widgets/im_card.dart';
import '../../../../core/widgets/im_empty_state.dart';
import '../../../../core/widgets/im_money_text.dart';
import '../../../../core/widgets/im_skeleton.dart';
import '../../../../core/widgets/im_status_chip.dart';

import '../../domain/entities/recommendation.dart';
import '../bloc/recommendations_bloc.dart';

class RecommendationsRail extends StatelessWidget {
  const RecommendationsRail({
    super.key,
    this.title = 'Recommended for You',
    this.onSelectRecommendation,
  });

  final String title;
  final ValueChanged<Recommendation>? onSelectRecommendation;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecommendationsBloc, RecommendationsState>(
      builder: (context, state) {
        if (state.status == RecommendationsStatus.loading ||
            state.status == RecommendationsStatus.initial) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: ImSpacing.space16),
              SizedBox(
                height: 220,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 4,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: ImSpacing.space16),
                  itemBuilder: (_, __) => const SizedBox(
                    width: 260,
                    child: ImSkeleton(height: 220, width: 260),
                  ),
                ),
              ),
            ],
          );
        }

        if (state.status == RecommendationsStatus.empty ||
            state.recommendations.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: ImSpacing.space16),
              const ImEmptyState(
                message: 'No recommendations available at this time.',
              ),
            ],
          );
        }

        if (state.status == RecommendationsStatus.error) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: ImSpacing.space16),
              ImCard(
                child: Text(
                  state.failure?.message ?? 'Failed to load recommendations',
                  style: const TextStyle(color: ImColors.danger600),
                ),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  '${state.recommendations.length} items',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: ImColors.ink500,
                      ),
                ),
              ],
            ),
            const SizedBox(height: ImSpacing.space16),
            SizedBox(
              height: 240,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: state.recommendations.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: ImSpacing.space16),
                itemBuilder: (context, index) {
                  final item = state.recommendations[index];
                  return SizedBox(
                    width: 280,
                    child: _RecommendationCard(
                      recommendation: item,
                      onTap: () => onSelectRecommendation?.call(item),
                      onDismiss: () {
                        context.read<RecommendationsBloc>().add(
                              DismissRecommendationRequested(item.id),
                            );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({
    required this.recommendation,
    this.onTap,
    this.onDismiss,
  });

  final Recommendation recommendation;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    return ImCard(
      onTap: onTap,
      padding: const EdgeInsets.all(ImSpacing.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: ImColors.ink100,
                backgroundImage: recommendation.avatarUrl != null
                    ? NetworkImage(recommendation.avatarUrl!)
                    : null,
                child: recommendation.avatarUrl == null
                    ? Icon(
                        recommendation.type == RecommendationType.creator
                            ? Icons.person
                            : Icons.campaign,
                        color: ImColors.ink700,
                      )
                    : null,
              ),
              const SizedBox(width: ImSpacing.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recommendation.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      recommendation.subtitle,
                      style: const TextStyle(
                        color: ImColors.ink500,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (onDismiss != null)
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: onDismiss,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 16,
                ),
            ],
          ),
          const SizedBox(height: ImSpacing.space12),
          Row(
            children: [
              ImStatusChip(
                status: EntityStatus.verified,
                label: recommendation.type.name.toUpperCase(),
              ),
              const Spacer(),
              if (recommendation.matchScore != null)
                Text(
                  recommendation.matchScoreLabel,
                  style: const TextStyle(
                    color: ImColors.primary700,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          if (recommendation.tags.isNotEmpty) ...[
            const SizedBox(height: ImSpacing.space12),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: recommendation.tags
                  .take(3)
                  .map(
                    (t) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: ImColors.ink100,
                        borderRadius: BorderRadius.circular(ImRadii.radiusSm),
                      ),
                      child: Text(
                        '#$t',
                        style: const TextStyle(
                          fontSize: 11,
                          color: ImColors.ink700,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (recommendation.estimatedBudget != null)
                ImMoneyText(
                  amount: recommendation.estimatedBudget!,
                  currency: recommendation.currency ?? 'USD',
                )
              else
                const SizedBox.shrink(),
              ImButton(
                label: 'View',
                variant: ImButtonVariant.tertiary,
                onPressed: onTap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
