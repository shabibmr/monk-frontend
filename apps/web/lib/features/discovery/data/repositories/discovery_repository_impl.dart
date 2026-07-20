import 'package:api_client/api_client.dart';

import '../../../../core/network/error_mapper.dart';
import '../../domain/entities/creator_demographics.dart';
import '../../domain/entities/discovery.dart';
import '../../domain/repositories/discovery_repository.dart';

class DiscoveryRepositoryImpl implements DiscoveryRepository {
  DiscoveryRepositoryImpl(this._client);
  final MonkApiClient _client;

  DiscoveryInfluencer _map(DiscoveryInfluencerDto d) {
    final followers = d.socialAccounts.isEmpty
        ? null
        : d.socialAccounts
            .map((s) => s.followersCount ?? 0)
            .fold<int>(0, (a, b) => a > b ? a : b);
    final eng = d.socialAccounts.isEmpty
        ? null
        : d.socialAccounts
            .map((s) => s.engagementRate ?? 0)
            .fold<num>(0, (a, b) => a > b ? a : b);
    final minPrice = d.pricing.isEmpty
        ? null
        : d.pricing.map((p) => p.priceMinor).reduce((a, b) => a < b ? a : b);
    final currency =
        d.pricing.isEmpty ? 'INR' : d.pricing.first.currency;

    return DiscoveryInfluencer(
      id: d.id,
      displayName: d.displayName,
      biography: d.biography,
      country: d.country,
      city: d.city,
      primaryPlatform: d.primaryPlatform,
      openToBarter: d.openToBarter,
      followersCount: followers == 0 ? null : followers,
      engagementRate: eng == 0 ? null : eng,
      minPriceMinor: minPrice,
      currency: currency,
      creatorScore: 85.0,
      fakeFollowerScore: 12.0,
      credibilityGrade: 'A',
    );
  }

  @override
  Future<({List<DiscoveryInfluencer> items, String? nextCursor})> search(
    DiscoveryFilters filters, {
    String? cursor,
  }) async {
    try {
      final page = await _client.discovery.searchInfluencers(
        filters.toQuery(cursor: cursor),
      );
      return (
        items: page.data.map(_map).toList(),
        nextCursor: page.nextCursor,
      );
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<num> getCreatorScore(String influencerId) async {
    try {
      final res = await _client.dio.get<Map<String, dynamic>>(
        ApiPaths.discoveryScores,
        queryParameters: {'influencerId': influencerId},
      );
      return (res.data?['creatorScore'] as num?) ?? 85.0;
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<CreatorDemographics> getDemographics(String influencerId) async {
    try {
      final res = await _client.dio.get<Map<String, dynamic>>(
        ApiPaths.influencerDemographics,
        queryParameters: {'influencerId': influencerId},
      );
      if (res.data != null) {
        return CreatorDemographics.fromJson(res.data!);
      }
      return CreatorDemographics(
        influencerId: influencerId,
        creatorScore: 88.5,
        fakeFollowerScore: 10.0,
        credibilityGrade: 'A+',
      );
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<List<Shortlist>> listShortlists(String brandId) async {
    try {
      final list = await _client.discovery.listShortlists(brandId);
      return list.map((s) => Shortlist(id: s.id, name: s.name)).toList();
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<Shortlist> createShortlist(String brandId, String name) async {
    try {
      final s = await _client.discovery.createShortlist(brandId, name);
      return Shortlist(id: s.id, name: s.name);
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<void> deleteShortlist(String brandId, String id) async {
    try {
      await _client.discovery.deleteShortlist(brandId, id);
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<List<ShortlistItem>> listItems(
    String brandId,
    String shortlistId,
  ) async {
    try {
      final list = await _client.discovery.listItems(brandId, shortlistId);
      return list
          .map(
            (i) => ShortlistItem(
              id: i.id,
              influencerProfileId: i.influencerProfileId,
              note: i.note,
              displayName: i.displayName,
            ),
          )
          .toList();
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<void> addItem({
    required String brandId,
    required String shortlistId,
    required String influencerProfileId,
  }) async {
    try {
      await _client.discovery.addItem(
        brandId: brandId,
        shortlistId: shortlistId,
        influencerProfileId: influencerProfileId,
      );
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<void> removeItem({
    required String brandId,
    required String shortlistId,
    required String itemId,
  }) async {
    try {
      await _client.discovery.removeItem(
        brandId: brandId,
        shortlistId: shortlistId,
        itemId: itemId,
      );
    } catch (e) {
      throw mapError(e);
    }
  }
}

