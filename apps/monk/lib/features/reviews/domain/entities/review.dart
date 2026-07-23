import 'package:equatable/equatable.dart';

bool isValidStarRating(int rating) => rating >= 1 && rating <= 5;

class Review extends Equatable {
  const Review({
    required this.id,
    required this.collaborationId,
    required this.reviewerSide,
    required this.visible,
    this.rating,
    this.body,
    this.visibleAfter,
    this.hidden = false,
  });

  final String id;
  final String collaborationId;
  final String reviewerSide;
  final bool visible;
  final int? rating;
  final String? body;
  final String? visibleAfter;
  final bool hidden;

  bool get isBrandSide => reviewerSide == 'brand';

  @override
  List<Object?> get props =>
      [id, collaborationId, reviewerSide, visible, rating, body, visibleAfter, hidden];
}
