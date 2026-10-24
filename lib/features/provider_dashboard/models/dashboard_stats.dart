class DashboardStats {
  final int totalBookings;
  final int completedBookings;
  final int pendingBookings;
  final double totalEarningsEtb;
  final double averageRating;
  final int reviewCount;
  final int openDisputes;
  final DateTime lastUpdated;

  DashboardStats({
    required this.totalBookings,
    required this.completedBookings,
    required this.pendingBookings,
    required this.totalEarningsEtb,
    required this.averageRating,
    required this.reviewCount,
    required this.openDisputes,
    required this.lastUpdated,
  });

  DashboardStats copyWith({
    int? totalBookings,
    int? completedBookings,
    int? pendingBookings,
    double? totalEarningsEtb,
    double? averageRating,
    int? reviewCount,
    int? openDisputes,
    DateTime? lastUpdated,
  }) {
    return DashboardStats(
      totalBookings: totalBookings ?? this.totalBookings,
      completedBookings: completedBookings ?? this.completedBookings,
      pendingBookings: pendingBookings ?? this.pendingBookings,
      totalEarningsEtb: totalEarningsEtb ?? this.totalEarningsEtb,
      averageRating: averageRating ?? this.averageRating,
      reviewCount: reviewCount ?? this.reviewCount,
      openDisputes: openDisputes ?? this.openDisputes,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  static DashboardStats get mockStats => DashboardStats(
    totalBookings: 45,
    completedBookings: 42,
    pendingBookings: 2,
    totalEarningsEtb: 15750,
    averageRating: 4.7,
    reviewCount: 38,
    openDisputes: 0,
    lastUpdated: DateTime.now(),
  );
}
