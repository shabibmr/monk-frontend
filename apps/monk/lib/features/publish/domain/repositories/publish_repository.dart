import '../entities/publish_schedule.dart';
import '../entities/published_post.dart';

abstract class PublishRepository {
  Future<PublishedPost> submit({
    required String collaborationId,
    required String deliverableId,
    required String liveUrl,
  });

  Future<PublishedPost> get({
    required String collaborationId,
    required String deliverableId,
  });

  Future<List<PublishedPost>> list(String collaborationId);

  Future<PublishedPost> manualConfirm(String publishedPostId, {String? note});

  Future<PublishSchedule> schedulePublish({
    required String deliverableId,
    required DateTime scheduledAt,
    required String platform,
    String? notes,
  });

  Future<PublishSchedule?> getSchedule(String deliverableId);

  Future<PublishSchedule> cancelSchedule(String scheduleId);
}
