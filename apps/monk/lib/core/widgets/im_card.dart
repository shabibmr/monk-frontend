import 'package:flutter/material.dart';

import '../theme/tokens.dart';

class ImCard extends StatelessWidget {
  const ImCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: padding ?? const EdgeInsets.all(ImSpacing.space16),
      child: child,
    );

    return Material(
      color: ImColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ImRadii.radiusMd),
        side: BorderSide(color: ImColors.ink300.withValues(alpha: 0.4)),
      ),
      clipBehavior: Clip.antiAlias,
      child: onTap == null
          ? content
          : InkWell(onTap: onTap, child: content),
    );
  }
}
