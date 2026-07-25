import '../../../features/content/domain/entities/content.dart';
import '../../../features/content/domain/repositories/content_repository.dart';
import '../../errors/failures.dart';
import '../mock_ids.dart';
import '../mock_seed_store.dart';

/// In-memory [ContentRepository].
///
/// Store keys:
/// - `content_submissions` → `List<ContentSubmission>` (versions nested)
/// - `content_comments` → `List<ContentComment>`
/// - `content_versions` → flat index of `List<ContentVersion>` (kept in sync)
class MockContentRepository implements ContentRepository {
  MockContentRepository(this._store);

  final MockSeedStore _store;

  void _ensureFixtures() {
    if (_store.list<ContentSubmission>('content_submissions').isNotEmpty) {
      return;
    }

    final version = ContentVersion(
      id: MockIds.content1,
      submissionId: 'sub-demo-1',
      versionNumber: 1,
      status: 'draft',
      caption: 'Glow up with our summer essentials ✨ #ad',
      hashtags: const ['#ad', '#summerglow'],
      links: const [],
      mediaFileIds: const ['file-demo-1'],
      immutable: false,
      collaborationId: MockIds.collab1,
      campaignDeliverableId: 'del-demo-1',
      disclosure: const DisclosureInfo(
        passed: true,
        requiredTags: ['#ad'],
        missingTags: [],
      ),
    );

    _store.putAll('content_submissions', [
      ContentSubmission(
        id: 'sub-demo-1',
        collaborationId: MockIds.collab1,
        campaignDeliverableId: 'del-demo-1',
        status: 'draft',
        currentVersionId: version.id,
        versions: [version],
      ),
    ]);
    _store.putAll('content_versions', [version]);
  }

  void _syncVersionIndex(ContentVersion v) {
    _store.replaceWhere<ContentVersion>(
      'content_versions',
      (x) => x.id == v.id,
      v,
    );
  }

  ContentVersion? _findVersion(String versionId) {
    // Prefer nested submissions (source of truth).
    for (final sub in _store.list<ContentSubmission>('content_submissions')) {
      for (final v in sub.versions) {
        if (v.id == versionId) return v;
      }
    }
    return _store.findWhere<ContentVersion>(
      'content_versions',
      (v) => v.id == versionId,
    );
  }

  ContentSubmission? _submissionForVersion(String versionId) {
    for (final sub in _store.list<ContentSubmission>('content_submissions')) {
      if (sub.versions.any((v) => v.id == versionId) ||
          sub.currentVersionId == versionId) {
        return sub;
      }
    }
    return null;
  }

  ContentSubmission _replaceSubmission(ContentSubmission sub) {
    _store.replaceWhere<ContentSubmission>(
      'content_submissions',
      (s) => s.id == sub.id,
      sub,
    );
    return sub;
  }

  ContentVersion _copyVersion(
    ContentVersion v, {
    String? status,
    bool? immutable,
    String? reviewComment,
    String? caption,
    List<String>? hashtags,
    List<String>? links,
    List<String>? mediaFileIds,
    DisclosureInfo? disclosure,
  }) =>
      ContentVersion(
        id: v.id,
        submissionId: v.submissionId,
        versionNumber: v.versionNumber,
        status: status ?? v.status,
        caption: caption ?? v.caption,
        hashtags: hashtags ?? v.hashtags,
        links: links ?? v.links,
        mediaFileIds: mediaFileIds ?? v.mediaFileIds,
        immutable: immutable ?? v.immutable,
        reviewComment: reviewComment ?? v.reviewComment,
        collaborationId: v.collaborationId,
        campaignDeliverableId: v.campaignDeliverableId,
        disclosure: disclosure ?? v.disclosure,
      );

  @override
  Future<List<ContentSubmission>> listSubmissions(
    String collaborationId,
  ) async {
    await _store.delay();
    _ensureFixtures();
    return _store
        .list<ContentSubmission>('content_submissions')
        .where((s) => s.collaborationId == collaborationId)
        .toList();
  }

  @override
  Future<ContentVersion> createVersion({
    required String collaborationId,
    required String deliverableId,
    required Map<String, dynamic> body,
  }) async {
    await _store.delay();
    _ensureFixtures();

    var sub = _store.findWhere<ContentSubmission>(
      'content_submissions',
      (s) =>
          s.collaborationId == collaborationId &&
          s.campaignDeliverableId == deliverableId,
    );

    final caption = (body['caption'] as String?) ?? '';
    final hashtags = (body['hashtags'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const <String>[];
    final links = (body['links'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const <String>[];
    final mediaFileIds = (body['mediaFileIds'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const <String>[];

    if (sub == null) {
      final subId = 'sub-mock-${DateTime.now().microsecondsSinceEpoch}';
      final versionId = collaborationId == MockIds.collab1 &&
              deliverableId == 'del-demo-1' &&
              _findVersion(MockIds.content1) == null
          ? MockIds.content1
          : 'content-mock-${DateTime.now().microsecondsSinceEpoch}';

      final version = ContentVersion(
        id: versionId,
        submissionId: subId,
        versionNumber: 1,
        status: 'draft',
        caption: caption,
        hashtags: hashtags,
        links: links,
        mediaFileIds: mediaFileIds,
        collaborationId: collaborationId,
        campaignDeliverableId: deliverableId,
        disclosure: DisclosureInfo(
          passed: hashtags.any((t) => t.toLowerCase().contains('ad')) ||
              caption.toLowerCase().contains('#ad'),
          requiredTags: const ['#ad'],
          missingTags: hashtags.any((t) => t.toLowerCase().contains('ad'))
              ? const []
              : const ['#ad'],
          overrideRequired:
              !hashtags.any((t) => t.toLowerCase().contains('ad')),
        ),
      );
      sub = ContentSubmission(
        id: subId,
        collaborationId: collaborationId,
        campaignDeliverableId: deliverableId,
        status: 'draft',
        currentVersionId: version.id,
        versions: [version],
      );
      _store.add('content_submissions', sub);
      _syncVersionIndex(version);
      return version;
    }

    final nextNum = sub.versions.isEmpty
        ? 1
        : sub.versions.map((v) => v.versionNumber).reduce((a, b) => a > b ? a : b) +
            1;

    final version = ContentVersion(
      id: 'content-mock-${DateTime.now().microsecondsSinceEpoch}',
      submissionId: sub.id,
      versionNumber: nextNum,
      status: 'draft',
      caption: caption,
      hashtags: hashtags,
      links: links,
      mediaFileIds: mediaFileIds,
      collaborationId: collaborationId,
      campaignDeliverableId: deliverableId,
      disclosure: DisclosureInfo(
        passed: hashtags.any((t) => t.toLowerCase().contains('ad')) ||
            caption.toLowerCase().contains('#ad'),
        requiredTags: const ['#ad'],
        missingTags: hashtags.any((t) => t.toLowerCase().contains('ad'))
            ? const []
            : const ['#ad'],
      ),
    );

    final updated = ContentSubmission(
      id: sub.id,
      collaborationId: sub.collaborationId,
      campaignDeliverableId: sub.campaignDeliverableId,
      status: 'draft',
      currentVersionId: version.id,
      versions: [...sub.versions, version],
    );
    _replaceSubmission(updated);
    _syncVersionIndex(version);
    return version;
  }

  @override
  Future<ContentVersion> submit(String versionId) async {
    await _store.delay();
    _ensureFixtures();

    final version = _findVersion(versionId);
    if (version == null) {
      throw NotFoundFailure('Content version not found: $versionId');
    }
    if (!version.isDraft && version.status != 'revision_requested') {
      throw ConflictFailure(
        'Cannot submit version in status ${version.status}',
      );
    }

    final submitted = _copyVersion(
      version,
      status: 'submitted',
      immutable: true,
    );

    final sub = _submissionForVersion(versionId);
    if (sub != null) {
      final versions = sub.versions
          .map((v) => v.id == versionId ? submitted : v)
          .toList();
      _replaceSubmission(
        ContentSubmission(
          id: sub.id,
          collaborationId: sub.collaborationId,
          campaignDeliverableId: sub.campaignDeliverableId,
          status: 'submitted',
          currentVersionId: versionId,
          versions: versions,
        ),
      );
    }
    _syncVersionIndex(submitted);
    return submitted;
  }

  @override
  Future<ContentVersion> getVersion(String versionId) async {
    await _store.delay();
    _ensureFixtures();
    final v = _findVersion(versionId);
    if (v == null) {
      throw NotFoundFailure('Content version not found: $versionId');
    }
    return v;
  }

  @override
  Future<ContentVersion> review({
    required String versionId,
    required String decision,
    String? comment,
    String? overrideReason,
  }) async {
    await _store.delay();
    _ensureFixtures();

    final version = _findVersion(versionId);
    if (version == null) {
      throw NotFoundFailure('Content version not found: $versionId');
    }
    if (!version.isSubmitted) {
      throw ConflictFailure(
        'Only submitted versions can be reviewed (status=${version.status})',
      );
    }

    final normalized = decision.toLowerCase().trim();
    String status;
    switch (normalized) {
      case 'approved':
      case 'approve':
        status = 'approved';
        break;
      case 'rejected':
      case 'reject':
        status = 'rejected';
        break;
      case 'revision_requested':
      case 'request_revision':
      case 'revision':
        status = 'revision_requested';
        break;
      default:
        throw ValidationFailure('Unknown review decision: $decision');
    }

    if (status == 'approved') {
      final disclosure = version.disclosure;
      final passed = disclosure?.passed ?? true;
      if (!canApproveWithDisclosure(
        disclosurePassed: passed,
        overrideReason: overrideReason,
      )) {
        throw const ValidationFailure(
          'Disclosure check failed — provide overrideReason to approve',
          errorCode: 'DISCLOSURE_OVERRIDE_REQUIRED',
        );
      }
    }

    final reviewed = _copyVersion(
      version,
      status: status,
      reviewComment: comment,
      immutable: true,
      disclosure: version.disclosure == null
          ? null
          : DisclosureInfo(
              passed: version.disclosure!.passed,
              requiredTags: version.disclosure!.requiredTags,
              missingTags: version.disclosure!.missingTags,
              overrideRequired: version.disclosure!.overrideRequired,
              overrideReason: overrideReason ?? version.disclosure!.overrideReason,
            ),
    );

    final sub = _submissionForVersion(versionId);
    if (sub != null) {
      final versions = sub.versions
          .map((v) => v.id == versionId ? reviewed : v)
          .toList();
      _replaceSubmission(
        ContentSubmission(
          id: sub.id,
          collaborationId: sub.collaborationId,
          campaignDeliverableId: sub.campaignDeliverableId,
          status: status,
          currentVersionId: versionId,
          versions: versions,
        ),
      );
    }
    _syncVersionIndex(reviewed);
    return reviewed;
  }

  @override
  Future<ContentComment> addComment({
    required String versionId,
    required String body,
  }) async {
    await _store.delay();
    _ensureFixtures();

    if (_findVersion(versionId) == null) {
      throw NotFoundFailure('Content version not found: $versionId');
    }
    if (body.trim().isEmpty) {
      throw const ValidationFailure('Comment body is required');
    }

    final comment = ContentComment(
      id: 'cmt-mock-${DateTime.now().microsecondsSinceEpoch}',
      contentVersionId: versionId,
      authorUserId: _store.currentUserId ?? MockIds.brand1,
      body: body.trim(),
      createdAt: DateTime.now().toUtc().toIso8601String(),
    );
    _store.add('content_comments', comment);
    return comment;
  }

  @override
  Future<List<ContentComment>> listComments(String versionId) async {
    await _store.delay();
    _ensureFixtures();
    return _store
        .list<ContentComment>('content_comments')
        .where((c) => c.contentVersionId == versionId)
        .toList();
  }
}
