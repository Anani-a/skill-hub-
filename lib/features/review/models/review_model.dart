class ReviewModel {
  final String id;
  final String reviewerId;
  final String reviewerName;
  final String targetId; // Provider ID if reviewing provider, User ID if reviewing customer
  final String targetName;
  final double rating; // 1.0 to 5.0
  final String comment;
  final DateTime createdAt;
  final List<String> tags; // e.g., ['professional', 'punctual', 'friendly']

  ReviewModel({
    required this.id,
    required this.reviewerId,
    required this.reviewerName,
    required this.targetId,
    required this.targetName,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.tags,
  });

  ReviewModel copyWith({
    String? id,
    String? reviewerId,
    String? reviewerName,
    String? targetId,
    String? targetName,
    double? rating,
    String? comment,
    DateTime? createdAt,
    List<String>? tags,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      reviewerId: reviewerId ?? this.reviewerId,
      reviewerName: reviewerName ?? this.reviewerName,
      targetId: targetId ?? this.targetId,
      targetName: targetName ?? this.targetName,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      tags: tags ?? this.tags,
    );
  }

  static List<ReviewModel> get mockReviews => [
    ReviewModel(
      id: 'r1',
      reviewerId: 'u1',
      reviewerName: 'Abel Abreham',
      targetId: 'p1',
      targetName: 'Bekele Tadesse',
      rating: 4.8,
      comment: 'Excellent electrician! Very professional and completed the job quickly.',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      tags: ['professional', 'punctual', 'thorough'],
    ),
    ReviewModel(
      id: 'r2',
      reviewerId: 'u2',
      reviewerName: 'Hana Mekonnen',
      targetId: 'p2',
      targetName: 'Yonas Alemu',
      rating: 4.5,
      comment: 'Good service, arrived on time. Very friendly.',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      tags: ['friendly', 'punctual'],
    ),
  ];
}
