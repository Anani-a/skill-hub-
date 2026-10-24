import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/booking_model.dart';

class BookingNotifier extends StateNotifier<List<BookingModel>> {
  BookingNotifier() : super(BookingModel.mockBookings);

  void addBooking(BookingModel booking) {
    state = [booking, ...state];
  }

  void updateBookingStatus(String bookingId, BookingStatus newStatus) {
    state = state.map((booking) {
      if (booking.id == bookingId) {
        return booking.copyWith(status: newStatus);
      }
      return booking;
    }).toList();
  }

  void cancelBooking(String bookingId) {
    updateBookingStatus(bookingId, BookingStatus.cancelled);
  }

  void submitDispute(String bookingId, String reason) {
    state = state.map((booking) {
      if (booking.id == bookingId) {
        return booking.copyWith(status: BookingStatus.disputed, disputeReason: reason);
      }
      return booking;
    }).toList();
  }

  List<BookingModel> getBookingsByStatus(BookingStatus status) {
    return state.where((b) => b.status == status).toList();
  }
}

final bookingsProvider =
    StateNotifierProvider<BookingNotifier, List<BookingModel>>((ref) {
  return BookingNotifier();
});

final bookingsListProvider = bookingsProvider;

final pendingBookingsProvider = Provider<List<BookingModel>>((ref) {
  final bookings = ref.watch(bookingsProvider);
  return bookings.where((b) => b.status == BookingStatus.pending).toList();
});

final bookingByIdProvider = Provider.family<BookingModel?, String>((ref, bookingId) {
  final bookings = ref.watch(bookingsProvider);
  for (final booking in bookings) {
    if (booking.id == bookingId) {
      return booking;
    }
  }
  return null;
});

final completedBookingsProvider = Provider<List<BookingModel>>((ref) {
  final bookings = ref.watch(bookingsProvider);
  return bookings.where((b) => b.status == BookingStatus.completed).toList();
});

final activeBookingsProvider = Provider<List<BookingModel>>((ref) {
  final bookings = ref.watch(bookingsProvider);
  const activeStatuses = [
    BookingStatus.pending,
    BookingStatus.accepted,
    BookingStatus.inService,
  ];
  return bookings.where((b) => activeStatuses.contains(b.status)).toList();
});
