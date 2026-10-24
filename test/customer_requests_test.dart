import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shuk_mobile/features/booking/views/customer_requests_screen.dart';
import 'package:shuk_mobile/shared/providers/mock_state_providers.dart';

void main() {
  testWidgets('Customer requests screen has no overflow on narrow screens (English)', (tester) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(languageProvider.notifier).setLanguage('en');
    container.read(currentRoleProvider.notifier).setRole('customer');

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: CustomerRequestsScreen(isShell: true),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Request Book'), findsOneWidget);
    expect(find.text('All Requests'), findsOneWidget);
    expect(find.text('Voice Requests'), findsOneWidget);
    expect(find.text('Direct Bookings'), findsOneWidget);

    // Scroll to Direct Bookings and tap it
    await tester.ensureVisible(find.text('Direct Bookings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Direct Bookings'));
    await tester.pumpAndSettle();

    // Scroll back to All Requests and tap it
    await tester.ensureVisible(find.text('All Requests'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('All Requests'));
    await tester.pumpAndSettle();

    // Check no overflow errors were thrown
    expect(tester.takeException(), isNull);
  });

  testWidgets('Customer requests screen has no overflow on 320px width', (tester) async {
    tester.view.physicalSize = const Size(320, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(languageProvider.notifier).setLanguage('en');
    container.read(currentRoleProvider.notifier).setRole('customer');

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: CustomerRequestsScreen(isShell: true),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Request Book'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Customer requests screen has no overflow on narrow screens (Amharic)', (tester) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(languageProvider.notifier).setLanguage('am');
    container.read(currentRoleProvider.notifier).setRole('customer');

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: CustomerRequestsScreen(isShell: true),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('የጥያቄ ደብተር'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
