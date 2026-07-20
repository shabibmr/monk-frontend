import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/tokens.dart';

/// Horizontal (or compact vertical) onboarding stepper with speech-bubble active
/// indicator (design.md §6).
class ImStepper extends StatelessWidget {
  const ImStepper({
    super.key,
    required this.labels,
    required this.currentStep,
    this.completedSteps = const {},
    this.onStepTap,
  });

  /// 1-based labels.
  final List<String> labels;

  /// 1-based current step index.
  final int currentStep;
  final Set<int> completedSteps;

  /// Only allows backward navigation when provided.
  final ValueChanged<int>? onStepTap;

  @override
  Widget build(BuildContext context) {
    final primary = context.portalTheme.primary;
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < ImLayout.compactBreakpoint;
        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < labels.length; i++)
                _StepTile(
                  index: i + 1,
                  label: labels[i],
                  current: currentStep == i + 1,
                  completed: completedSteps.contains(i + 1),
                  primary: primary,
                  onTap: _canTap(i + 1)
                      ? () => onStepTap?.call(i + 1)
                      : null,
                ),
            ],
          );
        }
        return Row(
          children: [
            for (var i = 0; i < labels.length; i++) ...[
              Expanded(
                child: _StepTile(
                  index: i + 1,
                  label: labels[i],
                  current: currentStep == i + 1,
                  completed: completedSteps.contains(i + 1),
                  primary: primary,
                  horizontal: true,
                  onTap: _canTap(i + 1)
                      ? () => onStepTap?.call(i + 1)
                      : null,
                ),
              ),
              if (i < labels.length - 1)
                Container(
                  width: 16,
                  height: 2,
                  color: ImColors.ink300.withValues(alpha: 0.5),
                ),
            ],
          ],
        );
      },
    );
  }

  bool _canTap(int step) {
    if (onStepTap == null) return false;
    // Allow completed or current or previous only — never skip forward.
    return step <= currentStep || completedSteps.contains(step);
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({
    required this.index,
    required this.label,
    required this.current,
    required this.completed,
    required this.primary,
    this.horizontal = false,
    this.onTap,
  });

  final int index;
  final String label;
  final bool current;
  final bool completed;
  final Color primary;
  final bool horizontal;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final child = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (current)
          CustomPaint(
            size: const Size(36, 40),
            painter: _BubblePainter(color: primary),
            child: Center(
              child: Text(
                '$index',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: ImColors.white,
                ),
              ),
            ),
          )
        else
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: completed ? ImColors.teal700 : ImColors.cream100,
              shape: BoxShape.circle,
              border: Border.all(
                color: completed ? ImColors.teal700 : ImColors.ink300,
              ),
            ),
            alignment: Alignment.center,
            child: completed
                ? const Icon(Icons.check, size: 16, color: ImColors.white)
                : Text(
                    '$index',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: ImColors.ink600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        const SizedBox(height: ImSpacing.space8),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: current ? FontWeight.w600 : FontWeight.w400,
            color: current ? ImColors.ink900 : ImColors.ink600,
          ),
        ),
      ],
    );

    final content = horizontal
        ? child
        : Padding(
            padding: const EdgeInsets.symmetric(vertical: ImSpacing.space8),
            child: Row(
              children: [
                if (current)
                  CustomPaint(
                    size: const Size(36, 40),
                    painter: _BubblePainter(color: primary),
                    child: Center(
                      child: Text(
                        '$index',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: ImColors.white,
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: completed ? ImColors.teal700 : ImColors.cream100,
                      shape: BoxShape.circle,
                    ),
                    child: completed
                        ? const Icon(Icons.check, size: 16, color: ImColors.white)
                        : Center(child: Text('$index')),
                  ),
                const SizedBox(width: ImSpacing.space12),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: current ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          );

    if (onTap == null) return content;
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(8), child: content);
  }
}

class _BubblePainter extends CustomPainter {
  _BubblePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height - 8),
      const Radius.circular(10),
    );
    canvas.drawRRect(r, paint);
    final path = Path()
      ..moveTo(size.width / 2 - 6, size.height - 8)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width / 2 + 6, size.height - 8)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BubblePainter oldDelegate) =>
      oldDelegate.color != color;
}
