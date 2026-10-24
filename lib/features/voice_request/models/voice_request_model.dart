enum VoiceRequestStatus { draft, recording, submitted, accepted, completed, rejected }

class VoiceRequestModel {
  final String id;
  final String title;
  final String description;
  final String audioPath;
  final int durationSeconds;
  final DateTime createdAt;
  final VoiceRequestStatus status;
  final List<String> categoryTags;
  final double? budgetEtb;
  final DateTime? preferredDateTime;

  VoiceRequestModel({
    required this.id,
    required this.title,
    required this.description,
    required this.audioPath,
    required this.durationSeconds,
    required this.createdAt,
    required this.status,
    required this.categoryTags,
    this.budgetEtb,
    this.preferredDateTime,
  });

  VoiceRequestModel copyWith({
    String? id,
    String? title,
    String? description,
    String? audioPath,
    int? durationSeconds,
    DateTime? createdAt,
    VoiceRequestStatus? status,
    List<String>? categoryTags,
    double? budgetEtb,
    DateTime? preferredDateTime,
  }) {
    return VoiceRequestModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      audioPath: audioPath ?? this.audioPath,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      categoryTags: categoryTags ?? this.categoryTags,
      budgetEtb: budgetEtb ?? this.budgetEtb,
      preferredDateTime: preferredDateTime ?? this.preferredDateTime,
    );
  }

  // Mock voice requests
  static List<VoiceRequestModel> get mockRequests => [
    VoiceRequestModel(
      id: 'vr1',
      title: 'Electrical Problem at Home',
      description: 'Strange buzzing sound from the main circuit breaker',
      audioPath: 'mock_audio_1.ogg',
      durationSeconds: 45,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      status: VoiceRequestStatus.submitted,
      categoryTags: ['electrical', 'urgent'],
      budgetEtb: 300,
      preferredDateTime: DateTime.now().add(const Duration(hours: 6)),
    ),
    VoiceRequestModel(
      id: 'vr2',
      title: 'Plumbing Leak Detection',
      description: 'Water leak somewhere in the walls, need to locate it',
      audioPath: 'mock_audio_2.ogg',
      durationSeconds: 32,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      status: VoiceRequestStatus.accepted,
      categoryTags: ['plumbing', 'leak'],
      budgetEtb: 500,
      preferredDateTime: DateTime.now().add(const Duration(days: 1)),
    ),
  ];
}
