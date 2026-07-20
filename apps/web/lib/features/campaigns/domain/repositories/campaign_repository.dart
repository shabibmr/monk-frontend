import '../entities/campaign.dart';

abstract class CampaignRepository {
  Future<List<Campaign>> list(String brandId);
  Future<Campaign> create(Map<String, dynamic> body);
  Future<CampaignDetail> get(String id);
  Future<Campaign> transition(String id, {required String to, String? reason});
  Future<Deliverable> addDeliverable(
    String campaignId,
    Map<String, dynamic> body,
  );
  Future<void> deleteDeliverable(String campaignId, String deliverableId);
}
