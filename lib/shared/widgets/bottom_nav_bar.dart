import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/nav_helpers.dart';
import '../../core/theme/app_theme.dart';

class ShukBottomNavBar extends ConsumerWidget {
  final int currentIndex;
  final String activeRole;
  final String activeLang;
  final ValueChanged<int>? onTabSelected;

  const ShukBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.activeRole,
    required this.activeLang,
    this.onTabSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = activeRole == 'admin';
    final isProvider = activeRole == 'provider';
    final safeIndex = (currentIndex >= 0 && currentIndex <= 4) ? currentIndex : 0;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        border: Border(
          top: BorderSide(color: AppTheme.outlineLighter, width: 1.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: BottomNavigationBar(
          backgroundColor: AppTheme.bgSurface,
          elevation: 0,
          currentIndex: safeIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: AppTheme.textCaption,
          showUnselectedLabels: true,
          showSelectedLabels: true,
          selectedLabelStyle: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w500,
          ),
          items: _buildItems(isAdmin, isProvider, activeLang),
          onTap: (index) {
            if (onTabSelected != null) {
              onTabSelected!(index);
            } else {
              _handleNavigation(context, ref, index, isAdmin, isProvider);
            }
          },
        ),
      ),
    );
  }

  List<BottomNavigationBarItem> _buildItems(
    bool isAdmin,
    bool isProvider,
    String activeLang,
  ) {
    if (isAdmin) {
      return [
        BottomNavigationBarItem(
          icon: const Icon(Icons.dashboard_outlined, size: 22),
          activeIcon: const Icon(Icons.dashboard_rounded, size: 22),
          label: activeLang == 'am' ? 'አጠቃላይ' : 'Overview',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.people_outline_rounded, size: 22),
          activeIcon: const Icon(Icons.people_rounded, size: 22),
          label: activeLang == 'am' ? 'ተጠቃሚዎች' : 'Users',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.verified_user_outlined, size: 22),
          activeIcon: const Icon(Icons.verified_user_rounded, size: 22),
          label: activeLang == 'am' ? 'ባለሙያዎች' : 'Providers',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.event_note_outlined, size: 22),
          activeIcon: const Icon(Icons.event_note_rounded, size: 22),
          label: activeLang == 'am' ? 'ቦኪንጎች' : 'Bookings',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.gavel_outlined, size: 22),
          activeIcon: const Icon(Icons.gavel_rounded, size: 22),
          label: activeLang == 'am' ? 'ክርክሮች' : 'Disputes',
        ),
      ];
    }

    if (isProvider) {
      return [
        BottomNavigationBarItem(
          icon: const Icon(Icons.dashboard_outlined, size: 22),
          activeIcon: const Icon(Icons.dashboard_rounded, size: 22),
          label: activeLang == 'am' ? 'ዳሽቦርድ' : 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.calendar_today_outlined, size: 22),
          activeIcon: const Icon(Icons.calendar_today_rounded, size: 22),
          label: activeLang == 'am' ? 'ትዕዛዞች' : 'Bookings',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.assignment_outlined, size: 22),
          activeIcon: const Icon(Icons.assignment_rounded, size: 22),
          label: activeLang == 'am' ? 'ጥያቄዎች' : 'Requests',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.chat_bubble_outline_rounded, size: 22),
          activeIcon: const Icon(Icons.chat_bubble_rounded, size: 22),
          label: activeLang == 'am' ? 'ውይይት' : 'Messages',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person_outline_rounded, size: 22),
          activeIcon: const Icon(Icons.person_rounded, size: 22),
          label: activeLang == 'am' ? 'መገለጫ' : 'Profile',
        ),
      ];
    }

    // Customer
    return [
      BottomNavigationBarItem(
        icon: const Icon(Icons.home_outlined, size: 22),
        activeIcon: const Icon(Icons.home_rounded, size: 22),
        label: activeLang == 'am' ? 'ቤት' : 'Home',
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.calendar_today_outlined, size: 22),
        activeIcon: const Icon(Icons.calendar_today_rounded, size: 22),
        label: activeLang == 'am' ? 'ትዕዛዞች' : 'Bookings',
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.assignment_outlined, size: 22),
        activeIcon: const Icon(Icons.assignment_rounded, size: 22),
        label: activeLang == 'am' ? 'ጥያቄዎች' : 'Requests',
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.chat_bubble_outline_rounded, size: 22),
        activeIcon: const Icon(Icons.chat_bubble_rounded, size: 22),
        label: activeLang == 'am' ? 'ውይይት' : 'Messages',
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.person_outline_rounded, size: 22),
        activeIcon: const Icon(Icons.person_rounded, size: 22),
        label: activeLang == 'am' ? 'መገለጫ' : 'Profile',
      ),
    ];
  }

  void _handleNavigation(
    BuildContext context,
    WidgetRef ref,
    int index,
    bool isAdmin,
    bool isProvider,
  ) {
    if (index == currentIndex) return;

    if (isAdmin) {
      context.go('/admin-dashboard');
      return;
    }

    if (isProvider) {
      ProviderNavHelper.go(context, ref, tab: index);
      return;
    }

    // Customer
    CustomerNavHelper.go(context, ref, tab: index);
  }
}
