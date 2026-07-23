import '../entities/review.dart';

abstract class ReviewRepository {
  Future<Review> create({
    required String collaborationId,
    required int rating,
    String? body,
  });

  Future<List<Review>> listForCollaboration(String collaborationId);

  Future<List<Review>> listForProfile(String profileId);

  Future<List<Review>> listForBrand(String brandId);

  Future<Review> hide(String reviewId);
}
