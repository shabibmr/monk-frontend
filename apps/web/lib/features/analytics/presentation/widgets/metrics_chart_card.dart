import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/im_card.dart';
import '../../../../core/widgets/im_skeleton.dart';
import '../../domain/entities/analytics_metric.dart';

/// Read-only chart card displaying automated metrics time-series or bar trends.
class MetricsChartCard extends StatelessWidget {
  const MetricsChartCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.dataPoints,
    this.unit = '',
    this.isLoading = false,
    this.isSyncing = false,
    this.primaryColor,
  });

  final String title;
  final String? subtitle;
  final List<MetricDataPoint> dataPoints;
  final String unit;
  final bool isLoading;
  final bool isSyncing;
  final Color? primaryColor;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return ImCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ImSkeleton(width: 140, height: 20),
            const SizedBox(height: ImSpacing.space8),
            const ImSkeleton(width: 200, height: 14),
            const SizedBox(height: ImSpacing.space24),
            const ImSkeleton(width: double.infinity, height: 160),
          ],
        ),
      );
    }

    final activeColor = primaryColor ?? Theme.of(context).colorScheme.primary;

    return ImCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: ImSpacing.space4),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: ImColors.ink600,
                          ),
                    ),
                  ],
                ],
              ),
              if (isSyncing)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ImSpacing.space8,
                    vertical: ImSpacing.space4,
                  ),
                  decoration: BoxDecoration(
                    color: ImColors.warning100,
                    borderRadius: BorderRadius.circular(ImRadii.radiusSm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: ImColors.warning600,
                        ),
                      ),
                      const SizedBox(width: ImSpacing.space4),
                      Text(
                        'Syncing…',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: ImColors.warning600,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: ImSpacing.space24),
          if (dataPoints.isEmpty)
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: ImColors.ink300.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(ImRadii.radiusMd),
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.show_chart, color: ImColors.ink600, size: 36),
                  const SizedBox(height: ImSpacing.space8),
                  Text(
                    'No metric history available yet',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: ImColors.ink600,
                        ),
                  ),
                ],
              ),
            )
          else
            SizedBox(
              height: 180,
              child: CustomPaint(
                size: const Size(double.infinity, 180),
                painter: _ChartPainter(
                  dataPoints: dataPoints,
                  lineColor: activeColor,
                  gridColor: ImColors.ink300.withValues(alpha: 0.3),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  _ChartPainter({
    required this.dataPoints,
    required this.lineColor,
    required this.gridColor,
  });

  final List<MetricDataPoint> dataPoints;
  final Color lineColor;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          lineColor.withValues(alpha: 0.3),
          lineColor.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final dotPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    // Draw horizontal grid lines
    const gridLines = 4;
    for (int i = 0; i <= gridLines; i++) {
      final y = (size.height / gridLines) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final values = dataPoints.map((e) => e.value).toList();
    final maxVal = math.max(values.reduce(math.max), 1.0);
    final minVal = values.reduce(math.min);
    final range = maxVal - minVal == 0 ? 1.0 : maxVal - minVal;

    final path = Path();
    final fillPath = Path();
    final points = <Offset>[];

    final dx = dataPoints.length > 1
        ? size.width / (dataPoints.length - 1)
        : size.width / 2;

    for (int i = 0; i < dataPoints.length; i++) {
      final x = dataPoints.length > 1 ? i * dx : size.width / 2;
      final normalized = (dataPoints[i].value - minVal) / range;
      final y = size.height - (normalized * (size.height * 0.7) + size.height * 0.15);
      points.add(Offset(x, y));

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    if (points.isNotEmpty) {
      fillPath.lineTo(points.last.dx, size.height);
      fillPath.close();
      canvas.drawPath(fillPath, fillPaint);
      canvas.drawPath(path, linePaint);

      for (final pt in points) {
        canvas.drawCircle(pt, 4, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) {
    return oldDelegate.dataPoints != dataPoints ||
        oldDelegate.lineColor != lineColor;
  }
}
