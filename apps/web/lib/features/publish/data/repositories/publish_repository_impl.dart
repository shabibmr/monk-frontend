import 'package:api_client/api_client.dart';

import '../../../../core/network/error_mapper.dart';
import '../../domain/entities/publish_schedule.dart';
import '../../domain/entities/published_post.dart';
import '../../domain/repositories/publish_repository.dart';

class PublishRepositoryImpl implements PublishRepository {
  PublishRepositoryImpl(this._client);
  final MonkApiClient _client;

  PublishedPost _map(PublishedPostDto d) => PublishedPost(
        id: d.id,
        collaborationId: d.collaborationId,
        campaignDeliverableId: d.campaignDeliverableId,
        liveUrl: d.liveUrl,
        platform: d.platform,
        ownershipVerified: d.ownershipVerified,
        verificationStatus: d.verificationStatus,
        verificationMethod: d.verificationMethod,
        verificationDetail: d.verificationDetail,
        verifiedAt: d.verifiedAt,
        autoPublish: d.autoPublish,
      );

  PublishSchedule _mapSchedule(PublishScheduleDto d) => PublishSchedule(
        id: d.id,
        deliverableId: d.deliverableId,
        collaborationId: d.collaborationId,
        scheduledAt: DateTime.tryParse(d.scheduledAt) ?? DateTime.now(),
        status: PublishScheduleStatus.fromString(d.status),
        platform: d.platform,
        approvalStatus: d.approvalStatus,
        notes: d.notes,
        createdAt: DateTime.tryParse(d.createdAt ?? ''),
      );

  @override
  Future<PublishedPost> submit({
    required String collaborationId,
    required String deliverableId,
    required String liveUrl,
  }) async {
    try {
      return _map(
        await _client.publish.submit(
          collaborationId: collaborationId,
          deliverableId: deliverableId,
          liveUrl: liveUrl,
        ),
      );
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<PublishedPost> get({
    required String collaborationId,
    required String deliverableId,
  }) async {
    try {
      return _map(
        await _client.publish.get(
          collaborationId: collaborationId,
          deliverableId: deliverableId,
        ),
      );
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<List<PublishedPost>> list(String collaborationId) async {
    try {
      final list = await _client.publish.list(collaborationId);
      return list.map(_map).toList();
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<PublishedPost> manualConfirm(
    String publishedPostId, {
    String? note,
  }) async {
    try {
      return _map(
        await _client.publish.manualConfirm(publishedPostId, note: note),
      );
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<PublishSchedule> schedulePublish({
    required String deliverableId,
    required DateTime scheduledAt,
    required String platform,
    String? notes,
  }) async {
    try {
      final dto = await _client.publish.schedulePublish(
        deliverableId: deliverableId,
        scheduledAt: scheduledAt.toIso8601String(),
        platform: platform,
        notes: notes,
      );
      return _mapSchedule(dto);
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<PublishSchedule?> getSchedule(String deliverableId) async {
    try {
      final dto = await _client.publish.getSchedule(deliverableId);
      return dto != null ? _mapSchedule(dto) : null;
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<PublishSchedule> cancelSchedule(String scheduleId) async {
    try {
      final dto = await _client.publish.cancelSchedule(scheduleId);
      return _mapSchedule(dto);
    } catch (e) {
      throw mapError(e);
    }
  }
}
