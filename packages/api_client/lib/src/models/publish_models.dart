class PublishedPostDto {
  const PublishedPostDto({
    required this.id,
    required this.collaborationId,
    required this.campaignDeliverableId,
    required this.liveUrl,
    required this.platform,
    required this.ownershipVerified,
    required this.verificationStatus,
    this.verificationMethod,
    this.verificationDetail,
    this.verifiedAt,
    this.submittedByUserId,
    this.autoPublish = false,
  });

  final String id;
  final String collaborationId;
  final String campaignDeliverableId;
  final String liveUrl;
  final String platform;
  final bool ownershipVerified;
  final String verificationStatus;
  final String? verificationMethod;
  final String? verificationDetail;
  final String? verifiedAt;
  final String? submittedByUserId;
  final bool autoPublish;

  factory PublishedPostDto.fromJson(Map<String, dynamic> json) {
    return PublishedPostDto(
      id: json['id'] as String,
      collaborationId: json['collaborationId'] as String? ?? '',
      campaignDeliverableId: json['campaignDeliverableId'] as String? ?? '',
      liveUrl: json['liveUrl'] as String? ?? '',
      platform: json['platform'] as String? ?? '',
      ownershipVerified: json['ownershipVerified'] as bool? ?? false,
      verificationStatus: json['verificationStatus'] as String? ?? 'pending',
      verificationMethod: json['verificationMethod'] as String?,
      verificationDetail: json['verificationDetail'] as String?,
      verifiedAt: json['verifiedAt']?.toString(),
      submittedByUserId: json['submittedByUserId'] as String?,
      autoPublish: json['autoPublish'] as bool? ?? false,
    );
  }
}

class PublishScheduleDto {
  const PublishScheduleDto({
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
  final String scheduledAt;
  final String status;
  final String platform;
  final String approvalStatus;
  final String? notes;
  final String? createdAt;

  factory PublishScheduleDto.fromJson(Map<String, dynamic> json) {
    return PublishScheduleDto(
      id: json['id'] as String? ?? '',
      deliverableId: json['deliverableId'] as String? ?? '',
      collaborationId: json['collaborationId'] as String? ?? '',
      scheduledAt: json['scheduledAt']?.toString() ?? '',
      status: json['status'] as String? ?? 'scheduled',
      platform: json['platform'] as String? ?? 'instagram',
      approvalStatus: json['approvalStatus'] as String? ?? 'pending',
      notes: json['notes'] as String?,
      createdAt: json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'deliverableId': deliverableId,
        'collaborationId': collaborationId,
        'scheduledAt': scheduledAt,
        'status': status,
        'platform': platform,
        'approvalStatus': approvalStatus,
        'notes': notes,
        'createdAt': createdAt,
      };
}

