import 'package:equatable/equatable.dart';
import 'package:monk_shared/monk_shared.dart';

enum PublishScheduleStatus {
  scheduled,
  published,
  failed,
  cancelled;

  static PublishScheduleStatus fromString(String raw) {
    switch (raw.toLowerCase()) {
      case 'published':
        return PublishScheduleStatus.published;
      case 'failed':
        return PublishScheduleStatus.failed;
      case 'cancelled':
        return PublishScheduleStatus.cancelled;
      case 'scheduled':
      default:
        return PublishScheduleStatus.scheduled;
    }
  }
}

class PublishSchedule extends Equatable {
  const PublishSchedule({
    required this.id,
    required this.deliverableId,
    required this.collaborationId,
    required this.scheduledAt,
    required this.status,
    required this.platform,
    required this.approvalStatus,
    this.notes,
    this.createdAt,
  });

  final String id;
  final String deliverableId;
  final String collaborationId;
  final DateTime scheduledAt;
  final PublishScheduleStatus status;
  final String platform;
  final String approvalStatus; // e.g. 'approved', 'pending', 'rejected'
  final String? notes;
  final DateTime? createdAt;

  bool get isApproved => approvalStatus.toLowerCase() == 'approved';

  EntityStatus get statusChip {
    switch (status) {
      case PublishScheduleStatus.scheduled:
        return EntityStatus.syncing;
      case PublishScheduleStatus.published:
        return EntityStatus.verified;
      case PublishScheduleStatus.failed:
        return EntityStatus.failed;
      case PublishScheduleStatus.cancelled:
        return EntityStatus.inReview;
    }
  }

  @override
  List<Object?> get props => [
        id,
        deliverableId,
        collaborationId,
        scheduledAt,
        status,
        platform,
        approvalStatus,
        notes,
        createdAt,
      ];
}
