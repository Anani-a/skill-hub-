import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/dispute_model.dart';

class DisputeNotifier extends StateNotifier<AsyncValue<List<DisputeModel>>> {
  DisputeNotifier() : super(const AsyncValue.data([])) {
    _initializeMockDisputes();
  }

  void _initializeMockDisputes() {
    final disputes = DisputeModel.mockDisputes;
    state = AsyncValue.data(disputes);
  }

  /// Open a new dispute
  Future<void> openDispute({
    required String bookingId,
    required String initiatorId,
    required String initiatorName,
    required String respondentId,
    required String respondentName,
    required String reason,
    required String description,
  }) async {
    state = const AsyncValue.loading();
    await Future.delayed(const Duration(milliseconds: 800));

    final newDispute = DisputeModel(
      id: 'd_${DateTime.now().millisecondsSinceEpoch}',
      bookingId: bookingId,
      initiatorId: initiatorId,
      initiatorName: initiatorName,
      respondentId: respondentId,
      respondentName: respondentName,
      reason: reason,
      description: description,
      createdAt: DateTime.now(),
      status: DisputeStatus.opened,
    );

    final currentDisputes = state.maybeWhen(
      data: (disputes) => disputes,
      orElse: () => <DisputeModel>[],
    );

    state = AsyncValue.data([newDispute, ...currentDisputes]);
  }

  /// Update dispute status
  Future<void> updateDisputeStatus(
    String disputeId,
    DisputeStatus newStatus, {
    String? resolution,
    String? resolvedBy,
  }) async {
    state = const AsyncValue.loading();
    await Future.delayed(const Duration(milliseconds: 500));

    final currentDisputes = state.maybeWhen(
      data: (disputes) => disputes,
      orElse: () => <DisputeModel>[],
    );

    final updatedDisputes = currentDisputes.map((dispute) {
      if (dispute.id == disputeId) {
        return dispute.copyWith(
          status: newStatus,
          resolution: resolution,
          resolvedBy: resolvedBy,
        );
      }
      return dispute;
    }).toList();

    state = AsyncValue.data(updatedDisputes);
  }

  /// Get disputes for a user (as initiator or respondent)
  List<DisputeModel> getDisputesForUser(String userId) {
    return state.maybeWhen(
      data: (disputes) => disputes
          .where((d) => d.initiatorId == userId || d.respondentId == userId)
          .toList(),
      orElse: () => <DisputeModel>[],
    );
  }

  /// Get open disputes
  List<DisputeModel> getOpenDisputes() {
    return state.maybeWhen(
      data: (disputes) =>
          disputes
              .where((d) =>
                  d.status == DisputeStatus.opened ||
                  d.status == DisputeStatus.underReview)
              .toList(),
      orElse: () => <DisputeModel>[],
    );
  }
}

// Global disputes provider
final disputesProvider =
    StateNotifierProvider<DisputeNotifier, AsyncValue<List<DisputeModel>>>((ref) {
  return DisputeNotifier();
});

// Derived: open disputes
final openDisputesProvider = Provider<List<DisputeModel>>((ref) {
  final disputes = ref.watch(disputesProvider);
  return disputes.maybeWhen(
    data: (disputes) => disputes
        .where((d) =>
            d.status == DisputeStatus.opened ||
            d.status == DisputeStatus.underReview)
        .toList(),
    orElse: () => <DisputeModel>[],
  );
});

// Derived: disputes by user
final disputesByUserProvider =
    Provider.family<List<DisputeModel>, String>((ref, userId) {
  final disputes = ref.watch(disputesProvider);
  return disputes.maybeWhen(
    data: (disputes) => disputes
        .where((d) => d.initiatorId == userId || d.respondentId == userId)
        .toList(),
    orElse: () => <DisputeModel>[],
  );
});

// Derived: open disputes count
final openDisputesCountProvider = Provider<int>((ref) {
  final openDisputes = ref.watch(openDisputesProvider);
  return openDisputes.length;
});
