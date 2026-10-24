import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/mock_state_providers.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../auth/providers/auth_provider.dart';
import '../../provider_profile/views/profile_screen.dart';

class UserProfileWrapper extends ConsumerWidget {
  const UserProfileWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(currentRoleProvider);
    if (role == 'provider') {
      return const ProviderProfileScreen(providerId: 'current');
    }
    return const CustomerProfileScreen();
  }
}

class CustomerProfileScreen extends ConsumerStatefulWidget {
  final bool isShell;
  const CustomerProfileScreen({super.key, this.isShell = false});

  @override
  ConsumerState<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends ConsumerState<CustomerProfileScreen> {
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;
  String _primaryAddress = 'Bole Sub-City, Addis Ababa, Ethiopia';

  final List<Map<String, String>> _savedAddresses = [
    {
      'id': 'addr_1',
      'title': 'Home',
      'titleAm': 'ቤት',
      'address': 'Bole Sub-City, Woreda 03, House 412, Addis Ababa',
      'type': 'home',
      'isDefault': 'true',
    },
    {
      'id': 'addr_2',
      'title': 'Office / Work',
      'titleAm': 'ቢሮ',
      'address': 'Kazanchis, Guinea Conakry St, Bloom Tower, 5th Floor',
      'type': 'work',
      'isDefault': 'false',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final activeLang = ref.watch(languageProvider);
    final activeRole = ref.watch(currentRoleProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    AppTheme.isDark = isDark;

    // Customer profile data from authProvider or default to Abel Abreham
    final authUser = ref.watch(authProvider).asData?.value;
    final String nameEn = authUser?.name ?? (activeLang == 'am' ? 'አቤል አብርሃም' : 'Abel Abreham');
    const String phone = '+251 912 345 678';
    const String memberSince = 'Member since Jan 2024';

    return Scaffold(
      backgroundColor: AppTheme.bgBase,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: Text(
          activeLang == 'am' ? 'የኔ መገለጫ' : 'My Profile',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.edit_rounded, color: Colors.white, size: 20),
              onPressed: () {
                _showEditProfileSheet(context, activeLang, nameEn, isDark);
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── 1. Hero Header ──────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? const [Color(0xFF20113B), Color(0xFF351B62)]
                    : const [Color(0xFF4527A0), Color(0xFF7E57C2)],
              ),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                child: Row(
                  children: [
                    // Avatar
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 26,
                        backgroundColor: isDark ? const Color(0xFF35235E) : const Color(0xFFD1C4E9),
                        child: Text(
                          'A',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppTheme.primaryLight : const Color(0xFF512DA8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Name + Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              Text(
                                nameEn,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.verified_rounded, color: Colors.white, size: 11),
                                    const SizedBox(width: 3),
                                    Text(
                                      memberSince,
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.95),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.phone_rounded, color: Colors.white70, size: 12),
                              const SizedBox(width: 4),
                              const Text(
                                phone,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Icon(Icons.location_on_rounded, color: Colors.white70, size: 12),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  _primaryAddress,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── 2. SCROLLABLE Content Below Header ─────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                // ── Stats Row ────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.bgSurface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.outlineLighter),
                      boxShadow: isDark
                          ? null
                          : [
                              BoxShadow(
                                color: const Color(0xFF512DA8).withValues(alpha: 0.07),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                    ),
                    child: Row(
                      children: [
                        _StatItem(
                          label: activeLang == 'am' ? 'ጠቅላላ ትዕዛዞች' : 'Total Bookings',
                          value: '12',
                          icon: Icons.assignment_rounded,
                          color: isDark ? AppTheme.primaryLight : const Color(0xFF512DA8),
                        ),
                        _VerticalDivider(),
                        _StatItem(
                          label: activeLang == 'am' ? 'በጥበቃ ላይ' : 'Pending',
                          value: '2',
                          icon: Icons.hourglass_empty_rounded,
                          color: const Color(0xFFFF9800),
                        ),
                        _VerticalDivider(),
                        _StatItem(
                          label: activeLang == 'am' ? 'ተጠናቀቀ' : 'Completed',
                          value: '9',
                          icon: Icons.task_alt_rounded,
                          color: const Color(0xFF2E7D32),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Account Section ──────────────────────────────────────
                _SectionHeader(
                  icon: Icons.person_rounded,
                  label: activeLang == 'am' ? 'መለያ' : 'Account',
                  isDark: isDark,
                ),
                _MenuCard(
                  items: [
                    _MenuItem(
                      icon: Icons.person_outline_rounded,
                      iconColor: isDark ? AppTheme.primaryLight : const Color(0xFF512DA8),
                      label: activeLang == 'am' ? 'ግላዊ መረጃ' : 'Personal Information',
                      subtitle: activeLang == 'am' ? 'ስም፣ ስልክ፣ ኢሜይል' : 'Name, phone, email',
                      onTap: () => _showEditProfileSheet(context, activeLang, nameEn, isDark),
                    ),
                    _MenuItem(
                      icon: Icons.location_on_outlined,
                      iconColor: AppTheme.primaryLight,
                      label: activeLang == 'am' ? 'የተቀመጡ አድራሻዎች' : 'Saved Addresses',
                      subtitle: _primaryAddress,
                      onTap: () => _showManageAddressSheet(context, activeLang, isDark),
                    ),
                    _MenuItem(
                      icon: Icons.lock_reset_rounded,
                      iconColor: isDark ? AppTheme.primaryLight : const Color(0xFF512DA8),
                      label: activeLang == 'am' ? 'ይለፍ ቃል ቀይር' : 'Change Password',
                      subtitle: activeLang == 'am' ? 'የአሁኑ እና አዲስ ይለፍ ቃል' : 'Update account password',
                      onTap: () => _showChangePasswordSheet(context, activeLang, isDark),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ── Preferences Section ──────────────────────────────────
                _SectionHeader(
                  icon: Icons.settings_rounded,
                  label: activeLang == 'am' ? 'ምርጫዎች' : 'Preferences',
                  isDark: isDark,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.bgSurface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.outlineLighter),
                      boxShadow: isDark
                          ? null
                          : [
                              BoxShadow(
                                color: const Color(0xFF512DA8).withValues(alpha: 0.06),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                    ),
                    child: Column(
                      children: [
                        // Dark Mode Toggle
                        _ToggleTile(
                          icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                          iconColor: const Color(0xFFFFB300),
                          label: activeLang == 'am' ? 'ጨለማ ገጽታ (Dark Mode)' : 'Dark Mode',
                          value: isDark,
                          onChanged: (val) {
                            ref.read(themeModeProvider.notifier).setThemeMode(
                              val ? ThemeMode.dark : ThemeMode.light,
                            );
                          },
                        ),
                        Divider(height: 1, thickness: 0.5, indent: 56, color: AppTheme.outlineLighter),

                        _ToggleTile(
                          icon: Icons.notifications_outlined,
                          iconColor: isDark ? AppTheme.primaryLight : const Color(0xFF512DA8),
                          label: activeLang == 'am' ? 'ማሳወቂያዎች' : 'Notifications',
                          value: _notificationsEnabled,
                          onChanged: (v) => setState(() => _notificationsEnabled = v),
                        ),
                        Divider(height: 1, thickness: 0.5, indent: 56, color: AppTheme.outlineLighter),
                        _ToggleTile(
                          icon: Icons.location_on_outlined,
                          iconColor: AppTheme.primaryLight,
                          label: activeLang == 'am' ? 'አካባቢ' : 'Location Services',
                          value: _locationEnabled,
                          onChanged: (v) => setState(() => _locationEnabled = v),
                        ),
                        Divider(height: 1, thickness: 0.5, indent: 56, color: AppTheme.outlineLighter),
                        // Language toggle
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF35235E) : AppTheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.language_rounded, color: Color(0xFF26A69A), size: 20),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  activeLang == 'am' ? 'ቋንቋ' : 'Language',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  ref.read(languageProvider.notifier).setLanguage(
                                    activeLang == 'am' ? 'en' : 'am',
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF35235E) : AppTheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isDark
                                          ? AppTheme.primaryLight.withValues(alpha: 0.4)
                                          : AppTheme.primaryLight.withValues(alpha: 0.5),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        activeLang == 'am' ? '🇪🇹 አማርኛ' : '🇺🇸 English',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? Colors.white : AppTheme.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.swap_horiz_rounded,
                                        size: 16,
                                        color: isDark ? Colors.white : AppTheme.primary,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Sign Out Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: AppTheme.bgSurface,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          title: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.error.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.logout_rounded, color: AppTheme.error, size: 22),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                activeLang == 'am' ? 'ውጣ' : 'Sign Out',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          content: Text(
                            activeLang == 'am'
                                ? 'ከመለያዎ መውጣት ይፈልጋሉ?'
                                : 'Are you sure you want to sign out?',
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: Text(
                                activeLang == 'am' ? 'ይቅር' : 'Cancel',
                                style: TextStyle(color: AppTheme.textSecondary),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(ctx).pop();
                                ref.read(authProvider.notifier).logout();
                                context.go('/login');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.error,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: Text(activeLang == 'am' ? 'አዎ፣ ውጣ' : 'Sign Out'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.bgSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.error.withValues(alpha: 0.3)),
                        boxShadow: isDark
                            ? null
                            : [
                                BoxShadow(
                                  color: AppTheme.error.withValues(alpha: 0.06),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppTheme.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.logout_rounded, color: AppTheme.error, size: 20),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            activeLang == 'am' ? 'ከመለያ ውጣ' : 'Sign Out',
                            style: const TextStyle(
                              color: AppTheme.error,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.error, size: 14),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // App version footer
                Center(
                  child: Text(
                    'Shuk v1.0.0 · Made in Ethiopia 🇪🇹',
                    style: TextStyle(fontSize: 11, color: AppTheme.textTertiary),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: widget.isShell
          ? null
          : ShukBottomNavBar(
              currentIndex: 4,
              activeRole: activeRole,
              activeLang: activeLang,
            ),
    );
  }

  void _showEditProfileSheet(BuildContext context, String activeLang, String nameEn, bool isDark) {
    final nameCtrl = TextEditingController(text: nameEn);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: AppTheme.bgSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.fromLTRB(
          24,
          20,
          24,
          MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.outlineLight,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              activeLang == 'am' ? 'መገለጫ አርትዕ' : 'Edit Profile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameCtrl,
              style: TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                labelText: activeLang == 'am' ? 'ሙሉ ስም' : 'Full Name',
                labelStyle: TextStyle(color: AppTheme.textSecondary),
                filled: true,
                fillColor: AppTheme.inputBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.inputBorderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: isDark ? AppTheme.primaryLight : AppTheme.primary, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 14),
            _EditField(label: activeLang == 'am' ? 'ስልክ' : 'Phone', initialValue: '+251 912 345 678', keyboardType: TextInputType.phone),
            const SizedBox(height: 14),
            _EditField(label: activeLang == 'am' ? 'አድራሻ' : 'Location', initialValue: 'Addis Ababa, Ethiopia'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  final newName = nameCtrl.text.trim();
                  if (newName.isNotEmpty) {
                    ref.read(authProvider.notifier).updateProfile(name: newName);
                  }
                  Navigator.of(ctx).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppTheme.primaryLight : AppTheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  activeLang == 'am' ? 'ለውጦችን አስቀምጥ' : 'Save Changes',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showManageAddressSheet(BuildContext context, String activeLang, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          decoration: BoxDecoration(
            color: AppTheme.bgSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.outlineLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    activeLang == 'am' ? 'የተቀመጡ አድራሻዎች' : 'Saved Addresses',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  TextButton.icon(
                    icon: Icon(Icons.add_rounded, size: 18, color: isDark ? AppTheme.primaryLight : AppTheme.primary),
                    label: Text(
                      activeLang == 'am' ? 'አዲስ አክል' : 'Add New',
                      style: TextStyle(
                        color: isDark ? AppTheme.primaryLight : AppTheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showAddNewAddressSheet(context, activeLang, isDark);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ..._savedAddresses.map((addr) {
                final isDefault = addr['isDefault'] == 'true';
                final isHome = addr['type'] == 'home';
                final title = activeLang == 'am' ? (addr['titleAm'] ?? addr['title']!) : addr['title']!;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDefault
                        ? (isDark ? const Color(0xFF35235E) : AppTheme.primaryContainer)
                        : AppTheme.bgBase,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDefault
                          ? (isDark ? AppTheme.primaryLight : AppTheme.primary)
                          : AppTheme.outlineLighter,
                      width: isDefault ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDefault
                              ? (isDark ? AppTheme.primaryLight : const Color(0xFF512DA8))
                              : (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE2E8F0)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isHome ? Icons.home_rounded : Icons.work_rounded,
                          color: isDefault
                              ? Colors.white
                              : (isDark ? AppTheme.textSecondary : const Color(0xFF475569)),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                if (isDefault) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isDark ? AppTheme.primaryLight : const Color(0xFF512DA8),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      activeLang == 'am' ? 'ዋና አድራሻ' : 'Default',
                                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              addr['address']!,
                              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isDefault ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                          color: isDefault
                              ? (isDark ? AppTheme.primaryLight : const Color(0xFF512DA8))
                              : AppTheme.textTertiary,
                          size: 22,
                        ),
                        onPressed: () {
                          setState(() {
                            for (var a in _savedAddresses) {
                              a['isDefault'] = 'false';
                            }
                            addr['isDefault'] = 'true';
                            _primaryAddress = addr['address']!;
                          });
                          setSheetState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(activeLang == 'am' ? 'ዋና አድራሻ ተቀይሯል ✓' : 'Default address updated ✓'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? AppTheme.primaryLight : const Color(0xFF512DA8),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(activeLang == 'am' ? 'ተከናውኗል' : 'Done', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddNewAddressSheet(BuildContext context, String activeLang, bool isDark) {
    final titleCtrl = TextEditingController();
    final addressCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.bgSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.outlineLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                activeLang == 'am' ? 'አዲስ አድራሻ አክል' : 'Add New Address',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleCtrl,
                style: TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  labelText: activeLang == 'am' ? 'የአድራሻ ስም (ለምሳሌ: ቤት፣ ቢሮ)' : 'Label (e.g. Home, Office, Gym)',
                  labelStyle: TextStyle(color: AppTheme.textSecondary),
                  filled: true,
                  fillColor: AppTheme.inputBg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.inputBorderColor)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressCtrl,
                maxLines: 2,
                style: TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  labelText: activeLang == 'am' ? 'ሙሉ አድራሻ (ክፍለ ከተማ፣ ወረዳ፣ የቤት ቁጥር)' : 'Full Address (Sub-City, Woreda, House No)',
                  labelStyle: TextStyle(color: AppTheme.textSecondary),
                  filled: true,
                  fillColor: AppTheme.inputBg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.inputBorderColor)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? AppTheme.primaryLight : AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final t = titleCtrl.text.trim();
                    final a = addressCtrl.text.trim();
                    if (t.isNotEmpty && a.isNotEmpty) {
                      setState(() {
                        _savedAddresses.add({
                          'id': 'addr_${DateTime.now().millisecondsSinceEpoch}',
                          'title': t,
                          'titleAm': t,
                          'address': a,
                          'type': 'custom',
                          'isDefault': 'false',
                        });
                      });
                      Navigator.pop(ctx);
                      _showManageAddressSheet(context, activeLang, isDark);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(activeLang == 'am' ? 'አድራሻ በተሳካ ሁኔታ ተጨምሯል ✓' : 'Address added successfully ✓'), behavior: SnackBarBehavior.floating),
                      );
                    }
                  },
                  child: Text(activeLang == 'am' ? 'አድራሻ አስቀምጥ' : 'Save Address', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangePasswordSheet(BuildContext context, String activeLang, bool isDark) {
    final currentPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: AppTheme.bgSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.fromLTRB(
          24,
          20,
          24,
          MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.outlineLight,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              activeLang == 'am' ? 'ይለፍ ቃል ቀይር' : 'Change Password',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              activeLang == 'am'
                  ? 'ለደህንነትዎ ጠንካራ ይለፍ ቃል ያስገቡ።'
                  : 'Enter your current and new password below.',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: currentPassController,
              obscureText: true,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
              decoration: InputDecoration(
                labelText: activeLang == 'am' ? 'የአሁኑ ይለፍ ቃል' : 'Current Password',
                labelStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                filled: true,
                fillColor: AppTheme.inputBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.inputBorderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: isDark ? AppTheme.primaryLight : AppTheme.primary, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: newPassController,
              obscureText: true,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
              decoration: InputDecoration(
                labelText: activeLang == 'am' ? 'አዲስ ይለፍ ቃል' : 'New Password',
                labelStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                filled: true,
                fillColor: AppTheme.inputBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.inputBorderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: isDark ? AppTheme.primaryLight : AppTheme.primary, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: confirmPassController,
              obscureText: true,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
              decoration: InputDecoration(
                labelText: activeLang == 'am' ? 'አዲሱን ይለፍ ቃል ያረጋግጡ' : 'Confirm New Password',
                labelStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                filled: true,
                fillColor: AppTheme.inputBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.inputBorderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: isDark ? AppTheme.primaryLight : AppTheme.primary, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (newPassController.text.trim().isEmpty || confirmPassController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(activeLang == 'am' ? 'ሁሉንም ሳጥኖች ይሙሉ!' : 'Please fill in all fields.'),
                        backgroundColor: AppTheme.statusWarning,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }
                  if (newPassController.text != confirmPassController.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(activeLang == 'am' ? 'ይለፍ ቃሎች አይዛመዱም!' : 'Passwords do not match.'),
                        backgroundColor: AppTheme.error,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(activeLang == 'am' ? 'ይለፍ ቃል በተሳካ ሁኔታ ተቀይሯል!' : 'Password updated successfully!'),
                      backgroundColor: AppTheme.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppTheme.primaryLight : AppTheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  activeLang == 'am' ? 'ይለፍ ቃል ቀይር' : 'Update Password',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stat Item ─────────────────────────────────────────────────────────────
class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatItem({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ── Vertical Divider ──────────────────────────────────────────────────────────
class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 0.5, height: 60, color: AppTheme.outlineLighter);
  }
}

// ── Section Header ────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  const _SectionHeader({required this.icon, required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final headerColor = isDark ? AppTheme.primaryLight : AppTheme.primary;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: headerColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: headerColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Menu Card ─────────────────────────────────────────────────────────────────
class _MenuCard extends StatelessWidget {
  final List<_MenuItem> items;
  const _MenuCard({required this.items});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.bgSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.outlineLighter),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: const Color(0xFF512DA8).withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          children: [
            for (int i = 0; i < items.length; i++) ...[
              items[i],
              if (i < items.length - 1)
                Divider(height: 1, thickness: 0.5, indent: 56, color: AppTheme.outlineLighter),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Menu Item ─────────────────────────────────────────────────────────────────
class _MenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textTertiary),
          ],
        ),
      ),
    );
  }
}

// ── Toggle Tile ───────────────────────────────────────────────────────────────
class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: isDark ? AppTheme.primaryLight : AppTheme.primary,
            activeTrackColor: (isDark ? AppTheme.primaryLight : AppTheme.primary).withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }
}

// ── Edit Field ────────────────────────────────────────────────────────────────
class _EditField extends StatelessWidget {
  final String label;
  final String initialValue;
  final TextInputType? keyboardType;

  const _EditField({required this.label, required this.initialValue, this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        filled: true,
        fillColor: AppTheme.inputBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.inputBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.inputBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primaryLight, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
