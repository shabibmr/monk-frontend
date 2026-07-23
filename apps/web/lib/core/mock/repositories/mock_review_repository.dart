import '../../../features/reviews/domain/entities/review.dart';
import '../../../features/reviews/domain/repositories/review_repository.dart';
import '../../errors/failures.dart';
import '../mock_ids.dart';
import '../mock_seed_store.dart';

/// Offline demo implementation of [ReviewRepository].
class MockReviewRepository implements ReviewRepository {
  MockReviewRepository(this.store);

  final MockSeedStore store;

  static const _key = 'reviews';
  /// Side index: reviewId → {profileId, brandId} for list filters.
  static const _metaKey = 'review_meta';

  void _ensureSeeded() {
    if (store.list<Review>(_key).isNotEmpty) return;
    store.putAll(_key, [
      Review(
        id: 'review-demo-1',
        collaborationId: MockIds.collab1,
        reviewerSide: 'brand',
        visible: true,
        rating: 5,
        body: 'Excellent delivery quality and on-time posting.',
        visibleAfter: DateTime.now()
            .subtract(const Duration(days: 2))
            .toIso8601String(),
      ),
      Review(
        id: 'review-demo-2',
        collaborationId: MockIds.collab1,
        reviewerSide: 'influencer',
        visible: true,
        rating: 4,
        body: 'Smooth brand communication and clear brief.',
        visibleAfter: DateTime.now()
            .subtract(const Duration(days: 1))
            .toIso8601String(),
      ),
    ]);
    store.putAll(_metaKey, [
      {
        'reviewId': 'review-demo-1',
        'profileId': MockIds.influencer1,
        'brandId': MockIds.brandOrg1,
        'collaborationId': MockIds.collab1,
      },
      {
        'reviewId': 'review-demo-2',
        'profileId': MockIds.influencer1,
        'brandId': MockIds.brandOrg1,
        'collaborationId': MockIds.collab1,
      },
    ]);
  }

  @override
  Future<Review> create({
    required String collaborationId,
    required int rating,
    String? body,
  }) async {
    await store.delay();
    _ensureSeeded();
    if (!isValidStarRating(rating)) {
      throw const ValidationFailure('Rating must be between 1 and 5.');
    }
    if (collaborationId.isEmpty) {
      throw const ValidationFailure('collaborationId is required.');
    }
    final review = Review(
      id: 'review-mock-${DateTime.now().millisecondsSinceEpoch}',
      collaborationId: collaborationId,
      reviewerSide: 'brand',
      visible: true,
      rating: rating,
      body: body,
      visibleAfter: DateTime.now().toIso8601String(),
    );
    store.add(_key, review);
    store.add(_metaKey, {
      'reviewId': review.id,
      'profileId': MockIds.influencer1,
      'brandId': store.primaryBrandId,
      'collaborationId': collaborationId,
    });
    return review;
  }

  @override
  Future<List<Review>> listForCollaboration(String collaborationId) async {
    await store.delay();
    _ensureSeeded();
    return store
        .list<Review>(_key)
        .where((r) => r.collaborationId == collaborationId && !r.hidden)
        .toList();
  }

  Set<String> _reviewIdsWhere(bool Function(Map meta) test) {
    final raw = store.collections[_metaKey] ?? const [];
    final ids = <String>{};
    for (final item in raw) {
      if (item is Map && test(item)) {
        final id = item['reviewId'];
        if (id is String) ids.add(id);
      }
    }
    return ids;
  }

  @override
  Future<List<Review>> listForProfile(String profileId) async {
    await store.delay();
    _ensureSeeded();
    final ids = _reviewIdsWhere((m) => m['profileId'] == profileId);
    return store
        .list<Review>(_key)
        .where((r) => ids.contains(r.id) && !r.hidden && r.visible)
        .toList();
  }

  @override
  Future<List<Review>> listForBrand(String brandId) async {
    await store.delay();
    _ensureSeeded();
    final ids = _reviewIdsWhere((m) => m['brandId'] == brandId);
    return store
        .list<Review>(_key)
        .where((r) => ids.contains(r.id) && !r.hidden && r.visible)
        .toList();
  }

  @override
  Future<Review> hide(String reviewId) async {
    await store.delay();
    _ensureSeeded();
    final existing = store.findWhere<Review>(_key, (r) => r.id == reviewId);
    if (existing == null) {
      throw NotFoundFailure('Review not found: $reviewId');
    }
    final updated = Review(
      id: existing.id,
      collaborationId: existing.collaborationId,
      reviewerSide: existing.reviewerSide,
      visible: false,
      rating: existing.rating,
      body: existing.body,
      visibleAfter: existing.visibleAfter,
      hidden: true,
    );
    store.replaceWhere<Review>(_key, (r) => r.id == reviewId, updated);
    return updated;
  }
}
