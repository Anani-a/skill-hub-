import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/views/onboarding_screen.dart';
import '../../features/auth/views/login_screen.dart';
import '../../features/auth/views/register_screen.dart';
import '../../features/home/views/customer_main_screen.dart';
import '../../features/provider_dashboard/views/provider_main_screen.dart';
import '../../shared/providers/mock_state_providers.dart';
import '../../features/provider_profile/views/profile_screen.dart';
import '../../features/voice_request/views/voice_request_screen.dart';
import '../../features/booking/views/booking_checkout_screen.dart';
import '../../features/booking/views/booking_details_screen.dart';
import '../../features/booking/views/active_service_screen.dart';
import '../../features/chat/views/chat_screen.dart';
import '../../features/admin/views/admin_dashboard_screen.dart';
import '../../features/dispute/views/dispute_screen.dart';
import '../../features/review/views/review_screen.dart';
import '../../features/provider_verification/views/provider_verification_step1_screen.dart';
import '../../features/provider_verification/views/provider_verification_step2_screen.dart';
import '../../features/provider_verification/views/provider_verification_status_screen.dart';
import '../../features/provider_onboarding/views/create_profile_screen.dart';
import '../../features/provider_onboarding/views/add_services_screen.dart';
import '../../features/provider_onboarding/views/availability_screen.dart';
import '../../features/provider_onboarding/views/service_area_screen.dart';
import '../../features/provider_onboarding/views/add_new_service_screen.dart';

export 'nav_helpers.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/provider-verification-step1',
      builder: (context, state) => const ProviderVerificationStep1Screen(),
    ),
    GoRoute(
      path: '/provider-verification-step2',
      builder: (context, state) => const ProviderVerificationStep2Screen(),
    ),
    GoRoute(
      path: '/provider-verification-status',
      builder: (context, state) => const ProviderVerificationStatusScreen(),
    ),
    GoRoute(
      path: '/provider-onboarding-profile',
      builder: (context, state) => const CreateProfileScreen(),
    ),
    GoRoute(
      path: '/provider-onboarding-services',
      builder: (context, state) => const AddServicesScreen(),
    ),
    GoRoute(
      path: '/provider-onboarding-add-new-service',
      builder: (context, state) => const AddNewServiceScreen(),
    ),
    GoRoute(
      path: '/provider-onboarding-availability',
      builder: (context, state) => const AvailabilityScreen(),
    ),
    GoRoute(
      path: '/provider-onboarding-service-area',
      builder: (context, state) => const ServiceAreaScreen(),
    ),

    // ── Customer Shell ───────────────────────────────────────────────────────
    // All customer tab paths live here. Each sets the tab then renders the
    // SAME CustomerMainScreen — GoRouter stays on this single page, so the
    // bottom nav never animates.
    GoRoute(
      path: '/home',
      pageBuilder: (context, state) => const NoTransitionPage(
        child: CustomerMainScreen(initialTab: 0),
      ),
    ),
    GoRoute(
      path: '/booking-history',
      pageBuilder: (context, state) => const NoTransitionPage(
        child: CustomerMainScreen(initialTab: 1),
      ),
    ),
    GoRoute(
      path: '/customer-requests',
      pageBuilder: (context, state) => const NoTransitionPage(
        child: CustomerMainScreen(initialTab: 2),
      ),
    ),

    // ── Provider Shell ───────────────────────────────────────────────────────
    GoRoute(
      path: '/provider-dashboard',
      pageBuilder: (context, state) => const NoTransitionPage(
        child: ProviderMainScreen(initialTab: 0),
      ),
    ),
    GoRoute(
      path: '/provider-bookings',
      pageBuilder: (context, state) => const NoTransitionPage(
        child: ProviderMainScreen(initialTab: 1),
      ),
    ),
    GoRoute(
      path: '/provider-requests',
      pageBuilder: (context, state) => const NoTransitionPage(
        child: ProviderMainScreen(initialTab: 2),
      ),
    ),

    // ── Shared tab routes (role-aware) ────────────────────────────────────────
    GoRoute(
      path: '/chat-list',
      pageBuilder: (context, state) => const NoTransitionPage(
        child: ShellChatListWrapper(),
      ),
    ),
    GoRoute(
      path: '/user-profile',
      pageBuilder: (context, state) => const NoTransitionPage(
        child: ShellUserProfileWrapper(),
      ),
    ),

    // ── Admin Shell ──────────────────────────────────────────────────────────
    GoRoute(
      path: '/admin-dashboard',
      pageBuilder: (context, state) => const NoTransitionPage(
        child: AdminDashboardScreen(),
      ),
    ),

    // ── Detail / Modal Routes (slide transition is OK here) ───────────────────
    GoRoute(
      path: '/provider-profile/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? 'p1';
        return ProviderProfileScreen(providerId: id);
      },
    ),
    GoRoute(
      path: '/voice-request',
      builder: (context, state) => const VoiceRequestScreen(),
    ),
    GoRoute(
      path: '/booking-checkout',
      builder: (context, state) {
        final providerId = state.uri.queryParameters['providerId'];
        return BookingCheckoutScreen(providerId: providerId);
      },
    ),
    GoRoute(
      path: '/chat',
      builder: (context, state) {
        final bookingId = state.uri.queryParameters['bookingId'];
        return ChatScreen(bookingId: bookingId);
      },
    ),
    GoRoute(
      path: '/booking-details/:bookingId',
      builder: (context, state) {
        final bookingId = state.pathParameters['bookingId'] ?? '';
        return BookingDetailsScreen(bookingId: bookingId);
      },
    ),
    GoRoute(
      path: '/active-service/:bookingId',
      builder: (context, state) {
        final bookingId = state.pathParameters['bookingId'] ?? '';
        return ActiveServiceScreen(bookingId: bookingId);
      },
    ),
    GoRoute(
      path: '/dispute',
      builder: (context, state) => const DisputeScreen(bookingId: 'b1'),
    ),
    GoRoute(
      path: '/dispute/:bookingId',
      builder: (context, state) {
        final bookingId = state.pathParameters['bookingId'] ?? '';
        return DisputeScreen(bookingId: bookingId);
      },
    ),
    GoRoute(
      path: '/review/:bookingId',
      builder: (context, state) {
        final bookingId = state.pathParameters['bookingId'] ?? '';
        return ReviewScreen(bookingId: bookingId);
      },
    ),
  ],
);

// ─────────────────────────────────────────────────────────────────────────────
// Role-aware wrappers for shared routes
// ─────────────────────────────────────────────────────────────────────────────

class ShellChatListWrapper extends ConsumerWidget {
  const ShellChatListWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(currentRoleProvider);
    if (role == 'provider') {
      return const ProviderMainScreen(initialTab: 3);
    }
    return const CustomerMainScreen(initialTab: 3);
  }
}

class ShellUserProfileWrapper extends ConsumerWidget {
  const ShellUserProfileWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(currentRoleProvider);
    if (role == 'provider') {
      return const ProviderMainScreen(initialTab: 4);
    }
    return const CustomerMainScreen(initialTab: 4);
  }
}
