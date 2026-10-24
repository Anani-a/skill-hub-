import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/mock_state_providers.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../providers/dashboard_provider.dart';
import '../models/dashboard_stats.dart';
import '../../booking/models/booking_model.dart';

import '../../auth/providers/auth_provider.dart';
import '../../provider_onboarding/providers/provider_onboarding_provider.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/notification_modal.dart';
import '../../notifications/providers/notification_provider.dart';
import '../../../core/router/nav_helpers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Provider Dashboard Screen
// ─────────────────────────────────────────────────────────────────────────────

class ProviderDashboardScreen extends ConsumerStatefulWidget {
  final bool isShell;
  const ProviderDashboardScreen({super.key, this.isShell = false});

  @override
  ConsumerState<ProviderDashboardScreen> createState() =>
      _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState
    extends ConsumerState<ProviderDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final activeLang = ref.watch(languageProvider);
    final dashboardAsync = ref.watch(dashboardProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    AppTheme.isDark = isDark;
    final headerColor = isDark ? const Color(0xFF1E1435) : AppTheme.primary;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: headerColor,
        drawer: const AppDrawer(),
        body: dashboardAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
          error: (e, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.white, size: 48),
                const SizedBox(height: 12),
                const Text('Failed to load', style: TextStyle(color: Colors.white)),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => ref.refresh(dashboardProvider),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                  child: Text('Retry', style: TextStyle(color: AppTheme.primary)),
                ),
              ],
            ),
          ),
          data: (stats) {
            final authUser = ref.watch(authProvider).asData?.value;
            final onboardingState = ref.watch(providerOnboardingProvider);
            final fullName = authUser?.name ?? (onboardingState.providerName.isNotEmpty ? onboardingState.providerName : 'Abel Abreham');
            final firstName = fullName.split(' ').first;
            return _DashboardBody(
              stats: stats,
              activeLang: activeLang,
              ref: ref,
              providerName: firstName,
              providerInitial: firstName.isNotEmpty ? firstName[0].toUpperCase() : 'A',
              onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
              headerColor: headerColor,
              isDark: isDark,
            );
          },
        ),
        bottomNavigationBar: widget.isShell
            ? null
            : ShukBottomNavBar(
                currentIndex: 0,
                activeRole: 'provider',
                activeLang: activeLang,
              ),
      ),
    );
  }
}

class _DashboardBody extends ConsumerWidget {
  final DashboardStats stats;
  final String activeLang;
  final WidgetRef ref;
  final String providerName;
  final String providerInitial;
  final VoidCallback onMenuPressed;
  final Color headerColor;
  final bool isDark;

  const _DashboardBody({
    required this.stats,
    required this.activeLang,
    required this.ref,
    required this.providerName,
    required this.providerInitial,
    required this.onMenuPressed,
    required this.headerColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: headerColor,
      child: Stack(
        children: [
          Column(
            children: [
              // ── Top Bar Header ──────────────────────────────────────────────
              _ProviderTopBar(
                activeLang: activeLang,
                providerInitial: providerInitial,
                onMenuPressed: onMenuPressed,
                ref: ref,
                headerColor: headerColor,
              ),

              // ── Rounded Body Sheet ──────────────────────────────────────────
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.bgBase,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),

                          // ── Greeting ───────────────────────────────────────
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  activeLang == 'am'
                                      ? 'ሰላም, $providerName! 👋'
                                      : 'Hi, $providerName! 👋',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textPrimary,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  activeLang == 'am'
                                      ? 'በሹክ ንግድዎን ያሳድጉ'
                                      : 'Grow your business with Shuk',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ── Stats Row ───────────────────────────────────────
                          _StatsRow(stats: stats, activeLang: activeLang, isDark: isDark),

                          const SizedBox(height: 28),

                          // ── Recent Bookings ─────────────────────────────────
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  activeLang == 'am' ? 'የቅርብ ጊዜ ትዕዛዞች' : 'Recent Bookings',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => ProviderNavHelper.go(context, ref, tab: 2),
                                  child: Text(
                                    'See all',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? AppTheme.primaryLight : AppTheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Booking cards list
                          _RecentBookingsList(activeLang: activeLang),

                          const SizedBox(height: 110), // space for CTA button
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),


        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top AppBar
// ─────────────────────────────────────────────────────────────────────────────

class _ProviderTopBar extends StatelessWidget {
  final String activeLang;
  final String providerInitial;
  final VoidCallback onMenuPressed;
  final WidgetRef ref;
  final Color headerColor;

  const _ProviderTopBar({
    required this.activeLang,
    required this.providerInitial,
    required this.onMenuPressed,
    required this.ref,
    required this.headerColor,
  });

  @override
  Widget build(BuildContext context) {
    final unreadNotifCount = ref.watch(unreadNotificationsCountProvider);

    return Container(
      color: headerColor,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Row(
            children: [
              // Hamburger menu — opens drawer
              GestureDetector(
                onTap: onMenuPressed,
                child: const Icon(Icons.menu_rounded, color: Colors.white, size: 26),
              ),

              // Shuk Logo + name in center
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          'S',
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Shuk',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),

              // Notification bell
              GestureDetector(
                onTap: () => showNotificationsModal(context, ref),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.notifications_rounded, color: Colors.white, size: 25),
                    if (unreadNotifCount > 0)
                      Positioned(
                        right: 1,
                        top: 0,
                        child: Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF5252),
                            shape: BoxShape.circle,
                            border: Border.all(color: headerColor, width: 1.5),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 14),

              // Profile Avatar
              GestureDetector(
                onTap: () => ProviderNavHelper.go(context, ref, tab: 4),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      providerInitial,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stats Row — 4 tiles in a horizontal scroll
// ─────────────────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final DashboardStats stats;
  final String activeLang;
  final bool isDark;
  const _StatsRow({required this.stats, required this.activeLang, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final tiles = [
      _StatTileData(
        icon: Icons.calendar_month_rounded,
        iconBg: isDark ? const Color(0xFF4527A0).withValues(alpha: 0.28) : const Color(0xFFEDE7F6),
        iconColor: isDark ? AppTheme.primaryLight : const Color(0xFF4527A0),
        value: stats.pendingBookings.toString(),
        label: activeLang == 'am' ? 'ንቁ ትዕዛዞች' : 'Active Bookings',
      ),
      _StatTileData(
        icon: Icons.account_balance_wallet_rounded,
        iconBg: isDark ? const Color(0xFF2E7D32).withValues(alpha: 0.28) : const Color(0xFFE8F5E9),
        iconColor: isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32),
        value: 'ETB ${(stats.totalEarningsEtb / 1000).toStringAsFixed(1)}K',
        label: activeLang == 'am' ? 'ጠቅላላ ገቢ' : 'Total Earnings',
      ),
      _StatTileData(
        icon: Icons.star_rounded,
        iconBg: isDark ? const Color(0xFFF9A825).withValues(alpha: 0.28) : const Color(0xFFFFF8E1),
        iconColor: isDark ? const Color(0xFFFFD54F) : const Color(0xFFF9A825),
        value: stats.averageRating.toStringAsFixed(1),
        label: activeLang == 'am' ? 'ደረጃ' : 'Rating',
      ),
      _StatTileData(
        icon: Icons.person_rounded,
        iconBg: isDark ? const Color(0xFFC62828).withValues(alpha: 0.28) : const Color(0xFFFCE4EC),
        iconColor: isDark ? const Color(0xFFE57373) : const Color(0xFFC62828),
        value: stats.reviewCount.toString(),
        label: activeLang == 'am' ? 'ግምገማዎች' : 'Reviews',
      ),
    ];

    return SizedBox(
      height: 126,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: tiles.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => _StatTile(data: tiles[i]),
      ),
    );
  }
}

class _StatTileData {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String value;
  final String label;
  const _StatTileData({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.value,
    required this.label,
  });
}

class _StatTile extends StatelessWidget {
  final _StatTileData data;
  const _StatTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 112,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.outlineLighter),
        boxShadow: AppTheme.isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: data.iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(data.icon, color: data.iconColor, size: 18),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary,
                  height: 1,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                data.label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Recent Bookings List
// ─────────────────────────────────────────────────────────────────────────────

class _RecentBookingsList extends ConsumerWidget {
  final String activeLang;
  const _RecentBookingsList({required this.activeLang});

  // Mock service thumbnails (emoji-based colored box as image substitute)
  static const List<Map<String, dynamic>> _mockCards = [
    {'emoji': '🛋️', 'bg': Color(0xFFE3F2FD), 'service': 'Home Cleaning', 'status': 'In Progress', 'statusColor': Color(0xFF1565C0), 'statusBg': Color(0xFFE3F2FD), 'date': 'Jul 29, 2026 · 10:00 AM', 'price': 'ETB 500/hr'},
    {'emoji': '🔧', 'bg': Color(0xFFFFF3E0), 'service': 'Plumbing Fix', 'status': 'Pending', 'statusColor': Color(0xFFE65100), 'statusBg': Color(0xFFFFF3E0), 'date': 'Jul 28, 2026 · 02:00 PM', 'price': 'ETB 600'},
    {'emoji': '⚡', 'bg': Color(0xFFF3E5F5), 'service': 'Electrical Repair', 'status': 'Accepted', 'statusColor': Color(0xFF2E7D32), 'statusBg': Color(0xFFE8F5E9), 'date': 'Jul 27, 2026 · 11:00 AM', 'price': 'ETB 500'},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(bookingsListProvider);
    final providerBookings = bookings
        .where((b) =>
            b.providerId == 'p1' ||
            b.status == BookingStatus.pending ||
            b.status == BookingStatus.accepted ||
            b.status == BookingStatus.inService)
        .take(3)
        .toList();

    // Use mock cards if no real data available
    if (providerBookings.isEmpty) {
      return Column(
        children: _mockCards
            .map((card) => _MockBookingCard(card: card))
            .toList(),
      );
    }

    return Column(
      children: providerBookings
          .asMap()
          .entries
          .map((e) => _RealBookingCard(booking: e.value, activeLang: activeLang))
          .toList(),
    );
  }
}

// ── Mock Booking Card (matches design image) ──────────────────────────────────

class _MockBookingCard extends StatelessWidget {
  final Map<String, dynamic> card;
  const _MockBookingCard({required this.card});

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark;
    final statusColor = card['statusColor'] as Color;
    final statusBg = isDark ? statusColor.withValues(alpha: 0.22) : (card['statusBg'] as Color);
    final thumbnailBg = isDark ? statusColor.withValues(alpha: 0.18) : (card['bg'] as Color);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.outlineLighter),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Row(
        children: [
          // Service thumbnail
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: thumbnailBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                card['emoji'] as String,
                style: const TextStyle(fontSize: 30),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + Status badge
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        card['service'] as String,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        card['status'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppTheme.primaryLight : statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Date
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 12, color: AppTheme.textTertiary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        card['date'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textTertiary,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Price
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    card['price'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppTheme.primaryLight : AppTheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Real Booking Card ─────────────────────────────────────────────────────────

class _RealBookingCard extends StatelessWidget {
  final BookingModel booking;
  final String activeLang;
  const _RealBookingCard({required this.booking, required this.activeLang});

  Color get _statusColor {
    switch (booking.status) {
      case BookingStatus.inService:
        return const Color(0xFF1565C0);
      case BookingStatus.pending:
        return const Color(0xFFE65100);
      case BookingStatus.accepted:
        return const Color(0xFF2E7D32);
      case BookingStatus.completed:
        return const Color(0xFF2E7D32);
      case BookingStatus.cancelled:
      case BookingStatus.disputed:
        return const Color(0xFFC62828);
      default:
        return const Color(0xFF757575);
    }
  }

  Color get _statusBg {
    final sc = _statusColor;
    if (AppTheme.isDark) {
      return sc.withValues(alpha: 0.22);
    }
    switch (booking.status) {
      case BookingStatus.inService:
        return const Color(0xFFE3F2FD);
      case BookingStatus.pending:
        return const Color(0xFFFFF3E0);
      case BookingStatus.accepted:
      case BookingStatus.completed:
        return const Color(0xFFE8F5E9);
      case BookingStatus.cancelled:
      case BookingStatus.disputed:
        return const Color(0xFFFFEBEE);
      default:
        return const Color(0xFFF5F5F5);
    }
  }

  String get _statusLabel {
    switch (booking.status) {
      case BookingStatus.inService:
        return activeLang == 'am' ? 'በሥራ ላይ' : 'In Progress';
      case BookingStatus.pending:
        return activeLang == 'am' ? 'ጥያቄ ላይ' : 'Pending';
      case BookingStatus.accepted:
        return activeLang == 'am' ? 'ተቀብሏል' : 'Accepted';
      case BookingStatus.completed:
        return activeLang == 'am' ? 'ተጠናቅቋል' : 'Completed';
      case BookingStatus.cancelled:
        return activeLang == 'am' ? 'ተሰርዟል' : 'Cancelled';
      case BookingStatus.disputed:
        return activeLang == 'am' ? 'ቅሬታ' : 'Disputed';
      default:
        return booking.status.name;
    }
  }

  String get _serviceEmoji {
    final s = booking.serviceType.toLowerCase();
    if (s.contains('clean')) return '🛋️';
    if (s.contains('plumb')) return '🔧';
    if (s.contains('electr')) return '⚡';
    if (s.contains('paint')) return '🎨';
    if (s.contains('garden')) return '🌿';
    return '🛠️';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark;
    final sc = _statusColor;
    final bg = _statusBg;

    return GestureDetector(
      onTap: () => context.push('/booking-details/${booking.id}'),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.bgSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.outlineLighter),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Row(
          children: [
            // Service thumbnail
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isDark ? sc.withValues(alpha: 0.18) : bg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(_serviceEmoji, style: const TextStyle(fontSize: 30)),
              ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + Status badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          booking.serviceType,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _statusLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isDark && booking.status == BookingStatus.inService ? AppTheme.primaryLight : sc,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Date
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 12, color: AppTheme.textTertiary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _formatDate(booking.dateTime),
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textTertiary,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Price aligned right
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'ETB ${booking.priceEtb.toInt()}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppTheme.primaryLight : AppTheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '—';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour == 0 ? 12 : dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} · $hour:$minute $period';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// View New Requests CTA — Floating Bottom Button (via Stack in parent)
// ─────────────────────────────────────────────────────────────────────────────
// NOTE: The "View New Requests" button is shown as a persistent bottom CTA
// overlaid on the Scaffold via bottomNavigationBar slot above the nav bar.
// We embed it directly in the Scaffold's body via an overlay approach below.
