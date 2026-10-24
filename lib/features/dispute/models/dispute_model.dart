enum DisputeStatus { opened, underReview, resolved, closed }

class DisputeModel {
  final String id;
  final String bookingId;
  final String initiatorId;
  final String initiatorName;
  final String respondentId;
  final String respondentName;
  final String reason;
  final String description;
  final DateTime createdAt;
  final DisputeStatus status;
  final String? resolution;
  final String? resolvedBy; // Admin/moderator ID

  DisputeModel({
    required this.id,
    required this.bookingId,
    required this.initiatorId,
    required this.initiatorName,
    required this.respondentId,
    required this.respondentName,
    required this.reason,
    required this.description,
    required this.createdAt,
    required this.status,
    this.resolution,
    this.resolvedBy,
  });

  DisputeModel copyWith({
    String? id,
    String? bookingId,
    String? initiatorId,
    String? initiatorName,
    String? respondentId,
    String? respondentName,
    String? reason,
    String? description,
    DateTime? createdAt,
    DisputeStatus? status,
    String? resolution,
    String? resolvedBy,
  }) {
    return DisputeModel(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      initiatorId: initiatorId ?? this.initiatorId,
      initiatorName: initiatorName ?? this.initiatorName,
      respondentId: respondentId ?? this.respondentId,
      respondentName: respondentName ?? this.respondentName,
      reason: reason ?? this.reason,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      resolution: resolution ?? this.resolution,
      resolvedBy: resolvedBy ?? this.resolvedBy,
    );
  }

  static List<DisputeModel> get mockDisputes => [
    DisputeModel(
      id: 'd1',
      bookingId: 'b1247',
      initiatorId: 'u1',
      initiatorName: 'Abel Abreham',
      respondentId: 'p1',
      respondentName: 'Bekele Tadesse',
      reason: 'Service not completed',
      description: 'The electrician left without finishing the work',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      status: DisputeStatus.underReview,
    ),
  ];
}
