import 'package:flutter/material.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/im_button.dart';
import '../../domain/entities/analytics_metric.dart';

/// Modal dialog showing status of an asynchronous report export job.
class ExportStatusDialog extends StatelessWidget {
  const ExportStatusDialog({
    super.key,
    required this.jobStatus,
    this.onDismiss,
    this.onRetry,
  });

  final ExportJobStatus jobStatus;
  final VoidCallback? onDismiss;
  final VoidCallback? onRetry;

  static Future<void> show(
    BuildContext context, {
    required ExportJobStatus jobStatus,
    VoidCallback? onDismiss,
    VoidCallback? onRetry,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: !jobStatus.isInProgress,
      builder: (context) => ExportStatusDialog(
        jobStatus: jobStatus,
        onDismiss: onDismiss,
        onRetry: onRetry,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ImRadii.radiusLg),
      ),
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(ImSpacing.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(ImSpacing.space12),
                  decoration: BoxDecoration(
                    color: _headerBgColor(),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_headerIcon(), color: _headerIconColor(), size: 24),
                ),
                const SizedBox(width: ImSpacing.space16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Export ${jobStatus.format.toUpperCase()} Report',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: ImSpacing.space4),
                      Text(
                        'Job ID: ${jobStatus.jobId}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: ImColors.ink600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: ImSpacing.space24),
            if (jobStatus.isInProgress) ...[
              LinearProgressIndicator(
                value: jobStatus.progressPercent > 0
                    ? jobStatus.progressPercent / 100.0
                    : null,
                backgroundColor: ImColors.ink300,
              ),
              const SizedBox(height: ImSpacing.space12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Generating report…',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: ImColors.ink600,
                    ),
                  ),
                  Text(
                    '${jobStatus.progressPercent}%',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ] else if (jobStatus.isCompleted) ...[
              Container(
                padding: const EdgeInsets.all(ImSpacing.space16),
                decoration: BoxDecoration(
                  color: ImColors.success100,
                  borderRadius: BorderRadius.circular(ImRadii.radiusMd),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: ImColors.success600),
                    const SizedBox(width: ImSpacing.space12),
                    Expanded(
                      child: Text(
                        'Your report is ready for download.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: ImColors.ink900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(ImSpacing.space16),
                decoration: BoxDecoration(
                  color: ImColors.danger100,
                  borderRadius: BorderRadius.circular(ImRadii.radiusMd),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: ImColors.danger600),
                    const SizedBox(width: ImSpacing.space12),
                    Expanded(
                      child: Text(
                        jobStatus.errorMessage ??
                            'Export failed. Please try again.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: ImColors.ink900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: ImSpacing.space24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (jobStatus.isFailed && onRetry != null) ...[
                  ImButton(
                    label: 'Retry',
                    variant: ImButtonVariant.secondary,
                    onPressed: () {
                      Navigator.of(context).pop();
                      onRetry?.call();
                    },
                  ),
                  const SizedBox(width: ImSpacing.space12),
                ],
                if (jobStatus.isCompleted && jobStatus.downloadUrl != null) ...[
                  ImButton(
                    label: 'Download Report',
                    icon: const Icon(Icons.download, size: 18),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(width: ImSpacing.space12),
                ],
                ImButton(
                  label: jobStatus.isInProgress ? 'Background' : 'Close',
                  variant: jobStatus.isCompleted
                      ? ImButtonVariant.secondary
                      : ImButtonVariant.primary,
                  onPressed: () {
                    Navigator.of(context).pop();
                    onDismiss?.call();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _headerBgColor() {
    if (jobStatus.isCompleted) return ImColors.success100;
    if (jobStatus.isFailed) return ImColors.danger100;
    return ImColors.teal100;
  }

  Color _headerIconColor() {
    if (jobStatus.isCompleted) return ImColors.success600;
    if (jobStatus.isFailed) return ImColors.danger600;
    return ImColors.teal700;
  }

  IconData _headerIcon() {
    if (jobStatus.isCompleted) return Icons.file_download_done;
    if (jobStatus.isFailed) return Icons.warning_amber;
    return Icons.cloud_download;
  }
}
