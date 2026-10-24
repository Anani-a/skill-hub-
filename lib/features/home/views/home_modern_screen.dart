import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../models/provider_model.dart';
import '../providers/home_provider.dart';
import '../../../shared/providers/mock_state_providers.dart'
    show languageProvider, currentRoleProvider, themeModeProvider;
import '../../auth/providers/auth_provider.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../../shared/widgets/notification_modal.dart';
import '../../notifications/providers/notification_provider.dart';
import '../../../core/router/nav_helpers.dart';

class HomeModernScreen extends ConsumerStatefulWidget {
  final bool isShell;
  const HomeModernScreen({super.key, this.isShell = false});

  @override
  ConsumerState<HomeModernScreen> createState() => _HomeModernScreenState();
}

class _HomeModernScreenState extends ConsumerState<HomeModernScreen> {
  String _selectedCategory = 'All';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeLang = ref.watch(languageProvider);
    final l10n = AppLocalizations(Locale(activeLang));
    final providers = ref.watch(providersListProvider);
    final activeRole = ref.watch(currentRoleProvider);
    final unreadNotifCount = ref.watch(unreadNotificationsCountProvider);
    final authUser = ref.watch(authProvider).asData?.value;
    final fullName = authUser?.name ?? 'Abel Abreham';
    final firstName = fullName.split(' ').first;
    final avatarInitial = firstName.isNotEmpty ? firstName[0].toUpperCase() : 'A';

    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    AppTheme.isDark = isDark;

    // Categories configuration with Shuk brand colors and localized labels
    final categories = [
      {
        'key': 'All',
        'labelAm': 'ሁሉም',
        'labelEn': 'All',
        'icon': Icons.apps_rounded,
        'color': isDark ? AppTheme.primaryLight : AppTheme.primary,
      },
      {
        'key': 'Plumbing',
        'labelAm': 'ቧንቧ',
        'labelEn': 'Plumbing',
        'icon': Icons.plumbing_rounded,
        'color': AppTheme.tertiary,
      },
      {
        'key': 'Electrical',
        'labelAm': 'ኤሌክትሪክ',
        'labelEn': 'Electrical',
        'icon': Icons.bolt_rounded,
        'color': AppTheme.secondary,
      },
      {
        'key': 'Cleaning',
        'labelAm': 'ማጽዳት',
        'labelEn': 'Cleaning',
        'icon': Icons.cleaning_services_rounded,
        'color': AppTheme.statusSuccess,
      },
      {
        'key': 'Tutoring',
        'labelAm': 'ትምህርት',
        'labelEn': 'Tutoring',
        'icon': Icons.school_rounded,
        'color': AppTheme.primaryLight,
      },
    ];

    // Filtered providers by Category and Real-time Search Query
    final filteredProviders = providers.maybeWhen(
      data: (providerList) {
        var list = providerList;
        if (_selectedCategory != 'All') {
          final query = _selectedCategory.toLowerCase();
          list = list.where((p) {
            final spec = p.specialty.toLowerCase();
            if (query == 'plumbing') return spec.contains('plumb');
            if (query == 'electrical') return spec.contains('elect');
            if (query == 'cleaning') return spec.contains('clean');
            if (query == 'tutoring') return spec.contains('tutor') || spec.contains('school');
            return spec.contains(query);
          }).toList();
        }
        if (_searchQuery.isNotEmpty) {
          final q = _searchQuery.toLowerCase();
          list = list.where((p) {
            final nameMatch = p.name.toLowerCase().contains(q);
            final specMatch = p.specialty.toLowerCase().contains(q) || p.specialtyAmharic.toLowerCase().contains(q);
            final bioMatch = p.bio.toLowerCase().contains(q);
            final skillsMatch = p.skills.any((s) => s.toLowerCase().contains(q));
            return nameMatch || specMatch || bioMatch || skillsMatch;
          }).toList();
        }
        return list;
      },
      orElse: () => <ProviderModel>[],
    );

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
        body: Container(
          color: headerColor,
          child: Column(
            children: [
              // ── Header (Deep Purple in light mode, Dark Violet in dark mode) ──
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                  child: Row(
                    children: [
                      // Sidebar Hamburger Button
                      GestureDetector(
                        onTap: () => _scaffoldKey.currentState?.openDrawer(),
                        child: const Icon(
                          Icons.menu_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),

                      // Shuk Brand Logo + Text (Center)
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

                      // Notification Bell
                      GestureDetector(
                        onTap: () => showNotificationsModal(context, ref),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Icon(
                              Icons.notifications_rounded,
                              color: Colors.white,
                              size: 25,
                            ),
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
                                    border: Border.all(
                                      color: headerColor,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 14),

                      // Profile Avatar
                      GestureDetector(
                        onTap: () => CustomerNavHelper.go(context, ref, tab: 4),
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
                              avatarInitial,
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

              // ── Rounded Body Sheet (Theme Adaptive) ──────────────────────
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
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Greeting Title & Subtitle
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    activeLang == 'am' ? 'ሰላም፣ $firstName' : 'Hi, $firstName',
                                    style: TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    '👋',
                                    style: TextStyle(fontSize: 24),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                activeLang == 'am'
                                    ? 'ዛሬ ምን ዓይነት አገልግሎት ይፈልጋሉ?'
                                    : 'What service do you need today?',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Hero Search Section
                          _buildHeroSearchSection(l10n, activeLang, isDark),
                          const SizedBox(height: 24),

                          // Categories
                          _buildCategoriesSection(categories, activeLang, l10n, isDark),
                          const SizedBox(height: 24),

                          // Nearby Providers Section
                          _buildProfessionalsSection(filteredProviders, activeLang, l10n, isDark),
                          const SizedBox(height: 110),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: widget.isShell
            ? null
            : ShukBottomNavBar(
                currentIndex: 0,
                activeRole: activeRole,
                activeLang: activeLang,
              ),
      ),
    );
  }

  Widget _buildHeroSearchSection(AppLocalizations l10n, String activeLang, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.outlineLighter,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: AppTheme.textSecondary,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v.trim()),
              onSubmitted: (v) {
                setState(() => _searchQuery = v.trim());
                FocusScope.of(context).unfocus();
              },
              decoration: InputDecoration(
                hintText: activeLang == 'am'
                    ? 'አገልግሎቶችን ወይም ባለሙያዎችን ይፈልጉ...'
                    : 'Search services or providers...',
                hintStyle: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.close_rounded, color: AppTheme.textSecondary, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Voice Request Mic Button
          GestureDetector(
            onTap: () => context.push('/voice-request'),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.primaryLight.withValues(alpha: 0.15)
                    : AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? AppTheme.primaryLight.withValues(alpha: 0.3)
                      : AppTheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.mic_none_rounded,
                  color: isDark ? AppTheme.primaryLight : AppTheme.primary,
                  size: 22,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Purple Search Icon Square Button
          GestureDetector(
            onTap: () {
              setState(() => _searchQuery = _searchController.text.trim());
              FocusScope.of(context).unfocus();
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark ? AppTheme.primaryLight : AppTheme.primary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? AppTheme.primaryLight : AppTheme.primary).withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.search_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection(
    List<Map<String, dynamic>> categories,
    String activeLang,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              activeLang == 'am' ? 'የአገልግሎት ምድቦች' : 'Categories',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_selectedCategory != 'All')
              GestureDetector(
                onTap: () => setState(() => _selectedCategory = 'All'),
                child: Text(
                  activeLang == 'am' ? 'ሁሉንም አሳይ' : 'Reset Filter',
                  style: TextStyle(
                    color: isDark ? AppTheme.primaryLight : AppTheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 94,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            clipBehavior: Clip.none,
            child: Row(
              children: [
                for (int index = 0; index < categories.length; index++) ...[
                  Builder(builder: (context) {
                    final cat = categories[index];
                    final isSelected = _selectedCategory == cat['key'];
                    final color = cat['color'] as Color;
                    final label = activeLang == 'am'
                        ? (cat['labelAm'] as String)
                        : (cat['labelEn'] as String);

                    return Padding(
                      padding: EdgeInsets.only(
                        right: index == categories.length - 1 ? 0 : 12,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = cat['key'] as String;
                          });
                        },
                        child: Column(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOutCubic,
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isSelected
                                      ? [color, color.withValues(alpha: 0.8)]
                                      : (isDark
                                          ? [color.withValues(alpha: 0.22), color.withValues(alpha: 0.08)]
                                          : [color.withValues(alpha: 0.12), color.withValues(alpha: 0.04)]),
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isSelected
                                      ? color
                                      : color.withValues(alpha: isDark ? 0.35 : 0.22),
                                  width: isSelected ? 2.0 : 1.2,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: color.withValues(alpha: 0.35),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        )
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Icon(
                                  cat['icon'] as IconData,
                                  color: isSelected ? Colors.white : color,
                                  size: 26,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                color: isSelected
                                    ? (isDark ? AppTheme.primaryLight : AppTheme.primary)
                                    : AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfessionalsSection(
    List<ProviderModel> professionals,
    String activeLang,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _searchQuery.isNotEmpty
                  ? (activeLang == 'am' ? 'የፍለጋ ውጤቶች (${professionals.length})' : 'Search Results (${professionals.length})')
                  : (activeLang == 'am' ? 'አቅራቢያ ያሉ ባለሙያዎች' : 'Nearby Providers'),
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_searchQuery.isNotEmpty || _selectedCategory != 'All')
              GestureDetector(
                onTap: () {
                  setState(() {
                    _searchQuery = '';
                    _searchController.clear();
                    _selectedCategory = 'All';
                  });
                },
                child: Text(
                  activeLang == 'am' ? 'ሁሉንም አሳይ' : 'Clear All',
                  style: TextStyle(
                    color: AppTheme.secondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        if (professionals.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppTheme.bgSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.outlineLighter),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off_rounded, size: 48, color: AppTheme.textTertiary),
                const SizedBox(height: 12),
                Text(
                  activeLang == 'am' ? 'ምንም ባለሙያ አልተገኘም' : 'No service providers found',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _searchQuery.isNotEmpty
                      ? (activeLang == 'am' ? 'ለ "$_searchQuery" የሚዛመድ የለም' : 'No results matching "$_searchQuery"')
                      : (activeLang == 'am' ? 'እባክዎን ሌላ ምድብ ይምረጡ' : 'Try selecting another category or clear filters'),
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: Text(activeLang == 'am' ? 'ማጣሪያዎችን አጽዳ' : 'Clear Filters'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark ? AppTheme.primaryLight : AppTheme.primary,
                    side: BorderSide(
                      color: (isDark ? AppTheme.primaryLight : AppTheme.primary).withValues(alpha: 0.5),
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                      _searchController.clear();
                      _selectedCategory = 'All';
                    });
                  },
                ),
              ],
            ),
          )
        else
          Column(
            children: [
              for (int index = 0; index < professionals.length; index++) ...[
                if (index > 0) const SizedBox(height: 16),
                _HoverableCard(
                  onTap: () => context.push('/provider-profile/${professionals[index].id}'),
                  child: _buildProviderCard(professionals[index], activeLang, l10n, isDark),
                ),
              ],
            ],
          ),
      ],
    );
  }

  Widget _buildProviderCard(ProviderModel pro, String activeLang, AppLocalizations l10n, bool isDark) {
    final isOnline = pro.isOnline;
    final addressText = pro.address ?? 'Bole, Addis Ababa';
    final reviewsCount = (pro.jobsCount * 0.38).round() + 12;
    final expYears = pro.id == 'p1' ? '8 yrs' : (pro.id == 'p2' ? '5 yrs' : (pro.id == 'p3' ? '4 yrs' : '6 yrs'));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        children: [
          // 1. Centered Circle Avatar
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? AppTheme.primaryLight.withValues(alpha: 0.15) : AppTheme.primaryContainer,
              border: Border.all(
                color: isDark ? AppTheme.primaryLight.withValues(alpha: 0.25) : Colors.black.withValues(alpha: 0.06),
                width: 1,
              ),
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

          // 3. Specialty in Orange (Secondary brand color)
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
                  color: isOnline ? AppTheme.statusOnline : AppTheme.statusOffline,
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
                  color: isOnline ? AppTheme.statusOnline : AppTheme.statusOffline,
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
              _buildStatColumn(
                value: '${pro.rating} ★',
                label: activeLang == 'am' ? 'ግምገማዎች' : '$reviewsCount REVIEWS',
              ),
              _buildStatColumn(
                value: '${pro.jobsCount}+',
                label: activeLang == 'am' ? 'የተሰሩ ስራዎች' : 'JOBS DONE',
              ),
              _buildStatColumn(
                value: expYears,
                label: activeLang == 'am' ? 'ልምድ' : 'EXPERIENCE',
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
                  icon: Icon(
                    Icons.remove_red_eye_outlined,
                    size: 15,
                    color: isDark ? Colors.white : AppTheme.textPrimary,
                  ),
                  label: Text(
                    activeLang == 'am' ? 'ዝርዝር' : 'Details',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppTheme.textPrimary,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFF35235E) : AppTheme.primaryContainer,
                    foregroundColor: isDark ? Colors.white : AppTheme.textPrimary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: isDark
                          ? BorderSide(color: AppTheme.primaryLight.withValues(alpha: 0.35))
                          : BorderSide.none,
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
                    backgroundColor: isDark ? AppTheme.primaryDark : AppTheme.primary,
                    side: BorderSide(
                      color: isDark
                          ? AppTheme.primaryLight.withValues(alpha: 0.45)
                          : AppTheme.primary.withValues(alpha: 0.5),
                    ),
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

  Widget _buildStatColumn({required String value, required String label}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: AppTheme.textTertiary,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}

class _HoverableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _HoverableCard({
    required this.child,
    required this.onTap,
  });

  @override
  State<_HoverableCard> createState() => _HoverableCardState();
}

class _HoverableCardState extends State<_HoverableCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final themeMode = Theme.of(context).brightness;
    final isDark = themeMode == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()..scale(_isHovered ? 1.015 : 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _isHovered
                ? (isDark ? AppTheme.primaryLight : AppTheme.primary.withValues(alpha: 0.35))
                : AppTheme.cardBorder,
            width: 1.0,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: (isDark ? AppTheme.primaryLight : AppTheme.primary).withValues(alpha: 0.15),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ]
              : (isDark ? null : AppTheme.shadowSmall),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(18),
            splashColor: AppTheme.primary.withValues(alpha: 0.08),
            highlightColor: AppTheme.primary.withValues(alpha: 0.04),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
