import '../../../features/recommendations/domain/entities/recommendation.dart';
import '../../../features/recommendations/domain/repositories/recommendations_repository.dart';
import '../mock_ids.dart';
import '../mock_seed_store.dart';

/// Offline demo implementation of [RecommendationsRepository].
class MockRecommendationsRepository implements RecommendationsRepository {
  MockRecommendationsRepository(this.store);

  final MockSeedStore store;

  static const _key = 'recommendations';

  void _ensureSeeded() {
    if (store.list<Recommendation>(_key).isNotEmpty) return;
    store.putAll(_key, [
      Recommendation(
        id: 'rec-demo-1',
        type: RecommendationType.creator,
        title: 'Arjun Creates',
        subtitle: 'Beauty · 85k followers · high skincare engagement',
        matchScore: 0.92,
        targetId: MockIds.influencer1,
        tags: const ['beauty', 'ugc', 'reels'],
        estimatedBudget: 20000,
        currency: 'INR',
      ),
      Recommendation(
        id: 'rec-demo-2',
        type: RecommendationType.creator,
        title: 'Maya Lifestyle',
        subtitle: 'Lifestyle · 120k followers · metro Gen-Z reach',
        matchScore: 0.84,
        targetId: MockIds.influencer2,
        tags: const ['lifestyle', 'fashion'],
        estimatedBudget: 28000,
        currency: 'INR',
      ),
      Recommendation(
        id: 'rec-demo-3',
        type: RecommendationType.creator,
        title: 'Tech with Sam',
        subtitle: 'Gadgets · 60k followers · unboxing specialist',
        matchScore: 0.76,
        targetId: MockIds.influencer3,
        tags: const ['tech', 'unboxing'],
        estimatedBudget: 35000,
        currency: 'INR',
      ),
      Recommendation(
        id: 'rec-demo-4',
        type: RecommendationType.campaign,
        title: 'Summer Skincare Launch',
        subtitle: 'Applications open · beauty creators preferred',
        matchScore: 0.88,
        targetId: MockIds.campaign1,
        tags: const ['beauty', 'paid', 'barter'],
        estimatedBudget: 250000,
        currency: 'INR',
      ),
      Recommendation(
        id: 'rec-demo-5',
        type: RecommendationType.campaign,
        title: 'Festive Apparel Drop',
        subtitle: 'In progress · hybrid collabs welcome',
        matchScore: 0.71,
        targetId: MockIds.campaign2,
        tags: const ['fashion', 'hybrid'],
        estimatedBudget: 400000,
        currency: 'INR',
      ),
    ]);
  }

  @override
  Future<List<Recommendation>> getRecommendations({
    String? campaignId,
    String? type,
    String? category,
  }) async {
    await store.delay();
    _ensureSeeded();
    var results = store.list<Recommendation>(_key);

    if (type != null && type.isNotEmpty) {
      final want = RecommendationType.fromString(type);
      results = results.where((r) => r.type == want).toList();
    }

    if (category != null && category.isNotEmpty) {
      final cat = category.toLowerCase();
      results = results
          .where(
            (r) =>
                r.tags.any((t) => t.toLowerCase() == cat) ||
                r.subtitle.toLowerCase().contains(cat) ||
                r.title.toLowerCase().contains(cat),
          )
          .toList();
    }

    // When campaignId is provided, prefer creator recommendations (matching UI).
    if (campaignId != null && campaignId.isNotEmpty) {
      final creators =
          results.where((r) => r.type == RecommendationType.creator).toList();
      if (creators.isNotEmpty) return creators;
    }

    return results;
  }
}
