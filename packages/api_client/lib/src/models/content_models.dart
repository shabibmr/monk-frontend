class DisclosureDto {
  const DisclosureDto({
    required this.passed,
    this.requiredTags = const [],
    this.missingTags = const [],
    this.overrideRequired = false,
    this.overrideReason,
  });

  final bool passed;
  final List<String> requiredTags;
  final List<String> missingTags;
  final bool overrideRequired;
  final String? overrideReason;

  factory DisclosureDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const DisclosureDto(passed: true);
    }
    final required = json['requiredTags'];
    final missing = json['missingTags'];
    final override = json['override'];
    return DisclosureDto(
      passed: json['passed'] as bool? ?? true,
      requiredTags: required is List
          ? required.map((e) => e.toString()).toList()
          : const [],
      missingTags: missing is List
          ? missing.map((e) => e.toString()).toList()
          : const [],
      overrideRequired: json['overrideRequired'] as bool? ?? false,
      overrideReason: override is Map
          ? override['reason'] as String?
          : json['overrideReason'] as String?,
    );
  }
}

class ContentVersionDto {
  const ContentVersionDto({
    required this.id,
    required this.submissionId,
    required this.versionNumber,
    required this.status,
    this.caption = '',
    this.hashtags = const [],
    this.links = const [],
    this.mediaFileIds = const [],
    this.immutable = false,
    this.reviewComment,
    this.submittedAt,
    this.collaborationId,
    this.campaignDeliverableId,
    this.disclosure,
  });

  final String id;
  final String submissionId;
  final int versionNumber;
  final String status;
  final String caption;
  final List<String> hashtags;
  final List<String> links;
  final List<String> mediaFileIds;
  final bool immutable;
  final String? reviewComment;
  final String? submittedAt;
  final String? collaborationId;
  final String? campaignDeliverableId;
  final DisclosureDto? disclosure;

  factory ContentVersionDto.fromJson(Map<String, dynamic> json) {
    final hashtags = json['hashtags'];
    final links = json['links'];
    final media = json['mediaFileIds'];
    final disclosure = json['disclosure'];
    return ContentVersionDto(
      id: json['id'] as String,
      submissionId: json['submissionId'] as String? ?? '',
      versionNumber: json['versionNumber'] as int? ?? 0,
      status: json['status'] as String? ?? 'draft',
      caption: json['caption'] as String? ?? '',
      hashtags: hashtags is List
          ? hashtags.map((e) => e.toString()).toList()
          : const [],
      links: links is List ? links.map((e) => e.toString()).toList() : const [],
      mediaFileIds:
          media is List ? media.map((e) => e.toString()).toList() : const [],
      immutable: json['immutable'] as bool? ?? false,
      reviewComment: json['reviewComment'] as String?,
      submittedAt: json['submittedAt']?.toString(),
      collaborationId: json['collaborationId'] as String?,
      campaignDeliverableId: json['campaignDeliverableId'] as String?,
      disclosure: disclosure is Map<String, dynamic>
          ? DisclosureDto.fromJson(disclosure)
          : null,
    );
  }
}

class ContentSubmissionDto {
  const ContentSubmissionDto({
    required this.id,
    required this.collaborationId,
    required this.campaignDeliverableId,
    required this.status,
    this.currentVersionId,
    this.versions = const [],
  });

  final String id;
  final String collaborationId;
  final String campaignDeliverableId;
  final String status;
  final String? currentVersionId;
  final List<ContentVersionDto> versions;

  factory ContentSubmissionDto.fromJson(Map<String, dynamic> json) {
    final versions = json['versions'] as List<dynamic>? ?? const [];
    return ContentSubmissionDto(
      id: json['id'] as String,
      collaborationId: json['collaborationId'] as String? ?? '',
      campaignDeliverableId: json['campaignDeliverableId'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      currentVersionId: json['currentVersionId'] as String?,
      versions: versions
          .map((e) => ContentVersionDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ContentCommentDto {
  const ContentCommentDto({
    required this.id,
    required this.contentVersionId,
    required this.authorUserId,
    required this.body,
    this.parentCommentId,
    this.createdAt,
  });

  final String id;
  final String contentVersionId;
  final String authorUserId;
  final String body;
  final String? parentCommentId;
  final String? createdAt;

  factory ContentCommentDto.fromJson(Map<String, dynamic> json) {
    return ContentCommentDto(
      id: json['id'] as String,
      contentVersionId: json['contentVersionId'] as String? ?? '',
      authorUserId: json['authorUserId'] as String? ?? '',
      body: json['body'] as String? ?? '',
      parentCommentId: json['parentCommentId'] as String?,
      createdAt: json['createdAt']?.toString(),
    );
  }
}
