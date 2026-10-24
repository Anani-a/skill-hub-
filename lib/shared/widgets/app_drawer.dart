import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/nav_helpers.dart';
import '../../core/theme/app_theme.dart';
import '../../features/home/views/customer_main_screen.dart';
import '../../features/provider_dashboard/views/provider_main_screen.dart';
import '../providers/mock_state_providers.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/notifications/providers/notification_provider.dart';
import 'notification_modal.dart';

// ─────────────────────────────────────────────────────────────────────────────
// App Drawer (Sidebar) — Unified Premium Design matching Admin Sidebar
// ─────────────────────────────────────────────────────────────────────────────

class AppDrawer extends ConsumerStatefulWidget {
  const AppDrawer({super.key});

  @override
  ConsumerState<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends ConsumerState<AppDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _showLogoutConfirmDialog(BuildContext context, String activeLang) {
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
              activeLang == 'am' ? 'ውጣ' : 'Confirm Logout',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary),
            ),
          ],
        ),
        content: Text(
          activeLang == 'am'
              ? 'እርግጠኛ ነዎት ከመለያዎ መውጣት ይፈልጋሉ?'
              : 'Are you sure you want to log out of your Shuk account?',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
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
              if (context.mounted && Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
              ref.read(currentRoleProvider.notifier).setRole('customer');
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              activeLang == 'am' ? 'ውጣ' : 'Logout',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeLang = ref.watch(languageProvider);
    final activeRole = ref.watch(currentRoleProvider);
    final authUser = ref.watch(authProvider).asData?.value;
    final unreadNotifCount = ref.watch(unreadNotificationsCountProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    AppTheme.isDark = isDark;
    final currentPath = GoRouterState.of(context).uri.toString();

    final userName = authUser?.name ?? (activeRole == 'provider' ? 'Bekele Tadesse' : 'Abel Abreham');
    final avatarLetter = userName.isNotEmpty ? userName[0].toUpperCase() : 'A';

    final String roleBadge;
    if (activeRole == 'admin') {
      roleBadge = activeLang == 'am' ? 'ዋና አስተዳዳሪ' : 'System Admin';
    } else if (activeRole == 'provider') {
      roleBadge = activeLang == 'am' ? 'የተረጋገጠ ባለሙያ' : 'Verified Provider';
    } else {
      roleBadge = activeLang == 'am' ? 'ደንበኛ' : 'Customer';
    }

    return FadeTransition(
      opacity: _fadeAnim,
      child: Drawer(
        width: MediaQuery.of(context).size.width * 0.82,
        backgroundColor: AppTheme.bgSurface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(28),
            bottomRight: Radius.circular(28),
          ),
        ),
        child: Column(
          children: [
            // ── Top Gradient Hero Header (Matching Admin Sidebar) ───────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 48, 20, 22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? const [Color(0xFF1E1435), Color(0xFF2E1C4D), Color(0xFF3F2766)]
                      : const [Color(0xFF311B92), Color(0xFF512DA8), Color(0xFF7E57C2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.white.withValues(alpha: 0.25),
                      child: Text(
                        avatarLetter,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            roleBadge,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Quick Theme & Language Preferences Row ──────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
              child: Row(
                children: [
                  Expanded(child: _CompactThemeToggle(activeLang: activeLang)),
                  const SizedBox(width: 8),
                  Expanded(child: _CompactLanguageToggle(activeLang: activeLang)),
                ],
              ),
            ),

            const Divider(height: 16, thickness: 0.8),

            // ── Role-Based Navigation Links List ────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 4),
                children: _buildRoleNavItems(context, activeRole, activeLang, currentPath, unreadNotifCount),
              ),
            ),

            // ── Bottom Logout Section (Matching Admin Sidebar) ──────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: AppTheme.outlineLighter)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.logout_rounded, color: AppTheme.error, size: 18),
                  label: Text(
                    activeLang == 'am' ? 'ውጣ' : 'Logout',
                    style: const TextStyle(
                      color: AppTheme.error,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.error, width: 1.2),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    _showLogoutConfirmDialog(context, activeLang);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRoleNavItems(
    BuildContext context,
    String activeRole,
    String activeLang,
    String currentPath,
    int unreadNotifCount,
  ) {
    if (activeRole == 'provider') {
      final pTab = ref.watch(providerTabProvider);
      return [
        _drawerItem(
          icon: Icons.dashboard_rounded,
          label: activeLang == 'am' ? 'ዳሽቦርድ' : 'Dashboard Overview',
          isSelected: pTab == 0,
          onTap: () {
            Navigator.pop(context);
            ProviderNavHelper.go(context, ref, tab: 0);
          },
        ),
        _drawerItem(
          icon: Icons.person_outline_rounded,
          label: activeLang == 'am' ? 'የባለሙያ መገለጫ' : 'Provider Profile',
          isSelected: pTab == 4,
          onTap: () {
            Navigator.pop(context);
            ProviderNavHelper.go(context, ref, tab: 4);
          },
        ),
        _drawerItem(
          icon: Icons.assignment_outlined,
          label: activeLang == 'am' ? 'የሥራ ጥያቄዎች' : 'Job Requests',
          isSelected: pTab == 2,
          onTap: () {
            Navigator.pop(context);
            ProviderNavHelper.go(context, ref, tab: 2);
          },
        ),
        _drawerItem(
          icon: Icons.calendar_today_outlined,
          label: activeLang == 'am' ? 'ትዕዛዞች ማስተዳደሪያ' : 'Bookings Management',
          isSelected: pTab == 1,
          onTap: () {
            Navigator.pop(context);
            ProviderNavHelper.go(context, ref, tab: 1);
          },
        ),
        _drawerItem(
          icon: Icons.chat_bubble_outline_rounded,
          label: activeLang == 'am' ? 'ውይይቶች' : 'Messages',
          isSelected: pTab == 3,
          onTap: () {
            Navigator.pop(context);
            ProviderNavHelper.go(context, ref, tab: 3);
          },
        ),
        _drawerItem(
          icon: Icons.notifications_none_rounded,
          label: activeLang == 'am' ? 'ማሳወቂያዎች' : 'Notifications',
          badgeCount: unreadNotifCount > 0 ? unreadNotifCount : null,
          isSelected: false,
          onTap: () {
            Navigator.pop(context);
            showNotificationsModal(context, ref);
          },
        ),
        _drawerItem(
          icon: Icons.gavel_outlined,
          label: activeLang == 'am' ? 'የክርክር ማእከል' : 'Disputes Center',
          isSelected: currentPath.startsWith('/dispute'),
          onTap: () {
            Navigator.pop(context);
            context.push('/dispute');
          },
        ),
      ];
    } else {
      // Customer Sidebar Items
      final cTab = ref.watch(customerTabProvider);
      return [
        _drawerItem(
          icon: Icons.home_rounded,
          label: activeLang == 'am' ? 'ዋና ገጽ' : 'Home',
          isSelected: cTab == 0,
          onTap: () {
            Navigator.pop(context);
            CustomerNavHelper.go(context, ref, tab: 0);
          },
        ),
        _drawerItem(
          icon: Icons.person_outline_rounded,
          label: activeLang == 'am' ? 'የኔ መገለጫ' : 'My Profile',
          isSelected: cTab == 4,
          onTap: () {
            Navigator.pop(context);
            CustomerNavHelper.go(context, ref, tab: 4);
          },
        ),
        _drawerItem(
          icon: Icons.assignment_outlined,
          label: activeLang == 'am' ? 'የጥያቄ ደብተር' : 'My Requests Book',
          isSelected: cTab == 2,
          onTap: () {
            Navigator.pop(context);
            CustomerNavHelper.go(context, ref, tab: 2);
          },
        ),
        _drawerItem(
          icon: Icons.history_rounded,
          label: activeLang == 'am' ? 'የትዕዛዝ ታሪክ' : 'Booking History',
          isSelected: cTab == 1,
          onTap: () {
            Navigator.pop(context);
            CustomerNavHelper.go(context, ref, tab: 1);
          },
        ),
        _drawerItem(
          icon: Icons.mic_none_rounded,
          label: activeLang == 'am' ? 'የድምፅ አገልግሎት ጥያቄ' : 'Voice Request',
          isSelected: currentPath == '/voice-request',
          onTap: () {
            Navigator.pop(context);
            context.push('/voice-request');
          },
        ),
        _drawerItem(
          icon: Icons.chat_bubble_outline_rounded,
          label: activeLang == 'am' ? 'ውይይቶች' : 'Messages',
          isSelected: cTab == 3,
          onTap: () {
            Navigator.pop(context);
            CustomerNavHelper.go(context, ref, tab: 3);
          },
        ),
        _drawerItem(
          icon: Icons.notifications_none_rounded,
          label: activeLang == 'am' ? 'ማሳወቂያዎች' : 'Notifications',
          badgeCount: unreadNotifCount > 0 ? unreadNotifCount : null,
          isSelected: false,
          onTap: () {
            Navigator.pop(context);
            showNotificationsModal(context, ref);
          },
        ),
        _drawerItem(
          icon: Icons.gavel_outlined,
          label: activeLang == 'am' ? 'የክርክር ማእከል' : 'Disputes Center',
          isSelected: currentPath.startsWith('/dispute'),
          onTap: () {
            Navigator.pop(context);
            context.push('/dispute');
          },
        ),
      ];
    }
  }

  Widget _drawerItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    int? badgeCount,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primary.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
          size: 22,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
          ),
        ),
        trailing: badgeCount != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.error,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              )
            : (isSelected ? const Icon(Icons.chevron_right_rounded, color: AppTheme.primary, size: 18) : null),
        onTap: onTap,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Compact Theme Toggle Pill (Light / Dark)
// ─────────────────────────────────────────────────────────────────────────────

class _CompactThemeToggle extends ConsumerWidget {
  final String activeLang;
  const _CompactThemeToggle({required this.activeLang});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Container(
      height: 38,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppTheme.bgBase,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.outlineLighter),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  color: !isDark ? AppTheme.bgSurface : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: !isDark
                      ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 4, offset: const Offset(0, 1))]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wb_sunny_rounded, size: 14, color: !isDark ? AppTheme.primary : AppTheme.textTertiary),
                    const SizedBox(width: 4),
                    Text(
                      activeLang == 'am' ? 'ብርሃን' : 'Light',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: !isDark ? FontWeight.bold : FontWeight.w500,
                        color: !isDark ? AppTheme.textPrimary : AppTheme.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.nightlight_round, size: 14, color: isDark ? Colors.white : AppTheme.textTertiary),
                    const SizedBox(width: 4),
                    Text(
                      activeLang == 'am' ? 'ጨለማ' : 'Dark',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isDark ? FontWeight.bold : FontWeight.w500,
                        color: isDark ? Colors.white : AppTheme.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Compact Language Toggle Pill (English / Amharic)
// ─────────────────────────────────────────────────────────────────────────────

class _CompactLanguageToggle extends ConsumerWidget {
  final String activeLang;
  const _CompactLanguageToggle({required this.activeLang});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAm = activeLang == 'am';

    return Container(
      height: 38,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppTheme.bgBase,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.outlineLighter),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => ref.read(languageProvider.notifier).setLanguage('en'),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  color: !isAm ? AppTheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '🇺🇸 EN',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: !isAm ? FontWeight.bold : FontWeight.w500,
                      color: !isAm ? Colors.white : AppTheme.textTertiary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => ref.read(languageProvider.notifier).setLanguage('am'),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  color: isAm ? AppTheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '🇪🇹 አማ',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isAm ? FontWeight.bold : FontWeight.w500,
                      color: isAm ? Colors.white : AppTheme.textTertiary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
