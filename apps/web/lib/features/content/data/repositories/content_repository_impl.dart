import 'package:api_client/api_client.dart';

import '../../../../core/network/error_mapper.dart';
import '../../domain/entities/content.dart';
import '../../domain/repositories/content_repository.dart';

class ContentRepositoryImpl implements ContentRepository {
  ContentRepositoryImpl(this._client);
  final MonkApiClient _client;

  DisclosureInfo? _mapDisclosure(DisclosureDto? d) {
    if (d == null) return null;
    return DisclosureInfo(
      passed: d.passed,
      requiredTags: d.requiredTags,
      missingTags: d.missingTags,
      overrideRequired: d.overrideRequired,
      overrideReason: d.overrideReason,
    );
  }

  ContentVersion _mapVersion(ContentVersionDto d) => ContentVersion(
        id: d.id,
        submissionId: d.submissionId,
        versionNumber: d.versionNumber,
        status: d.status,
        caption: d.caption,
        hashtags: d.hashtags,
        links: d.links,
        mediaFileIds: d.mediaFileIds,
        immutable: d.immutable,
        reviewComment: d.reviewComment,
        collaborationId: d.collaborationId,
        campaignDeliverableId: d.campaignDeliverableId,
        disclosure: _mapDisclosure(d.disclosure),
      );

  ContentSubmission _mapSubmission(ContentSubmissionDto d) => ContentSubmission(
        id: d.id,
        collaborationId: d.collaborationId,
        campaignDeliverableId: d.campaignDeliverableId,
        status: d.status,
        currentVersionId: d.currentVersionId,
        versions: d.versions.map(_mapVersion).toList(),
      );

  ContentComment _mapComment(ContentCommentDto d) => ContentComment(
        id: d.id,
        contentVersionId: d.contentVersionId,
        authorUserId: d.authorUserId,
        body: d.body,
        parentCommentId: d.parentCommentId,
        createdAt: d.createdAt,
      );

  @override
  Future<List<ContentSubmission>> listSubmissions(
    String collaborationId,
  ) async {
    try {
      final list = await _client.content.listSubmissions(collaborationId);
      return list.map(_mapSubmission).toList();
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<ContentVersion> createVersion({
    required String collaborationId,
    required String deliverableId,
    required Map<String, dynamic> body,
  }) async {
    try {
      return _mapVersion(
        await _client.content.createVersion(
          collaborationId: collaborationId,
          deliverableId: deliverableId,
          body: body,
        ),
      );
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<ContentVersion> submit(String versionId) async {
    try {
      return _mapVersion(await _client.content.submit(versionId));
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<ContentVersion> getVersion(String versionId) async {
    try {
      return _mapVersion(await _client.content.getVersion(versionId));
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<ContentVersion> review({
    required String versionId,
    required String decision,
    String? comment,
    String? overrideReason,
  }) async {
    try {
      return _mapVersion(
        await _client.content.review(
          versionId,
          decision: decision,
          comment: comment,
          overrideReason: overrideReason,
        ),
      );
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<ContentComment> addComment({
    required String versionId,
    required String body,
  }) async {
    try {
      return _mapComment(
        await _client.content.addComment(versionId, body: body),
      );
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<List<ContentComment>> listComments(String versionId) async {
    try {
      final list = await _client.content.listComments(versionId);
      return list.map(_mapComment).toList();
    } catch (e) {
      throw mapError(e);
    }
  }
}
