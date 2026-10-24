import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/voice_request_model.dart';

class VoiceRequestNotifier extends StateNotifier<AsyncValue<List<VoiceRequestModel>>> {
  VoiceRequestNotifier() : super(const AsyncValue.data([])) {
    _initializeMockRequests();
  }

  void _initializeMockRequests() {
    final requests = VoiceRequestModel.mockRequests;
    state = AsyncValue.data(requests);
  }

  /// Submit a new voice request
  Future<void> submitVoiceRequest({
    required String title,
    required String description,
    required String audioPath,
    required int durationSeconds,
    required List<String> categoryTags,
    double? budgetEtb,
    DateTime? preferredDateTime,
  }) async {
    state = const AsyncValue.loading();
    await Future.delayed(const Duration(milliseconds: 800));

    final newRequest = VoiceRequestModel(
      id: 'vr_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: description,
      audioPath: audioPath,
      durationSeconds: durationSeconds,
      createdAt: DateTime.now(),
      status: VoiceRequestStatus.submitted,
      categoryTags: categoryTags,
      budgetEtb: budgetEtb,
      preferredDateTime: preferredDateTime,
    );

    final currentRequests = state.maybeWhen(
      data: (requests) => requests,
      orElse: () => <VoiceRequestModel>[],
    );

    state = AsyncValue.data([newRequest, ...currentRequests]);
  }

  /// Update request status
  Future<void> updateRequestStatus(
    String requestId,
    VoiceRequestStatus newStatus,
  ) async {
    state = const AsyncValue.loading();
    await Future.delayed(const Duration(milliseconds: 400));

    final currentRequests = state.maybeWhen(
      data: (requests) => requests,
      orElse: () => <VoiceRequestModel>[],
    );

    final updatedRequests = currentRequests.map((req) {
      if (req.id == requestId) {
        return req.copyWith(status: newStatus);
      }
      return req;
    }).toList();

    state = AsyncValue.data(updatedRequests);
  }

  /// Get requests by status
  List<VoiceRequestModel> getRequestsByStatus(VoiceRequestStatus status) {
    return state.maybeWhen(
      data: (requests) => requests.where((r) => r.status == status).toList(),
      orElse: () => <VoiceRequestModel>[],
    );
  }
}

// Global voice requests provider
final voiceRequestsProvider = StateNotifierProvider<VoiceRequestNotifier,
    AsyncValue<List<VoiceRequestModel>>>((ref) {
  return VoiceRequestNotifier();
});

// Derived: submitted requests
final submittedRequestsProvider = Provider<List<VoiceRequestModel>>((ref) {
  final requests = ref.watch(voiceRequestsProvider);
  return requests.maybeWhen(
    data: (requests) =>
        requests.where((r) => r.status == VoiceRequestStatus.submitted).toList(),
    orElse: () => <VoiceRequestModel>[],
  );
});

// Derived: accepted requests
final acceptedRequestsProvider = Provider<List<VoiceRequestModel>>((ref) {
  final requests = ref.watch(voiceRequestsProvider);
  return requests.maybeWhen(
    data: (requests) =>
        requests.where((r) => r.status == VoiceRequestStatus.accepted).toList(),
    orElse: () => <VoiceRequestModel>[],
  );
});
