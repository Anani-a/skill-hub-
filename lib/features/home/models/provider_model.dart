enum VerificationStatus { verified, pending, unverified }

class ProviderModel {
  final String id;
  final String name;
  final String emoji;
  final String specialty;
  final String specialtyAmharic;
  final double rating;
  final double distanceKm;
  final int jobsCount;
  final double hourlyRateEtb;
  final bool isOnline;
  final VerificationStatus verificationStatus;
  final String bio;
  final List<String> skills;
  final String? address;
  final String? qualifications;
  final String? coverageArea;
  final String? workingHours;

  ProviderModel({
    required this.id,
    required this.name,
    required this.emoji,
    required this.specialty,
    required this.specialtyAmharic,
    required this.rating,
    required this.distanceKm,
    required this.jobsCount,
    required this.hourlyRateEtb,
    required this.isOnline,
    required this.verificationStatus,
    required this.bio,
    required this.skills,
    this.address,
    this.qualifications,
    this.coverageArea,
    this.workingHours,
  });

  ProviderModel copyWith({
    String? id,
    String? name,
    String? emoji,
    String? specialty,
    String? specialtyAmharic,
    double? rating,
    double? distanceKm,
    int? jobsCount,
    double? hourlyRateEtb,
    bool? isOnline,
    VerificationStatus? verificationStatus,
    String? bio,
    List<String>? skills,
    String? address,
    String? qualifications,
    String? coverageArea,
    String? workingHours,
  }) {
    return ProviderModel(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      specialty: specialty ?? this.specialty,
      specialtyAmharic: specialtyAmharic ?? this.specialtyAmharic,
      rating: rating ?? this.rating,
      distanceKm: distanceKm ?? this.distanceKm,
      jobsCount: jobsCount ?? this.jobsCount,
      hourlyRateEtb: hourlyRateEtb ?? this.hourlyRateEtb,
      isOnline: isOnline ?? this.isOnline,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      bio: bio ?? this.bio,
      skills: skills ?? this.skills,
      address: address ?? this.address,
      qualifications: qualifications ?? this.qualifications,
      coverageArea: coverageArea ?? this.coverageArea,
      workingHours: workingHours ?? this.workingHours,
    );
  }

  // Comprehensive High-Quality Mock Data
  static List<ProviderModel> get mockProviders => [
    ProviderModel(
      id: 'p1',
      name: 'Bekele Tadesse',
      emoji: '👨‍🔧',
      specialty: 'Master Electrician',
      specialtyAmharic: 'ዋና የኤሌክትሪክ ባለሙያ',
      rating: 4.9,
      distanceKm: 1.2,
      jobsCount: 340,
      hourlyRateEtb: 250,
      isOnline: true,
      verificationStatus: VerificationStatus.verified,
      bio: 'Specialized in domestic wiring, solar installation, and power grid repair. Over 8 years of certified service in Addis Ababa.',
      skills: ['Wiring', 'Solar Panels', 'Generator Repair', 'Appliance Fix'],
      address: 'Bole, Addis Ababa',
      qualifications: 'Level IV Certified Electrical Technician',
      coverageArea: 'Bole, Yeka, Kirkos (Up to 10 km)',
      workingHours: 'Mon - Sat: 8:00 AM - 6:00 PM',
    ),
    ProviderModel(
      id: 'p2',
      name: 'Hana Mekonnen',
      emoji: '👩‍🔧',
      specialty: 'Professional Cleaner',
      specialtyAmharic: 'የቤትና ቢሮ ማጽዳት ባለሙያ',
      rating: 4.7,
      distanceKm: 2.5,
      jobsCount: 215,
      hourlyRateEtb: 180,
      isOnline: true,
      verificationStatus: VerificationStatus.verified,
      bio: 'Expert in deep cleaning, home sanitation, and post-construction scrubbing. 100% satisfaction rating guaranteed.',
      skills: ['Deep Clean', 'Sofa Washing', 'Office Sanitization', 'Disinfection'],
    ),
    ProviderModel(
      id: 'p3',
      name: 'Yonas Alemu',
      emoji: '🔧',
      specialty: 'Expert Plumber',
      specialtyAmharic: 'የቧንቧ ሠራተኛ',
      rating: 4.5,
      distanceKm: 3.8,
      jobsCount: 89,
      hourlyRateEtb: 200,
      isOnline: false,
      verificationStatus: VerificationStatus.pending,
      bio: 'Experienced in leakage repair, bathroom systems installation, water pumps maintenance, and drainage pipeline unclogging.',
      skills: ['Pipe Unclogging', 'Leak Fixes', 'Pump Fitting', 'Tiling'],
    ),
    ProviderModel(
      id: 'p4',
      name: 'Tewodros Girma',
      emoji: '📚',
      specialty: 'Mathematics Tutor',
      specialtyAmharic: 'የሂሳብ መምህር',
      rating: 4.8,
      distanceKm: 0.9,
      jobsCount: 145,
      hourlyRateEtb: 300,
      isOnline: true,
      verificationStatus: VerificationStatus.verified,
      bio: 'High school and college level Mathematics tutor with 5 years experience in personalized student academic development.',
      skills: ['Algebra', 'Calculus', 'Exam Prep', 'Statistics'],
    ),
  ];
}
