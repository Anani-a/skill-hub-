import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/mock_state_providers.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../auth/providers/auth_provider.dart';
import '../../dispute/providers/dispute_provider.dart';
import '../../home/models/provider_model.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // 0: Overview, 1: Users, 2: Providers, 3: Bookings, 4: Disputes,
  // 5: Admin Profile, 6: Reviews & Ratings, 7: Analytics, 8: Services & Categories, 9: Notifications, 10: System Settings
  int _currentTab = 0;

  // Search queries
  String _userSearchQuery = '';
  String _bookingSearchQuery = '';
  String _disputeSearchQuery = '';
  String _reviewSearchQuery = '';
  String _categorySearchQuery = '';

  // Tab sub-filters
  int _userSubTab = 0; // 0: All, 1: Customers, 2: Providers
  int _bookingSubTab = 0; // 0: All, 1: Pending, 2: Ongoing, 3: Completed
  int _disputeSubTab = 0; // 0: All, 1: Open, 2: Resolved
  int _reviewStarFilter = 0; // 0: All, 5, 4, 3, 2, 1
  String _providerFilter = 'All';
  String _notifFilter = 'All'; // All, Unread, Bookings, KYC, Disputes

  // Advanced Filters
  String _userStatusFilter = 'All';
  String _analyticsPeriod = 'This Week';
  int _selectedChartDay = 6; // Sunday by default

  // Notification read states
  int _unreadNotifCount = 3;
  final Set<int> _readNotifs = {};

  // Admin Profile state
  String _adminName = 'Admin User';
  String _adminEmail = 'admin@shuk.com';
  String _adminPhone = '+251 912 345 678';
  final String _adminRole = 'Super Administrator';
  String _adminDepartment = 'Management';
  final String _adminJoined = 'Jan 10, 2026';
  bool _twoFactorEnabled = true;

  // System Settings state
  double _commissionRate = 15.0;
  String _escrowReleaseWindow = '48 hours';
  double _minPayoutThreshold = 500.0;
  bool _maintenanceMode = false;
  bool _autoVerifyKyc = true;
  bool _strict2Fa = true;
  bool _pushNotifsEnabled = true;

  // Local state for interactive status overrides
  final Map<String, String> _userStatusOverrides = {};
  final Map<String, String> _bookingStatusOverrides = {};
  final Map<String, String> _disputeStatusOverrides = {};
  final List<_AdminUserModel> _dynamicNewUsers = [];

  // Dynamic Reviews List
  final List<_AdminReviewModel> _reviews = [
    _AdminReviewModel(
      id: 'rev_1',
      name: 'Dawit Alemu',
      date: 'Aug 06, 2026',
      stars: 5,
      comment: 'Great service and very professional.',
      service: 'Home Cleaning',
      provider: 'Sara Tadesse',
      avatarBg: const Color(0xFFBFDBFE),
      isFeatured: true,
      adminReply: 'Thank you for choosing Shuk services! We are glad you had a great experience.',
    ),
    _AdminReviewModel(
      id: 'rev_2',
      name: 'Marta Hailu',
      date: 'Aug 06, 2026',
      stars: 4,
      comment: 'Good work, arrived on time.',
      service: 'Plumbing',
      provider: 'Mekonnen Desta',
      avatarBg: const Color(0xFFFDE68A),
    ),
    _AdminReviewModel(
      id: 'rev_3',
      name: 'Abel Biru',
      date: 'Aug 05, 2026',
      stars: 5,
      comment: 'Excellent service provider!',
      service: 'Electrical Repair',
      provider: 'Daniel Getachew',
      avatarBg: const Color(0xFFE2E8F0),
    ),
    _AdminReviewModel(
      id: 'rev_4',
      name: 'Sara Tadesse',
      date: 'Aug 05, 2026',
      stars: 4,
      comment: 'Very friendly and skilled.',
      service: 'Painting',
      provider: 'Bekele Tadesse',
      avatarBg: const Color(0xFFDDD6FE),
    ),
    _AdminReviewModel(
      id: 'rev_5',
      name: 'Kebede Ayalew',
      date: 'Aug 04, 2026',
      stars: 5,
      comment: 'Fast response and fixed the leak perfectly.',
      service: 'Plumbing',
      provider: 'Mekonnen Desta',
      avatarBg: const Color(0xFFFECDD3),
    ),
    _AdminReviewModel(
      id: 'rev_6',
      name: 'Worku Tesfaye',
      date: 'Aug 03, 2026',
      stars: 4,
      comment: 'Fair pricing and transparent communication.',
      service: 'Carpentry',
      provider: 'Yonas Bekele',
      avatarBg: const Color(0xFFD1FAE5),
    ),
  ];

  // Dynamic Categories list
  final List<_CategoryItemModel> _categories = [
    _CategoryItemModel(id: 'cat_1', title: 'Home Cleaning', count: 1050, icon: Icons.home_outlined, color: const Color(0xFF512DA8), status: 'Active'),
    _CategoryItemModel(id: 'cat_2', title: 'Plumbing', count: 1120, icon: Icons.plumbing_outlined, color: const Color(0xFF2563EB), status: 'Active'),
    _CategoryItemModel(id: 'cat_3', title: 'Electrical Repair', count: 980, icon: Icons.electrical_services_outlined, color: const Color(0xFF7C3AED), status: 'Active'),
    _CategoryItemModel(id: 'cat_4', title: 'Painting', count: 470, icon: Icons.format_paint_outlined, color: const Color(0xFFD97706), status: 'Active'),
    _CategoryItemModel(id: 'cat_5', title: 'Carpentry', count: 450, icon: Icons.construction_outlined, color: const Color(0xFF059669), status: 'Active'),
    _CategoryItemModel(id: 'cat_6', title: 'Appliance Repair', count: 320, icon: Icons.kitchen_outlined, color: const Color(0xFFDC2626), status: 'Active'),
    _CategoryItemModel(id: 'cat_7', title: 'Computer Repair', count: 210, icon: Icons.devices_outlined, color: const Color(0xFF4F46E5), status: 'Active'),
  ];



  @override
  Widget build(BuildContext context) {
    final activeLang = ref.watch(languageProvider);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.bgBase,
      drawer: _buildAdminSidebar(activeLang),
      appBar: _buildAppBar(activeLang),
      body: IndexedStack(
        index: _currentTab,
        children: [
          _buildOverviewTab(activeLang),             // 0
          _buildUsersTab(activeLang),                // 1
          _buildProvidersTab(activeLang),            // 2
          _buildBookingsTab(activeLang),             // 3
          _buildDisputesTab(activeLang),             // 4
          _buildAdminProfileTab(activeLang),         // 5 (Image 1)
          _buildReviewsAndRatingsTab(activeLang),    // 6 (Image 2)
          _buildAnalyticsTab(activeLang),            // 7 (Image 3)
          _buildServicesAndCategoriesTab(activeLang),// 8 (Image 4)
          _buildNotificationsTab(activeLang),        // 9 (Image 5)
          _buildSystemSettingsTab(activeLang),       // 10
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(activeLang),
      bottomNavigationBar: _buildBottomNav(activeLang),
    );
  }

  Widget? _buildFloatingActionButton(String activeLang) {
    if (_currentTab == 6) {
      return FloatingActionButton.extended(
        onPressed: () => _showAddReviewDialog(context, activeLang),
        backgroundColor: const Color(0xFFF59E0B),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.rate_review_rounded, size: 20),
        label: const Text('Add Review', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        elevation: 4,
      );
    } else if (_currentTab == 9) {
      return FloatingActionButton.extended(
        onPressed: () => _showBroadcastAlertModal(context, activeLang),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.campaign_rounded, size: 20),
        label: const Text('Broadcast Alert', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        elevation: 4,
      );
    }
    return null;
  }

  // ═══════════════════════════════════════════════════════════════
  //  BOTTOM NAVIGATION BAR
  // ═══════════════════════════════════════════════════════════════
  Widget _buildBottomNav(String activeLang) {
    return ShukBottomNavBar(
      currentIndex: _currentTab <= 4 ? _currentTab : 0,
      activeRole: 'admin',
      activeLang: activeLang,
      onTabSelected: (index) {
        setState(() => _currentTab = index);
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  ADMIN SIDEBAR DRAWER
  // ═══════════════════════════════════════════════════════════════
  Widget _buildAdminSidebar(String activeLang) {
    return Drawer(
      backgroundColor: AppTheme.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Top Admin Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF311B92), Color(0xFF512DA8), Color(0xFF7E57C2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: Text(
                      _adminName.isNotEmpty ? _adminName[0].toUpperCase() : 'A',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _adminName,
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _adminRole,
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Navigation Links
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 10),
                children: [
                  _drawerNavItem(icon: Icons.dashboard_rounded, label: activeLang == 'am' ? 'አጠቃላይ ዳሽቦርድ' : 'Dashboard Overview', tabIndex: 0),
                  _drawerNavItem(icon: Icons.person_outline_rounded, label: activeLang == 'am' ? 'የአስተዳዳሪ መገለጫ' : 'Admin Profile', tabIndex: 5),
                  _drawerNavItem(icon: Icons.star_outline_rounded, label: activeLang == 'am' ? 'ግምገማዎች እና ደረጃዎች' : 'Reviews & Ratings', tabIndex: 6),
                  _drawerNavItem(icon: Icons.analytics_outlined, label: activeLang == 'am' ? 'አናሊቲክስ እና ስታቲስቲክስ' : 'Analytics', tabIndex: 7),
                  _drawerNavItem(icon: Icons.category_outlined, label: activeLang == 'am' ? 'አገልግሎቶች እና ምድቦች' : 'Services & Categories', tabIndex: 8),
                  _drawerNavItem(
                    icon: Icons.notifications_none_rounded,
                    label: activeLang == 'am' ? 'ማሳወቂያዎች' : 'Notifications',
                    tabIndex: 9,
                    badgeCount: _unreadNotifCount > 0 ? _unreadNotifCount : null,
                  ),
                  _drawerNavItem(icon: Icons.settings_outlined, label: activeLang == 'am' ? 'የስርዓት ቅንብሮች' : 'System Settings', tabIndex: 10),
                ],
              ),
            ),

            // Logout Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.logout_rounded, color: AppTheme.error, size: 18),
                  label: Text(
                    activeLang == 'am' ? 'ውጣ' : 'Logout',
                    style: const TextStyle(color: AppTheme.error, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.error),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    _showLogoutConfirmDialog(context, activeLang);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerNavItem({
    required IconData icon,
    required String label,
    required int tabIndex,
    int? badgeCount,
  }) {
    final isSelected = _currentTab == tabIndex;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primary.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? AppTheme.primary : AppTheme.textSecondary, size: 22),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
          ),
        ),
        trailing: badgeCount != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.error,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              )
            : (isSelected ? Icon(Icons.chevron_right_rounded, color: AppTheme.primary, size: 18) : null),
        onTap: () {
          Navigator.pop(context);
          setState(() => _currentTab = tabIndex);
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  APP BAR
  // ═══════════════════════════════════════════════════════════════
  PreferredSizeWidget _buildAppBar(String activeLang) {
    String titleText;
    switch (_currentTab) {
      case 1:
        titleText = activeLang == 'am' ? 'ተጠቃሚዎች' : 'Users';
        break;
      case 2:
        titleText = activeLang == 'am' ? 'ባለሙያዎች ማረጋገጫ' : 'Provider Verification';
        break;
      case 3:
        titleText = activeLang == 'am' ? 'ቦኪንጎች' : 'Bookings';
        break;
      case 4:
        titleText = activeLang == 'am' ? 'ክርክሮች' : 'Disputes';
        break;
      case 5:
        titleText = activeLang == 'am' ? 'የአስተዳዳሪ መገለጫ' : 'Admin Profile';
        break;
      case 6:
        titleText = activeLang == 'am' ? 'ግምገማዎች እና ደረጃዎች' : 'Reviews & Ratings';
        break;
      case 7:
        titleText = activeLang == 'am' ? 'አናሊቲክስ' : 'Analytics';
        break;
      case 8:
        titleText = activeLang == 'am' ? 'አገልግሎቶች እና ምድቦች' : 'Services & Categories';
        break;
      case 9:
        titleText = activeLang == 'am' ? 'ማሳወቂያዎች' : 'Notifications';
        break;
      case 10:
        titleText = activeLang == 'am' ? 'የስርዓት ቅንብሮች' : 'System Settings';
        break;
      default:
        titleText = activeLang == 'am' ? 'የአስተዳደር ዳሽቦርድ' : 'Admin Dashboard';
    }

    return AppBar(
      backgroundColor: AppTheme.bgSurface,
      elevation: 0.5,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(
          _currentTab == 0 ? Icons.menu_rounded : Icons.arrow_back_rounded,
          color: AppTheme.textPrimary,
          size: 24,
        ),
        onPressed: () {
          if (_currentTab == 0) {
            _scaffoldKey.currentState?.openDrawer();
          } else {
            setState(() => _currentTab = 0);
          }
        },
      ),
      title: Text(
        titleText,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 18,
          color: AppTheme.textPrimary,
          letterSpacing: -0.3,
        ),
      ),
      actions: [
        if (_currentTab == 1)
          IconButton(
            icon: Icon(Icons.filter_alt_outlined, color: AppTheme.primary, size: 22),
            onPressed: () => _showUserFilterBottomSheet(context, activeLang),
          )
        else if (_currentTab == 3)
          IconButton(
            icon: Icon(Icons.tune_rounded, color: AppTheme.primary, size: 22),
            onPressed: () => _showBookingFilterBottomSheet(context, activeLang),
          )
        else if (_currentTab == 4)
          IconButton(
            icon: Icon(Icons.filter_alt_outlined, color: AppTheme.primary, size: 22),
            onPressed: () => _showDisputeFilterBottomSheet(context, activeLang),
          )
        else if (_currentTab == 9)
          TextButton(
            onPressed: () {
              setState(() {
                _unreadNotifCount = 0;
                _readNotifs.addAll([0, 1, 2, 3, 4, 5]);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All notifications marked as read ✓'), behavior: SnackBarBehavior.floating),
              );
            },
            child: Text(
              activeLang == 'am' ? 'ሁሉንም አንብብ' : 'Mark all as read',
              style: TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        if (_currentTab != 9)
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                setState(() => _currentTab = 9);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none_rounded,
                      color: AppTheme.textPrimary,
                      size: 24,
                    ),
                    if (_unreadNotifCount > 0)
                      Positioned(
                        top: -2,
                        right: -2,
                        child: IgnorePointer(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppTheme.bgSurface, width: 1.5),
                            ),
                            child: Text(
                              '$_unreadNotifCount',
                              style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  TAB 5: ADMIN PROFILE (IMAGE 1)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildAdminProfileTab(String activeLang) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // Profile Card Container
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.bgSurface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Purple Top Hero with Avatar & Edit Badge
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 24, bottom: 20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF512DA8), Color(0xFF673AB7), Color(0xFF7E57C2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 86,
                          height: 86,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            color: const Color(0xFFBFDBFE),
                          ),
                          child: Center(
                            child: Text(
                              _adminName.isNotEmpty ? _adminName[0].toUpperCase() : 'A',
                              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Color(0xFF1E1B4B)),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => _showEditAdminProfileDialog(context, activeLang),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                              ),
                              child: Icon(Icons.edit_rounded, size: 14, color: AppTheme.primary),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Name & Role Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Column(
                    children: [
                      Text(
                        _adminName,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _adminRole,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 20, indent: 20, endIndent: 20),

                // Information Rows (Matching Image 1)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                  child: Column(
                    children: [
                      _profileInfoRow(Icons.email_outlined, 'Email', _adminEmail),
                      const SizedBox(height: 16),
                      _profileInfoRow(Icons.phone_outlined, 'Phone', _adminPhone),
                      const SizedBox(height: 16),
                      _profileInfoRow(Icons.people_outline_rounded, 'Role', _adminRole),
                      const SizedBox(height: 16),
                      _profileInfoRow(Icons.calendar_today_outlined, 'Department', _adminDepartment),
                      const SizedBox(height: 16),
                      _profileInfoRow(Icons.access_time_rounded, 'Joined', _adminJoined),
                      const SizedBox(height: 16),
                      _profileInfoRow(
                        Icons.security_rounded,
                        'Security 2FA',
                        _twoFactorEnabled ? 'Active (SMS/OTP)' : 'Disabled',
                      ),
                    ],
                  ),
                ),

                // Secondary Action Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: Icon(Icons.lock_reset_rounded, size: 16, color: AppTheme.primary),
                          label: const Text('Security', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppTheme.primary),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => _showChangePasswordModal(context, activeLang),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: Icon(Icons.history_rounded, size: 16, color: AppTheme.textSecondary),
                          label: const Text('Activity Logs', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppTheme.border),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => _showAuditLogModal(context, activeLang),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Red Outlined Logout Button (Matching Image 1)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 18),
                      label: Text(
                        activeLang == 'am' ? 'ውጣ' : 'Logout',
                        style: const TextStyle(
                          color: Color(0xFFEF4444),
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFCA5A5), width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () => _showLogoutConfirmDialog(context, activeLang),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.textCaption),
        const SizedBox(width: 14),
        SizedBox(
          width: 95,
          child: Text(
            label,
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _showLogoutConfirmDialog(BuildContext context, String activeLang) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(activeLang == 'am' ? 'መውጣት ይፈልጋሉ?' : 'Log out of Admin?'),
        content: Text(
          activeLang == 'am'
              ? 'የአስተዳዳሪ ክፍለ-ጊዜዎ ይዘጋል እና ወደ መግቢያ ገጽ ይመለሳሉ።'
              : 'You will be logged out of your admin session and redirected to the login page.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(activeLang == 'am' ? 'ይቅር' : 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              if (context.mounted && Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
              ref.read(currentRoleProvider.notifier).setRole('customer');
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
            child: Text(activeLang == 'am' ? 'ውጣ' : 'Logout'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordModal(BuildContext context, String activeLang) {
    final oldPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      backgroundColor: AppTheme.bgSurface,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20, left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Change Admin Password', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            const SizedBox(height: 16),
            TextField(controller: oldPassCtrl, obscureText: true, decoration: InputDecoration(labelText: 'Current Password', filled: true, fillColor: AppTheme.inputBg, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 10),
            TextField(controller: newPassCtrl, obscureText: true, decoration: InputDecoration(labelText: 'New Password', filled: true, fillColor: AppTheme.inputBg, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 10),
            TextField(controller: confirmPassCtrl, obscureText: true, decoration: InputDecoration(labelText: 'Confirm New Password', filled: true, fillColor: AppTheme.inputBg, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password changed securely ✓'), behavior: SnackBarBehavior.floating));
                },
                child: const Text('Update Password'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAuditLogModal(BuildContext context, String activeLang) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      backgroundColor: AppTheme.bgSurface,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Admin Activity Audit Log', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            const SizedBox(height: 14),
            _auditItem('Login from Chrome on Windows', '192.168.1.13 • 10 mins ago', Icons.devices_rounded),
            _auditItem('Resolved Dispute #DP-25-006', 'Refunded 350 ETB to Abel Biru • 2 hours ago', Icons.gavel_rounded),
            _auditItem('Approved Provider KYC: Dawit Bekele', 'Verified National ID • 4 hours ago', Icons.verified_user_rounded),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, child: OutlinedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))),
          ],
        ),
      ),
    );
  }

  Widget _auditItem(String title, String subtitle, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                Text(subtitle, style: TextStyle(fontSize: 11, color: AppTheme.textCaption)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditAdminProfileDialog(BuildContext context, String activeLang) {
    final nameCtrl = TextEditingController(text: _adminName);
    final emailCtrl = TextEditingController(text: _adminEmail);
    final phoneCtrl = TextEditingController(text: _adminPhone);
    final deptCtrl = TextEditingController(text: _adminDepartment);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      backgroundColor: AppTheme.bgSurface,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Edit Admin Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
            const SizedBox(height: 16),
            TextField(controller: nameCtrl, decoration: InputDecoration(labelText: 'Full Name', filled: true, fillColor: AppTheme.inputBg, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 10),
            TextField(controller: emailCtrl, decoration: InputDecoration(labelText: 'Email Address', filled: true, fillColor: AppTheme.inputBg, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 10),
            TextField(controller: phoneCtrl, decoration: InputDecoration(labelText: 'Phone Number', filled: true, fillColor: AppTheme.inputBg, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 10),
            TextField(controller: deptCtrl, decoration: InputDecoration(labelText: 'Department', filled: true, fillColor: AppTheme.inputBg, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () {
                  setState(() {
                    _adminName = nameCtrl.text.trim();
                    _adminEmail = emailCtrl.text.trim();
                    _adminPhone = phoneCtrl.text.trim();
                    _adminDepartment = deptCtrl.text.trim();
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully ✓'), behavior: SnackBarBehavior.floating));
                },
                child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  TAB 6: REVIEWS & RATINGS (IMAGE 2)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildReviewsAndRatingsTab(String activeLang) {
    final filteredReviews = _reviews.where((r) {
      if (_reviewStarFilter > 0 && r.stars != _reviewStarFilter) return false;
      if (_reviewSearchQuery.isNotEmpty) {
        final q = _reviewSearchQuery.toLowerCase();
        return r.name.toLowerCase().contains(q) || r.comment.toLowerCase().contains(q) || r.service.toLowerCase().contains(q) || r.provider.toLowerCase().contains(q);
      }
      return true;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Overall Rating Summary Card (Image 2) ───────────────────
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.bgSurface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Left Column: Big score + Stars
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activeLang == 'am' ? 'አጠቃላይ ደረጃ' : 'Overall Rating',
                        style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      RichText(
                        text: TextSpan(
                          text: '4.8 ',
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppTheme.textPrimary),
                          children: [
                            TextSpan(
                              text: '/ 5',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textCaption),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < 4 ? Icons.star_rounded : Icons.star_half_rounded,
                            size: 18,
                            color: const Color(0xFFF59E0B),
                          );
                        }),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '(${_reviews.length + 2242} Reviews)',
                        style: TextStyle(fontSize: 11, color: AppTheme.textCaption),
                      ),
                    ],
                  ),
                ),
                Container(height: 100, width: 1, color: AppTheme.divider),
                const SizedBox(width: 14),

                // Right Column: Progress Distribution Bars
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      _ratingBarRow('5 Stars', 0.76, '76%'),
                      const SizedBox(height: 4),
                      _ratingBarRow('4 Stars', 0.16, '16%'),
                      const SizedBox(height: 4),
                      _ratingBarRow('3 Stars', 0.04, '4%'),
                      const SizedBox(height: 4),
                      _ratingBarRow('2 Stars', 0.02, '2%'),
                      const SizedBox(height: 4),
                      _ratingBarRow('1 Star', 0.02, '2%'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Search Bar & Star Filter Row
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.inputBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.inputBorderColor),
                  ),
                  child: TextField(
                    onChanged: (v) => setState(() => _reviewSearchQuery = v),
                    style: TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Search reviews & comments...',
                      hintStyle: TextStyle(color: AppTheme.textHint, fontSize: 13),
                      prefixIcon: Icon(Icons.search_rounded, color: AppTheme.textCaption, size: 18),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<int>(
                icon: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppTheme.bgSurface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.border)),
                  child: Icon(Icons.filter_list_rounded, color: AppTheme.primary, size: 20),
                ),
                onSelected: (val) => setState(() => _reviewStarFilter = val),
                itemBuilder: (ctx) => [
                  const PopupMenuItem(value: 0, child: Text('All Star Ratings')),
                  const PopupMenuItem(value: 5, child: Text('⭐⭐⭐⭐⭐ 5 Stars')),
                  const PopupMenuItem(value: 4, child: Text('⭐⭐⭐⭐ 4 Stars')),
                  const PopupMenuItem(value: 3, child: Text('⭐⭐⭐ 3 Stars')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Section Title: Recent Reviews ───────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                activeLang == 'am' ? 'የቅርብ ጊዜ ግምገማዎች' : 'Recent Reviews',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
              ),
              GestureDetector(
                onTap: () => setState(() {
                  _reviewStarFilter = 0;
                  _reviewSearchQuery = '';
                }),
                child: Text(
                  activeLang == 'am' ? 'ሁሉንም እይ' : 'View All',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Reviews List Card Container (Image 2) ───────────────────
          Container(
            decoration: BoxDecoration(
              color: AppTheme.bgSurface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.border),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: filteredReviews.length,
              separatorBuilder: (_, __) => const Divider(height: 16, indent: 64, endIndent: 16),
              itemBuilder: (context, index) {
                final rev = filteredReviews[index];
                return _reviewItemWidget(rev, activeLang);
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _ratingBarRow(String starLabel, double percentage, String percentText) {
    return Row(
      children: [
        SizedBox(
          width: 44,
          child: Text(starLabel, style: TextStyle(fontSize: 10, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 6,
              backgroundColor: const Color(0xFFEDE9FE),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF512DA8)),
            ),
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 26,
          child: Text(percentText, style: TextStyle(fontSize: 10, color: AppTheme.textCaption, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _reviewItemWidget(_AdminReviewModel rev, String activeLang) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: rev.avatarBg,
            child: Text(rev.name[0], style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(rev.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                        if (rev.isFeatured) ...[
                          const SizedBox(width: 6),
                          Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1), decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(6)), child: const Text('Featured', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFFD97706)))),
                        ],
                      ],
                    ),
                    Text(rev.date, style: TextStyle(fontSize: 11, color: AppTheme.textCaption)),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < rev.stars ? Icons.star_rounded : Icons.star_border_rounded,
                      size: 14,
                      color: const Color(0xFFF59E0B),
                    );
                  }),
                ),
                const SizedBox(height: 4),
                Text(rev.comment, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                if (rev.adminReply != null) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppTheme.primaryContainer, borderRadius: BorderRadius.circular(8)),
                    child: Text('Admin: ${rev.adminReply}', style: TextStyle(fontSize: 11, color: AppTheme.primary, fontWeight: FontWeight.w600)),
                  ),
                ],
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, color: AppTheme.textCaption, size: 18),
            onSelected: (val) {
              if (val == 'reply') {
                _showReplyDialog(rev);
              } else if (val == 'feature') {
                setState(() => rev.isFeatured = !rev.isFeatured);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Review updated ✓'), behavior: SnackBarBehavior.floating));
              } else if (val == 'delete') {
                setState(() => _reviews.removeWhere((r) => r.id == rev.id));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Review deleted ✓'), behavior: SnackBarBehavior.floating));
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(value: 'reply', child: const Text('Reply as Admin')),
              PopupMenuItem(value: 'feature', child: Text(rev.isFeatured ? 'Unpin Review' : 'Feature Review')),
              const PopupMenuItem(value: 'delete', child: Text('Delete Review', style: TextStyle(color: Colors.red))),
            ],
          ),
        ],
      ),
    );
  }

  void _showReplyDialog(_AdminReviewModel rev) {
    final replyCtrl = TextEditingController(text: rev.adminReply ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Reply to ${rev.name}'),
        content: TextField(
          controller: replyCtrl,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'Type official administrative reply...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() => rev.adminReply = replyCtrl.text.trim());
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reply published ✓'), behavior: SnackBarBehavior.floating));
            },
            child: const Text('Publish Reply'),
          ),
        ],
      ),
    );
  }

  void _showAddReviewDialog(BuildContext context, String activeLang) {
    final nameCtrl = TextEditingController();
    final commentCtrl = TextEditingController();
    int stars = 5;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      backgroundColor: AppTheme.bgSurface,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20, left: 24, right: 24, top: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add Customer Review', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              const SizedBox(height: 16),
              TextField(controller: nameCtrl, decoration: InputDecoration(labelText: 'Customer Name', filled: true, fillColor: AppTheme.inputBg, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 10),
              TextField(controller: commentCtrl, maxLines: 2, decoration: InputDecoration(labelText: 'Review Comment', filled: true, fillColor: AppTheme.inputBg, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Rating: '),
                  ...List.generate(5, (i) => IconButton(
                    icon: Icon(i < stars ? Icons.star_rounded : Icons.star_border_rounded, color: const Color(0xFFF59E0B)),
                    onPressed: () => setModalState(() => stars = i + 1),
                  )),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
                  onPressed: () {
                    if (nameCtrl.text.trim().isNotEmpty) {
                      setState(() {
                        _reviews.insert(0, _AdminReviewModel(
                          id: 'rev_${DateTime.now().millisecondsSinceEpoch}',
                          name: nameCtrl.text.trim(),
                          date: 'Today',
                          stars: stars,
                          comment: commentCtrl.text.trim().isNotEmpty ? commentCtrl.text.trim() : 'Great overall experience!',
                          service: 'General Service',
                          provider: 'Sara Tadesse',
                          avatarBg: const Color(0xFFC7D2FE),
                        ));
                      });
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Review added ✓'), behavior: SnackBarBehavior.floating));
                    }
                  },
                  child: const Text('Save Review'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  TAB 7: ANALYTICS (IMAGE 3)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildAnalyticsTab(String activeLang) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Period Selector Dropdown (Image 3)
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.bgSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _analyticsPeriod,
                  isDense: true,
                  icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.textPrimary, size: 18),
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  items: ['This Week', 'This Month', 'This Year', 'All Time'].map((period) {
                    return DropdownMenuItem(value: period, child: Text(period));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _analyticsPeriod = val);
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 2 Stats Cards Row (Image 3)
          Row(
            children: [
              Expanded(
                child: _analyticsStatCard('Total Bookings', '1,250', '↑ 18.5%', const Color(0xFF10B981)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _analyticsStatCard('Total Revenue', '98,450 ETB', '↑ 15.3%', const Color(0xFF10B981)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _analyticsStatCard('Platform Commission', '14,767 ETB', '↑ 12.0%', AppTheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _analyticsStatCard('Active Escrow', '48,500 ETB', '100% Secured', const Color(0xFF2563EB)),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Bookings Overview Area Chart Card (Image 3)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.bgSurface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Bookings Overview',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                    ),
                    Text(
                      _selectedChartDay == 6 ? 'Sun: 85 Bookings' : 'Day $_selectedChartDay',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 130,
                  child: CustomPaint(
                    size: const Size(double.infinity, 130),
                    painter: _AnalyticsLineChartPainter(),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].asMap().entries.map((entry) {
                    final isSel = _selectedChartDay == entry.key;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedChartDay = entry.key),
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          fontSize: 11,
                          color: isSel ? AppTheme.primary : AppTheme.textCaption,
                          fontWeight: isSel ? FontWeight.w900 : FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Top Services Breakdown (Image 3)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.bgSurface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Top Services',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 16),
                _serviceProgressRow(Icons.home_outlined, 'Home Cleaning', '450 bookings', 0.49, '49%'),
                const SizedBox(height: 12),
                _serviceProgressRow(Icons.plumbing_outlined, 'Plumbing', '250 bookings', 0.22, '22%'),
                const SizedBox(height: 12),
                _serviceProgressRow(Icons.electrical_services_outlined, 'Electrical Repair', '160 bookings', 0.14, '14%'),
                const SizedBox(height: 12),
                _serviceProgressRow(Icons.format_paint_outlined, 'Painting', '120 bookings', 0.10, '10%'),
                const SizedBox(height: 12),
                _serviceProgressRow(Icons.construction_outlined, 'Carpentry', '100 bookings', 0.05, '5%'),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _analyticsStatCard(String label, String value, String trend, Color trendColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
          const SizedBox(height: 4),
          Text(trend, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: trendColor)),
        ],
      ),
    );
  }

  Widget _serviceProgressRow(IconData icon, String title, String bookings, double progress, String percent) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF3EEFF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              Text(bookings, style: TextStyle(fontSize: 11, color: AppTheme.textCaption)),
            ],
          ),
        ),
        Expanded(
          flex: 4,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: const Color(0xFFEDE9FE),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF512DA8)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 28,
          child: Text(percent, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  TAB 8: SERVICES & CATEGORIES (IMAGE 4)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildServicesAndCategoriesTab(String activeLang) {
    final filteredCategories = _categories.where((c) {
      if (_categorySearchQuery.isEmpty) return true;
      return c.title.toLowerCase().contains(_categorySearchQuery.toLowerCase());
    }).toList();

    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              color: AppTheme.inputBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.inputBorderColor),
            ),
            child: TextField(
              onChanged: (v) => setState(() => _categorySearchQuery = v),
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 13.5),
              decoration: InputDecoration(
                hintText: activeLang == 'am' ? 'ምድቦችን ፈልግ...' : 'Search categories...',
                hintStyle: TextStyle(color: AppTheme.textHint, fontSize: 13.5),
                prefixIcon: Icon(Icons.search_rounded, color: AppTheme.textCaption, size: 19),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ),
        ),

        // Categories List (Matching Image 4)
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
            itemCount: filteredCategories.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final cat = filteredCategories[index];
              return _categoryItemCard(cat);
            },
          ),
        ),

        // Bottom Full-Width Button (+ Add Category) (Matching Image 4)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.bgSurface,
            border: Border(top: BorderSide(color: AppTheme.divider)),
          ),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
              label: Text(
                activeLang == 'am' ? '+ ምድብ አክል' : '+ Add Category',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _showAddCategoryDialog(context, activeLang),
            ),
          ),
        ),
      ],
    );
  }

  Widget _categoryItemCard(_CategoryItemModel cat) {
    return GestureDetector(
      onTap: () => _showEditCategoryDialog(cat),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.bgSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF3EEFF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(cat.icon, color: AppTheme.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cat.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                  const SizedBox(height: 2),
                  Text('${cat.count} services', style: TextStyle(fontSize: 12, color: AppTheme.textCaption)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: cat.status == 'Active' ? const Color(0xFFE8F8EE) : const Color(0xFFFFECEB),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                cat.status,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: cat.status == 'Active' ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, color: AppTheme.textCaption, size: 20),
          ],
        ),
      ),
    );
  }



  void _showEditCategoryDialog(_CategoryItemModel cat) {
    final titleCtrl = TextEditingController(text: cat.title);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      backgroundColor: AppTheme.bgSurface,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20, left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Manage Category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            const SizedBox(height: 14),
            TextField(controller: titleCtrl, decoration: InputDecoration(labelText: 'Title', filled: true, fillColor: AppTheme.inputBg, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() => cat.status = cat.status == 'Active' ? 'Inactive' : 'Active');
                      Navigator.pop(ctx);
                    },
                    child: Text(cat.status == 'Active' ? 'Set Inactive' : 'Set Active'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
                    onPressed: () {
                      setState(() => cat.title = titleCtrl.text.trim());
                      Navigator.pop(ctx);
                    },
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, String activeLang) {
    final titleCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      backgroundColor: AppTheme.bgSurface,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20, left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add New Service Category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            const SizedBox(height: 16),
            TextField(
              controller: titleCtrl,
              decoration: InputDecoration(
                labelText: 'Category Title',
                filled: true,
                fillColor: AppTheme.inputBg,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () {
                  if (titleCtrl.text.trim().isNotEmpty) {
                    setState(() {
                      _categories.add(_CategoryItemModel(
                        id: 'cat_${DateTime.now().millisecondsSinceEpoch}',
                        title: titleCtrl.text.trim(),
                        count: 0,
                        icon: Icons.category_outlined,
                        color: AppTheme.primary,
                        status: 'Active',
                      ));
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Category created successfully ✓'), behavior: SnackBarBehavior.floating));
                  }
                },
                child: const Text('Save Category', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }



  // ═══════════════════════════════════════════════════════════════
  //  TAB 9: NOTIFICATIONS (IMAGE 5)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildNotificationsTab(String activeLang) {
    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      children: [
        // Category Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['All', 'Unread', 'Bookings', 'KYC', 'Disputes'].map((f) {
              final isSel = _notifFilter == f;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(f),
                  selected: isSel,
                  selectedColor: AppTheme.primary,
                  labelStyle: TextStyle(color: isSel ? Colors.white : AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 12),
                  onSelected: (val) => setState(() => _notifFilter = f),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),

        // Section: Today (Image 5)
        Text(
          activeLang == 'am' ? 'ዛሬ' : 'Today',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 10),

        if (_notifFilter == 'All' || _notifFilter == 'KYC' || (_notifFilter == 'Unread' && !_readNotifs.contains(0))) ...[
          _notifCardItem(
            index: 0,
            icon: Icons.person_add_alt_1_rounded,
            iconColor: const Color(0xFF7C3AED),
            iconBg: const Color(0xFFF3EEFF),
            title: 'New Provider Registered',
            subtitle: 'Abebe Kebede joined as Electrician',
            time: '10:30 AM',
            onTap: () => setState(() => _currentTab = 2),
          ),
          const SizedBox(height: 10),
        ],

        if (_notifFilter == 'All' || _notifFilter == 'KYC' || (_notifFilter == 'Unread' && !_readNotifs.contains(1))) ...[
          _notifCardItem(
            index: 1,
            icon: Icons.shield_outlined,
            iconColor: const Color(0xFFD97706),
            iconBg: const Color(0xFFFEF3C7),
            title: 'Provider Verification Required',
            subtitle: 'Mekonnen Desta submitted documents',
            time: '09:15 AM',
            onTap: () => setState(() => _currentTab = 2),
          ),
          const SizedBox(height: 10),
        ],

        if (_notifFilter == 'All' || _notifFilter == 'Bookings' || (_notifFilter == 'Unread' && !_readNotifs.contains(2))) ...[
          _notifCardItem(
            index: 2,
            icon: Icons.calendar_today_outlined,
            iconColor: const Color(0xFF2563EB),
            iconBg: const Color(0xFFDBEAFE),
            title: 'New Booking',
            subtitle: 'Home Cleaning booking received',
            time: '08:25 AM',
            onTap: () => setState(() => _currentTab = 3),
          ),
          const SizedBox(height: 10),
        ],

        if (_notifFilter == 'All' || _notifFilter == 'Bookings' || (_notifFilter == 'Unread' && !_readNotifs.contains(3))) ...[
          _notifCardItem(
            index: 3,
            icon: Icons.credit_card_outlined,
            iconColor: const Color(0xFF10B981),
            iconBg: const Color(0xFFE8F8EE),
            title: 'Payment Received',
            subtitle: '350 ETB from Dawit Alemu',
            time: '07:40 AM',
            onTap: () => setState(() => _currentTab = 3),
          ),
          const SizedBox(height: 10),
        ],

        if (_notifFilter == 'All' || _notifFilter == 'Disputes' || (_notifFilter == 'Unread' && !_readNotifs.contains(4))) ...[
          _notifCardItem(
            index: 4,
            icon: Icons.warning_amber_rounded,
            iconColor: const Color(0xFFEF4444),
            iconBg: const Color(0xFFFFECEB),
            title: 'New Dispute Opened',
            subtitle: 'Booking #BK-7854 opened a dispute',
            time: '06:50 AM',
            onTap: () => setState(() => _currentTab = 4),
          ),
          const SizedBox(height: 20),
        ],

        // Section: Earlier (Image 5)
        Text(
          activeLang == 'am' ? 'ቀደም ሲል' : 'Earlier',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 10),

        if (_notifFilter == 'All' || (_notifFilter == 'Unread' && !_readNotifs.contains(5))) ...[
          _notifCardItem(
            index: 5,
            icon: Icons.notifications_active_outlined,
            iconColor: const Color(0xFF512DA8),
            iconBg: const Color(0xFFF3EEFF),
            title: 'System Alert',
            subtitle: 'Scheduled maintenance on Aug 10',
            time: 'Yesterday',
            onTap: () => setState(() => _currentTab = 10),
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _notifCardItem({
    required int index,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required String time,
    required VoidCallback onTap,
  }) {
    final isUnread = !_readNotifs.contains(index);

    return GestureDetector(
      onTap: () {
        setState(() {
          _readNotifs.add(index);
          _unreadNotifCount = (_unreadNotifCount > 0) ? _unreadNotifCount - 1 : 0;
        });
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.bgSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Row(
              children: [
                Text(time, style: TextStyle(fontSize: 11, color: AppTheme.textCaption)),
                if (isUnread) ...[
                  const SizedBox(width: 6),
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(color: Color(0xFF4F46E5), shape: BoxShape.circle),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showBroadcastAlertModal(BuildContext context, String activeLang) {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    String audience = 'All Users';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      backgroundColor: AppTheme.bgSurface,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20, left: 24, right: 24, top: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Broadcast Announcement', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              const SizedBox(height: 14),
              TextField(controller: titleCtrl, decoration: InputDecoration(labelText: 'Title', filled: true, fillColor: AppTheme.inputBg, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 10),
              TextField(controller: bodyCtrl, maxLines: 2, decoration: InputDecoration(labelText: 'Message / SMS Content', filled: true, fillColor: AppTheme.inputBg, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: ['All Users', 'Customers Only', 'Providers Only'].map((a) {
                  final isSel = audience == a;
                  return ChoiceChip(
                    label: Text(a),
                    selected: isSel,
                    selectedColor: AppTheme.primary,
                    labelStyle: TextStyle(color: isSel ? Colors.white : AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 11),
                    onSelected: (val) => setModalState(() => audience = a),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.send_rounded, size: 16),
                  label: const Text('Send Broadcast Alert'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Broadcast sent successfully to 2,450 users 📢'), behavior: SnackBarBehavior.floating));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  TAB 10: SYSTEM SETTINGS
  // ═══════════════════════════════════════════════════════════════
  Widget _buildSystemSettingsTab(String activeLang) {
    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      children: [
        _settingsSectionTitle(activeLang == 'am' ? 'የገንዘብ እና ኮሚሽን ቅንብሮች' : 'Financial & Marketplace Commission'),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppTheme.bgSurface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.border)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Platform Commission Fee', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  Text('${_commissionRate.toInt()}%', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppTheme.primary)),
                ],
              ),
              Slider(
                value: _commissionRate,
                min: 5,
                max: 30,
                divisions: 25,
                activeColor: AppTheme.primary,
                onChanged: (v) => setState(() => _commissionRate = v),
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Escrow Auto-Release Window', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  DropdownButton<String>(
                    value: _escrowReleaseWindow,
                    underline: const SizedBox(),
                    items: ['24 hours', '48 hours', '72 hours'].map((w) => DropdownMenuItem(value: w, child: Text(w, style: const TextStyle(fontSize: 13)))).toList(),
                    onChanged: (val) => setState(() => _escrowReleaseWindow = val!),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _minPayoutThreshold = _minPayoutThreshold == 500.0 ? 1000.0 : (_minPayoutThreshold == 1000.0 ? 300.0 : 500.0);
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Minimum Payout Threshold', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppTheme.primaryContainer, borderRadius: BorderRadius.circular(8)),
                      child: Text('${_minPayoutThreshold.toInt()} ETB ✎', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        _settingsSectionTitle(activeLang == 'am' ? 'የስርዓት ደህንነት እና ማረጋገጫ' : 'Security & Compliance'),
        Container(
          decoration: BoxDecoration(color: AppTheme.bgSurface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.border)),
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Admin 2-Factor Auth (2FA)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                subtitle: const Text('Require OTP authentication for Super Admin actions', style: TextStyle(fontSize: 11)),
                value: _twoFactorEnabled,
                activeColor: AppTheme.primary,
                onChanged: (v) => setState(() => _twoFactorEnabled = v),
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text('Maintenance Mode', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                subtitle: const Text('Temporarily pause customer booking requests', style: TextStyle(fontSize: 11)),
                value: _maintenanceMode,
                activeColor: AppTheme.error,
                onChanged: (v) {
                  setState(() => _maintenanceMode = v);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_maintenanceMode ? 'Maintenance mode enabled ⚠️' : 'Maintenance mode disabled ✓'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text('Fayda e-KYC Auto-Verify', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                subtitle: const Text('Automatically approve verified National ID records', style: TextStyle(fontSize: 11)),
                value: _autoVerifyKyc,
                activeColor: AppTheme.primary,
                onChanged: (v) => setState(() => _autoVerifyKyc = v),
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text('Enforce 2FA for Providers', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                subtitle: const Text('Require SMS OTP login for all service providers', style: TextStyle(fontSize: 11)),
                value: _strict2Fa,
                activeColor: AppTheme.primary,
                onChanged: (v) => setState(() => _strict2Fa = v),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        _settingsSectionTitle('Push Notifications & Gateway'),
        Container(
          decoration: BoxDecoration(color: AppTheme.bgSurface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.border)),
          child: SwitchListTile(
            title: const Text('Push Notification Server (FCM)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            subtitle: const Text('Firebase Cloud Messaging for live alerts', style: TextStyle(fontSize: 11)),
            value: _pushNotifsEnabled,
            activeColor: AppTheme.primary,
            onChanged: (v) => setState(() => _pushNotifsEnabled = v),
          ),
        ),
        const SizedBox(height: 16),

        _settingsSectionTitle(activeLang == 'am' ? 'ዳታቤዝ እና ሪፖርቶች' : 'Data & System Backups'),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppTheme.bgSurface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.border)),
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.cloud_download_outlined, color: AppTheme.primary),
                title: const Text('Backup Full Database (CSV/JSON)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                subtitle: const Text('2,450 users • 4,820 bookings • 24 disputes', style: TextStyle(fontSize: 11)),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  onPressed: () => _exportPlatformReport(context, activeLang),
                  child: const Text('Backup'),
                ),
              ),
              const Divider(height: 12),
              ListTile(
                leading: const Icon(Icons.delete_sweep_outlined, color: Color(0xFFD97706)),
                title: const Text('Clear App Cache', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                trailing: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('App cache cleared ✓'), behavior: SnackBarBehavior.floating));
                  },
                  child: const Text('Clear'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _settingsSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  TAB 0: OVERVIEW
  // ═══════════════════════════════════════════════════════════════
  Widget _buildOverviewTab(String activeLang) {
    final providers = ref.watch(providersListProvider);
    final bookings = ref.watch(bookingsListProvider);
    final disputesAsync = ref.watch(disputesProvider);

    final pendingCount = providers.where((p) => p.verificationStatus == VerificationStatus.pending).length;
    final totalBookings = bookings.length + 4814;
    final disputesCount = disputesAsync.asData?.value.length ?? 24;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF311B92), Color(0xFF512DA8), Color(0xFF7E57C2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Shuk Admin Operations', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.9))),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(12)), child: const Text('LIVE 🟢', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800))),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('48,500 ETB', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
                const SizedBox(height: 2),
                Text('Total Active Escrow Funds Secured on Platform', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.8))),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)), child: const Text('Commission: 7,280 ETB', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)))),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.download_rounded, size: 14, color: AppTheme.primary),
                      label: const Text('Export', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppTheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      onPressed: () => _exportPlatformReport(context, activeLang),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Metrics 4-Grid
          Row(
            children: [
              Expanded(child: _metricCard(value: '2,450', label: 'TOTAL USERS', subTrend: '+12% this week', color: AppTheme.primary, icon: Icons.people_rounded, onTap: () => setState(() => _currentTab = 1))),
              const SizedBox(width: 12),
              Expanded(child: _metricCard(value: '$totalBookings', label: 'BOOKINGS', subTrend: '+18% this week', color: const Color(0xFF2563EB), icon: Icons.event_note_rounded, onTap: () => setState(() => _currentTab = 3))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _metricCard(value: '$pendingCount', label: 'PENDING KYC', subTrend: '$pendingCount need review', color: AppTheme.statusPending, icon: Icons.verified_user_rounded, onTap: () => setState(() => _currentTab = 2))),
              const SizedBox(width: 12),
              Expanded(child: _metricCard(value: '$disputesCount', label: 'DISPUTES', subTrend: '16 Open • 8 Resolved', color: AppTheme.statusError, icon: Icons.gavel_rounded, onTap: () => setState(() => _currentTab = 4))),
            ],
          ),
          const SizedBox(height: 20),

          // Quick Action Shortcuts to other Views
          Text('Quick Navigation', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _quickActionButton(icon: Icons.star_outline_rounded, label: 'Reviews (4.8★)', color: const Color(0xFFF59E0B), onTap: () => setState(() => _currentTab = 6))),
              const SizedBox(width: 8),
              Expanded(child: _quickActionButton(icon: Icons.analytics_outlined, label: 'Analytics', color: const Color(0xFF2563EB), onTap: () => setState(() => _currentTab = 7))),
              const SizedBox(width: 8),
              Expanded(child: _quickActionButton(icon: Icons.category_outlined, label: 'Categories', color: AppTheme.primary, onTap: () => setState(() => _currentTab = 8))),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  TAB 1: USERS TAB
  // ═══════════════════════════════════════════════════════════════
  Widget _buildUsersTab(String activeLang) {
    final providers = ref.watch(providersListProvider);

    final List<_AdminUserModel> allUsers = [
      _AdminUserModel(id: 'u1', name: 'Abel Biru', role: 'Customer', phone: '+251 912 345 678', email: 'abel.biru@gmail.com', date: 'Aug 06, 2026', status: 'Active', avatarBg: const Color(0xFFE2E8F0), avatarInitial: 'A', totalOrders: 14),
      _AdminUserModel(id: 'u2', name: 'Marta Hailu', role: 'Customer', phone: '+251 923 456 789', email: 'marta.hailu@outlook.com', date: 'Aug 05, 2026', status: 'Active', avatarBg: const Color(0xFFFDE68A), avatarInitial: 'M', totalOrders: 8),
      _AdminUserModel(id: 'u3', name: 'Dawit Alemu', role: 'Provider', phone: '+251 911 234 567', email: 'dawit.alemu@shuk.et', date: 'Aug 05, 2026', status: 'Verified', avatarBg: const Color(0xFFBFDBFE), avatarInitial: 'D', totalOrders: 42, rating: 4.9),
      _AdminUserModel(id: 'u4', name: 'Sara Tadesse', role: 'Provider', phone: '+251 915 678 123', email: 'sara.tadesse@shuk.et', date: 'Aug 04, 2026', status: 'Verified', avatarBg: const Color(0xFFDDD6FE), avatarInitial: 'S', totalOrders: 56, rating: 4.8),
      _AdminUserModel(id: 'u5', name: 'Kebede Ayalew', role: 'Provider', phone: '+251 913 567 890', email: 'kebede.ayalew@shuk.et', date: 'Aug 03, 2026', status: 'Suspended', avatarBg: const Color(0xFFFECDD3), avatarInitial: 'K', totalOrders: 19, rating: 3.6),
      _AdminUserModel(id: 'u6', name: 'Worku Tesfaye', role: 'Customer', phone: '+251 922 111 222', email: 'worku.tesfaye@yahoo.com', date: 'Aug 02, 2026', status: 'Active', avatarBg: const Color(0xFFD1FAE5), avatarInitial: 'W', totalOrders: 5),
      ..._dynamicNewUsers,
      ...providers.map((p) => _AdminUserModel(
        id: p.id,
        name: p.name,
        role: 'Provider',
        phone: '+251 910 ${p.id.hashCode.abs().toString().padRight(6, '0').substring(0, 6)}',
        email: '${p.name.toLowerCase().replaceAll(' ', '.')}@shuk.et',
        date: 'Jul 28, 2026',
        status: p.verificationStatus == VerificationStatus.verified ? 'Verified' : 'Active',
        avatarBg: const Color(0xFFE0E7FF),
        avatarInitial: p.name.isNotEmpty ? p.name[0] : 'P',
        totalOrders: p.jobsCount,
        rating: p.rating,
      )),
    ];

    for (final user in allUsers) {
      if (_userStatusOverrides.containsKey(user.id)) {
        user.status = _userStatusOverrides[user.id]!;
      }
    }

    final allCount = allUsers.length + 2444;
    final customerCount = allUsers.where((u) => u.role.toLowerCase() == 'customer').length + 1864;
    final providerCount = allUsers.where((u) => u.role.toLowerCase() == 'provider').length + 574;

    var tabFiltered = allUsers.where((u) {
      if (_userSubTab == 1) return u.role.toLowerCase() == 'customer';
      if (_userSubTab == 2) return u.role.toLowerCase() == 'provider';
      return true;
    }).toList();

    if (_userStatusFilter != 'All') {
      tabFiltered = tabFiltered.where((u) => u.status.toLowerCase() == _userStatusFilter.toLowerCase()).toList();
    }

    var filteredUsers = tabFiltered.where((u) {
      if (_userSearchQuery.isEmpty) return true;
      final q = _userSearchQuery.toLowerCase();
      return u.name.toLowerCase().contains(q) || u.phone.toLowerCase().contains(q) || u.email.toLowerCase().contains(q) || u.role.toLowerCase().contains(q);
    }).toList();

    return Column(
      children: [
        Container(
          color: AppTheme.bgSurface,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _underlineTabItem(label: 'All ($allCount)', isSelected: _userSubTab == 0, onTap: () => setState(() => _userSubTab = 0)),
              _underlineTabItem(label: 'Customers ($customerCount)', isSelected: _userSubTab == 1, onTap: () => setState(() => _userSubTab = 1)),
              _underlineTabItem(label: 'Providers ($providerCount)', isSelected: _userSubTab == 2, onTap: () => setState(() => _userSubTab = 2)),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1, color: Color(0xFFF1F1F4)),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Container(
            height: 48,
            decoration: BoxDecoration(color: AppTheme.inputBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.inputBorderColor)),
            child: TextField(
              onChanged: (v) => setState(() => _userSearchQuery = v),
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
              decoration: InputDecoration(hintText: 'Search users...', prefixIcon: Icon(Icons.search_rounded, color: AppTheme.textCaption, size: 20), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13)),
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 80),
            itemCount: filteredUsers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) => _buildSeparatedUserCard(filteredUsers[index], activeLang),
          ),
        ),
      ],
    );
  }

  Widget _buildSeparatedUserCard(_AdminUserModel user, String activeLang) {
    Color badgeBg;
    Color badgeTextColor;
    if (user.status == 'Active' || user.status == 'Verified') {
      badgeBg = const Color(0xFFE8F8EE);
      badgeTextColor = const Color(0xFF16A34A);
    } else if (user.status == 'Deactivated') {
      badgeBg = const Color(0xFFFEF3C7);
      badgeTextColor = const Color(0xFFD97706);
    } else if (user.status == 'Suspended') {
      badgeBg = const Color(0xFFFFECEB);
      badgeTextColor = const Color(0xFFDC2626);
    } else {
      badgeBg = const Color(0xFFF1F5F9);
      badgeTextColor = const Color(0xFF64748B);
    }

    return GestureDetector(
      onTap: () => _showUserDetailsModal(user, activeLang),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppTheme.bgSurface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.border)),
        child: Row(
          children: [
            CircleAvatar(radius: 24, backgroundColor: user.avatarBg, child: Text(user.avatarInitial, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.textPrimary))),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                  Text('${user.role}${user.role == 'Provider' && user.rating > 0 ? ' • ⭐ ${user.rating}' : ''}', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  Text(user.phone, style: TextStyle(fontSize: 12, color: AppTheme.textCaption)),
                  Text(user.date, style: TextStyle(fontSize: 11, color: AppTheme.textHint)),
                ],
              ),
            ),
            Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5), decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(12)), child: Text(user.status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: badgeTextColor))),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  TAB 2: PROVIDERS TAB
  // ═══════════════════════════════════════════════════════════════
  Widget _buildProvidersTab(String activeLang) {
    final providers = ref.watch(providersListProvider);
    final filtered = _providerFilter == 'All' ? providers : providers.where((p) => _providerFilter == 'Verified' ? p.verificationStatus == VerificationStatus.verified : p.verificationStatus == VerificationStatus.pending).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: ['All', 'Pending', 'Verified'].map((f) {
              final isSel = _providerFilter == f;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(f),
                  selected: isSel,
                  selectedColor: AppTheme.primary,
                  labelStyle: TextStyle(color: isSel ? Colors.white : AppTheme.textPrimary, fontWeight: FontWeight.bold),
                  onSelected: (s) => setState(() => _providerFilter = f),
                ),
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) => _providerVerificationCard(filtered[index], activeLang),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  TAB 3: BOOKINGS TAB
  // ═══════════════════════════════════════════════════════════════
  Widget _buildBookingsTab(String activeLang) {
    final List<_AdminBookingModel> allBookings = [
      _AdminBookingModel(id: 'BK-7856', service: 'Home Cleaning', customer: 'Dawit Alemu', customerPhone: '+251 911 234 567', provider: 'Sara Tadesse', providerPhone: '+251 915 678 123', dateTime: 'Aug 06, 2026 • 10:00 AM', price: '280 ETB', status: 'Pending', isEscrowHeld: true),
      _AdminBookingModel(id: 'BK-7855', service: 'Plumbing', customer: 'Abel Biru', customerPhone: '+251 912 345 678', provider: 'Mekonnen Desta', providerPhone: '+251 914 555 777', dateTime: 'Aug 06, 2026 • 09:30 AM', price: '350 ETB', status: 'Accepted', isEscrowHeld: true),
      _AdminBookingModel(id: 'BK-7854', service: 'Electrical Repair', customer: 'Marta Hailu', customerPhone: '+251 923 456 789', provider: 'Daniel Getachew', providerPhone: '+251 910 112 233', dateTime: 'Aug 05, 2026 • 05:00 PM', price: '450 ETB', status: 'In Progress', isEscrowHeld: true),
      _AdminBookingModel(id: 'BK-7853', service: 'Carpentry', customer: 'Kebede Ayalew', customerPhone: '+251 913 567 890', provider: 'Yonas Bekele', providerPhone: '+251 918 889 900', dateTime: 'Aug 05, 2026 • 02:30 PM', price: '500 ETB', status: 'Completed', isEscrowHeld: false),
      _AdminBookingModel(id: 'BK-7852', service: 'Painting & Finishing', customer: 'Worku Tesfaye', customerPhone: '+251 922 111 222', provider: 'Bekele Tadesse', providerPhone: '+251 916 443 322', dateTime: 'Aug 04, 2026 • 11:15 AM', price: '650 ETB', status: 'Completed', isEscrowHeld: false),
      _AdminBookingModel(id: 'BK-7851', service: 'Appliance Repair', customer: 'Abel Abreham', customerPhone: '+251 911 000 111', provider: 'Dawit Bekele', providerPhone: '+251 913 778 899', dateTime: 'Aug 04, 2026 • 03:00 PM', price: '320 ETB', status: 'Disputed', isEscrowHeld: true),
    ];

    for (final b in allBookings) {
      if (_bookingStatusOverrides.containsKey(b.id)) b.status = _bookingStatusOverrides[b.id]!;
    }

    var filtered = allBookings.where((b) {
      if (_bookingSubTab == 1 && b.status.toLowerCase() != 'pending') return false;
      if (_bookingSubTab == 2 && (b.status.toLowerCase() != 'accepted' && b.status.toLowerCase() != 'in progress')) return false;
      if (_bookingSubTab == 3 && b.status.toLowerCase() != 'completed') return false;
      if (_bookingSearchQuery.isNotEmpty) {
        final q = _bookingSearchQuery.toLowerCase();
        return b.id.toLowerCase().contains(q) || b.service.toLowerCase().contains(q) || b.customer.toLowerCase().contains(q) || b.provider.toLowerCase().contains(q);
      }
      return true;
    }).toList();

    return Column(
      children: [
        Container(
          color: AppTheme.bgSurface,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _underlineTabItem(label: 'All (4,820)', isSelected: _bookingSubTab == 0, onTap: () => setState(() => _bookingSubTab = 0)),
                _underlineTabItem(label: 'Pending (280)', isSelected: _bookingSubTab == 1, onTap: () => setState(() => _bookingSubTab = 1)),
                _underlineTabItem(label: 'Ongoing (320)', isSelected: _bookingSubTab == 2, onTap: () => setState(() => _bookingSubTab = 2)),
                _underlineTabItem(label: 'Completed (4,220)', isSelected: _bookingSubTab == 3, onTap: () => setState(() => _bookingSubTab = 3)),
              ],
            ),
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Container(
            height: 48,
            decoration: BoxDecoration(color: AppTheme.inputBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.inputBorderColor)),
            child: TextField(onChanged: (v) => setState(() => _bookingSearchQuery = v), decoration: InputDecoration(hintText: 'Search bookings...', prefixIcon: Icon(Icons.search_rounded, color: AppTheme.textCaption), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13))),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _buildBookingCard(filtered[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildBookingCard(_AdminBookingModel b) {
    return GestureDetector(
      onTap: () => _showBookingDetailsModal(b, 'en'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppTheme.bgSurface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.border)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(b.id, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)), Text(b.status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary))]),
            const SizedBox(height: 4),
            Text(b.service, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
            Text('Customer: ${b.customer}', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            Text('Provider: ${b.provider}', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            Text(b.dateTime, style: TextStyle(fontSize: 11, color: AppTheme.textCaption)),
            const SizedBox(height: 6),
            Text(b.price, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  TAB 4: DISPUTES TAB
  // ═══════════════════════════════════════════════════════════════
  Widget _buildDisputesTab(String activeLang) {
    final List<_AdminDisputeModel> allDisputes = [
      _AdminDisputeModel(id: 'DP-25-008', bookingId: 'BK-7845', customer: 'Dawit Alemu', amount: '280 ETB', date: 'Aug 06, 2026', status: 'Open'),
      _AdminDisputeModel(id: 'DP-25-007', bookingId: 'BK-7832', customer: 'Marta Hailu', amount: '450 ETB', date: 'Aug 05, 2026', status: 'In Review'),
      _AdminDisputeModel(id: 'DP-25-006', bookingId: 'BK-7821', customer: 'Abel Biru', amount: '350 ETB', date: 'Aug 05, 2026', status: 'Resolved'),
      _AdminDisputeModel(id: 'DP-25-005', bookingId: 'BK-7812', customer: 'Sara Tadesse', amount: '600 ETB', date: 'Aug 04, 2026', status: 'Open'),
    ];

    for (final d in allDisputes) {
      if (_disputeStatusOverrides.containsKey(d.id)) d.status = _disputeStatusOverrides[d.id]!;
    }

    var filtered = allDisputes.where((d) {
      if (_disputeSubTab == 1 && d.status == 'Resolved') return false;
      if (_disputeSubTab == 2 && d.status != 'Resolved') return false;
      if (_disputeSearchQuery.isNotEmpty) {
        final q = _disputeSearchQuery.toLowerCase();
        return d.id.toLowerCase().contains(q) || d.bookingId.toLowerCase().contains(q) || d.customer.toLowerCase().contains(q);
      }
      return true;
    }).toList();

    return Column(
      children: [
        Container(
          color: AppTheme.bgSurface,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _underlineTabItem(label: 'All (24)', isSelected: _disputeSubTab == 0, onTap: () => setState(() => _disputeSubTab = 0)),
              _underlineTabItem(label: 'Open (16)', isSelected: _disputeSubTab == 1, onTap: () => setState(() => _disputeSubTab = 1)),
              _underlineTabItem(label: 'Resolved (8)', isSelected: _disputeSubTab == 2, onTap: () => setState(() => _disputeSubTab = 2)),
            ],
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.inputBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.inputBorderColor),
            ),
            child: TextField(
              onChanged: (v) => setState(() => _disputeSearchQuery = v),
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search disputes...',
                hintStyle: TextStyle(color: AppTheme.textHint, fontSize: 14),
                prefixIcon: Icon(Icons.search_rounded, color: AppTheme.textCaption, size: 20),
                suffixIcon: _disputeSearchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () => setState(() => _disputeSearchQuery = ''),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final d = filtered[index];
              return GestureDetector(
                onTap: () => _showDisputeResolutionModal(d, activeLang),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppTheme.bgSurface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.border)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(d.id, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)), Text(d.status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: d.status == 'Resolved' ? AppTheme.success : AppTheme.error))]),
                      Text('Booking: ${d.bookingId}', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                      Text('Customer: ${d.customer}', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                      Text('Amount: ${d.amount}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                      Text(d.date, style: TextStyle(fontSize: 11, color: AppTheme.textCaption)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  COMMON HELPERS & MODALS
  // ═══════════════════════════════════════════════════════════════
  Widget _underlineTabItem({required String label, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: isSelected ? AppTheme.primary : Colors.transparent, width: 2.5))),
        child: Text(label, style: TextStyle(fontSize: 14, fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600, color: isSelected ? AppTheme.primary : AppTheme.textSecondary)),
      ),
    );
  }

  Widget _metricCard({required String value, required String label, required String subTrend, required Color color, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppTheme.bgSurface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.border)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Icon(icon, color: color, size: 20), Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppTheme.textCaption)]),
            const SizedBox(height: 10),
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
            Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.textSecondary)),
            Text(subTrend, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _quickActionButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: 0.2))),
        child: Column(children: [Icon(icon, color: color, size: 20), const SizedBox(height: 4), Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color))]),
      ),
    );
  }

  Widget _providerVerificationCard(ProviderModel p, String lang) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppTheme.bgSurface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.border)),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: AppTheme.primary.withValues(alpha: 0.1), child: Text(p.emoji, style: const TextStyle(fontSize: 20))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(p.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)), Text(p.specialty, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary))])),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
            onPressed: () {
              ref.read(providersListProvider.notifier).verifyProvider(p.id);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${p.name} verified ✓'), behavior: SnackBarBehavior.floating));
            },
            child: const Text('Verify', style: TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }

  void _showUserDetailsModal(_AdminUserModel user, String lang) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      backgroundColor: AppTheme.bgSurface,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final currentStatus = _userStatusOverrides[user.id] ?? user.status;
          final isActive = currentStatus == 'Active' || currentStatus == 'Verified';
          final isDeactivated = currentStatus == 'Deactivated';
          final isSuspended = currentStatus == 'Suspended';

          Color currentBadgeBg = isActive
              ? const Color(0xFFE8F8EE)
              : (isDeactivated ? const Color(0xFFFEF3C7) : const Color(0xFFFFECEB));
          Color currentBadgeColor = isActive
              ? const Color(0xFF16A34A)
              : (isDeactivated ? const Color(0xFFD97706) : const Color(0xFFDC2626));

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              left: 20,
              right: 20,
              top: 12,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: AppTheme.outlineLight, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: user.avatarBg,
                      child: Text(
                        user.avatarInitial,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.textPrimary),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                user.role,
                                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
                              ),
                              if (user.role == 'Provider' && user.rating > 0) ...[
                                const SizedBox(width: 6),
                                Text(
                                  '• ⭐ ${user.rating}',
                                  style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(color: currentBadgeBg, borderRadius: BorderRadius.circular(12)),
                      child: Text(
                        currentStatus,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: currentBadgeColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.bgBase,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.outlineLighter),
                  ),
                  child: Column(
                    children: [
                      _userModalDetailRow(Icons.phone_rounded, 'Phone', user.phone),
                      const Divider(height: 14),
                      _userModalDetailRow(Icons.email_outlined, 'Email', user.email),
                      const Divider(height: 14),
                      _userModalDetailRow(Icons.calendar_today_rounded, 'Registered', user.date),
                      const Divider(height: 14),
                      _userModalDetailRow(Icons.shopping_bag_outlined, 'Total Orders / Jobs', '${user.totalOrders} completed'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  lang == 'am' ? 'የተጠቃሚ ሁኔታ አስተዳድር' : 'Manage User Account Status',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Active button
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.check_circle_rounded, size: 16),
                        label: Text(
                          lang == 'am' ? 'አግብር' : 'Active',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isActive ? const Color(0xFF16A34A) : Colors.grey.shade200,
                          foregroundColor: isActive ? Colors.white : Colors.grey.shade700,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          setState(() {
                            _userStatusOverrides[user.id] = 'Active';
                          });
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(lang == 'am' ? '${user.name} አሁን ንቁ ነው ✓' : '${user.name} is now Active ✓'),
                              backgroundColor: const Color(0xFF16A34A),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Deactivate button
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.pause_circle_filled_rounded, size: 16),
                        label: Text(
                          lang == 'am' ? 'አቦዝን' : 'Deactive',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDeactivated ? const Color(0xFFD97706) : Colors.grey.shade200,
                          foregroundColor: isDeactivated ? Colors.white : Colors.grey.shade700,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          setState(() {
                            _userStatusOverrides[user.id] = 'Deactivated';
                          });
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(lang == 'am' ? '${user.name} ቦዝኗል' : '${user.name} has been Deactivated'),
                              backgroundColor: const Color(0xFFD97706),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Suspend button
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.block_rounded, size: 16),
                        label: Text(
                          lang == 'am' ? 'አግድ' : 'Suspend',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSuspended ? const Color(0xFFDC2626) : Colors.grey.shade200,
                          foregroundColor: isSuspended ? Colors.white : Colors.grey.shade700,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          setState(() {
                            _userStatusOverrides[user.id] = 'Suspended';
                          });
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(lang == 'am' ? '${user.name} ታግዷል 🚫' : '${user.name} has been Suspended 🚫'),
                              backgroundColor: const Color(0xFFDC2626),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(lang == 'am' ? 'ዝጋ' : 'Close', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _userModalDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textSecondary),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(fontSize: 12.5, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
        const Spacer(),
        Text(value, style: TextStyle(fontSize: 12.5, color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
      ],
    );
  }

  void _showBookingDetailsModal(_AdminBookingModel b, String lang) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      backgroundColor: AppTheme.bgSurface,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Booking #${b.id}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            Text('${b.service} • ${b.price}', style: TextStyle(fontSize: 14, color: AppTheme.primary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Customer: ${b.customer} (${b.customerPhone})', style: TextStyle(fontSize: 13, color: AppTheme.textPrimary)),
            Text('Provider: ${b.provider} (${b.providerPhone})', style: TextStyle(fontSize: 13, color: AppTheme.textPrimary)),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))),
          ],
        ),
      ),
    );
  }

  void _showDisputeResolutionModal(_AdminDisputeModel d, String lang) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      backgroundColor: AppTheme.bgSurface,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dispute #${d.id}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            Text('Booking: ${d.bookingId} • Amount: ${d.amount}', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success, foregroundColor: Colors.white),
                    onPressed: () {
                      setState(() => _disputeStatusOverrides[d.id] = 'Resolved');
                      Navigator.pop(ctx);
                    },
                    child: const Text('Resolve'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() => _disputeStatusOverrides[d.id] = 'In Review');
                      Navigator.pop(ctx);
                    },
                    child: const Text('Investigate'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showUserFilterBottomSheet(BuildContext context, String lang) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      backgroundColor: AppTheme.bgSurface,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Filter Users by Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: ['All', 'Active', 'Deactivated', 'Suspended'].map((st) {
                  final isSel = _userStatusFilter == st;
                  return ChoiceChip(
                    label: Text(st),
                    selected: isSel,
                    selectedColor: AppTheme.primary,
                    labelStyle: TextStyle(color: isSel ? Colors.white : AppTheme.textPrimary, fontWeight: FontWeight.bold),
                    onSelected: (val) {
                      setState(() => _userStatusFilter = st);
                      setModalState(() {});
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Apply Filter'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBookingFilterBottomSheet(BuildContext context, String lang) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      backgroundColor: AppTheme.bgSurface,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quick Bookings Filter', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
            const SizedBox(height: 14),
            ListTile(
              leading: Icon(Icons.access_time_rounded, color: AppTheme.statusWarning),
              title: const Text('Show Pending Only'),
              onTap: () {
                setState(() => _bookingSubTab = 1);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: Icon(Icons.check_circle_outline_rounded, color: AppTheme.success),
              title: const Text('Show Completed Only'),
              onTap: () {
                setState(() => _bookingSubTab = 3);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDisputeFilterBottomSheet(BuildContext context, String lang) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      backgroundColor: AppTheme.bgSurface,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quick Dispute Filter', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
            const SizedBox(height: 14),
            ListTile(
              leading: Icon(Icons.warning_amber_rounded, color: AppTheme.statusError),
              title: const Text('Show Open Disputes Only'),
              onTap: () {
                setState(() => _disputeSubTab = 1);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: Icon(Icons.check_circle_outline_rounded, color: AppTheme.success),
              title: const Text('Show Resolved Disputes Only'),
              onTap: () {
                setState(() => _disputeSubTab = 2);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _exportPlatformReport(BuildContext context, String lang) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Platform Report exported successfully 📊'), behavior: SnackBarBehavior.floating));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  ANALYTICS LINE CHART PAINTER
// ─────────────────────────────────────────────────────────────────────────────
class _AnalyticsLineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final points = [
      Offset(0, size.height * 0.85),
      Offset(size.width * 0.16, size.height * 0.65),
      Offset(size.width * 0.33, size.height * 0.72),
      Offset(size.width * 0.50, size.height * 0.45),
      Offset(size.width * 0.66, size.height * 0.68),
      Offset(size.width * 0.83, size.height * 0.25),
      Offset(size.width, size.height * 0.10),
    ];

    final path = Path()..moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [const Color(0xFF512DA8).withValues(alpha: 0.25), const Color(0xFF512DA8).withValues(alpha: 0.0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = const Color(0xFF512DA8)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);

    final dotPaint = Paint()..color = const Color(0xFF512DA8);
    final innerDotPaint = Paint()..color = Colors.white;

    for (final p in points) {
      canvas.drawCircle(p, 5, dotPaint);
      canvas.drawCircle(p, 2.5, innerDotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
//  HELPER DATA MODELS
// ─────────────────────────────────────────────────────────────────────────────
class _AdminUserModel {
  final String id;
  final String name;
  final String role;
  final String phone;
  final String email;
  final String date;
  String status;
  final Color avatarBg;
  final String avatarInitial;
  final int totalOrders;
  final double rating;

  _AdminUserModel({
    required this.id,
    required this.name,
    required this.role,
    required this.phone,
    this.email = '',
    required this.date,
    required this.status,
    required this.avatarBg,
    required this.avatarInitial,
    this.totalOrders = 0,
    this.rating = 5.0,
  });
}

class _AdminBookingModel {
  final String id;
  final String service;
  final String customer;
  final String customerPhone;
  final String provider;
  final String providerPhone;
  final String dateTime;
  final String price;
  String status;
  final bool isEscrowHeld;

  _AdminBookingModel({
    required this.id,
    required this.service,
    required this.customer,
    this.customerPhone = '+251 912 345 678',
    required this.provider,
    this.providerPhone = '+251 911 234 567',
    required this.dateTime,
    required this.price,
    required this.status,
    this.isEscrowHeld = true,
  });
}

class _AdminDisputeModel {
  final String id;
  final String bookingId;
  final String customer;
  final String amount;
  final String date;
  String status;

  _AdminDisputeModel({
    required this.id,
    required this.bookingId,
    required this.customer,
    required this.amount,
    required this.date,
    required this.status,
  });
}

class _CategoryItemModel {
  final String id;
  String title;
  int count;
  final IconData icon;
  final Color color;
  String status;

  _CategoryItemModel({
    required this.id,
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    required this.status,
  });
}

class _AdminReviewModel {
  final String id;
  final String name;
  final String date;
  final int stars;
  final String comment;
  final String service;
  final String provider;
  final Color avatarBg;
  bool isFeatured;
  String? adminReply;

  _AdminReviewModel({
    required this.id,
    required this.name,
    required this.date,
    required this.stars,
    required this.comment,
    required this.service,
    required this.provider,
    required this.avatarBg,
    this.isFeatured = false,
    this.adminReply,
  });
}


