import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/dispute/models/dispute_model.dart';
import '../../../features/dispute/providers/dispute_provider.dart';
import '../models/provider_model.dart';
import '../providers/home_provider.dart';
import '../../../shared/providers/mock_state_providers.dart' show languageProvider, currentRoleProvider;

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _selectedCategory = 'All';
  ProviderModel? _selectedMapProvider;
  final MapController _mapController = MapController();

  // Coordinates centered on Bole, Addis Ababa
  final LatLng _center = const LatLng(9.0200, 38.7890);

  @override
  Widget build(BuildContext context) {
    final activeLang = ref.watch(languageProvider);
    final l10n = AppLocalizations(Locale(activeLang));
    final providers = ref.watch(providersListProvider);
    final activeRole = ref.watch(currentRoleProvider);
    final authUserAsync = ref.watch(authProvider);

    // Determine role from auth user if available, otherwise fall back to currentRoleProvider
    final userRole = authUserAsync.maybeWhen(
      data: (user) => user?.role.toString().split('.').last ?? activeRole,
      orElse: () => activeRole,
    );

    // Filtered providers list
    final filteredProviders = providers.maybeWhen(
      data: (providerList) => _selectedCategory == 'All'
          ? providerList
          : providerList
              .where((p) =>
                  p.specialty.contains(_selectedCategory) ||
                  _selectedCategory == 'All')
              .toList(),
      orElse: () => <ProviderModel>[],
    );

    if (userRole == 'admin') {
      final disputesAsync = ref.watch(disputesProvider);
      final openDisputeCount = ref.watch(openDisputesCountProvider);
      final totalDisputes = disputesAsync.maybeWhen(data: (list) => list.length, orElse: () => 0);
      final resolvedDisputes = disputesAsync.maybeWhen(
        data: (list) => list.where((d) => d.status == DisputeStatus.resolved || d.status == DisputeStatus.closed).length,
        orElse: () => 0,
      );

      return Scaffold(
        appBar: AppBar(
          title: Text(activeLang == 'am' ? 'የአስተዳደር ገጽ' : 'Admin Console'),
          centerTitle: true,
          actions: [
            TextButton(
              onPressed: () => ref.read(currentRoleProvider.notifier).setRole('customer'),
              child: Text(
                activeLang == 'am' ? 'ወደ ደንበኛ' : 'Customer Mode',
                style: const TextStyle(color: AppTheme.secondary),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                activeLang == 'am' ? 'እንኳን ደህና መጡ አስተዳደር' : 'Welcome, Admin',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 12),
              Text(
                activeLang == 'am'
                    ? 'እባክዎ የግንኙነት እና አቤቱታ ግጭቶችን እይ' : 'Review disputes and platform health metrics.',
                style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  _buildAdminStatCard(
                    title: activeLang == 'am' ? 'ክፍተት ጥያቄዎች' : 'Open Disputes',
                    value: openDisputeCount.toString(),
                    color: AppTheme.statusError,
                  ),
                  const SizedBox(width: 12),
                  _buildAdminStatCard(
                    title: activeLang == 'am' ? 'ጠቅላላ ጥያቄዎች' : 'Total Disputes',
                    value: totalDisputes.toString(),
                    color: AppTheme.secondary,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildAdminStatCard(
                title: activeLang == 'am' ? 'የተፈታ ጥያቄዎች' : 'Resolved',
                value: resolvedDisputes.toString(),
                color: AppTheme.statusSuccess,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.push('/admin-dashboard'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  activeLang == 'am' ? 'የአስተዳደር ቦርድ ክፈት' : 'Open Admin Dashboard',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                activeLang == 'am' ? 'ክፍተት ጥያቄዎች' : 'Pending Disputes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 16),
              if (openDisputeCount == 0)
                Center(
                  child: Text(
                    activeLang == 'am' ? 'ክፍተት ጥያቄ የለም' : 'No open disputes right now.',
                    style: TextStyle(color: AppTheme.textTertiary),
                  ),
                )
              else ...ref.watch(openDisputesProvider).map((dispute) => _buildDisputeCard(dispute, activeLang)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // 1. Interactive Flutter Map with OpenStreetMap tiles
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 13.5,
              onTap: (_, __) {
                setState(() {
                  _selectedMapProvider = null;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.shuk.app',
                // Make the map visually match the dark mode theme using a color filter!
                tileBuilder: (context, tileWidget, tile) {
                  return ColorFiltered(
                    colorFilter: const ColorFilter.matrix(<double>[
                      -0.2126, -0.7152, -0.0722, 0, 255,
                      -0.2126, -0.7152, -0.0722, 0, 255,
                      -0.2126, -0.7152, -0.0722, 0, 255,
                      0, 0, 0, 1, 0,
                    ]),
                    child: tileWidget,
                  );
                },
              ),
              // Nearby Provider Pins
              MarkerLayer(
                markers: [
                  for (final p in filteredProviders)
                    Marker(
                      width: 50,
                      height: 50,
                      point: LatLng(
                        _center.latitude + (p.id == 'p1' ? 0.005 : p.id == 'p2' ? -0.008 : p.id == 'p3' ? 0.012 : -0.003),
                        _center.longitude + (p.id == 'p1' ? -0.004 : p.id == 'p2' ? 0.009 : p.id == 'p3' ? -0.010 : 0.006),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedMapProvider = p;
                          });
                          _mapController.move(
                            LatLng(
                              _center.latitude + (p.id == 'p1' ? 0.002 : p.id == 'p2' ? -0.006 : p.id == 'p3' ? 0.010 : -0.001),
                              _center.longitude + (p.id == 'p1' ? -0.004 : p.id == 'p2' ? 0.009 : p.id == 'p3' ? -0.010 : 0.006),
                            ),
                            14.0
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: p.id == _selectedMapProvider?.id ? AppTheme.primary : AppTheme.bgElevated,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Center(
                            child: Text(
                              p.emoji,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          // 2. Beautiful Glassmorphism Header overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: AppTheme.glassDecoration(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (activeRole == 'admin') {
                        context.push('/admin-dashboard');
                        return;
                      }

                      ref.read(currentRoleProvider.notifier).toggleRole();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            activeRole == 'customer'
                                ? 'Switched to Provider Dashboard perspective'
                                : 'Switched to Customer discovery perspective',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: activeRole == 'provider' || activeRole == 'admin'
                            ? AppTheme.secondary
                            : Colors.white.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        activeRole == 'admin' ? '🛡️' : (activeRole == 'provider' ? '⚙️' : '👨‍🔧'),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.get('app_name'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          activeRole == 'provider'
                              ? 'Provider Mode (ባለሙያ)'
                              : activeRole == 'admin'
                                  ? 'Admin Mode'
                                  : 'Bole, Addis Ababa',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (activeRole == 'provider') {
                        context.push('/provider-dashboard');
                      } else {
                        ref.read(languageProvider.notifier).setLanguage(activeLang == 'am' ? 'en' : 'am');
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white24),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        activeRole == 'provider'
                            ? (activeLang == 'am' ? 'ቦርድ' : 'Dashboard')
                            : (activeLang == 'am' ? 'EN' : 'አማ'),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.secondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => context.push('/booking-history'),
                    child: const Icon(Icons.history, color: Colors.white, size: 24),
                  ),
                ],
              ),
            ),
          ),

          // 3. Customer Quick Stats (for customer role only)
          if (activeRole == 'customer')
            Positioned(
              top: MediaQuery.of(context).padding.top + 95,
              left: 16,
              right: 16,
              child: Consumer(
                builder: (context, ref, child) {
                  final stats = ref.watch(customerStatsProvider);
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildQuickStatItem(
                          icon: '📋',
                          label: activeLang == 'am' ? 'ጠቅላላ' : 'Total',
                          value: stats.totalBookings.toString(),
                          bgColor: AppTheme.tertiary,
                        ),
                        const SizedBox(width: 10),
                        _buildQuickStatItem(
                          icon: '⏳',
                          label: activeLang == 'am' ? 'ነቅ' : 'Active',
                          value: stats.activeBookings.toString(),
                          bgColor: AppTheme.secondary,
                        ),
                        const SizedBox(width: 10),
                        _buildQuickStatItem(
                          icon: '💰',
                          label: activeLang == 'am' ? 'ሊተወይ' : 'Spent',
                          value: '${(stats.totalSpentEtb / 1000).toStringAsFixed(1)}k',
                          bgColor: AppTheme.secondary,
                        ),
                        const SizedBox(width: 10),
                        _buildQuickStatItem(
                          icon: '❤️',
                          label: activeLang == 'am' ? 'ተወዳጅ' : 'Saved',
                          value: stats.favoriteProviders.toString(),
                          bgColor: AppTheme.statusError,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

          // 3. Category Filter Chips overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + (activeRole == 'customer' ? 160 : 80),
            left: 0,
            right: 0,
            child: SizedBox(
              height: 46,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _categoryChip('All', 'ሁሉም', '🔍'),
                  _categoryChip('Electrician', 'ኤሌክትሪክ', '⚡'),
                  _categoryChip('Cleaner', 'ማጽዳት', '🧹'),
                  _categoryChip('Plumber', 'ቧንቧ', '🔧'),
                  _categoryChip('Tutor', 'ማስጠናት', '📚'),
                ],
              ),
            ),
          ),

          // 4. Selected Map Pin Provider Card Preview Overlay
          if (_selectedMapProvider != null)
            Positioned(
              bottom: 250,
              left: 16,
              right: 16,
              child: _buildProviderPreviewCard(_selectedMapProvider!, activeLang),
            ),

          // 5. Voice Service Request Floating Button (Low literacy support)
          Positioned(
            bottom: 100,
            right: 16,
            child: FloatingActionButton.extended(
              onPressed: () => context.push('/voice-request'),
              backgroundColor: AppTheme.secondary,
              foregroundColor: AppTheme.primary,
              elevation: 6,
              icon: const Icon(Icons.mic, size: 24),
              label: Text(
                activeLang == 'am' ? 'በድምፅ እዘዝ' : 'Voice Request',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // 6. Nearby Providers list sheet at bottom
          DraggableScrollableSheet(
            initialChildSize: 0.1,
            minChildSize: 0.08,
            maxChildSize: 0.5,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: AppTheme.bgElevated,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  border: Border(top: BorderSide(color: Colors.white10)),
                ),
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  itemCount: filteredProviders.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Column(
                        children: [
                          Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 15),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.get('nearby'),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${filteredProviders.length} online',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.statusSuccess,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                        ],
                      );
                    }
                    final p = filteredProviders[index - 1];
                    return _buildProviderListCard(p, activeLang);
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatItem({
    required String icon,
    required String label,
    required String value,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bgColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: bgColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryChip(String key, String amharicName, String icon) {
    final activeLang = ref.watch(languageProvider);
    final isSelected = _selectedCategory == key;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = key;
          _selectedMapProvider = null;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : AppTheme.bgElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.secondary : Colors.white10,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              activeLang == 'am' ? amharicName : key,
              style: TextStyle(
                color: isSelected ? AppTheme.primary : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderPreviewCard(ProviderModel p, String activeLang) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glassDecoration(),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(p.emoji, style: const TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  p.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  activeLang == 'am' ? p.specialtyAmharic : p.specialty,
                  style: const TextStyle(fontSize: 11, color: AppTheme.secondary),
                ),
                const SizedBox(height: 4),
                Text(
                  '⭐ ${p.rating}  •  📍 ${p.distanceKm} km',
                  style: const TextStyle(fontSize: 11, color: Colors.white60),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => context.push('/provider-profile/${p.id}'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.secondary,
              foregroundColor: AppTheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('View', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          )
        ],
      ),
    );
  }

  Widget _buildProviderListCard(ProviderModel pro, String activeLang) {
    final isOnline = pro.isOnline;
    final addressText = pro.address ?? 'Bole, Addis Ababa';
    final reviewsCount = (pro.jobsCount * 0.38).round() + 12;
    final expYears = pro.id == 'p1' ? '8 yrs' : (pro.id == 'p2' ? '5 yrs' : (pro.id == 'p3' ? '4 yrs' : '6 yrs'));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // 1. Centered Circle Avatar
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryContainer,
              border: Border.all(color: Colors.black.withValues(alpha: 0.06), width: 1),
            ),
            child: Center(
              child: Text(
                pro.emoji,
                style: const TextStyle(fontSize: 26),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // 2. Name with Verified Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                pro.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              if (pro.verificationStatus == VerificationStatus.verified) ...[
                const SizedBox(width: 4),
                const Icon(
                  Icons.verified,
                  color: AppTheme.tertiary,
                  size: 16,
                ),
              ],
            ],
          ),
          const SizedBox(height: 2),

          // 3. Specialty in Amber/Orange
          Text(
            activeLang == 'am' ? pro.specialtyAmharic : pro.specialty,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.secondary,
            ),
          ),
          const SizedBox(height: 6),

          // 4. Location & Online status
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on_outlined, color: AppTheme.textTertiary, size: 13),
              const SizedBox(width: 2),
              Text(
                addressText,
                style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
              ),
              const SizedBox(width: 4),
              Text('•', style: TextStyle(color: AppTheme.textTertiary, fontSize: 10)),
              const SizedBox(width: 4),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isOnline ? AppTheme.statusOnline : Colors.grey,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                isOnline
                    ? (activeLang == 'am' ? 'አሁን ይገኛሉ' : 'Available Now')
                    : (activeLang == 'am' ? 'ከመስመር ውጭ' : 'Offline'),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isOnline ? AppTheme.statusOnline : Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 5. Rate header & Rate Amount
          Text(
            activeLang == 'am' ? 'ዋጋ' : 'RATE',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: AppTheme.textTertiary,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            '${pro.hourlyRateEtb.toInt()} ETB / hr',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 10),

          // 6. Stats Row (Rating, Jobs Done, Experience)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text(
                    '${pro.rating} ★',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    activeLang == 'am' ? 'ግምገማዎች' : '$reviewsCount REVIEWS',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppTheme.textTertiary, letterSpacing: 0.4),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    '${pro.jobsCount}+',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    activeLang == 'am' ? 'የተሰሩ ስራዎች' : 'JOBS DONE',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppTheme.textTertiary, letterSpacing: 0.4),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    expYears,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    activeLang == 'am' ? 'ልምድ' : 'EXPERIENCE',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppTheme.textTertiary, letterSpacing: 0.4),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 7. Action buttons (Details & Chat)
          Row(
            children: [
              // Details button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/provider-profile/${pro.id}'),
                  icon: Icon(Icons.remove_red_eye_outlined, size: 15, color: AppTheme.textPrimary),
                  label: Text(
                    activeLang == 'am' ? 'ዝርዝር' : 'Details',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryContainer,
                    foregroundColor: AppTheme.textPrimary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Chat button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/chat'),
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 15, color: Colors.white),
                  label: Text(
                    activeLang == 'am' ? 'ውይይት' : 'Chat',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    side: BorderSide(color: Colors.black.withValues(alpha: 0.1)),
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
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

  Widget _buildAdminStatCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisputeCard(dynamic dispute, String activeLang) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '#${dispute.id}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              Text(
                dispute.status == DisputeStatus.underReview
                    ? (activeLang == 'am' ? 'በእይታ ላይ' : 'Under review')
                    : dispute.status == DisputeStatus.opened
                        ? (activeLang == 'am' ? 'ተከፍቷል' : 'Opened')
                        : (activeLang == 'am' ? 'የተፈታ' : 'Resolved'),
                style: const TextStyle(color: AppTheme.secondary, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${activeLang == 'am' ? 'ምክንያት' : 'Reason'}: ${dispute.reason}',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            '${activeLang == 'am' ? 'አንደኛ' : 'Initiator'}: ${dispute.initiatorName}',
            style: const TextStyle(color: Colors.white60, fontSize: 11),
          ),
          Text(
            '${activeLang == 'am' ? 'እቅድ ላይ ያለ' : 'Respondent'}: ${dispute.respondentName}',
            style: const TextStyle(color: Colors.white60, fontSize: 11),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: dispute.status == DisputeStatus.resolved || dispute.status == DisputeStatus.closed
                ? null
                : () async {
                    await ref.read(disputesProvider.notifier).updateDisputeStatus(
                      dispute.id,
                      DisputeStatus.resolved,
                      resolution: activeLang == 'am' ? 'ተፈታ' : 'Resolved by admin',
                      resolvedBy: 'admin_1',
                    );
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          activeLang == 'am' ? 'ጥያቄው ተፈታ' : 'Dispute resolved successfully',
                        ),
                        backgroundColor: AppTheme.statusSuccess,
                      ),
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.secondary,
              foregroundColor: AppTheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Text(
              activeLang == 'am' ? 'እቅድ እንዲያረጋግጡ' : 'Resolve Dispute',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
