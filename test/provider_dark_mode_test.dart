import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shuk_mobile/features/provider_dashboard/views/provider_main_screen.dart';
import 'package:shuk_mobile/features/provider_dashboard/views/provider_dashboard_screen.dart';
import 'package:shuk_mobile/features/booking/views/provider_booking_screen.dart';
import 'package:shuk_mobile/features/provider_dashboard/views/request_management_screen.dart';
import 'package:shuk_mobile/features/provider_profile/views/profile_screen.dart';
import 'package:shuk_mobile/shared/providers/mock_state_providers.dart';
import 'package:shuk_mobile/core/theme/app_theme.dart';

void main() {
  test('themeModeProvider synchronizes AppTheme.isDark state automatically', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Initial state is light
    expect(container.read(themeModeProvider), ThemeMode.light);
    expect(AppTheme.isDark, isFalse);

    // Set to dark mode
    container.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
    expect(container.read(themeModeProvider), ThemeMode.dark);
    expect(AppTheme.isDark, isTrue);

    // Toggle theme back to light
    container.read(themeModeProvider.notifier).toggleTheme();
    expect(container.read(themeModeProvider), ThemeMode.light);
    expect(AppTheme.isDark, isFalse);

    // Toggle theme to dark again
    container.read(themeModeProvider.notifier).toggleTheme();
    expect(container.read(themeModeProvider), ThemeMode.dark);
    expect(AppTheme.isDark, isTrue);
  });

  testWidgets('ProviderMainScreen responds immediately to theme mode changes', (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(languageProvider.notifier).setLanguage('en');
    container.read(currentRoleProvider.notifier).setRole('provider');
    container.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: Consumer(
          builder: (context, ref, _) {
            final mode = ref.watch(themeModeProvider);
            return MaterialApp(
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: mode,
              home: const ProviderMainScreen(initialTab: 0),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Shuk'), findsOneWidget);
    expect(AppTheme.isDark, isFalse);

    // Toggle to Dark Mode
    container.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
    await tester.pumpAndSettle();

    expect(AppTheme.isDark, isTrue);
    expect(find.text('Shuk'), findsOneWidget);
    final exc = tester.takeException();
    if (exc != null) {
      if (exc is FlutterError) {
        // ignore: avoid_print
        print('EXCEPTION DETAILS FULL:\n${exc.diagnostics.map((d) => d.toStringDeep()).join("\n")}');
      } else {
        // ignore: avoid_print
        print('EXCEPTION DETAILS: $exc');
      }
    }
    expect(exc, isNull);
  });

  testWidgets('ProviderDashboardScreen renders properly in dark mode', (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(languageProvider.notifier).setLanguage('en');
    container.read(currentRoleProvider.notifier).setRole('provider');
    container.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          home: const ProviderDashboardScreen(isShell: true),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Shuk'), findsOneWidget);
    expect(find.text('Recent Bookings'), findsOneWidget);
    final exc = tester.takeException();
    if (exc != null) {
      if (exc is FlutterError) {
        // ignore: avoid_print
        print('EXCEPTION DETAILS FULL:\n${exc.diagnostics.map((d) => d.toStringDeep()).join("\n")}');
      } else {
        // ignore: avoid_print
        print('EXCEPTION DETAILS: $exc');
      }
    }
    expect(exc, isNull);
  });

  testWidgets('ProviderBookingScreen renders properly in dark mode with tabs', (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(languageProvider.notifier).setLanguage('en');
    container.read(currentRoleProvider.notifier).setRole('provider');
    container.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          home: const ProviderBookingScreen(isShell: true),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Provider Work Center'), findsOneWidget);
    final exc = tester.takeException();
    if (exc != null) {
      if (exc is FlutterError) {
        // ignore: avoid_print
        print('EXCEPTION DETAILS FULL:\n${exc.diagnostics.map((d) => d.toStringDeep()).join("\n")}');
      } else {
        // ignore: avoid_print
        print('EXCEPTION DETAILS: $exc');
      }
    }
    expect(exc, isNull);
  });

  testWidgets('RequestManagementScreen renders properly in dark mode', (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(languageProvider.notifier).setLanguage('en');
    container.read(currentRoleProvider.notifier).setRole('provider');
    container.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          home: const RequestManagementScreen(isShell: true),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Customer Requests'), findsOneWidget);
    final exc = tester.takeException();
    if (exc != null) {
      if (exc is FlutterError) {
        // ignore: avoid_print
        print('EXCEPTION DETAILS FULL:\n${exc.diagnostics.map((d) => d.toStringDeep()).join("\n")}');
      } else {
        // ignore: avoid_print
        print('EXCEPTION DETAILS: $exc');
      }
    }
    expect(exc, isNull);
  });

  testWidgets('ProviderProfileScreen renders in dark mode and toggle changes themeModeProvider', (tester) async {
    tester.view.physicalSize = const Size(400, 1100);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(languageProvider.notifier).setLanguage('en');
    container.read(currentRoleProvider.notifier).setRole('provider');
    container.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          home: const ProviderProfileScreen(providerId: 'current', isShell: true),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('My Provider Profile'), findsOneWidget);
    expect(find.text('Dark Mode'), findsOneWidget);

    final switchFinder = find.byType(Switch).first;
    await tester.ensureVisible(switchFinder);
    await tester.pumpAndSettle();

    // Tap switch to turn off dark mode
    await tester.tap(switchFinder);
    await tester.pumpAndSettle();

    expect(container.read(themeModeProvider), ThemeMode.light);
    expect(AppTheme.isDark, isFalse);
    final exc = tester.takeException();
    if (exc != null) {
      if (exc is FlutterError) {
        // ignore: avoid_print
        print('EXCEPTION DETAILS FULL:\n${exc.diagnostics.map((d) => d.toStringDeep()).join("\n")}');
      } else {
        // ignore: avoid_print
        print('EXCEPTION DETAILS: $exc');
      }
    }
    expect(exc, isNull);
  });
}
