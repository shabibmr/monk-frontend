import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Negotiation offer bubble (design.md §6). Tail-left = brand, tail-right = creator.
enum ImBubbleSide { brand, creator }

class ImBubbleCard extends StatelessWidget {
  const ImBubbleCard({
    super.key,
    required this.side,
    required this.child,
    this.locked = false,
    this.semanticLabel,
  });

  final ImBubbleSide side;
  final Widget child;
  final bool locked;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final isBrand = side == ImBubbleSide.brand;
    final bg = isBrand ? ImColors.teal100 : ImColors.coral100;
    final align = isBrand ? Alignment.centerLeft : Alignment.centerRight;
    final border = locked
        ? Border.all(color: ImColors.success600, width: 2)
        : null;

    return Semantics(
      label: semanticLabel ??
          (isBrand ? 'Brand offer bubble' : 'Creator offer bubble'),
      child: Align(
        alignment: align,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: CustomPaint(
            painter: _TailPainter(
              color: bg,
              side: side,
              borderColor: locked ? ImColors.success600 : null,
            ),
            child: Container(
              margin: EdgeInsets.only(
                left: isBrand ? 0 : ImSpacing.space24,
                right: isBrand ? ImSpacing.space24 : 0,
                bottom: ImSpacing.space12,
              ),
              padding: const EdgeInsets.all(ImSpacing.space16),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(ImRadii.radiusMd),
                border: border,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _TailPainter extends CustomPainter {
  _TailPainter({
    required this.color,
    required this.side,
    this.borderColor,
  });

  final Color color;
  final ImBubbleSide side;
  final Color? borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    // Tail rendered as small triangle outside main box via path on edge.
    final paint = Paint()..color = color;
    final path = Path();
    if (side == ImBubbleSide.brand) {
      path
        ..moveTo(0, size.height - 28)
        ..lineTo(-10, size.height - 18)
        ..lineTo(0, size.height - 12)
        ..close();
    } else {
      path
        ..moveTo(size.width, size.height - 28)
        ..lineTo(size.width + 10, size.height - 18)
        ..lineTo(size.width, size.height - 12)
        ..close();
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TailPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.side != side ||
      oldDelegate.borderColor != borderColor;
}
