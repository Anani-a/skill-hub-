import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shuk_mobile/features/provider_dashboard/views/request_management_screen.dart';
import 'package:shuk_mobile/features/booking/views/provider_booking_screen.dart';
import 'package:shuk_mobile/features/booking/views/booking_details_screen.dart';
import 'package:shuk_mobile/shared/providers/mock_state_providers.dart' as shared_state;

void main() {
  testWidgets('RequestManagementScreen displays customer requests header', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          shared_state.languageProvider.overrideWith((ref) {
            final notifier = shared_state.LanguageNotifier();
            notifier.setLanguage('en');
            return notifier;
          }),
        ],
        child: const MaterialApp(
          home: RequestManagementScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Customer Requests'), findsOneWidget);
    expect(find.byType(RequestManagementScreen), findsOneWidget);

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('Provider bookings screen shows provider work center and filter tabs', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          shared_state.languageProvider.overrideWith((ref) {
            final notifier = shared_state.LanguageNotifier();
            notifier.setLanguage('en');
            return notifier;
          }),
          shared_state.currentRoleProvider.overrideWith((ref) {
            final notifier = shared_state.RoleNotifier();
            notifier.setRole('provider');
            return notifier;
          }),
        ],
        child: const MaterialApp(
          home: ProviderBookingScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Provider Work Center'), findsOneWidget);
    expect(find.byType(ProviderBookingScreen), findsOneWidget);

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('Provider bookings screen exposes a chat action for active work', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          shared_state.languageProvider.overrideWith((ref) {
            final notifier = shared_state.LanguageNotifier();
            notifier.setLanguage('en');
            return notifier;
          }),
          shared_state.currentRoleProvider.overrideWith((ref) {
            final notifier = shared_state.RoleNotifier();
            notifier.setRole('provider');
            return notifier;
          }),
        ],
        child: const MaterialApp(
          home: ProviderBookingScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Chat'), findsAtLeastNWidgets(1));

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('Booking details screen shows request overview and info', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          shared_state.languageProvider.overrideWith((ref) {
            final notifier = shared_state.LanguageNotifier();
            notifier.setLanguage('en');
            return notifier;
          }),
        ],
        child: const MaterialApp(
          home: BookingDetailsScreen(bookingId: 'b1251'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Request Details'), findsOneWidget);
    expect(find.text('Request Overview'), findsOneWidget);

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
