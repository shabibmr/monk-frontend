import 'package:flutter/material.dart';
import 'package:monk_shared/monk_shared.dart';

import '../theme/status_colors.dart';
import '../theme/tokens.dart';

class ImStatusChip extends StatelessWidget {
  const ImStatusChip({
    super.key,
    required this.status,
    this.label,
  });

  final EntityStatus status;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final semantic = statusSemanticFor(status);
    final colors = statusChipColors(semantic);
    final text = label ?? entityStatusLabel(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ImSpacing.space12,
        vertical: ImSpacing.space4,
      ),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: BorderRadius.circular(ImRadii.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: colors.fg,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: ImSpacing.space8),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.fg,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
          ),
        ],
      ),
    );
  }
}
