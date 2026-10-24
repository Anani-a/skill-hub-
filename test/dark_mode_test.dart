import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shuk_mobile/features/home/views/home_modern_screen.dart';
import 'package:shuk_mobile/features/profile/views/customer_profile_screen.dart';
import 'package:shuk_mobile/features/dispute/views/dispute_screen.dart';
import 'package:shuk_mobile/shared/providers/mock_state_providers.dart';
import 'package:shuk_mobile/core/theme/app_theme.dart';

void main() {
  testWidgets('HomeModernScreen renders properly in dark mode', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(languageProvider.notifier).setLanguage('en');
    container.read(currentRoleProvider.notifier).setRole('customer');
    container.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          home: const HomeModernScreen(isShell: true),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Shuk'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('CustomerProfileScreen renders properly in dark mode and toggle works', (tester) async {
    tester.view.physicalSize = const Size(400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(languageProvider.notifier).setLanguage('en');
    container.read(currentRoleProvider.notifier).setRole('customer');
    container.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          home: const CustomerProfileScreen(isShell: true),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('My Profile'), findsOneWidget);
    expect(find.text('Dark Mode'), findsOneWidget);

    final switchFinder = find.byType(Switch).first;
    await tester.ensureVisible(switchFinder);
    await tester.pumpAndSettle();

    await tester.tap(switchFinder);
    await tester.pumpAndSettle();

    expect(container.read(themeModeProvider), ThemeMode.light);
    expect(tester.takeException(), isNull);
  });

  testWidgets('DisputeScreen renders properly in dark mode', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(languageProvider.notifier).setLanguage('en');
    container.read(currentRoleProvider.notifier).setRole('customer');
    container.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          home: const DisputeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Dispute Resolution Center'), findsOneWidget);
    expect(find.text('Submit Dispute to Admin'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
