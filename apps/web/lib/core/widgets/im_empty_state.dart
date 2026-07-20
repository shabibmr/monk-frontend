import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'im_button.dart';

/// Empty state with speech-bubble frame (design.md §6).
class ImEmptyState extends StatelessWidget {
  const ImEmptyState({
    super.key,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: CustomPaint(
          painter: _BubblePainter(
            color: ImColors.ink300.withValues(alpha: 0.6),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              ImSpacing.space32,
              ImSpacing.space32,
              ImSpacing.space32,
              ImSpacing.space48,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium,
                ),
                if (actionLabel != null && onAction != null) ...[
                  const SizedBox(height: ImSpacing.space24),
                  ImButton(label: actionLabel!, onPressed: onAction),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BubblePainter extends CustomPainter {
  _BubblePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height - 16),
      const Radius.circular(ImRadii.radiusLg),
    );
    canvas.drawRRect(rrect, paint);

    final path = Path()
      ..moveTo(size.width / 2 - 12, size.height - 16)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width / 2 + 12, size.height - 16);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BubblePainter oldDelegate) =>
      oldDelegate.color != color;
}
