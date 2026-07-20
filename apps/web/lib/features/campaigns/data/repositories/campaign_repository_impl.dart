import 'package:api_client/api_client.dart';

import '../../../../core/network/error_mapper.dart';
import '../../domain/entities/campaign.dart';
import '../../domain/repositories/campaign_repository.dart';

class CampaignRepositoryImpl implements CampaignRepository {
  CampaignRepositoryImpl(this._client);
  final MonkApiClient _client;

  Campaign _map(CampaignDto d) => Campaign(
        id: d.id,
        brandId: d.brandId,
        name: d.name,
        code: d.code,
        status: d.status,
        mode: d.mode,
        objective: d.objective,
        currency: d.currency,
        budgetTotalMinor: d.budgetTotalMinor,
        deliverableCount: d.deliverableCount ?? 0,
      );

  Deliverable _mapDel(DeliverableDto d) => Deliverable(
        id: d.id,
        platform: d.platform,
        deliverableType: d.deliverableType,
        disclosureTags: d.disclosureTags,
        captionGuidelines: d.captionGuidelines,
      );

  @override
  Future<List<Campaign>> list(String brandId) async {
    try {
      final list = await _client.campaigns.list(brandId);
      return list.map(_map).toList();
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<Campaign> create(Map<String, dynamic> body) async {
    try {
      return _map(await _client.campaigns.create(body));
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<CampaignDetail> get(String id) async {
    try {
      final d = await _client.campaigns.get(id);
      return CampaignDetail(
        campaign: _map(d.campaign).copyWithDeliverableCount(
          d.deliverables.length,
        ),
        deliverables: d.deliverables.map(_mapDel).toList(),
      );
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<Campaign> transition(
    String id, {
    required String to,
    String? reason,
  }) async {
    try {
      return _map(
        await _client.campaigns.transition(id, to: to, reason: reason),
      );
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<Deliverable> addDeliverable(
    String campaignId,
    Map<String, dynamic> body,
  ) async {
    try {
      return _mapDel(
        await _client.campaigns.addDeliverable(campaignId, body),
      );
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<void> deleteDeliverable(
    String campaignId,
    String deliverableId,
  ) async {
    try {
      await _client.campaigns.deleteDeliverable(campaignId, deliverableId);
    } catch (e) {
      throw mapError(e);
    }
  }
}

extension on Campaign {
  Campaign copyWithDeliverableCount(int count) => Campaign(
        id: id,
        brandId: brandId,
        name: name,
        code: code,
        status: status,
        mode: mode,
        objective: objective,
        currency: currency,
        budgetTotalMinor: budgetTotalMinor,
        deliverableCount: count,
      );
}
