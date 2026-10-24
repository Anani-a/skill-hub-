import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingServiceItem {
  final String id;
  final String title;
  final double priceEtb;
  final int durationMinutes;
  final bool isActive;
  final String emoji;

  OnboardingServiceItem({
    required this.id,
    required this.title,
    required this.priceEtb,
    required this.durationMinutes,
    this.isActive = true,
    this.emoji = '🧹',
  });

  OnboardingServiceItem copyWith({
    String? id,
    String? title,
    double? priceEtb,
    int? durationMinutes,
    bool? isActive,
    String? emoji,
  }) {
    return OnboardingServiceItem(
      id: id ?? this.id,
      title: title ?? this.title,
      priceEtb: priceEtb ?? this.priceEtb,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      isActive: isActive ?? this.isActive,
      emoji: emoji ?? this.emoji,
    );
  }
}

class ProviderOnboardingState {
  final String profileEmoji;
  final String providerName;
  final String businessName;
  final String serviceCategory;
  final String experienceYears;
  final String aboutText;
  final String locationAddress;
  final double hourlyRateEtb;
  final List<String> skills;
  final List<String> certifications;
  final List<OnboardingServiceItem> services;
  final bool isAvailable;
  final bool isVacationMode;
  final Map<String, String> workingHours;
  final double coverageRadiusKm;

  const ProviderOnboardingState({
    this.profileEmoji = '👨‍🔧',
    this.providerName = 'Abel Abreham',
    this.businessName = 'Abel Cleaning & Repair Services',
    this.serviceCategory = 'Home Services & Cleaning',
    this.experienceYears = '5 years',
    this.aboutText = 'Professional cleaning and maintenance services in Addis Ababa with over 5 years of industry experience.',
    this.locationAddress = 'Bole, Addis Ababa',
    this.hourlyRateEtb = 250.0,
    this.skills = const ['Wiring', 'Solar Panels', 'Appliance Fix', 'Generator Repair'],
    this.certifications = const ['Fayda e-KYC Verified', 'Grade A Certified'],
    this.services = const [],
    this.isAvailable = true,
    this.isVacationMode = false,
    this.workingHours = const {
      'Monday': '08:00 AM - 06:00 PM',
      'Tuesday': '08:00 AM - 06:00 PM',
      'Wednesday': '08:00 AM - 06:00 PM',
      'Thursday': '08:00 AM - 06:00 PM',
      'Friday': '08:00 AM - 06:00 PM',
      'Saturday': '09:00 AM - 04:00 PM',
      'Sunday': '09:00 AM - 04:00 PM',
    },
    this.coverageRadiusKm = 5.0,
  });

  ProviderOnboardingState copyWith({
    String? profileEmoji,
    String? providerName,
    String? businessName,
    String? serviceCategory,
    String? experienceYears,
    String? aboutText,
    String? locationAddress,
    double? hourlyRateEtb,
    List<String>? skills,
    List<String>? certifications,
    List<OnboardingServiceItem>? services,
    bool? isAvailable,
    bool? isVacationMode,
    Map<String, String>? workingHours,
    double? coverageRadiusKm,
  }) {
    return ProviderOnboardingState(
      profileEmoji: profileEmoji ?? this.profileEmoji,
      providerName: providerName ?? this.providerName,
      businessName: businessName ?? this.businessName,
      serviceCategory: serviceCategory ?? this.serviceCategory,
      experienceYears: experienceYears ?? this.experienceYears,
      aboutText: aboutText ?? this.aboutText,
      locationAddress: locationAddress ?? this.locationAddress,
      hourlyRateEtb: hourlyRateEtb ?? this.hourlyRateEtb,
      skills: skills ?? this.skills,
      certifications: certifications ?? this.certifications,
      services: services ?? this.services,
      isAvailable: isAvailable ?? this.isAvailable,
      isVacationMode: isVacationMode ?? this.isVacationMode,
      workingHours: workingHours ?? this.workingHours,
      coverageRadiusKm: coverageRadiusKm ?? this.coverageRadiusKm,
    );
  }
}

class ProviderOnboardingNotifier extends StateNotifier<ProviderOnboardingState> {
  ProviderOnboardingNotifier()
      : super(
          ProviderOnboardingState(
            services: [
              OnboardingServiceItem(id: 's1', title: 'Home Cleaning', priceEtb: 250, durationMinutes: 60, emoji: '🧹'),
              OnboardingServiceItem(id: 's2', title: 'Electrical Repair', priceEtb: 350, durationMinutes: 90, emoji: '⚡'),
              OnboardingServiceItem(id: 's3', title: 'Plumbing Service', priceEtb: 300, durationMinutes: 90, emoji: '🔧'),
              OnboardingServiceItem(id: 's4', title: 'Painting', priceEtb: 400, durationMinutes: 120, emoji: '🎨'),
            ],
          ),
        );

  void updateProfileInfo({
    String? profileEmoji,
    String? providerName,
    String? businessName,
    String? category,
    String? experience,
    String? about,
    String? location,
    double? hourlyRate,
    List<String>? skills,
    List<String>? certifications,
  }) {
    state = state.copyWith(
      profileEmoji: profileEmoji,
      providerName: providerName,
      businessName: businessName,
      serviceCategory: category,
      experienceYears: experience,
      aboutText: about,
      locationAddress: location,
      hourlyRateEtb: hourlyRate,
      skills: skills,
      certifications: certifications,
    );
  }

  void toggleAvailable(bool value) {
    state = state.copyWith(isAvailable: value);
  }

  void toggleVacationMode(bool value) {
    state = state.copyWith(isVacationMode: value);
  }

  void updateWorkingHours(String day, String hours) {
    final updatedMap = Map<String, String>.from(state.workingHours);
    updatedMap[day] = hours;
    state = state.copyWith(workingHours: updatedMap);
  }

  void updateRadius(double radiusKm) {
    state = state.copyWith(coverageRadiusKm: radiusKm);
  }

  void addService(OnboardingServiceItem item) {
    state = state.copyWith(services: [...state.services, item]);
  }

  void removeService(String id) {
    state = state.copyWith(
      services: state.services.where((s) => s.id != id).toList(),
    );
  }
}

final providerOnboardingProvider =
    StateNotifierProvider<ProviderOnboardingNotifier, ProviderOnboardingState>((ref) {
  return ProviderOnboardingNotifier();
});
