import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Cream shimmer skeleton (design.md §10).
class ImSkeleton extends StatefulWidget {
  const ImSkeleton({
    super.key,
    this.height = 16,
    this.width,
    this.borderRadius = ImRadii.radiusSm,
  });

  final double height;
  final double? width;
  final double borderRadius;

  @override
  State<ImSkeleton> createState() => _ImSkeletonState();
}

class _ImSkeletonState extends State<ImSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final t = _c.value;
        return Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            color: Color.lerp(ImColors.cream100, ImColors.cream50, t),
          ),
        );
      },
    );
  }
}

class ImSkeletonCard extends StatelessWidget {
  const ImSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ImSpacing.space16),
      decoration: BoxDecoration(
        color: ImColors.white,
        borderRadius: BorderRadius.circular(ImRadii.radiusMd),
        border: Border.all(color: ImColors.ink300.withValues(alpha: 0.4)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ImSkeleton(height: 20, width: 160),
          SizedBox(height: ImSpacing.space12),
          ImSkeleton(height: 14),
          SizedBox(height: ImSpacing.space8),
          ImSkeleton(height: 14, width: 220),
        ],
      ),
    );
  }
}
