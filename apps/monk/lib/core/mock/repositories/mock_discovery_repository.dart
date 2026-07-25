import '../../../features/discovery/domain/entities/creator_demographics.dart';
import '../../../features/discovery/domain/entities/discovery.dart';
import '../../../features/discovery/domain/repositories/discovery_repository.dart';
import '../../errors/failures.dart';
import '../mock_ids.dart';
import '../mock_seed_store.dart';

/// In-memory [DiscoveryRepository].
///
/// Store keys:
/// - `discovery_influencers` → `List<DiscoveryInfluencer>`
/// - `shortlists` → `List<Shortlist>`
/// - singles `shortlist_brand` → `Map<String, String>` shortlistId → brandId
/// - singles `shortlist_items` → `Map<String, List<ShortlistItem>>`
class MockDiscoveryRepository implements DiscoveryRepository {
  MockDiscoveryRepository(this._store);

  final MockSeedStore _store;

  void _ensureFixtures() {
    if (_store.list<DiscoveryInfluencer>('discovery_influencers').isEmpty) {
      _store.putAll('discovery_influencers', [
        DiscoveryInfluencer(
          id: MockIds.influencer1,
          displayName: 'Arjun Creates',
          biography: 'Lifestyle & beauty creator based in Mumbai.',
          country: 'IN',
          city: 'Mumbai',
          primaryPlatform: 'instagram',
          openToBarter: true,
          followersCount: 125000,
          engagementRate: 3.8,
          minPriceMinor: 500000,
          currency: 'INR',
          creatorScore: 88.5,
          fakeFollowerScore: 9.2,
          credibilityGrade: 'A',
        ),
        DiscoveryInfluencer(
          id: MockIds.influencer2,
          displayName: 'Nisha Reels',
          biography: 'Fashion & travel short-form specialist.',
          country: 'IN',
          city: 'Bengaluru',
          primaryPlatform: 'instagram',
          openToBarter: false,
          followersCount: 82000,
          engagementRate: 4.5,
          minPriceMinor: 350000,
          currency: 'INR',
          creatorScore: 91.0,
          fakeFollowerScore: 6.1,
          credibilityGrade: 'A+',
        ),
        DiscoveryInfluencer(
          id: MockIds.influencer3,
          displayName: 'Tech with Kabir',
          biography: 'Gadgets, reviews, YouTube long-form.',
          country: 'IN',
          city: 'Delhi',
          primaryPlatform: 'youtube',
          openToBarter: true,
          followersCount: 210000,
          engagementRate: 2.9,
          minPriceMinor: 1200000,
          currency: 'INR',
          creatorScore: 84.0,
          fakeFollowerScore: 14.0,
          credibilityGrade: 'B+',
        ),
        const DiscoveryInfluencer(
          id: 'inf-demo-4',
          displayName: 'Foodie Anya',
          biography: 'City food trails and cafe hops.',
          country: 'IN',
          city: 'Pune',
          primaryPlatform: 'instagram',
          openToBarter: true,
          followersCount: 45000,
          engagementRate: 5.1,
          minPriceMinor: 200000,
          currency: 'INR',
          creatorScore: 79.5,
          fakeFollowerScore: 11.0,
          credibilityGrade: 'B',
        ),
        const DiscoveryInfluencer(
          id: 'inf-demo-5',
          displayName: 'Fit Raj',
          biography: 'Fitness coach and product tester.',
          country: 'IN',
          city: 'Hyderabad',
          primaryPlatform: 'youtube',
          openToBarter: false,
          followersCount: 160000,
          engagementRate: 3.2,
          minPriceMinor: 800000,
          currency: 'INR',
          creatorScore: 86.0,
          fakeFollowerScore: 8.5,
          credibilityGrade: 'A',
        ),
      ]);
    }

    if (_store.list<Shortlist>('shortlists').isEmpty) {
      _store.putAll('shortlists', [
        const Shortlist(id: MockIds.shortlist1, name: 'Beauty Launch Shortlist'),
      ]);
      _shortlistBrand()[MockIds.shortlist1] = MockIds.brandOrg1;
      _shortlistItems()[MockIds.shortlist1] = [
        ShortlistItem(
          id: 'sli-demo-1',
          influencerProfileId: MockIds.influencer1,
          displayName: 'Arjun Creates',
          note: 'Top pick for reels',
        ),
        ShortlistItem(
          id: 'sli-demo-2',
          influencerProfileId: MockIds.influencer2,
          displayName: 'Nisha Reels',
        ),
      ];
    }
  }

  Map<String, String> _shortlistBrand() {
    final raw = _store.singles['shortlist_brand'];
    if (raw is Map<String, String>) return raw;
    if (raw is Map) {
      final converted = raw.map((k, v) => MapEntry(k.toString(), v.toString()));
      _store.singles['shortlist_brand'] = converted;
      return converted;
    }
    final map = <String, String>{};
    _store.singles['shortlist_brand'] = map;
    return map;
  }

  Map<String, List<ShortlistItem>> _shortlistItems() {
    final raw = _store.singles['shortlist_items'];
    if (raw is Map<String, List<ShortlistItem>>) return raw;
    if (raw is Map) {
      final converted = <String, List<ShortlistItem>>{};
      raw.forEach((k, v) {
        if (v is List<ShortlistItem>) {
          converted[k.toString()] = v;
        } else if (v is List) {
          converted[k.toString()] = v.whereType<ShortlistItem>().toList();
        }
      });
      _store.singles['shortlist_items'] = converted;
      return converted;
    }
    final map = <String, List<ShortlistItem>>{};
    _store.singles['shortlist_items'] = map;
    return map;
  }

  @override
  Future<({List<DiscoveryInfluencer> items, String? nextCursor})> search(
    DiscoveryFilters filters, {
    String? cursor,
  }) async {
    await _store.delay();
    _ensureFixtures();

    var items = _store.list<DiscoveryInfluencer>('discovery_influencers');

    final q = filters.q.trim().toLowerCase();
    if (q.isNotEmpty) {
      items = items
          .where(
            (i) =>
                (i.displayName?.toLowerCase().contains(q) ?? false) ||
                (i.biography?.toLowerCase().contains(q) ?? false) ||
                (i.city?.toLowerCase().contains(q) ?? false) ||
                i.id.toLowerCase().contains(q),
          )
          .toList();
    }
    if (filters.platform != null && filters.platform!.isNotEmpty) {
      items = items
          .where((i) => i.primaryPlatform == filters.platform)
          .toList();
    }
    if (filters.country != null && filters.country!.isNotEmpty) {
      items = items.where((i) => i.country == filters.country).toList();
    }
    if (filters.openToBarter != null) {
      items = items
          .where((i) => i.openToBarter == filters.openToBarter)
          .toList();
    }
    if (filters.minCreatorScore != null) {
      items = items
          .where(
            (i) => (i.creatorScore ?? 0) >= filters.minCreatorScore!,
          )
          .toList();
    }
    if (filters.maxFakeFollowersScore != null) {
      items = items
          .where(
            (i) =>
                (i.fakeFollowerScore ?? 0) <= filters.maxFakeFollowersScore!,
          )
          .toList();
    }

    switch (filters.sort) {
      case 'followers':
        items.sort(
          (a, b) => (b.followersCount ?? 0).compareTo(a.followersCount ?? 0),
        );
      case 'score':
        items.sort(
          (a, b) => (b.creatorScore ?? 0).compareTo(a.creatorScore ?? 0),
        );
      case 'price':
        items.sort(
          (a, b) => (a.minPriceMinor ?? 0).compareTo(b.minPriceMinor ?? 0),
        );
      default:
        break;
    }

    var start = 0;
    if (cursor != null && cursor.isNotEmpty) {
      start = int.tryParse(cursor) ?? 0;
    }
    const pageSize = 20;
    final page = items.skip(start).take(pageSize).toList();
    final next =
        start + pageSize < items.length ? '${start + pageSize}' : null;
    return (items: page, nextCursor: next);
  }

  @override
  Future<num> getCreatorScore(String influencerId) async {
    await _store.delay();
    _ensureFixtures();
    final inf = _store.findWhere<DiscoveryInfluencer>(
      'discovery_influencers',
      (i) => i.id == influencerId,
    );
    return inf?.creatorScore ?? 85.0;
  }

  @override
  Future<CreatorDemographics> getDemographics(String influencerId) async {
    await _store.delay();
    _ensureFixtures();

    final inf = _store.findWhere<DiscoveryInfluencer>(
      'discovery_influencers',
      (i) => i.id == influencerId,
    );

    return CreatorDemographics(
      influencerId: influencerId,
      creatorScore: inf?.creatorScore ?? 85.0,
      fakeFollowerScore: inf?.fakeFollowerScore ?? 12.0,
      credibilityGrade: inf?.credibilityGrade ?? 'A',
      genderBreakdown: const {'female': 62.0, 'male': 36.0, 'other': 2.0},
      ageBreakdown: const {
        '13-17': 5.0,
        '18-24': 38.0,
        '25-34': 42.0,
        '35-44': 12.0,
        '45+': 3.0,
      },
      topLocations: {
        if (inf?.country != null) inf!.country!: 72.0,
        'United States': 12.0,
        'UAE': 8.0,
        'Other': 8.0,
      },
      topLanguages: const ['English', 'Hindi'],
    );
  }

  @override
  Future<List<Shortlist>> listShortlists(String brandId) async {
    await _store.delay();
    _ensureFixtures();
    final brands = _shortlistBrand();
    return _store
        .list<Shortlist>('shortlists')
        .where((s) => brands[s.id] == brandId)
        .toList();
  }

  @override
  Future<Shortlist> createShortlist(String brandId, String name) async {
    await _store.delay();
    _ensureFixtures();

    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw const ValidationFailure('Shortlist name is required');
    }

    final shortlist = Shortlist(
      id: brandId == MockIds.brandOrg1 &&
              _store.findWhere<Shortlist>(
                    'shortlists',
                    (s) => s.id == MockIds.shortlist1,
                  ) ==
                  null
          ? MockIds.shortlist1
          : 'shortlist-mock-${DateTime.now().microsecondsSinceEpoch}',
      name: trimmed,
    );
    _store.add('shortlists', shortlist);
    _shortlistBrand()[shortlist.id] = brandId;
    _shortlistItems().putIfAbsent(shortlist.id, () => <ShortlistItem>[]);
    return shortlist;
  }

  @override
  Future<void> deleteShortlist(String brandId, String id) async {
    await _store.delay();
    _ensureFixtures();

    final brands = _shortlistBrand();
    if (brands[id] != null && brands[id] != brandId) {
      throw const ForbiddenFailure('Shortlist does not belong to this brand');
    }
    final existing =
        _store.findWhere<Shortlist>('shortlists', (s) => s.id == id);
    if (existing == null) {
      throw NotFoundFailure('Shortlist not found: $id');
    }
    _store.removeWhere<Shortlist>('shortlists', (s) => s.id == id);
    brands.remove(id);
    _shortlistItems().remove(id);
  }

  @override
  Future<List<ShortlistItem>> listItems(
    String brandId,
    String shortlistId,
  ) async {
    await _store.delay();
    _ensureFixtures();
    _assertShortlist(brandId, shortlistId);
    return List<ShortlistItem>.from(
      _shortlistItems()[shortlistId] ?? const [],
    );
  }

  @override
  Future<void> addItem({
    required String brandId,
    required String shortlistId,
    required String influencerProfileId,
  }) async {
    await _store.delay();
    _ensureFixtures();
    _assertShortlist(brandId, shortlistId);

    final items = _shortlistItems().putIfAbsent(
      shortlistId,
      () => <ShortlistItem>[],
    );
    if (items.any((i) => i.influencerProfileId == influencerProfileId)) {
      throw const ConflictFailure(
        'Influencer already on shortlist',
        errorCode: 'DUPLICATE_SHORTLIST_ITEM',
      );
    }

    final inf = _store.findWhere<DiscoveryInfluencer>(
      'discovery_influencers',
      (i) => i.id == influencerProfileId,
    );

    items.add(
      ShortlistItem(
        id: 'sli-mock-${DateTime.now().microsecondsSinceEpoch}',
        influencerProfileId: influencerProfileId,
        displayName: inf?.displayName,
      ),
    );
  }

  @override
  Future<void> removeItem({
    required String brandId,
    required String shortlistId,
    required String itemId,
  }) async {
    await _store.delay();
    _ensureFixtures();
    _assertShortlist(brandId, shortlistId);

    final items = _shortlistItems()[shortlistId] ?? <ShortlistItem>[];
    final before = items.length;
    items.removeWhere((i) => i.id == itemId);
    if (items.length == before) {
      throw NotFoundFailure('Shortlist item not found: $itemId');
    }
    _shortlistItems()[shortlistId] = items;
  }

  void _assertShortlist(String brandId, String shortlistId) {
    final brands = _shortlistBrand();
    final existing =
        _store.findWhere<Shortlist>('shortlists', (s) => s.id == shortlistId);
    if (existing == null) {
      throw NotFoundFailure('Shortlist not found: $shortlistId');
    }
    if (brands[shortlistId] != null && brands[shortlistId] != brandId) {
      throw const ForbiddenFailure('Shortlist does not belong to this brand');
    }
  }
}
