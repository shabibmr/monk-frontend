import 'package:flutter/material.dart';
import 'package:monk_shared/monk_shared.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/creator_demographics.dart';

class CreatorDemographicsCard extends StatelessWidget {
  const CreatorDemographicsCard({
    super.key,
    required this.demographics,
    this.isLoading = false,
  });

  final CreatorDemographics demographics;
  final bool isLoading;

  EntityStatus _fakeFollowerStatus(num score) {
    if (score < 15) return EntityStatus.verified;
    if (score < 35) return EntityStatus.inProgress;
    return EntityStatus.rejected;
  }

  String _fakeFollowerLabel(num score) {
    if (score < 15) return 'Low Risk (${score.toStringAsFixed(0)}% fake)';
    if (score < 35) return 'Medium Risk (${score.toStringAsFixed(0)}% fake)';
    return 'High Risk (${score.toStringAsFixed(0)}% fake)';
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const ImSkeletonCard();
    }

    final theme = Theme.of(context);

    return ImCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Audience Demographics & Authenticity',
                style: theme.textTheme.titleMedium,
              ),
              ImStatusChip(
                status: EntityStatus.verified,
                label: 'Grade ${demographics.credibilityGrade}',
              ),
            ],
          ),
          const SizedBox(height: ImSpacing.space16),
          Row(
            children: [
              Expanded(
                child: _ScoreBox(
                  label: 'Creator Score',
                  value: '${demographics.creatorScore.toStringAsFixed(1)} / 100',
                  color: ImColors.teal700,
                ),
              ),
              const SizedBox(width: ImSpacing.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Audience Integrity',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: ImColors.ink600,
                      ),
                    ),
                    const SizedBox(height: ImSpacing.space4),
                    ImStatusChip(
                      status: _fakeFollowerStatus(demographics.fakeFollowerScore),
                      label: _fakeFollowerLabel(demographics.fakeFollowerScore),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: ImSpacing.space16),
          const Divider(),
          const SizedBox(height: ImSpacing.space12),
          Text(
            'Gender Breakdown',
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: ImSpacing.space8),
          ...demographics.genderBreakdown.entries.map((e) {
            final pct = e.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: ImSpacing.space8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        e.key[0].toUpperCase() + e.key.substring(1),
                        style: theme.textTheme.bodyMedium,
                      ),
                      Text(
                        '${pct.toStringAsFixed(1)}%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: ImSpacing.space4),
                  LinearProgressIndicator(
                    value: pct / 100.0,
                    backgroundColor: ImColors.cream100,
                    color: e.key.toLowerCase() == 'female'
                        ? ImColors.coral500
                        : ImColors.teal700,
                    minHeight: 6,
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: ImSpacing.space12),
          Text(
            'Age Distribution',
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: ImSpacing.space8),
          ...demographics.ageBreakdown.entries.map((e) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 60,
                    child: Text(
                      e.key,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: e.value / 100.0,
                      backgroundColor: ImColors.cream100,
                      color: ImColors.teal700,
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(width: ImSpacing.space8),
                  SizedBox(
                    width: 45,
                    child: Text(
                      '${e.value.toStringAsFixed(0)}%',
                      textAlign: TextAlign.end,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: ImSpacing.space12),
          Text(
            'Top Audience Locations',
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: ImSpacing.space8),
          Wrap(
            spacing: ImSpacing.space8,
            runSpacing: ImSpacing.space8,
            children: demographics.topLocations.entries.map((e) {
              return Chip(
                label: Text('${e.key}: ${e.value.toStringAsFixed(0)}%'),
                backgroundColor: ImColors.cream50,
                side: const BorderSide(color: ImColors.ink300),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ScoreBox extends StatelessWidget {
  const _ScoreBox({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(ImSpacing.space12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(color: ImColors.ink600),
          ),
          const SizedBox(height: ImSpacing.space4),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
