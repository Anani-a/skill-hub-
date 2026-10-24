enum BookingStatus { draft, pending, accepted, inService, completed, cancelled, disputed }

class BookingModel {
  final String id;
  final String providerId;
  final String providerName;
  final String providerEmoji;
  final String serviceType;
  final DateTime dateTime;
  final BookingStatus status;
  final double priceEtb;
  final String? voiceNotePath;
  final int? voiceNoteDurationSeconds;
  final bool isEscrowHeld;
  final String description;
  final String? disputeReason;
  final String? customerName;
  final String? customerPhone;
  final String? customerLocation;

  BookingModel({
    required this.id,
    required this.providerId,
    required this.providerName,
    required this.providerEmoji,
    required this.serviceType,
    required this.dateTime,
    required this.status,
    required this.priceEtb,
    this.voiceNotePath,
    this.voiceNoteDurationSeconds,
    required this.description,
    required this.isEscrowHeld,
    this.disputeReason,
    this.customerName,
    this.customerPhone,
    this.customerLocation,
  });

  BookingModel copyWith({
    String? id,
    String? providerId,
    String? providerName,
    String? providerEmoji,
    String? serviceType,
    DateTime? dateTime,
    BookingStatus? status,
    double? priceEtb,
    String? voiceNotePath,
    int? voiceNoteDurationSeconds,
    String? description,
    bool? isEscrowHeld,
    String? disputeReason,
    String? customerName,
    String? customerPhone,
    String? customerLocation,
  }) {
    return BookingModel(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      providerEmoji: providerEmoji ?? this.providerEmoji,
      serviceType: serviceType ?? this.serviceType,
      dateTime: dateTime ?? this.dateTime,
      status: status ?? this.status,
      priceEtb: priceEtb ?? this.priceEtb,
      voiceNotePath: voiceNotePath ?? this.voiceNotePath,
      voiceNoteDurationSeconds: voiceNoteDurationSeconds ?? this.voiceNoteDurationSeconds,
      description: description ?? this.description,
      isEscrowHeld: isEscrowHeld ?? this.isEscrowHeld,
      disputeReason: disputeReason ?? this.disputeReason,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerLocation: customerLocation ?? this.customerLocation,
    );
  }

  // Initial Mock Booking Records
  static List<BookingModel> get mockBookings => [
    BookingModel(
      id: 'b1247',
      providerId: 'p1',
      providerName: 'Bekele Tadesse',
      providerEmoji: '👨‍🔧',
      serviceType: 'Electrical Repair',
      dateTime: DateTime.now().subtract(const Duration(days: 2)),
      status: BookingStatus.completed,
      priceEtb: 500,
      description: 'Complete home electrical repair with circuit safety check and wiring stabilization.',
      isEscrowHeld: false,
      customerName: 'Abel Abreham',
      customerPhone: '+251 911 22 33 44',
      customerLocation: 'Bole, Addis Ababa',
    ),
    BookingModel(
      id: 'b1250',
      providerId: 'p1',
      providerName: 'Bekele Tadesse',
      providerEmoji: '👨‍🔧',
      serviceType: 'Electrical Repair',
      dateTime: DateTime.now().add(const Duration(hours: 2)),
      status: BookingStatus.pending,
      priceEtb: 420,
      description: 'Urgent switchboard inspection and breaker replacement request from a customer near the city center.',
      isEscrowHeld: false,
      customerName: 'Abel Abreham',
      customerPhone: '+251 911 22 33 44',
      customerLocation: 'Bole Medhanealem, Addis Ababa',
    ),
    BookingModel(
      id: 'b1251',
      providerId: 'p1',
      providerName: 'Bekele Tadesse',
      providerEmoji: '👨‍🔧',
      serviceType: 'Appliance Fix',
      dateTime: DateTime.now().add(const Duration(hours: 6)),
      status: BookingStatus.accepted,
      priceEtb: 280,
      description: 'Refrigerator compressor diagnostics and relay check for a customer needing same-day support.',
      isEscrowHeld: true,
      customerName: 'Tigist Haile',
      customerPhone: '+251 912 34 56 78',
      customerLocation: 'CMC, Addis Ababa',
    ),
    BookingModel(
      id: 'b1248',
      providerId: 'p2',
      providerName: 'Hana Mekonnen',
      providerEmoji: '👩‍🔧',
      serviceType: 'Office Deep Clean',
      dateTime: DateTime.now().add(const Duration(hours: 4)),
      status: BookingStatus.inService,
      priceEtb: 360,
      description: 'Deep cleaning for a 3-room office space with upholstery and window treatment.',
      isEscrowHeld: true,
      voiceNotePath: 'mock_audio_clean.ogg',
      voiceNoteDurationSeconds: 15,
      customerName: 'Meron Tadesse',
      customerPhone: '+251 933 44 55 66',
      customerLocation: 'Kazanchis, Addis Ababa',
    ),
    BookingModel(
      id: 'b1249',
      providerId: 'p3',
      providerName: 'Yonas Alemu',
      providerEmoji: '🔧',
      serviceType: 'Pipeline Unclogging',
      dateTime: DateTime.now().add(const Duration(days: 1)),
      status: BookingStatus.pending,
      priceEtb: 200,
      description: 'Urgent pipeline unclogging required in the kitchen sink and bathroom drain.',
      isEscrowHeld: false,
      customerName: 'Solomon Gebre',
      customerPhone: '+251 922 55 66 77',
      customerLocation: 'Sarbet, Addis Ababa',
    ),
  ];
}
