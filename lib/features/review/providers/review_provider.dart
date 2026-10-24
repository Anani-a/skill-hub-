import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/review_model.dart';

class ReviewNotifier extends StateNotifier<AsyncValue<List<ReviewModel>>> {
  ReviewNotifier() : super(const AsyncValue.data([])) {
    _initializeMockReviews();
  }

  void _initializeMockReviews() {
    final reviews = ReviewModel.mockReviews;
    state = AsyncValue.data(reviews);
  }

  /// Submit a new review
  Future<void> submitReview({
    required String reviewerId,
    required String reviewerName,
    required String targetId,
    required String targetName,
    required double rating,
    required String comment,
    required List<String> tags,
  }) async {
    state = const AsyncValue.loading();
    await Future.delayed(const Duration(milliseconds: 800));

    final newReview = ReviewModel(
      id: 'r_${DateTime.now().millisecondsSinceEpoch}',
      reviewerId: reviewerId,
      reviewerName: reviewerName,
      targetId: targetId,
      targetName: targetName,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
      tags: tags,
    );

    final currentReviews = state.maybeWhen(
      data: (reviews) => reviews,
      orElse: () => <ReviewModel>[],
    );

    state = AsyncValue.data([newReview, ...currentReviews]);
  }

  /// Get reviews for a target (provider/user)
  List<ReviewModel> getReviewsForTarget(String targetId) {
    return state.maybeWhen(
      data: (reviews) =>
          reviews.where((r) => r.targetId == targetId).toList(),
      orElse: () => <ReviewModel>[],
    );
  }

  /// Calculate average rating for a target
  double calculateAverageRating(String targetId) {
    final targetReviews = getReviewsForTarget(targetId);
    if (targetReviews.isEmpty) return 0.0;
    final sum = targetReviews.fold(0.0, (prev, r) => prev + r.rating);
    return sum / targetReviews.length;
  }
}

// Global reviews provider
final reviewsProvider =
    StateNotifierProvider<ReviewNotifier, AsyncValue<List<ReviewModel>>>((ref) {
  return ReviewNotifier();
});

// Derived: reviews by target (provider family)
final reviewsByTargetProvider =
    Provider.family<List<ReviewModel>, String>((ref, targetId) {
  final reviews = ref.watch(reviewsProvider);
  return reviews.maybeWhen(
    data: (reviews) =>
        reviews.where((r) => r.targetId == targetId).toList(),
    orElse: () => <ReviewModel>[],
  );
});

// Derived: average rating for target (provider family)
final averageRatingProvider = Provider.family<double, String>((ref, targetId) {
  final reviews = ref.watch(reviewsByTargetProvider(targetId));
  if (reviews.isEmpty) return 0.0;
  final sum = reviews.fold(0.0, (prev, r) => prev + r.rating);
  return sum / reviews.length;
});

// Derived: high-rated reviews (4+ stars)
final highRatedReviewsProvider = Provider<List<ReviewModel>>((ref) {
  final reviews = ref.watch(reviewsProvider);
  return reviews.maybeWhen(
    data: (reviews) => reviews.where((r) => r.rating >= 4.0).toList(),
    orElse: () => <ReviewModel>[],
  );
});
