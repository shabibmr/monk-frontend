import '../../../features/publish/domain/entities/publish_schedule.dart';
import '../../../features/publish/domain/entities/published_post.dart';
import '../../../features/publish/domain/repositories/publish_repository.dart';
import '../../errors/failures.dart';
import '../mock_ids.dart';
import '../mock_seed_store.dart';

/// In-memory [PublishRepository].
///
/// Store keys:
/// - `published_posts` → `List<PublishedPost>`
/// - `publish_schedules` → `List<PublishSchedule>`
class MockPublishRepository implements PublishRepository {
  MockPublishRepository(this._store);

  final MockSeedStore _store;

  void _ensureFixtures() {
    if (_store.list<PublishedPost>('published_posts').isNotEmpty) return;

    _store.putAll('published_posts', [
      PublishedPost(
        id: MockIds.published1,
        collaborationId: MockIds.collab1,
        campaignDeliverableId: 'del-demo-1',
        liveUrl: 'https://www.instagram.com/reel/demo-summer-glow/',
        platform: 'instagram',
        ownershipVerified: false,
        verificationStatus: 'pending',
        verificationMethod: 'url_submit',
        verificationDetail: 'Awaiting ownership verification',
      ),
    ]);
  }

  PublishedPost? _find(String id) =>
      _store.findWhere<PublishedPost>('published_posts', (p) => p.id == id);

  PublishedPost _replace(PublishedPost p) {
    _store.replaceWhere<PublishedPost>(
      'published_posts',
      (x) => x.id == p.id,
      p,
    );
    return p;
  }

  String _platformFromUrl(String url) {
    final lower = url.toLowerCase();
    if (lower.contains('youtube') || lower.contains('youtu.be')) {
      return 'youtube';
    }
    if (lower.contains('instagram')) return 'instagram';
    if (lower.contains('linkedin')) return 'linkedin';
    if (lower.contains('facebook')) return 'facebook';
    if (lower.contains('x.com') || lower.contains('twitter')) return 'x';
    return 'instagram';
  }

  @override
  Future<PublishedPost> submit({
    required String collaborationId,
    required String deliverableId,
    required String liveUrl,
  }) async {
    await _store.delay();
    _ensureFixtures();

    if (!looksLikeHttpUrl(liveUrl)) {
      throw const ValidationFailure(
        'liveUrl must be a valid http(s) URL',
        errorCode: 'INVALID_URL',
      );
    }

    final existing = _store.findWhere<PublishedPost>(
      'published_posts',
      (p) =>
          p.collaborationId == collaborationId &&
          p.campaignDeliverableId == deliverableId,
    );

    final post = PublishedPost(
      id: existing?.id ??
          (collaborationId == MockIds.collab1 && deliverableId == 'del-demo-1'
              ? MockIds.published1
              : 'pub-mock-${DateTime.now().microsecondsSinceEpoch}'),
      collaborationId: collaborationId,
      campaignDeliverableId: deliverableId,
      liveUrl: liveUrl.trim(),
      platform: _platformFromUrl(liveUrl),
      ownershipVerified: false,
      verificationStatus: 'verifying',
      verificationMethod: 'url_submit',
      verificationDetail: 'Mock verification in progress',
    );

    if (existing != null) {
      return _replace(post);
    }
    _store.add('published_posts', post);
    return post;
  }

  @override
  Future<PublishedPost> get({
    required String collaborationId,
    required String deliverableId,
  }) async {
    await _store.delay();
    _ensureFixtures();

    final post = _store.findWhere<PublishedPost>(
      'published_posts',
      (p) =>
          p.collaborationId == collaborationId &&
          p.campaignDeliverableId == deliverableId,
    );
    if (post == null) {
      throw NotFoundFailure(
        'Published post not found for collab=$collaborationId del=$deliverableId',
      );
    }
    return post;
  }

  @override
  Future<List<PublishedPost>> list(String collaborationId) async {
    await _store.delay();
    _ensureFixtures();
    return _store
        .list<PublishedPost>('published_posts')
        .where((p) => p.collaborationId == collaborationId)
        .toList();
  }

  @override
  Future<PublishedPost> manualConfirm(
    String publishedPostId, {
    String? note,
  }) async {
    await _store.delay();
    _ensureFixtures();

    final post = _find(publishedPostId);
    if (post == null) {
      throw NotFoundFailure('Published post not found: $publishedPostId');
    }
    if (post.isVerified) {
      return post;
    }

    final confirmed = PublishedPost(
      id: post.id,
      collaborationId: post.collaborationId,
      campaignDeliverableId: post.campaignDeliverableId,
      liveUrl: post.liveUrl,
      platform: post.platform,
      ownershipVerified: true,
      verificationStatus: 'verified',
      verificationMethod: 'manual',
      verificationDetail: note ?? 'Manually confirmed in demo',
      verifiedAt: DateTime.now().toUtc().toIso8601String(),
      autoPublish: post.autoPublish,
    );
    return _replace(confirmed);
  }

  @override
  Future<PublishSchedule> schedulePublish({
    required String deliverableId,
    required DateTime scheduledAt,
    required String platform,
    String? notes,
  }) async {
    await _store.delay();
    _ensureFixtures();

    if (scheduledAt.isBefore(DateTime.now().subtract(const Duration(minutes: 1)))) {
      throw const ValidationFailure('scheduledAt must be in the future');
    }
    if (platform.trim().isEmpty) {
      throw const ValidationFailure('platform is required');
    }

    // Infer collab from existing posts/schedules/submissions context.
    final fromPost = _store.findWhere<PublishedPost>(
      'published_posts',
      (p) => p.campaignDeliverableId == deliverableId,
    );
    final collabId = fromPost?.collaborationId ?? MockIds.collab1;

    final existing = _store.findWhere<PublishSchedule>(
      'publish_schedules',
      (s) =>
          s.deliverableId == deliverableId &&
          s.status == PublishScheduleStatus.scheduled,
    );
    if (existing != null) {
      throw ConflictFailure(
        'Active schedule already exists: ${existing.id}',
        errorCode: 'SCHEDULE_EXISTS',
      );
    }

    final schedule = PublishSchedule(
      id: 'sched-mock-${DateTime.now().microsecondsSinceEpoch}',
      deliverableId: deliverableId,
      collaborationId: collabId,
      scheduledAt: scheduledAt,
      status: PublishScheduleStatus.scheduled,
      platform: platform,
      approvalStatus: 'approved',
      notes: notes,
      createdAt: DateTime.now().toUtc(),
    );
    _store.add('publish_schedules', schedule);
    return schedule;
  }

  @override
  Future<PublishSchedule?> getSchedule(String deliverableId) async {
    await _store.delay();
    _ensureFixtures();

    final schedules = _store
        .list<PublishSchedule>('publish_schedules')
        .where((s) => s.deliverableId == deliverableId)
        .toList();
    if (schedules.isEmpty) return null;

    // Prefer active scheduled, else latest.
    for (final s in schedules.reversed) {
      if (s.status == PublishScheduleStatus.scheduled) return s;
    }
    return schedules.last;
  }

  @override
  Future<PublishSchedule> cancelSchedule(String scheduleId) async {
    await _store.delay();
    _ensureFixtures();

    final existing = _store.findWhere<PublishSchedule>(
      'publish_schedules',
      (s) => s.id == scheduleId,
    );
    if (existing == null) {
      throw NotFoundFailure('Publish schedule not found: $scheduleId');
    }
    if (existing.status == PublishScheduleStatus.cancelled) {
      return existing;
    }
    if (existing.status == PublishScheduleStatus.published) {
      throw const ConflictFailure('Cannot cancel an already published schedule');
    }

    final cancelled = PublishSchedule(
      id: existing.id,
      deliverableId: existing.deliverableId,
      collaborationId: existing.collaborationId,
      scheduledAt: existing.scheduledAt,
      status: PublishScheduleStatus.cancelled,
      platform: existing.platform,
      approvalStatus: existing.approvalStatus,
      notes: existing.notes,
      createdAt: existing.createdAt,
    );
    _store.replaceWhere<PublishSchedule>(
      'publish_schedules',
      (s) => s.id == scheduleId,
      cancelled,
    );
    return cancelled;
  }
}
