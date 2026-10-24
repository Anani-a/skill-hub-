import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/dashboard_stats.dart';
import '../../../shared/providers/mock_state_providers.dart';
import '../../../features/booking/models/booking_model.dart';

class DashboardNotifier extends StateNotifier<AsyncValue<DashboardStats>> {
  final Ref _ref;

  DashboardNotifier(this._ref) : super(const AsyncValue.loading()) {
    _initializeDashboard();

    // Listen to changes in bookings list
    _ref.listen(bookingsListProvider, (previous, next) {
      _updateStats(next);
    });
  }

  void _initializeDashboard() async {
    await Future.delayed(const Duration(milliseconds: 400));
    _updateStats(_ref.read(bookingsListProvider));
  }

  void _updateStats(List<BookingModel> bookings) {
    final providerBookings = bookings.where((b) => b.providerId == 'p1').toList();
    final completed = providerBookings.where((b) => b.status == BookingStatus.completed).toList();
    final pending = providerBookings.where((b) => b.status == BookingStatus.pending).toList();
    final disputes = providerBookings.where((b) => b.status == BookingStatus.disputed).toList();

    final totalEarnings = completed.fold<double>(0, (sum, b) => sum + b.priceEtb);

    state = AsyncValue.data(DashboardStats(
      totalBookings: providerBookings.length,
      completedBookings: completed.length,
      pendingBookings: pending.length,
      totalEarningsEtb: totalEarnings,
      averageRating: 4.9,
      reviewCount: 38,
      openDisputes: disputes.length,
      lastUpdated: DateTime.now(),
    ));
  }

  /// Refresh dashboard stats
  Future<void> refreshStats() async {
    state = const AsyncValue.loading();
    await Future.delayed(const Duration(milliseconds: 500));
    _updateStats(_ref.read(bookingsListProvider));
  }

  /// Update stats manually (used when related data changes)
  void updateStats(DashboardStats newStats) {
    state = AsyncValue.data(newStats);
  }
}

// Global dashboard provider
final dashboardProvider = StateNotifierProvider<DashboardNotifier,
    AsyncValue<DashboardStats>>((ref) {
  return DashboardNotifier(ref);
});

// Derived: completion rate percentage
final completionRateProvider = Provider<double>((ref) {
  final dashboard = ref.watch(dashboardProvider);
  return dashboard.maybeWhen(
    data: (stats) {
      if (stats.totalBookings == 0) return 0.0;
      return (stats.completedBookings / stats.totalBookings) * 100;
    },
    orElse: () => 0.0,
  );
});

// Derived: average earning per booking
final averageEarningPerBookingProvider = Provider<double>((ref) {
  final dashboard = ref.watch(dashboardProvider);
  return dashboard.maybeWhen(
    data: (stats) {
      if (stats.completedBookings == 0) return 0.0;
      return stats.totalEarningsEtb / stats.completedBookings;
    },
    orElse: () => 0.0,
  );
});

// Derived: health score (based on rating and disputes)
final healthScoreProvider = Provider<double>((ref) {
  final dashboard = ref.watch(dashboardProvider);
  return dashboard.maybeWhen(
    data: (stats) {
      double score = stats.averageRating * 20; // Rating contributes 0-100
      score -= (stats.openDisputes * 10); // Each dispute reduces score by 10
      return score.clamp(0.0, 100.0);
    },
    orElse: () => 0.0,
  );
});
