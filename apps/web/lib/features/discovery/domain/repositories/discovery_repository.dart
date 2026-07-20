import '../entities/creator_demographics.dart';
import '../entities/discovery.dart';

abstract class DiscoveryRepository {
  Future<({List<DiscoveryInfluencer> items, String? nextCursor})> search(
    DiscoveryFilters filters, {
    String? cursor,
  });

  Future<num> getCreatorScore(String influencerId);
  Future<CreatorDemographics> getDemographics(String influencerId);

  Future<List<Shortlist>> listShortlists(String brandId);
  Future<Shortlist> createShortlist(String brandId, String name);
  Future<void> deleteShortlist(String brandId, String id);
  Future<List<ShortlistItem>> listItems(String brandId, String shortlistId);
  Future<void> addItem({
    required String brandId,
    required String shortlistId,
    required String influencerProfileId,
  });
  Future<void> removeItem({
    required String brandId,
    required String shortlistId,
    required String itemId,
  });
}

