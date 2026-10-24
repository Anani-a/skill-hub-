import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/mock_state_providers.dart';
import '../../booking/models/booking_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/dispute_model.dart';
import '../providers/dispute_provider.dart';

class DisputeScreen extends ConsumerStatefulWidget {
  final String? bookingId;

  const DisputeScreen({
    super.key,
    this.bookingId,
  });

  @override
  ConsumerState<DisputeScreen> createState() => _DisputeScreenState();
}

class _DisputeScreenState extends ConsumerState<DisputeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();

  String? _selectedBookingId;
  String _selectedReason = 'Work Quality Issue';
  bool _isSubmitting = false;
  bool _hasEvidenceAttached = false;

  final List<Map<String, dynamic>> _customerReasons = [
    {
      'key': 'Work Quality Issue',
      'labelAm': 'የሥራ ጥራት ችግር',
      'icon': Icons.build_circle_outlined,
    },
    {
      'key': 'Work Incomplete / Abandoned',
      'labelAm': 'ሥራው አልተጠናቀቀም / ተተውቷል',
      'icon': Icons.warning_amber_rounded,
    },
    {
      'key': 'Provider No-Show',
      'labelAm': 'ባለሙያው አልመጣም',
      'icon': Icons.person_off_outlined,
    },
    {
      'key': 'Overcharging / Pricing Dispute',
      'labelAm': 'ከመጠን ያለፈ ክፍያ ጥያቄ',
      'icon': Icons.payments_outlined,
    },
    {
      'key': 'Property Damage',
      'labelAm': 'የንብረት ውድመት',
      'icon': Icons.home_repair_service_outlined,
    },
    {
      'key': 'Unprofessional Behavior',
      'labelAm': 'የባህሪ ጥሰት',
      'icon': Icons.sentiment_very_dissatisfied_rounded,
    },
  ];

  final List<Map<String, dynamic>> _providerReasons = [
    {
      'key': 'Non-Payment / Escrow Issue',
      'labelAm': 'ክፍያ አለመፈጸም',
      'icon': Icons.request_quote_outlined,
    },
    {
      'key': 'Customer Unresponsive',
      'labelAm': 'ደንበኛው መልስ አይሰጥም',
      'icon': Icons.phone_disabled_outlined,
    },
    {
      'key': 'Scope Creep Without Pay',
      'labelAm': 'ያለተጨማሪ ክፍያ ተጨማሪ ሥራ ጥያቄ',
      'icon': Icons.add_task_rounded,
    },
    {
      'key': 'Unsafe Work Environment',
      'labelAm': 'አስተማማኝ ያልሆነ የሥራ ቦታ',
      'icon': Icons.gavel_rounded,
    },
    {
      'key': 'Unreasonable Demands',
      'labelAm': 'ተገቢ ያልሆነ ጥያቄ',
      'icon': Icons.report_problem_outlined,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedBookingId = widget.bookingId != null && widget.bookingId!.isNotEmpty
        ? widget.bookingId
        : null;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeLang = ref.watch(languageProvider);
    final activeRole = ref.watch(currentRoleProvider);
    final isProvider = activeRole == 'provider';
    final rawBookings = ref.watch(bookingsListProvider);
    final bookings = rawBookings.isNotEmpty ? rawBookings : [_mockFallbackBooking];
    final authUser = ref.watch(authProvider).asData?.value;
    final userName = authUser?.name ?? (isProvider ? 'Bekele Tadesse' : 'Abel Abreham');

    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    AppTheme.isDark = isDark;

    // Ensure _selectedBookingId is valid and exists in current bookings list
    if (_selectedBookingId == null || !bookings.any((b) => b.id == _selectedBookingId)) {
      _selectedBookingId = bookings.first.id;
    }

    final selectedBooking = bookings.firstWhere(
      (b) => b.id == _selectedBookingId,
      orElse: () => bookings.first,
    );

    final reasonsList = isProvider ? _providerReasons : _customerReasons;
    final primaryAccent = isDark ? AppTheme.primaryLight : AppTheme.primary;

    return Scaffold(
      backgroundColor: AppTheme.bgBase,
      appBar: AppBar(
        backgroundColor: AppTheme.bgSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(isProvider ? '/provider-dashboard' : '/home');
            }
          },
        ),
        title: Text(
          activeLang == 'am' ? 'የክርክር ማእከል' : 'Dispute Resolution Center',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: primaryAccent,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: primaryAccent,
          indicatorWeight: 3,
          labelColor: primaryAccent,
          unselectedLabelColor: AppTheme.textCaption,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: [
            Tab(
              icon: const Icon(Icons.gavel_rounded, size: 18),
              text: isProvider
                  ? (activeLang == 'am' ? 'በደንበኛ ላይ አቤቱታ' : 'Dispute Customer')
                  : (activeLang == 'am' ? 'በአቅራቢ ላይ አቤቱታ' : 'Dispute Provider'),
            ),
            Tab(
              icon: const Icon(Icons.history_edu_rounded, size: 18),
              text: activeLang == 'am' ? 'የአቤቱታዎች ሁኔታ' : 'Admin Review Status',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ── TAB 1: Raise Dispute Form ────────────────────────────────────
          _buildRaiseDisputeTab(
            context: context,
            activeLang: activeLang,
            isProvider: isProvider,
            userName: userName,
            bookings: bookings,
            selectedBooking: selectedBooking,
            reasonsList: reasonsList,
            isDark: isDark,
          ),

          // ── TAB 2: Submitted Disputes Admin Status List ──────────────────
          _buildDisputeStatusTab(
            context: context,
            activeLang: activeLang,
            isProvider: isProvider,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  // ── TAB 1: Raise Dispute Form ──────────────────────────────────────────────
  Widget _buildRaiseDisputeTab({
    required BuildContext context,
    required String activeLang,
    required bool isProvider,
    required String userName,
    required List<BookingModel> bookings,
    required BookingModel selectedBooking,
    required List<Map<String, dynamic>> reasonsList,
    required bool isDark,
  }) {
    final primaryAccent = isDark ? AppTheme.primaryLight : AppTheme.primary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Admin Escalation Notice Banner ──────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF261545) : AppTheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? AppTheme.primaryLight.withValues(alpha: 0.35)
                      : AppTheme.purple200,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryAccent.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.admin_panel_settings_rounded, color: primaryAccent, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activeLang == 'am' ? '🛡️ ለአስተዳዳሪ (Admin) የሚመራ አቤቱታ' : '🛡️ Admin Resolution & Protection',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: primaryAccent,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          activeLang == 'am'
                              ? 'የሚያቀርቡት አቤቱታ በቀጥታ ለሹክ አስተዳዳሪ (Admin Team) ይላካል። የአስተዳዳሪ ውሳኔ እስከሚሰጥ ድረስ የክፍያ ገንዘብ በደህና ተይዞ ይቆያል።'
                              : 'Your dispute will be submitted directly to the Shuk Admin Team for review. Funds are held safely in Escrow until resolved by Admin.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Party Roles Info Box ─────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.bgCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppTheme.border : AppTheme.primaryContainer,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        isProvider ? Icons.engineering_rounded : Icons.person_rounded,
                        color: primaryAccent,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        activeLang == 'am' ? 'አቤቱታ አቅራቢ:' : 'Dispute Initiator:',
                        style: TextStyle(fontSize: 12, color: AppTheme.textCaption),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$userName (${isProvider ? (activeLang == 'am' ? 'ባለሙያ' : 'Provider') : (activeLang == 'am' ? 'ደንበኛ' : 'Customer')})',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Divider(height: 1, color: AppTheme.divider),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        isProvider ? Icons.person_rounded : Icons.engineering_rounded,
                        color: AppTheme.secondary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        activeLang == 'am' ? 'ተከሳሽ ተቃዋሚ:' : 'Respondent Target:',
                        style: TextStyle(fontSize: 12, color: AppTheme.textCaption),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isProvider
                            ? 'Customer (${selectedBooking.id})'
                            : '${selectedBooking.providerName} (${selectedBooking.serviceType})',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Booking Selection Dropdown ───────────────────────────────────
            _buildSectionTitle(
              activeLang == 'am' ? 'የተያያዘበትን ትዕዛዝ ይምረጡ' : 'Select Associated Booking',
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.inputBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.inputBorderColor),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedBookingId,
                  isExpanded: true,
                  dropdownColor: AppTheme.bgSurface,
                  icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.iconSecondary),
                  items: bookings.map((b) {
                    return DropdownMenuItem<String>(
                      value: b.id,
                      child: Row(
                        children: [
                          Text(b.providerEmoji, style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${b.serviceType} (${b.providerName}) • ${b.priceEtb.toInt()} ETB',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedBookingId = val);
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Dispute Reason Choice Chips ────────────────────────────────
            _buildSectionTitle(
              activeLang == 'am' ? 'የአቤቱታው ዋነኛ ምክንያት' : 'Select Primary Reason',
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: reasonsList.map((r) {
                final key = r['key'] as String;
                final label = activeLang == 'am' ? r['labelAm'] as String : key;
                final icon = r['icon'] as IconData;
                final isSelected = _selectedReason == key;

                return ChoiceChip(
                  avatar: Icon(
                    icon,
                    size: 16,
                    color: isSelected ? Colors.white : primaryAccent,
                  ),
                  label: Text(label),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : AppTheme.textPrimary,
                  ),
                  selected: isSelected,
                  selectedColor: primaryAccent,
                  backgroundColor: AppTheme.bgCard,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? primaryAccent : AppTheme.border,
                      width: 1.2,
                    ),
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedReason = key);
                    }
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // ── Detailed Description Input ──────────────────────────────────
            _buildSectionTitle(
              activeLang == 'am' ? 'ዝርዝር ማብራሪያ ይጻፉ' : 'Detailed Complaint Description',
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              maxLines: 5,
              style: TextStyle(fontSize: 14, color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: activeLang == 'am'
                    ? 'እባክዎ የተፈጠረውን ችግር፣ ጊዜ እና ዝርዝር ሁኔታዎችን ያስረዱ...'
                    : 'Describe what happened in detail, including dates, work issues, or agreement breaches...',
                hintStyle: TextStyle(fontSize: 13, color: AppTheme.inputPlaceholder),
                filled: true,
                fillColor: AppTheme.inputBg,
                contentPadding: const EdgeInsets.all(16),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppTheme.inputBorderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: primaryAccent, width: 1.5),
                ),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return activeLang == 'am' ? 'እባክዎ አቤቱታዎን ያስገቡ' : 'Please enter a detailed description';
                }
                if (val.trim().length < 10) {
                  return activeLang == 'am' ? 'እባክዎ ቢያንስ 10 ፊደላት ያስገቡ' : 'Description must be at least 10 characters';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // ── Evidence Attachment Upload Button ────────────────────────────
            OutlinedButton.icon(
              onPressed: () {
                setState(() => _hasEvidenceAttached = !_hasEvidenceAttached);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _hasEvidenceAttached
                          ? (activeLang == 'am' ? 'የማስረጃ ፎቶ ተያይዟል!' : 'Evidence photo attached!')
                          : (activeLang == 'am' ? 'ማስረጃ ተሰርዟል' : 'Evidence attachment removed'),
                    ),
                    backgroundColor: _hasEvidenceAttached ? AppTheme.success : AppTheme.error,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
              icon: Icon(
                _hasEvidenceAttached ? Icons.check_circle_rounded : Icons.add_a_photo_outlined,
                color: _hasEvidenceAttached ? AppTheme.success : primaryAccent,
                size: 20,
              ),
              label: Text(
                _hasEvidenceAttached
                    ? (activeLang == 'am' ? 'ማስረጃ ፎቶ ተያይዟል (1)' : 'Evidence Attached (1 photo)')
                    : (activeLang == 'am' ? '+ ፎቶ / ማስረጃ አያይዝ' : '+ Attach Photo / Document Evidence'),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: _hasEvidenceAttached ? AppTheme.success : primaryAccent,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: _hasEvidenceAttached ? AppTheme.success : primaryAccent,
                  width: 1.2,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 30),

            // ── Submit Button to Admin ───────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 54,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? const [Color(0xFF4527A0), Color(0xFF673AB7), Color(0xFF7E57C2)]
                        : const [AppTheme.primaryDark, AppTheme.primary, AppTheme.primaryLight],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: primaryAccent.withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isSubmitting
                      ? null
                      : () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            final messenger = ScaffoldMessenger.of(context);
                            setState(() => _isSubmitting = true);

                            // Open dispute in Riverpod provider
                            await ref.read(disputesProvider.notifier).openDispute(
                                  bookingId: selectedBooking.id,
                                  initiatorId: isProvider ? 'p1' : 'u1',
                                  initiatorName: userName,
                                  respondentId: isProvider ? 'u1' : selectedBooking.providerId,
                                  respondentName: isProvider ? 'Customer' : selectedBooking.providerName,
                                  reason: _selectedReason,
                                  description: _descriptionController.text.trim(),
                                );

                            // Also mark booking as disputed in booking notifier
                            ref.read(bookingsListProvider.notifier).submitDispute(
                                  selectedBooking.id,
                                  _descriptionController.text.trim(),
                                );

                            setState(() => _isSubmitting = false);
                            _descriptionController.clear();

                            // Switch to Tab 2 to show status
                            _tabController.animateTo(1);

                            messenger.showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.verified_rounded, color: Colors.white, size: 20),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        activeLang == 'am'
                                            ? 'አቤቱታዎ ለሹክ አስተዳዳሪ (Admin) በተሳካ ሁኔታ ተልኳል!'
                                            : 'Dispute submitted to Shuk Admin Team successfully!',
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: AppTheme.success,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              activeLang == 'am' ? 'አቤቱታውን ለአስተዳዳሪ አቅርብ' : 'Submit Dispute to Admin',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── TAB 2: Submitted Disputes List & Admin Review Status ─────────────────
  Widget _buildDisputeStatusTab({
    required BuildContext context,
    required String activeLang,
    required bool isProvider,
    required bool isDark,
  }) {
    final disputesAsync = ref.watch(disputesProvider);
    final primaryAccent = isDark ? AppTheme.primaryLight : AppTheme.primary;

    return disputesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error loading disputes: $e')),
      data: (disputeList) {
        if (disputeList.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: isDark ? primaryAccent.withValues(alpha: 0.15) : AppTheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.folder_off_outlined, color: primaryAccent, size: 36),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    activeLang == 'am' ? 'ምንም የተመዘገበ አቤቱታ የለም' : 'No Open Disputes Recorded',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    activeLang == 'am'
                        ? 'አቤቱታ ካለዎት በመጀመሪያው ገጽ ላይ ቅጹን ሞልተው ለአስተዳዳሪ መላክ ይችላሉ።'
                        : 'Submit a dispute from the form tab if you encounter any issue with a booking.',
                    style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(),
          itemCount: disputeList.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (ctx, idx) {
            final d = disputeList[idx];
            return _buildDisputeStatusCard(ctx, d, activeLang, isProvider, isDark);
          },
        );
      },
    );
  }

  Widget _buildDisputeStatusCard(
    BuildContext context,
    DisputeModel dispute,
    String activeLang,
    bool isProvider,
    bool isDark,
  ) {
    Color statusColor;
    String statusText;
    IconData statusIcon;
    final primaryAccent = isDark ? AppTheme.primaryLight : AppTheme.primary;

    switch (dispute.status) {
      case DisputeStatus.opened:
        statusColor = AppTheme.statusError;
        statusText = activeLang == 'am' ? 'ክፍት - ለአስተዳዳሪ ተልኳል' : 'Submitted to Admin';
        statusIcon = Icons.report_problem_rounded;
        break;
      case DisputeStatus.underReview:
        statusColor = AppTheme.secondary;
        statusText = activeLang == 'am' ? 'በአስተዳዳሪ ግምገማ ላይ' : 'Under Admin Review';
        statusIcon = Icons.find_in_page_rounded;
        break;
      case DisputeStatus.resolved:
        statusColor = AppTheme.success;
        statusText = activeLang == 'am' ? 'በአስተዳዳሪ ተፈቷል' : 'Resolved by Admin';
        statusIcon = Icons.check_circle_rounded;
        break;
      case DisputeStatus.closed:
        statusColor = AppTheme.textCaption;
        statusText = activeLang == 'am' ? 'ተዘጋቷል' : 'Closed';
        statusIcon = Icons.archive_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: statusColor.withValues(alpha: 0.35), width: 1.2),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: primaryAccent.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 14, color: statusColor),
                    const SizedBox(width: 6),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                '#${dispute.id}',
                style: TextStyle(fontSize: 11, color: AppTheme.textHint, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            dispute.reason,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dispute.description,
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
              height: 1.35,
            ),
          ),

          const SizedBox(height: 12),
          Divider(height: 1, color: AppTheme.divider),
          const SizedBox(height: 10),

          Row(
            children: [
              Icon(Icons.person_outline_rounded, size: 14, color: AppTheme.textCaption),
              const SizedBox(width: 4),
              Text(
                '${activeLang == 'am' ? 'አቅራቢ:' : 'Initiator:'} ${dispute.initiatorName}',
                style: TextStyle(fontSize: 11, color: AppTheme.textCaption),
              ),
              const Spacer(),
              Icon(Icons.gavel_rounded, size: 14, color: primaryAccent),
              const SizedBox(width: 4),
              Text(
                activeLang == 'am' ? 'የሹክ አስተዳዳሪ' : 'Shuk Admin Team',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: primaryAccent),
              ),
            ],
          ),

          if (dispute.resolution != null && dispute.resolution!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.success.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_rounded, color: AppTheme.success, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${activeLang == 'am' ? 'የአስተዳዳሪ ውሳኔ:' : 'Admin Decision:'} ${dispute.resolution}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.success,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppTheme.textSecondary,
      ),
    );
  }
}

// Fallback booking object in case lookup fails
final _mockFallbackBooking = BookingModel(
  id: 'b1',
  providerId: 'p1',
  providerName: 'Bekele Tadesse',
  providerEmoji: '👨‍🔧',
  serviceType: 'Electrical Repair',
  dateTime: DateTime.now(),
  status: BookingStatus.disputed,
  priceEtb: 250.0,
  description: 'Disputed booking',
  isEscrowHeld: true,
);
