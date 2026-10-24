import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/mock_state_providers.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import 'provider_dashboard_screen.dart';
import '../../booking/views/provider_booking_screen.dart';
import 'request_management_screen.dart';
import '../../chat/views/chat_list_screen.dart';
import '../../provider_profile/views/profile_screen.dart';

final providerTabProvider = StateProvider<int>((ref) => 0);

class ProviderMainScreen extends ConsumerStatefulWidget {
  final int initialTab;
  const ProviderMainScreen({super.key, this.initialTab = 0});

  @override
  ConsumerState<ProviderMainScreen> createState() => _ProviderMainScreenState();
}

class _ProviderMainScreenState extends ConsumerState<ProviderMainScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(providerTabProvider.notifier).state = widget.initialTab;
      }
    });
  }

  @override
  void didUpdateWidget(ProviderMainScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(providerTabProvider.notifier).state = widget.initialTab;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTab = ref.watch(providerTabProvider);
    final activeLang = ref.watch(languageProvider);
    final themeMode = ref.watch(themeModeProvider);
    AppTheme.isDark = (themeMode == ThemeMode.dark);
    final safeIndex = (currentTab >= 0 && currentTab <= 4) ? currentTab : 0;

    return Scaffold(
      backgroundColor: AppTheme.bgBase,
      body: IndexedStack(
        index: safeIndex,
        children: [
          ProviderDashboardScreen(isShell: true),
          ProviderBookingScreen(isShell: true),
          RequestManagementScreen(isShell: true),
          ChatListScreen(isShell: true),
          ProviderProfileScreen(providerId: 'current', isShell: true),
        ],
      ),
      bottomNavigationBar: ShukBottomNavBar(
        currentIndex: safeIndex,
        activeRole: 'provider',
        activeLang: activeLang,
        onTabSelected: (index) {
          ref.read(providerTabProvider.notifier).state = index;
        },
      ),
    );
  }
}
