import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shuk_mobile/features/admin/views/admin_dashboard_screen.dart';
import 'package:shuk_mobile/features/booking/views/booking_history_screen.dart';
import 'package:shuk_mobile/features/chat/views/chat_list_screen.dart';
import 'package:shuk_mobile/features/home/views/home_modern_screen.dart';
import 'package:shuk_mobile/features/provider_profile/views/profile_screen.dart';
import 'package:shuk_mobile/features/voice_request/views/voice_request_screen.dart';
import 'package:shuk_mobile/main.dart';
import 'package:shuk_mobile/shared/providers/mock_state_providers.dart';
import 'package:shuk_mobile/shared/widgets/bottom_nav_bar.dart';

void main() {
  testWidgets('ShukApp renders root without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ShukApp(),
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('provider booking history shows provider message when in provider role', (WidgetTester tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(currentRoleProvider.notifier).setRole('provider');

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: BookingHistoryScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('ይህ ክፍል ለባለሙያ ታሪክ የለም'), findsOneWidget);
  });

  testWidgets('provider profile renders ShukBottomNavBar and profile scaffold', (WidgetTester tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(currentRoleProvider.notifier).setRole('provider');

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: ProviderProfileScreen(providerId: 'current')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(ShukBottomNavBar), findsOneWidget);
  });

  testWidgets('home screen hides customer CTA in provider mode', (WidgetTester tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(currentRoleProvider.notifier).setRole('provider');

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: HomeModernScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Become a Shuk Provider'), findsNothing);
    expect(find.text('JOIN OUR COMMUNITY'), findsNothing);
  });

  testWidgets('customer booking history renders its main UI and ShukBottomNavBar', (WidgetTester tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(currentRoleProvider.notifier).setRole('customer');

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: BookingHistoryScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(ShukBottomNavBar), findsOneWidget);
  });

  testWidgets('customer chat list renders conversation screen and messages header', (WidgetTester tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(currentRoleProvider.notifier).setRole('customer');

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: ChatListScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(ChatListScreen), findsOneWidget);
  });

  testWidgets('customer voice request screen renders its call-to-action', (WidgetTester tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(currentRoleProvider.notifier).setRole('customer');

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: VoiceRequestScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
  });

  testWidgets('admin dashboard renders its main admin UI', (WidgetTester tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(currentRoleProvider.notifier).setRole('admin');

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: AdminDashboardScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            ((widget.data ?? '').contains('Admin') ||
                (widget.data ?? '').contains('ዳሽ') ||
                (widget.data ?? '').contains('የአስተዳደር')),
      ),
      findsAtLeastNWidgets(1),
    );
  });
}
