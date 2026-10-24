import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/mock_state_providers.dart' as shared_state;
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../features/booking/models/booking_model.dart';
import '../../../core/router/nav_helpers.dart';

class RequestManagementScreen extends ConsumerStatefulWidget {
  final bool isShell;
  const RequestManagementScreen({super.key, this.isShell = false});

  @override
  ConsumerState<RequestManagementScreen> createState() => _RequestManagementScreenState();
}

class _RequestManagementScreenState extends ConsumerState<RequestManagementScreen> {
  String? _playingVoiceBookingId;

  void _showAcceptConfirmationDialog(BuildContext context, BookingModel booking, String activeLang) {
    ref.read(shared_state.bookingsListProvider.notifier).updateBookingStatus(booking.id, BookingStatus.accepted);

    final senderName = booking.customerName ?? 'Abel Abreham';

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppTheme.bgSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 36),
              ),
              const SizedBox(height: 16),
              Text(
                activeLang == 'am' ? 'ጥያቄው ተቀብሏል!' : 'Request Accepted!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                activeLang == 'am'
                    ? 'ከ $senderName የቀረበውን የ ${booking.serviceType} ጥያቄ በተሳካ ሁኔታ ተቀብለዋል።'
                    : 'You have successfully accepted the ${booking.serviceType} request from $senderName.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.bgBase,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(activeLang == 'am' ? 'ደረጃ:' : 'Status:', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                        const Text('CONFIRMED', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.success)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(activeLang == 'am' ? 'የአገልግሎት ዋጋ:' : 'Service Fee:', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                        Text('${booking.priceEtb.toInt()} ETB', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.push('/chat?bookingId=${booking.id}');
                      },
                      icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                      label: Text(activeLang == 'am' ? 'ውይይት ጀምር' : 'Chat Client'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ProviderNavHelper.go(context, ref, tab: 1);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(activeLang == 'am' ? 'ትዕዛዝ እይ' : 'View Work'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeclineReasonSheet(BuildContext context, BookingModel booking, String activeLang) {
    String selectedReason = activeLang == 'am' ? 'በተጠቀሰው ሰዓት አልችልም' : 'Schedule Conflict';
    final customReasonController = TextEditingController();

    final reasonsList = activeLang == 'am'
        ? [
            'በተጠቀሰው ሰዓት አልችልም',
            'የተጠየቀው ቦታ በጣም ሩቅ ነው',
            'የሥራው አይነት የእኔ ሙያ አይደለም',
            'ሌላ ምክንያት',
          ]
        : [
            'Schedule Conflict',
            'Location Too Far',
            'Not My Area of Expertise',
            'Other Reason',
          ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.outlineLight,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.cancel_outlined, color: AppTheme.error, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        activeLang == 'am' ? 'ጥያቄውን ያለመቀበል ምክንያት' : 'Reason for Declining',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    activeLang == 'am'
                        ? 'እባክዎን ጥያቄውን የሚተውበትን ምክንያት ይምረጡ (ለደንበኛው ይላካል)።'
                        : 'Please select a reason for declining this request.',
                    style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  ...reasonsList.map((reason) {
                    final isSelected = selectedReason == reason;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () => setSheetState(() => selectedReason = reason),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.error.withValues(alpha: 0.08) : AppTheme.bgBase,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? AppTheme.error : AppTheme.outlineLighter,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                size: 18,
                                color: isSelected ? AppTheme.error : AppTheme.textTertiary,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  reason,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    color: isSelected ? AppTheme.error : AppTheme.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  TextField(
                    controller: customReasonController,
                    style: TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                    decoration: InputDecoration(
                      hintText: activeLang == 'am' ? 'ተጨማሪ ማብራሪያ (በምርጫ)...' : 'Additional note for customer (optional)...',
                      hintStyle: TextStyle(fontSize: 12, color: AppTheme.textTertiary),
                      filled: true,
                      fillColor: AppTheme.bgBase,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppTheme.outlineLighter),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppTheme.outlineLighter),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.textSecondary,
                            side: BorderSide(color: AppTheme.outlineLight),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(activeLang == 'am' ? 'ተመለስ' : 'Cancel'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final finalReason = customReasonController.text.trim().isNotEmpty
                                ? '$selectedReason: ${customReasonController.text.trim()}'
                                : selectedReason;

                            ref.read(shared_state.bookingsListProvider.notifier).updateBookingStatus(booking.id, BookingStatus.cancelled);

                            Navigator.pop(ctx);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  activeLang == 'am'
                                      ? 'ጥያቄ #${booking.id} ተተውል ($finalReason)'
                                      : 'Request #${booking.id} declined ($finalReason)',
                                ),
                                backgroundColor: AppTheme.error,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.error,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            activeLang == 'am' ? 'ጥያቄውን ሰርዝ' : 'Confirm Decline',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeLang = ref.watch(shared_state.languageProvider);
    final activeRole = ref.watch(shared_state.currentRoleProvider);
    final allBookings = ref.watch(shared_state.bookingsListProvider);
    final themeMode = ref.watch(shared_state.themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    AppTheme.isDark = isDark;

    final pendingRequests = allBookings
        .where((b) => b.status == BookingStatus.pending || b.status == BookingStatus.draft)
        .toList();

    return Scaffold(
      backgroundColor: AppTheme.bgBase,
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: AppTheme.bgSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Row(
          children: [
            Builder(
              builder: (context) => InkWell(
                onTap: () => Scaffold.of(context).openDrawer(),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (AppTheme.isDark ? AppTheme.primaryLight : AppTheme.primary).withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primary.withValues(alpha: 0.15)),
                  ),
                  child: Icon(
                    Icons.inbox_rounded,
                    color: AppTheme.isDark ? AppTheme.primaryLight : AppTheme.primary,
                    size: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activeLang == 'am' ? 'የደንበኞች ጥያቄዎች' : 'Customer Requests',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    activeLang == 'am'
                        ? '${pendingRequests.length} በመጠበቅ ላይ ያሉ ጥያቄዎች'
                        : '${pendingRequests.length} pending request(s) awaiting response',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: pendingRequests.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.check_circle_outline_rounded, size: 48, color: AppTheme.primary),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      activeLang == 'am' ? 'ምንም የሚጠበቅ ጥያቄ የለም' : 'No Pending Requests',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      activeLang == 'am'
                          ? 'አዳዲስ የደንበኞች አገልግሎት ጥያቄዎች ሲደርሱ እዚህ ይታያሉ።'
                          : 'New customer service requests will appear here for you to accept or decline.',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: pendingRequests.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final booking = pendingRequests[index];
                return _buildCustomerRequestCard(booking, activeLang);
              },
            ),
      bottomNavigationBar: widget.isShell
          ? null
          : ShukBottomNavBar(
              currentIndex: 2,
              activeRole: activeRole,
              activeLang: activeLang,
            ),
    );
  }

  Widget _buildCustomerRequestCard(BookingModel booking, String activeLang) {
    final isPlayingVoice = _playingVoiceBookingId == booking.id;
    final senderName = booking.customerName ?? 'Abel Abreham';
    final senderPhone = booking.customerPhone ?? '+251 911 22 33 44';
    final senderLocation = booking.customerLocation ?? 'Bole, Addis Ababa';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.outlineLighter),
        boxShadow: AppTheme.isDark ? null : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Request Sender / Customer Badge Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.primary.withValues(alpha: 0.12)),
            ),
            child: Row(
              children: [
                // Customer Avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('👨', style: TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            activeLang == 'am' ? 'ጥያቄ አቅራቢ: ' : 'Sender: ',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              senderName,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.verified_user_rounded, size: 14, color: AppTheme.primary),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 12, color: AppTheme.textTertiary),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              '$senderLocation • $senderPhone',
                              style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 2. Service Details & Price
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(booking.providerEmoji, style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.serviceType,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Request #${booking.id} • ${_formatDate(booking.dateTime)}',
                      style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: (AppTheme.isDark ? AppTheme.primaryLight : AppTheme.primary).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${booking.priceEtb.toInt()} ETB',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.isDark ? AppTheme.primaryLight : AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 3. Description Snippet
          if (booking.description.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.bgBase,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                booking.description,
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 12),
          ],

          // 4. Voice note bar if attached
          if (booking.voiceNotePath != null) ...[
            GestureDetector(
              onTap: () {
                setState(() {
                  _playingVoiceBookingId = isPlayingVoice ? null : booking.id;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.primaryLight.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPlayingVoice ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                      color: AppTheme.primaryLight,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isPlayingVoice ? 'Playing voice request...' : 'Customer voice note attached',
                      style: TextStyle(fontSize: 11, color: AppTheme.primaryLight, fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    Text(
                      '${booking.voiceNoteDurationSeconds ?? 15}s 🎙️',
                      style: TextStyle(fontSize: 10, color: AppTheme.primaryLight),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // 5. Actions Row: Accept, Decline, View Details
          Row(
            children: [
              // Decline Button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showDeclineReasonSheet(context, booking, activeLang),
                  icon: const Icon(Icons.close_rounded, size: 16),
                  label: Text(
                    activeLang == 'am' ? 'አትቀበል' : 'Decline',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.error,
                    side: BorderSide(color: AppTheme.error.withValues(alpha: 0.4)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Accept Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showAcceptConfirmationDialog(context, booking, activeLang),
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: Text(
                    activeLang == 'am' ? 'ተቀበል' : 'Accept',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                      if (states.contains(WidgetState.pressed)) {
                        return const Color(0xFF4527A0);
                      }
                      if (states.contains(WidgetState.hovered)) {
                        return const Color(0xFF673AB7);
                      }
                      return const Color(0xFF512DA8);
                    }),
                    foregroundColor: WidgetStateProperty.all(Colors.white),
                    elevation: WidgetStateProperty.all(0),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 10)),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // View Details Button
              IconButton(
                onPressed: () => context.push('/booking-details/${booking.id}'),
                icon: const Icon(Icons.visibility_outlined, size: 20),
                color: AppTheme.textPrimary,
                tooltip: activeLang == 'am' ? 'ዝርዝር' : 'View Details',
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.bgBase,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}


