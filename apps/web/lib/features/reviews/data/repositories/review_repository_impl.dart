import 'package:api_client/api_client.dart';

import '../../../../core/network/error_mapper.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  ReviewRepositoryImpl(this._client);
  final MonkApiClient _client;

  Review _map(ReviewDto d) => Review(
        id: d.id,
        collaborationId: d.collaborationId,
        reviewerSide: d.reviewerSide,
        visible: d.visible,
        rating: d.rating,
        body: d.body,
        visibleAfter: d.visibleAfter,
        hidden: d.hidden,
      );

  @override
  Future<Review> create({
    required String collaborationId,
    required int rating,
    String? body,
  }) async {
    try {
      return _map(
        await _client.reviews.create(
          collaborationId,
          rating: rating,
          body: body,
        ),
      );
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<List<Review>> listForCollaboration(String collaborationId) async {
    try {
      final list =
          await _client.reviews.listForCollaboration(collaborationId);
      return list.map(_map).toList();
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<List<Review>> listForProfile(String profileId) async {
    try {
      final list = await _client.reviews.listForProfile(profileId);
      return list.map(_map).toList();
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<List<Review>> listForBrand(String brandId) async {
    try {
      final list = await _client.reviews.listForBrand(brandId);
      return list.map(_map).toList();
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<Review> hide(String reviewId) async {
    try {
      return _map(await _client.reviews.hide(reviewId));
    } catch (e) {
      throw mapError(e);
    }
  }
}
