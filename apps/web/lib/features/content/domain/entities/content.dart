import 'package:equatable/equatable.dart';
import 'package:monk_shared/monk_shared.dart';

/// Mirrors server canApproveDisclosure — client only for UX enablement.
bool canApproveWithDisclosure({
  required bool disclosurePassed,
  String? overrideReason,
}) {
  if (disclosurePassed) return true;
  return overrideReason != null && overrideReason.trim().isNotEmpty;
}

EntityStatus contentVersionStatusToEntity(String status) {
  switch (status) {
    case 'draft':
      return EntityStatus.draft;
    case 'submitted':
      return EntityStatus.submitted;
    case 'approved':
      return EntityStatus.approved;
    case 'rejected':
      return EntityStatus.rejected;
    case 'revision_requested':
      return EntityStatus.revisionRequested;
    default:
      return EntityStatus.inReview;
  }
}

class DisclosureInfo extends Equatable {
  const DisclosureInfo({
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

  @override
  List<Object?> get props =>
      [passed, requiredTags, missingTags, overrideRequired, overrideReason];
}

class ContentVersion extends Equatable {
  const ContentVersion({
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
  final String? collaborationId;
  final String? campaignDeliverableId;
  final DisclosureInfo? disclosure;

  bool get isDraft => status == 'draft';
  bool get isSubmitted => status == 'submitted';
  EntityStatus get statusChip => contentVersionStatusToEntity(status);

  @override
  List<Object?> get props => [
        id,
        submissionId,
        versionNumber,
        status,
        caption,
        hashtags,
        links,
        mediaFileIds,
        immutable,
        reviewComment,
        collaborationId,
        campaignDeliverableId,
        disclosure,
      ];
}

class ContentSubmission extends Equatable {
  const ContentSubmission({
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
  final List<ContentVersion> versions;

  ContentVersion? get latestVersion =>
      versions.isEmpty ? null : versions.last;

  ContentVersion? get latestSubmitted {
    for (final v in versions.reversed) {
      if (v.isSubmitted) return v;
    }
    return null;
  }

  @override
  List<Object?> get props =>
      [id, collaborationId, campaignDeliverableId, status, currentVersionId, versions];
}

class ContentComment extends Equatable {
  const ContentComment({
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

  @override
  List<Object?> get props =>
      [id, contentVersionId, authorUserId, body, parentCommentId, createdAt];
}
