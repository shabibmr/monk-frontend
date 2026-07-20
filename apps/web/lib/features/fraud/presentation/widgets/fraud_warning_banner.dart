import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monk_shared/monk_shared.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/fraud_risk_report.dart';
import '../bloc/fraud_bloc.dart';
import '../bloc/fraud_state.dart';

class FraudWarningBanner extends StatelessWidget {
  const FraudWarningBanner({
    super.key,
    this.report,
    this.entityId,
    this.onDismiss,
  });

  final FraudRiskReport? report;
  final String? entityId;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    if (report != null) {
      return _buildContent(context, report!);
    }

    return BlocBuilder<FraudBloc, FraudState>(
      builder: (context, state) {
        if (state.isDismissed || state.report == null || !state.report!.hasRiskFlag) {
          return const SizedBox.shrink();
        }
        return _buildContent(context, state.report!);
      },
    );
  }

  Widget _buildContent(BuildContext context, FraudRiskReport r) {
    if (!r.hasRiskFlag) {
      return const SizedBox.shrink();
    }

    final isHigh = r.riskLevel == 'high' || r.riskScore >= 0.7;
    final isDuplicate = r.isDuplicate;

    final bannerBg = isHigh ? ImColors.danger100 : ImColors.warning100;
    final borderColor = isHigh ? ImColors.danger600 : ImColors.warning600;
    final iconColor = isHigh ? ImColors.danger600 : ImColors.warning600;

    return ImCard(
      child: Container(
        padding: const EdgeInsets.all(ImSpacing.space12),
        decoration: BoxDecoration(
          color: bannerBg,
          borderRadius: BorderRadius.circular(ImRadii.radiusSm),
          border: Border.all(color: borderColor.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  isHigh ? Icons.warning_amber_rounded : Icons.info_outline,
                  color: iconColor,
                  size: 24,
                ),
                const SizedBox(width: ImSpacing.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            isDuplicate
                                ? 'Duplicate Entity Warning'
                                : 'Fraud Risk Flag',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: ImColors.ink900,
                                ),
                          ),
                          const SizedBox(width: ImSpacing.space8),
                          ImStatusChip(
                            status: isHigh
                                ? EntityStatus.disputed
                                : EntityStatus.held,
                            label: isDuplicate
                                ? 'Duplicate Flag'
                                : 'Risk Score: ${r.riskScore.toStringAsFixed(2)}',
                          ),
                        ],
                      ),
                      const SizedBox(height: ImSpacing.space4),
                      Text(
                        'API Risk Rating: ${r.riskLevel.toUpperCase()} (Score: ${r.riskScore.toStringAsFixed(2)})',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: ImColors.ink700,
                        ),
                      ),
                      const SizedBox(height: ImSpacing.space6),
                      if (r.flaggedReasons.isNotEmpty) ...[
                        const Text(
                          'Flagged Reasons:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: ImColors.ink800,
                          ),
                        ),
                        const SizedBox(height: ImSpacing.space2),
                        ...r.flaggedReasons.map(
                          (reason) => Padding(
                            padding: const EdgeInsets.only(left: 4, top: 1),
                            child: Row(
                              children: [
                                const Icon(Icons.circle, size: 4, color: ImColors.ink700),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    reason,
                                    style: const TextStyle(fontSize: 12, color: ImColors.ink800),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: ImSpacing.space8),
                      Text(
                        'Recommendation: ${r.recommendation}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: ImColors.ink800,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onDismiss != null)
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: onDismiss,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
