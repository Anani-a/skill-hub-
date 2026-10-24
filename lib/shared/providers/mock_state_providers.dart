import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../features/home/models/provider_model.dart';
import '../../features/booking/models/booking_model.dart';
import '../../features/chat/models/chat_model.dart';

// 1. Language Preference State Provider
class LanguageNotifier extends StateNotifier<String> {
  LanguageNotifier() : super('am'); // Default is Amharic as specified

  void setLanguage(String lang) {
    state = lang;
  }
}

final languageProvider = StateNotifierProvider<LanguageNotifier, String>((ref) {
  return LanguageNotifier();
});

// 2. Active User Role perspective state
class RoleNotifier extends StateNotifier<String> {
  RoleNotifier() : super('customer');

  void toggleRole() {
    state = state == 'customer' ? 'provider' : 'customer';
  }
  
  void setRole(String role) {
    state = role;
  }
  
  void switchToAdmin() {
    state = 'admin';
  }
  
  void switchToCustomer() {
    state = 'customer';
  }
}

final currentRoleProvider = StateNotifierProvider<RoleNotifier, String>((ref) {
  return RoleNotifier();
});

// 3. Providers List State Management
class ProvidersNotifier extends StateNotifier<List<ProviderModel>> {
  ProvidersNotifier() : super(ProviderModel.mockProviders);

  void toggleOnlineStatus(String providerId) {
    state = [
      for (final p in state)
        if (p.id == providerId)
          p.copyWith(isOnline: !p.isOnline)
        else
          p
    ];
  }

  void verifyProvider(String providerId) {
    state = [
      for (final p in state)
        if (p.id == providerId)
          p.copyWith(verificationStatus: VerificationStatus.verified)
        else
          p
    ];
  }

  void updateProviderProfile({
    required String providerId,
    required String name,
    required String bio,
    required double hourlyRate,
    required List<String> skills,
    required String specialty,
    required String specialtyAmharic,
    String? address,
    String? qualifications,
    String? coverageArea,
    String? workingHours,
  }) {
    state = [
      for (final p in state)
        if (p.id == providerId)
          p.copyWith(
            name: name,
            bio: bio,
            hourlyRateEtb: hourlyRate,
            skills: skills,
            specialty: specialty,
            specialtyAmharic: specialtyAmharic,
            address: address,
            qualifications: qualifications,
            coverageArea: coverageArea,
            workingHours: workingHours,
          )
        else
          p
    ];
  }
}

final providersListProvider = StateNotifierProvider<ProvidersNotifier, List<ProviderModel>>((ref) {
  return ProvidersNotifier();
});

// 4. Bookings State Management
class BookingsNotifier extends StateNotifier<List<BookingModel>> {
  final Ref _ref;
  BookingsNotifier(this._ref) : super(BookingModel.mockBookings);

  void addBooking(BookingModel booking) {
    state = [booking, ...state];
  }

  void updateBookingStatus(String bookingId, BookingStatus newStatus) {
    state = [
      for (final b in state)
        if (b.id == bookingId)
          b.copyWith(
            status: newStatus,
            isEscrowHeld: newStatus == BookingStatus.inService || newStatus == BookingStatus.accepted,
          )
        else
          b
    ];

    if (newStatus == BookingStatus.accepted) {
      final b = state.firstWhere((item) => item.id == bookingId);
      _ref.read(chatMessagesProvider.notifier).receiveMockResponse(
        "ጤና ይስጥልኝ! የ ${b.serviceType} ጥያቄዎን ተቀብያለሁ። ዝርዝር ሁኔታዎችን እዚህ እንወያይ።\n(Hello! I have accepted your request for ${b.serviceType}. Let's discuss details here.)",
        b.providerName,
      );
    }
  }

  void cancelBooking(String bookingId) {
    updateBookingStatus(bookingId, BookingStatus.cancelled);
  }

  void submitDispute(String bookingId, String reason) {
    state = [
      for (final b in state)
        if (b.id == bookingId)
          b.copyWith(
            status: BookingStatus.disputed,
            disputeReason: reason,
          )
        else
          b
    ];
  }
}

final bookingsListProvider = StateNotifierProvider<BookingsNotifier, List<BookingModel>>((ref) {
  return BookingsNotifier(ref);
});

final bookingByIdProvider = Provider.family<BookingModel?, String>((ref, bookingId) {
  final bookings = ref.watch(bookingsListProvider);
  for (final booking in bookings) {
    if (booking.id == bookingId) {
      return booking;
    }
  }
  return null;
});

final pendingBookingsProvider = Provider<List<BookingModel>>((ref) {
  final bookings = ref.watch(bookingsListProvider);
  return bookings.where((b) => b.status == BookingStatus.pending).toList();
});

final activeBookingsProvider = Provider<List<BookingModel>>((ref) {
  final bookings = ref.watch(bookingsListProvider);
  return bookings.where((b) => b.status == BookingStatus.pending || b.status == BookingStatus.accepted || b.status == BookingStatus.inService).toList();
});

final completedBookingsProvider = Provider<List<BookingModel>>((ref) {
  final bookings = ref.watch(bookingsListProvider);
  return bookings.where((b) => b.status == BookingStatus.completed).toList();
});

// 5. Chat Messages State Management
class ChatNotifier extends StateNotifier<List<MessageModel>> {
  ChatNotifier() : super(MessageModel.mockMessages);

  void sendMessage(String content, MessageType type, {int? voiceDuration, SenderRole? senderRole, String? senderName}) {
    final newMsg = MessageModel(
      id: 'm_${DateTime.now().millisecondsSinceEpoch}',
      senderName: senderName ?? 'Abel Abreham',
      senderRole: senderRole ?? SenderRole.customer,
      content: content,
      type: type,
      timestamp: DateTime.now(),
      voiceDurationSeconds: voiceDuration,
      isRead: false,
    );
    state = [...state, newMsg];
  }

  void receiveMockResponse(String content, String senderName) {
    final newMsg = MessageModel(
      id: 'm_${DateTime.now().millisecondsSinceEpoch}',
      senderName: senderName,
      senderRole: SenderRole.provider,
      content: content,
      type: MessageType.text,
      timestamp: DateTime.now(),
      isRead: false,
    );
    state = [...state, newMsg];
  }

  void clearMessages() {
    state = [];
  }
}

final chatMessagesProvider = StateNotifierProvider<ChatNotifier, List<MessageModel>>((ref) {
  return ChatNotifier();
});

// 6. Theme Mode State Provider (Light / Dark)
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.light) {
    AppTheme.isDark = false;
  }

  void setThemeMode(ThemeMode mode) {
    AppTheme.isDark = (mode == ThemeMode.dark);
    state = mode;
  }

  void toggleTheme() {
    final next = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    AppTheme.isDark = (next == ThemeMode.dark);
    state = next;
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});
