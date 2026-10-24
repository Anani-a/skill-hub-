import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shuk_mobile/main.dart';
import 'package:shuk_mobile/core/router/app_router.dart';
import 'package:shuk_mobile/shared/providers/mock_state_providers.dart';

void main() {
  testWidgets('Test customer bottom nav clicks', (WidgetTester tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(currentRoleProvider.notifier).setRole('customer');

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const ShukApp(),
      ),
    );
    await tester.pumpAndSettle();

    appRouter.go('/home');
    await tester.pumpAndSettle();

    // Verify on home
    expect(find.byType(BottomNavigationBar), findsOneWidget);

    // Tap Bookings (item 1)
    await tester.tap(find.text('ትዕዛዞች').first);
    await tester.pumpAndSettle();

    // Tap Requests (item 2)
    await tester.tap(find.text('ጥያቄዎች').first);
    await tester.pumpAndSettle();

    // Tap Messages (item 3)
    await tester.tap(find.text('ውይይት').first);
    await tester.pumpAndSettle();

    // Tap Profile (item 4)
    await tester.tap(find.text('መገለጫ').first);
    await tester.pumpAndSettle();

    // Tap Home (item 0)
    await tester.tap(find.text('ቤት').first);
    await tester.pumpAndSettle();
  });

  testWidgets('Test provider bottom nav clicks', (WidgetTester tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(currentRoleProvider.notifier).setRole('provider');

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const ShukApp(),
      ),
    );
    await tester.pumpAndSettle();

    appRouter.go('/provider-dashboard');
    await tester.pumpAndSettle();

    // Verify on provider dashboard
    expect(find.byType(BottomNavigationBar), findsOneWidget);

    // Tap Bookings (item 1)
    await tester.tap(find.text('ትዕዛዞች').first);
    await tester.pumpAndSettle();

    // Tap Requests (item 2)
    await tester.tap(find.text('ጥያቄዎች').first);
    await tester.pumpAndSettle();

    // Tap Messages (item 3)
    await tester.tap(find.text('ውይይት').first);
    await tester.pumpAndSettle();

    // Tap Profile (item 4)
    await tester.tap(find.text('መገለጫ').first);
    await tester.pumpAndSettle();

    // Tap Dashboard (item 0)
    await tester.tap(find.text('ዳሽቦርድ').first);
    await tester.pumpAndSettle();
  });

  testWidgets('Test customer bottom nav clicks in English', (WidgetTester tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(currentRoleProvider.notifier).setRole('customer');
    container.read(languageProvider.notifier).setLanguage('en');

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const ShukApp(),
      ),
    );
    await tester.pumpAndSettle();

    appRouter.go('/home');
    await tester.pumpAndSettle();

    expect(find.byType(BottomNavigationBar), findsOneWidget);

    // Tap Bookings (item 1)
    await tester.tap(find.text('Bookings').first);
    await tester.pumpAndSettle();

    // Tap Requests (item 2)
    await tester.tap(find.text('Requests').first);
    await tester.pumpAndSettle();

    // Tap Messages (item 3)
    await tester.tap(find.text('Messages').first);
    await tester.pumpAndSettle();

    // Tap Profile (item 4)
    await tester.tap(find.text('Profile').first);
    await tester.pumpAndSettle();

    // Tap Home (item 0)
    await tester.tap(find.text('Home').first);
    await tester.pumpAndSettle();
  });

  testWidgets('Test provider bottom nav clicks in English', (WidgetTester tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(currentRoleProvider.notifier).setRole('provider');
    container.read(languageProvider.notifier).setLanguage('en');

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const ShukApp(),
      ),
    );
    await tester.pumpAndSettle();

    appRouter.go('/provider-dashboard');
    await tester.pumpAndSettle();

    expect(find.byType(BottomNavigationBar), findsOneWidget);

    // Tap Bookings (item 1)
    await tester.tap(find.text('Bookings').first);
    await tester.pumpAndSettle();

    // Tap Requests (item 2)
    await tester.tap(find.text('Requests').first);
    await tester.pumpAndSettle();

    // Tap Messages (item 3)
    await tester.tap(find.text('Messages').first);
    await tester.pumpAndSettle();

    // Tap Profile (item 4)
    await tester.tap(find.text('Profile').first);
    await tester.pumpAndSettle();

    // Tap Dashboard (item 0)
    await tester.tap(find.text('Dashboard').first);
    await tester.pumpAndSettle();
  });

  testWidgets('Test admin bottom nav clicks', (WidgetTester tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(currentRoleProvider.notifier).setRole('admin');

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const ShukApp(),
      ),
    );
    await tester.pumpAndSettle();

    appRouter.go('/admin-dashboard');
    await tester.pumpAndSettle();

    expect(find.byType(BottomNavigationBar), findsOneWidget);

    // Tap Users (item 1)
    await tester.tap(find.text('ተጠቃሚዎች').first);
    await tester.pumpAndSettle();

    // Tap Providers (item 2)
    await tester.tap(find.text('ባለሙያዎች').first);
    await tester.pumpAndSettle();

    // Tap Bookings (item 3)
    await tester.tap(find.text('ቦኪንጎች').first);
    await tester.pumpAndSettle();

    // Tap Disputes (item 4)
    await tester.tap(find.text('ክርክሮች').first);
    await tester.pumpAndSettle();

    // Tap Overview (item 0)
    await tester.tap(find.text('አጠቃላይ').first);
    await tester.pumpAndSettle();
  });
}
