import 'package:flutter/material.dart';
import 'package:monk_shared/monk_shared.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/im_button.dart';
import '../../../../core/widgets/im_card.dart';
import '../../../../core/widgets/im_status_chip.dart';
import '../../domain/entities/publish_schedule.dart';

class PublishJobStatusCard extends StatelessWidget {
  const PublishJobStatusCard({
    super.key,
    required this.schedule,
    this.onCancel,
    this.onReschedule,
  });

  final PublishSchedule schedule;
  final VoidCallback? onCancel;
  final VoidCallback? onReschedule;

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        '${schedule.scheduledAt.year}-${schedule.scheduledAt.month.toString().padLeft(2, '0')}-${schedule.scheduledAt.day.toString().padLeft(2, '0')} ${schedule.scheduledAt.hour.toString().padLeft(2, '0')}:${schedule.scheduledAt.minute.toString().padLeft(2, '0')}';

    return ImCard(
      padding: const EdgeInsets.all(ImSpacing.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.schedule, color: ImColors.primary600, size: 20),
              const SizedBox(width: ImSpacing.space8),
              const Text(
                'Publish Schedule Job Status',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              ImStatusChip(
                status: schedule.statusChip,
                label: schedule.status.name.toUpperCase(),
              ),
            ],
          ),
          const SizedBox(height: ImSpacing.space12),
          const Divider(),
          const SizedBox(height: ImSpacing.space8),
          Row(
            children: [
              const Text(
                'Platform: ',
                style: TextStyle(color: ImColors.ink500, fontSize: 13),
              ),
              Text(
                schedule.platform.toUpperCase(),
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(width: ImSpacing.space24),
              const Text(
                'Scheduled For: ',
                style: TextStyle(color: ImColors.ink500, fontSize: 13),
              ),
              Text(
                formattedDate,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: ImSpacing.space8),
          Row(
            children: [
              const Text(
                'Content Approval: ',
                style: TextStyle(color: ImColors.ink500, fontSize: 13),
              ),
              ImStatusChip(
                status: schedule.isApproved
                    ? EntityStatus.verified
                    : EntityStatus.inReview,
                label: schedule.approvalStatus.toUpperCase(),
              ),
            ],
          ),
          if (schedule.notes != null && schedule.notes!.isNotEmpty) ...[
            const SizedBox(height: ImSpacing.space8),
            Text(
              'Notes: ${schedule.notes}',
              style: const TextStyle(color: ImColors.ink700, fontSize: 12),
            ),
          ],
          if (schedule.status == PublishScheduleStatus.scheduled) ...[
            const SizedBox(height: ImSpacing.space16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onReschedule != null)
                  ImButton(
                    label: 'Reschedule',
                    variant: ImButtonVariant.secondary,
                    onPressed: onReschedule,
                  ),
                if (onReschedule != null && onCancel != null)
                  const SizedBox(width: ImSpacing.space8),
                if (onCancel != null)
                  ImButton(
                    label: 'Cancel Schedule',
                    variant: ImButtonVariant.destructive,
                    onPressed: onCancel,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
