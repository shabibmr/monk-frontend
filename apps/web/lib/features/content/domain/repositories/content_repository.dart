import '../entities/content.dart';

abstract class ContentRepository {
  Future<List<ContentSubmission>> listSubmissions(String collaborationId);

  Future<ContentVersion> createVersion({
    required String collaborationId,
    required String deliverableId,
    required Map<String, dynamic> body,
  });

  Future<ContentVersion> submit(String versionId);

  Future<ContentVersion> getVersion(String versionId);

  Future<ContentVersion> review({
    required String versionId,
    required String decision,
    String? comment,
    String? overrideReason,
  });

  Future<ContentComment> addComment({
    required String versionId,
    required String body,
  });

  Future<List<ContentComment>> listComments(String versionId);
}
