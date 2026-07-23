import 'package:flutter/material.dart';

import '../../../../core/theme/tokens.dart';
import '../../domain/entities/content.dart';

/// Disclosure status banner (design.md §7) — tags only from API payload.
class DisclosureBanner extends StatelessWidget {
  const DisclosureBanner({super.key, required this.disclosure});

  final DisclosureInfo disclosure;

  @override
  Widget build(BuildContext context) {
    final bg = disclosure.passed ? ImColors.success100 : ImColors.warning100;
    final fg = disclosure.passed ? ImColors.success600 : ImColors.warning600;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ImSpacing.space16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(ImRadii.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                disclosure.passed ? Icons.check_circle : Icons.warning_amber,
                color: fg,
              ),
              const SizedBox(width: ImSpacing.space8),
              Expanded(
                child: Text(
                  disclosure.passed
                      ? 'Required disclosures present'
                      : 'Disclosure check failed',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: fg,
                      ),
                ),
              ),
            ],
          ),
          if (disclosure.requiredTags.isNotEmpty) ...[
            const SizedBox(height: ImSpacing.space8),
            Text(
              'Required: ${disclosure.requiredTags.join(', ')}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          if (!disclosure.passed && disclosure.missingTags.isNotEmpty) ...[
            const SizedBox(height: ImSpacing.space4),
            Text(
              'Missing: ${disclosure.missingTags.join(', ')}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
