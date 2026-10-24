enum PaymentStatus { pending, processing, completed, failed, refunded }

enum PaymentMethod { creditCard, mobileWallet, bankTransfer, cash }

class PaymentModel {
  final String id;
  final String bookingId;
  final double amountEtb;
  final PaymentMethod method;
  final PaymentStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? transactionReference;
  final String? failureReason;

  PaymentModel({
    required this.id,
    required this.bookingId,
    required this.amountEtb,
    required this.method,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.transactionReference,
    this.failureReason,
  });

  PaymentModel copyWith({
    String? id,
    String? bookingId,
    double? amountEtb,
    PaymentMethod? method,
    PaymentStatus? status,
    DateTime? createdAt,
    DateTime? completedAt,
    String? transactionReference,
    String? failureReason,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      amountEtb: amountEtb ?? this.amountEtb,
      method: method ?? this.method,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      transactionReference: transactionReference ?? this.transactionReference,
      failureReason: failureReason ?? this.failureReason,
    );
  }

  static List<PaymentModel> get mockPayments => [
    PaymentModel(
      id: 'pay1',
      bookingId: 'b1247',
      amountEtb: 500,
      method: PaymentMethod.creditCard,
      status: PaymentStatus.completed,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      completedAt: DateTime.now().subtract(const Duration(days: 2, hours: 1)),
      transactionReference: 'TXN-202406-001',
    ),
    PaymentModel(
      id: 'pay2',
      bookingId: 'b1248',
      amountEtb: 360,
      method: PaymentMethod.mobileWallet,
      status: PaymentStatus.processing,
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      transactionReference: 'TXN-202406-002',
    ),
  ];
}
