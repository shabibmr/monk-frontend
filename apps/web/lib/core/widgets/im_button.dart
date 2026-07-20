import 'package:flutter/material.dart';

import '../theme/tokens.dart';

enum ImButtonVariant { primary, secondary, tertiary, destructive }

class ImButton extends StatelessWidget {
  const ImButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = ImButtonVariant.primary,
    this.loading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final ImButtonVariant variant;
  final bool loading;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    final child = loading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: ImSpacing.space8),
              ],
              Text(label),
            ],
          );

    switch (variant) {
      case ImButtonVariant.primary:
        return ElevatedButton(
          onPressed: enabled ? onPressed : null,
          child: child,
        );
      case ImButtonVariant.secondary:
        return OutlinedButton(
          onPressed: enabled ? onPressed : null,
          child: child,
        );
      case ImButtonVariant.tertiary:
        return TextButton(
          onPressed: enabled ? onPressed : null,
          child: child,
        );
      case ImButtonVariant.destructive:
        return ElevatedButton(
          onPressed: enabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: ImColors.danger600,
            foregroundColor: ImColors.white,
          ),
          child: child,
        );
    }
  }
}
