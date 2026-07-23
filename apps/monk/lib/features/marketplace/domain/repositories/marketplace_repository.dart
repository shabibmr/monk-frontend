import '../entities/marketplace.dart';

abstract class MarketplaceRepository {
  Future<({List<MarketplaceCampaign> items, String? nextCursor})> browse({
    String? platform,
    String? objective,
    String? collabType,
    String? cursor,
  });

  Future<MarketplaceCampaign> getCampaign(String id);

  Future<Application> apply({
    required String campaignId,
    required String profileId,
    required String proposedCollabType,
    String? pitch,
    List<Map<String, dynamic>>? proposedPrices,
  });

  Future<List<Application>> listMine(String profileId);

  Future<List<Application>> brandInbox(
    String brandId, {
    String? campaignId,
    String? status,
  });

  Future<Application> shortlist(String applicationId);

  Future<Application> reject(String applicationId, {required String reason});

  Future<Application> withdraw(String applicationId);

  Future<Application> invite({
    required String campaignId,
    required String profileId,
    String? message,
  });

  Future<Application> acceptInvite(String applicationId);

  Future<Application> declineInvite(String applicationId);
}
