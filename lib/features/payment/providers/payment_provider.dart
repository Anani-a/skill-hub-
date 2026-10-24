import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/payment_model.dart';

class PaymentNotifier extends StateNotifier<AsyncValue<List<PaymentModel>>> {
  PaymentNotifier() : super(const AsyncValue.data([])) {
    _initializeMockPayments();
  }

  void _initializeMockPayments() {
    final payments = PaymentModel.mockPayments;
    state = AsyncValue.data(payments);
  }

  /// Process a new payment
  Future<void> processPayment({
    required String bookingId,
    required double amountEtb,
    required PaymentMethod method,
  }) async {
    state = const AsyncValue.loading();
    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    final newPayment = PaymentModel(
      id: 'pay_${DateTime.now().millisecondsSinceEpoch}',
      bookingId: bookingId,
      amountEtb: amountEtb,
      method: method,
      status: PaymentStatus.completed,
      createdAt: DateTime.now(),
      completedAt: DateTime.now(),
      transactionReference: 'TXN-${DateTime.now().millisecondsSinceEpoch}',
    );

    final currentPayments = state.maybeWhen(
      data: (payments) => payments,
      orElse: () => <PaymentModel>[],
    );

    state = AsyncValue.data([newPayment, ...currentPayments]);
  }

  /// Update payment status
  Future<void> updatePaymentStatus(
    String paymentId,
    PaymentStatus newStatus, {
    String? failureReason,
  }) async {
    state = const AsyncValue.loading();
    await Future.delayed(const Duration(milliseconds: 500));

    final currentPayments = state.maybeWhen(
      data: (payments) => payments,
      orElse: () => <PaymentModel>[],
    );

    final updatedPayments = currentPayments.map((payment) {
      if (payment.id == paymentId) {
        return payment.copyWith(
          status: newStatus,
          completedAt: newStatus == PaymentStatus.completed ? DateTime.now() : null,
          failureReason: failureReason,
        );
      }
      return payment;
    }).toList();

    state = AsyncValue.data(updatedPayments);
  }

  /// Refund a payment
  Future<void> refundPayment(String paymentId) async {
    await updatePaymentStatus(paymentId, PaymentStatus.refunded);
  }

  /// Get payment by ID
  PaymentModel? getPaymentById(String paymentId) {
    return state.maybeWhen(
      data: (payments) => payments.cast<PaymentModel?>().firstWhere(
            (p) => p?.id == paymentId,
            orElse: () => null,
          ),
      orElse: () => null,
    );
  }

  /// Get payments by booking ID
  List<PaymentModel> getPaymentsByBookingId(String bookingId) {
    return state.maybeWhen(
      data: (payments) =>
          payments.where((p) => p.bookingId == bookingId).toList(),
      orElse: () => <PaymentModel>[],
    );
  }
}

// Global payments provider
final paymentsProvider = StateNotifierProvider<PaymentNotifier,
    AsyncValue<List<PaymentModel>>>((ref) {
  return PaymentNotifier();
});

// Derived: completed payments
final completedPaymentsProvider = Provider<List<PaymentModel>>((ref) {
  final payments = ref.watch(paymentsProvider);
  return payments.maybeWhen(
    data: (payments) =>
        payments.where((p) => p.status == PaymentStatus.completed).toList(),
    orElse: () => <PaymentModel>[],
  );
});

// Derived: pending/processing payments
final pendingPaymentsProvider = Provider<List<PaymentModel>>((ref) {
  final payments = ref.watch(paymentsProvider);
  return payments.maybeWhen(
    data: (payments) => payments
        .where((p) =>
            p.status == PaymentStatus.pending ||
            p.status == PaymentStatus.processing)
        .toList(),
    orElse: () => <PaymentModel>[],
  );
});

// Total revenue (completed payments sum)
final totalRevenueProvider = Provider<double>((ref) {
  final payments = ref.watch(paymentsProvider);
  return payments.maybeWhen(
    data: (payments) => payments
        .where((p) => p.status == PaymentStatus.completed)
        .fold(0.0, (sum, p) => sum + p.amountEtb),
    orElse: () => 0.0,
  );
});
