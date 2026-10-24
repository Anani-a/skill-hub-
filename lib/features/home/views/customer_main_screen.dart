import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/mock_state_providers.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import 'home_modern_screen.dart';
import '../../booking/views/booking_history_screen.dart';
import '../../booking/views/customer_requests_screen.dart';
import '../../chat/views/chat_list_screen.dart';
import '../../profile/views/customer_profile_screen.dart';

final customerTabProvider = StateProvider<int>((ref) => 0);

class CustomerMainScreen extends ConsumerStatefulWidget {
  final int initialTab;
  const CustomerMainScreen({super.key, this.initialTab = 0});

  @override
  ConsumerState<CustomerMainScreen> createState() => _CustomerMainScreenState();
}

class _CustomerMainScreenState extends ConsumerState<CustomerMainScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(customerTabProvider.notifier).state = widget.initialTab;
      }
    });
  }

  @override
  void didUpdateWidget(CustomerMainScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(customerTabProvider.notifier).state = widget.initialTab;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTab = ref.watch(customerTabProvider);
    final activeLang = ref.watch(languageProvider);
    final themeMode = ref.watch(themeModeProvider);
    AppTheme.isDark = (themeMode == ThemeMode.dark);
    final safeIndex = (currentTab >= 0 && currentTab <= 4) ? currentTab : 0;

    return Scaffold(
      backgroundColor: AppTheme.bgBase,
      body: IndexedStack(
        index: safeIndex,
        children: [
          HomeModernScreen(isShell: true),
          BookingHistoryScreen(isShell: true),
          CustomerRequestsScreen(isShell: true),
          ChatListScreen(isShell: true),
          CustomerProfileScreen(isShell: true),
        ],
      ),
      bottomNavigationBar: ShukBottomNavBar(
        currentIndex: safeIndex,
        activeRole: 'customer',
        activeLang: activeLang,
        onTabSelected: (index) {
          ref.read(customerTabProvider.notifier).state = index;
        },
      ),
    );
  }
}
