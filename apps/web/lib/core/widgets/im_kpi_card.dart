import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'im_card.dart';
import 'im_money_text.dart';

/// Dense KPI tile for dashboards (design.md §8 / plan 08).
class ImKpiCard extends StatelessWidget {
  const ImKpiCard({
    super.key,
    required this.label,
    this.valueText,
    this.moneyMinor,
    this.currencyCode,
  }) : assert(
          valueText != null || moneyMinor != null,
          'Provide valueText or moneyMinor',
        );

  final String label;
  final String? valueText;
  final int? moneyMinor;
  final String? currencyCode;

  @override
  Widget build(BuildContext context) {
    return ImCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: ImColors.ink600,
                ),
          ),
          const SizedBox(height: ImSpacing.space8),
          if (moneyMinor != null && currencyCode != null)
            ImMoneyText(
              minorUnits: moneyMinor!,
              currencyCode: currencyCode!,
              style: Theme.of(context).textTheme.headlineSmall,
            )
          else
            Text(
              valueText ?? '—',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
            ),
        ],
      ),
    );
  }
}
