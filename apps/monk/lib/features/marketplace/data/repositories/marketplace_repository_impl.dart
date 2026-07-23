import 'package:api_client/api_client.dart';

import '../../../../core/network/error_mapper.dart';
import '../../domain/entities/marketplace.dart';
import '../../domain/repositories/marketplace_repository.dart';

class MarketplaceRepositoryImpl implements MarketplaceRepository {
  MarketplaceRepositoryImpl(this._client);
  final MonkApiClient _client;

  MarketplaceCampaign _mapCampaign(MarketplaceCampaignDto d) =>
      MarketplaceCampaign(
        id: d.id,
        name: d.name,
        code: d.code,
        status: d.status,
        mode: d.mode,
        objective: d.objective,
        currency: d.currency,
        budgetTotalMinor: d.budgetTotalMinor,
        permittedCollabTypes: d.permittedCollabTypes,
        brand: d.brand == null
            ? null
            : MarketplaceBrand(
                id: d.brand!.id,
                companyName: d.brand!.companyName,
                country: d.brand!.country,
                industry: d.brand!.industry,
              ),
        deliverables: d.deliverables
            .map(
              (x) => MarketplaceDeliverable(
                id: x.id,
                platform: x.platform,
                deliverableType: x.deliverableType,
                disclosureTags: x.disclosureTags,
                captionGuidelines: x.captionGuidelines,
              ),
            )
            .toList(),
      );

  Application _mapApp(ApplicationDto d) => Application(
        id: d.id,
        campaignId: d.campaignId,
        influencerProfileId: d.influencerProfileId,
        origin: d.origin,
        status: d.status,
        pitch: d.pitch,
        proposedCollabType: d.proposedCollabType,
        rejectionReason: d.rejectionReason,
        createdAt: d.createdAt,
      );

  @override
  Future<({List<MarketplaceCampaign> items, String? nextCursor})> browse({
    String? platform,
    String? objective,
    String? collabType,
    String? cursor,
  }) async {
    try {
      final page = await _client.applications.browseMarketplace(
        platform: platform,
        objective: objective,
        collabType: collabType,
        cursor: cursor,
      );
      return (
        items: page.data.map(_mapCampaign).toList(),
        nextCursor: page.nextCursor,
      );
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<MarketplaceCampaign> getCampaign(String id) async {
    try {
      return _mapCampaign(await _client.applications.getMarketplaceCampaign(id));
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<Application> apply({
    required String campaignId,
    required String profileId,
    required String proposedCollabType,
    String? pitch,
    List<Map<String, dynamic>>? proposedPrices,
  }) async {
    try {
      return _mapApp(
        await _client.applications.apply(campaignId, {
          'profileId': profileId,
          'proposedCollabType': proposedCollabType,
          if (pitch != null && pitch.isNotEmpty) 'pitch': pitch,
          if (proposedPrices != null) 'proposedPrices': proposedPrices,
        }),
      );
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<List<Application>> listMine(String profileId) async {
    try {
      final list = await _client.applications.listMine(profileId);
      return list.map(_mapApp).toList();
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<List<Application>> brandInbox(
    String brandId, {
    String? campaignId,
    String? status,
  }) async {
    try {
      final list = await _client.applications.brandInbox(
        brandId,
        campaignId: campaignId,
        status: status,
      );
      return list.map(_mapApp).toList();
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<Application> shortlist(String applicationId) async {
    try {
      return _mapApp(await _client.applications.shortlist(applicationId));
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<Application> reject(
    String applicationId, {
    required String reason,
  }) async {
    try {
      return _mapApp(
        await _client.applications.reject(applicationId, reason: reason),
      );
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<Application> withdraw(String applicationId) async {
    try {
      return _mapApp(await _client.applications.withdraw(applicationId));
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<Application> invite({
    required String campaignId,
    required String profileId,
    String? message,
  }) async {
    try {
      return _mapApp(
        await _client.applications.invite(
          campaignId,
          profileId: profileId,
          message: message,
        ),
      );
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<Application> acceptInvite(String applicationId) async {
    try {
      return _mapApp(await _client.applications.acceptInvite(applicationId));
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<Application> declineInvite(String applicationId) async {
    try {
      return _mapApp(await _client.applications.declineInvite(applicationId));
    } catch (e) {
      throw mapError(e);
    }
  }
}
