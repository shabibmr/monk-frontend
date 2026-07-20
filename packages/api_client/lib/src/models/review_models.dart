class ReviewDto {
  const ReviewDto({
    required this.id,
    required this.collaborationId,
    required this.reviewerSide,
    required this.visible,
    this.rating,
    this.body,
    this.visibleAfter,
    this.hidden = false,
    this.createdAt,
  });

  final String id;
  final String collaborationId;
  final String reviewerSide;
  final bool visible;
  final int? rating;
  final String? body;
  final String? visibleAfter;
  final bool hidden;
  final String? createdAt;

  factory ReviewDto.fromJson(Map<String, dynamic> json) {
    final rating = json['rating'];
    return ReviewDto(
      id: json['id'] as String,
      collaborationId: json['collaborationId'] as String? ?? '',
      reviewerSide: json['reviewerSide'] as String? ?? '',
      visible: json['visible'] as bool? ?? false,
      rating: rating is int
          ? rating
          : rating is num
              ? rating.toInt()
              : int.tryParse('$rating'),
      body: json['body'] as String?,
      visibleAfter: json['visibleAfter']?.toString(),
      hidden: json['hidden'] as bool? ?? false,
      createdAt: json['createdAt']?.toString(),
    );
  }
}
