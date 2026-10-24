import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/views/customer_main_screen.dart';
import '../../features/provider_dashboard/views/provider_main_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Navigation helpers for Customer and Provider shells.
//
// Instead of navigating to separate routes for each tab (which causes GoRouter
// to unmount+remount the shell widget and slide the nav bar), we stay on the
// SAME route whenever already on the shell, and update only the Riverpod tab
// state. The IndexedStack switches the tab instantly without moving the
// bottom navigation bar, exactly matching the stable Admin Dashboard behavior.
// ─────────────────────────────────────────────────────────────────────────────

class CustomerNavHelper {
  static void go(BuildContext context, WidgetRef ref, {required int tab}) {
    ref.read(customerTabProvider.notifier).state = tab;
    final currentRoute = GoRouterState.of(context).matchedLocation;
    if (!_isCustomerShellRoute(currentRoute)) {
      context.go('/home');
    }
  }

  static bool _isCustomerShellRoute(String route) {
    const shellRoutes = [
      '/home',
      '/booking-history',
      '/customer-requests',
      '/chat-list',
      '/user-profile',
    ];
    return shellRoutes.contains(route);
  }
}

class ProviderNavHelper {
  static void go(BuildContext context, WidgetRef ref, {required int tab}) {
    ref.read(providerTabProvider.notifier).state = tab;
    final currentRoute = GoRouterState.of(context).matchedLocation;
    if (!_isProviderShellRoute(currentRoute)) {
      context.go('/provider-dashboard');
    }
  }

  static bool _isProviderShellRoute(String route) {
    const shellRoutes = [
      '/provider-dashboard',
      '/provider-bookings',
      '/provider-requests',
      '/chat-list',
      '/user-profile',
    ];
    return shellRoutes.contains(route);
  }
}
